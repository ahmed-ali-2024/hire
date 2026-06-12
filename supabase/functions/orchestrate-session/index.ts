import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BAND_BASE_URL = "https://app.band.ai/api/v1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// ============================================================
// Types
// ============================================================
interface OrchestrationRequest {
  sessionId: string;
  jobDescription: string;
  jobTitle: string;
  candidates: Array<{
    id: string;
    name: string;
    cvText: string;
    fileName: string;
  }>;
}

interface AgentResult {
  score: number;
  summary: string;
  recommendation: "accept" | "reject" | "maybe";
  rawData: Record<string, unknown>;
}

// ============================================================
// Band API Helpers
// ============================================================
async function bandCreateRoom(agentApiKey: string): Promise<string> {
  const res = await fetch(`${BAND_BASE_URL}/agent/chats`, {
    method: "POST",
    headers: { "X-API-Key": agentApiKey, "Content-Type": "application/json" },
    body: JSON.stringify({ chat: { title: "Hire Analysis Session" } }),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error("Band createRoom failed:", err);
    return "";
  }
  const data = await res.json();
  return data?.data?.id ?? "";
}

async function bandAddParticipant(roomId: string, agentApiKey: string, participantId: string): Promise<void> {
  const res = await fetch(`${BAND_BASE_URL}/agent/chats/${roomId}/participants`, {
    method: "POST",
    headers: { "X-API-Key": agentApiKey, "Content-Type": "application/json" },
    body: JSON.stringify({ participant: { id: participantId } }),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error("Band addParticipant failed:", err);
  }
}

async function bandSendMessage(
  roomId: string,
  senderApiKey: string,
  content: string,
  mentions: Array<{ id: string; handle?: string; name?: string }>,
): Promise<void> {
  if (!roomId) return;
  const res = await fetch(`${BAND_BASE_URL}/agent/chats/${roomId}/messages`, {
    method: "POST",
    headers: { "X-API-Key": senderApiKey, "Content-Type": "application/json" },
    body: JSON.stringify({
      message: {
        text: content,
        content: content,
        mentions,
      },
    }),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error("Band sendMessage failed:", err);
  }
}

// ============================================================
// AI Calls - AIMLAPI
// ============================================================
async function callAIMLAPI(apiKey: string, systemPrompt: string, userPrompt: string): Promise<string> {
  const res = await fetch("https://api.aimlapi.com/v1/chat/completions", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      temperature: 0.3,
      max_tokens: 1500,
    }),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error("AIMLAPI error:", err);
    throw new Error(`AIMLAPI failed: ${err}`);
  }
  const data = await res.json();
  return data?.choices?.[0]?.message?.content ?? "";
}

// ============================================================
// AI Calls - Featherless (Adversarial Reviewer)
// ============================================================
async function callFeatherless(apiKey: string, systemPrompt: string, userPrompt: string): Promise<string> {
  const res = await fetch("https://api.featherless.ai/v1/chat/completions", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "meta-llama/Llama-3.1-8B-Instruct",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      temperature: 0.4,
      max_tokens: 1200,
    }),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error("Featherless error:", err);
    throw new Error(`Featherless failed: ${err}`);
  }
  const data = await res.json();
  return data?.choices?.[0]?.message?.content ?? "";
}

// ============================================================
// Parse AI JSON response safely
// ============================================================
function parseAgentResult(rawText: string, agentName: string): AgentResult {
  try {
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);
      return {
        score: Math.min(10, Math.max(0, parseFloat(parsed.score) || 5)),
        summary: parsed.summary ?? parsed.analysis ?? rawText.slice(0, 300),
        recommendation: (["accept", "reject", "maybe"].includes(parsed.recommendation))
          ? parsed.recommendation
          : "maybe",
        rawData: parsed,
      };
    }
  } catch (_) {
    console.warn(`${agentName}: Could not parse JSON, using raw text`);
  }
  return {
    score: 5,
    summary: rawText.slice(0, 500),
    recommendation: "maybe",
    rawData: { rawText },
  };
}

// ============================================================
// Agent Prompts
// ============================================================
function getScreeningPrompt(candidate: { name: string; cvText: string }, jobDescription: string) {
  const system = `You are an expert CV Screening Agent. Your job is to evaluate CVs against job descriptions objectively and professionally.
Respond with a JSON object only, no other text. Format:
{
  "score": <number 0-10>,
  "summary": "<2-3 sentence evaluation>",
  "recommendation": "<accept|reject|maybe>",
  "strengths": ["<strength1>", "<strength2>"],
  "weaknesses": ["<weakness1>"],
  "skills_match": <number 0-10>
}`;
  const user = `Job Description:\n${jobDescription}\n\nCandidate: ${candidate.name}\nCV:\n${candidate.cvText.slice(0, 3000)}`;
  return { system, user };
}

function getReviewerPrompt(
  candidate: { name: string; cvText: string },
  screeningResult: AgentResult,
  jobDescription: string,
) {
  const system = `You are an Adversarial Reviewer Agent. Your role is to critically review previous screening decisions to detect bias, inconsistency, or overlooked factors.
Respond with a JSON object only:
{
  "score": <number 0-10>,
  "summary": "<critical review in 2-3 sentences>",
  "recommendation": "<accept|reject|maybe>",
  "bias_detected": <true|false>,
  "conflict_with_screening": <true|false>,
  "confidence": <number 0-10>
}`;
  const user = `Job Description:\n${jobDescription}\n\nCandidate: ${candidate.name}\nScreening Score: ${screeningResult.score}/10\nScreening Summary: ${screeningResult.summary}\n\nCV Extract:\n${candidate.cvText.slice(0, 2000)}`;
  return { system, user };
}

function getInterviewPrompt(candidate: { name: string; cvText: string }, jobDescription: string) {
  const system = `You are a Technical Interview Agent. Simulate a technical interview for the candidate based on their CV and the job requirements.
Generate 3 key technical questions and evaluate their likely answers based on CV evidence.
Respond with JSON only:
{
  "score": <number 0-10>,
  "summary": "<interview assessment in 2-3 sentences>",
  "recommendation": "<accept|reject|maybe>",
  "questions": ["<q1>", "<q2>", "<q3>"],
  "technical_depth": <number 0-10>,
  "communication_score": <number 0-10>
}`;
  const user = `Job Description:\n${jobDescription}\n\nCandidate: ${candidate.name}\nCV:\n${candidate.cvText.slice(0, 2500)}`;
  return { system, user };
}

function getCulturalPrompt(candidate: { name: string; cvText: string }, jobDescription: string) {
  const system = `You are a Cultural Fit Assessment Agent. Evaluate the candidate's cultural fit based on their CV, work history, and the company's implied culture from the job description.
Respond with JSON only:
{
  "score": <number 0-10>,
  "summary": "<cultural assessment in 2-3 sentences>",
  "recommendation": "<accept|reject|maybe>",
  "teamwork_indicators": <number 0-10>,
  "adaptability": <number 0-10>,
  "values_alignment": <number 0-10>
}`;
  const user = `Job Requirements & Culture:\n${jobDescription}\n\nCandidate: ${candidate.name}\nCV:\n${candidate.cvText.slice(0, 2000)}`;
  return { system, user };
}

function getCoordinatorPrompt(
  candidate: { name: string },
  screening: AgentResult,
  review: AgentResult,
  interview: AgentResult,
  cultural: AgentResult,
) {
  const system = `You are the Coordinator Agent. Your job is to synthesize all agent evaluations into a final hiring recommendation.
Respond with JSON only:
{
  "score": <number 0-10>,
  "summary": "<comprehensive final assessment in 3-4 sentences>",
  "recommendation": "<accept|reject|maybe>",
  "screening_weight": 0.25,
  "review_adjustment": <-1 to 1>,
  "interview_weight": 0.35,
  "cultural_weight": 0.15,
  "has_conflict": <true|false>,
  "conflict_note": "<explanation if conflict exists or null>",
  "final_advice": "<one actionable sentence for HR>"
}`;
  const user = `Candidate: ${candidate.name}

Agent Evaluations:
1. Screening Agent: Score ${screening.score}/10, Recommendation: ${screening.recommendation}
   Summary: ${screening.summary}

2. Adversarial Reviewer: Score ${review.score}/10, Recommendation: ${review.recommendation}
   Summary: ${review.summary}

3. Interview Agent: Score ${interview.score}/10, Recommendation: ${interview.recommendation}
   Summary: ${interview.summary}

4. Cultural Fit Agent: Score ${cultural.score}/10, Recommendation: ${cultural.recommendation}
   Summary: ${cultural.summary}`;
  return { system, user };
}

// ============================================================
// Main Handler
// ============================================================
serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Read secrets
    const aimlApiKey = Deno.env.get("AIMLAPI_KEY") ?? "";
    const featherlessKey = Deno.env.get("FEATHERLESS_KEY") ?? "";
    const coordinatorApiKey = Deno.env.get("BAND_COORDINATOR_API_KEY") ?? "";
    const screeningApiKey = Deno.env.get("BAND_SCREENING_API_KEY") ?? "";
    const reviewerApiKey = Deno.env.get("BAND_REVIEWER_API_KEY") ?? "";
    const interviewApiKey = Deno.env.get("BAND_INTERVIEW_API_KEY") ?? "";
    const culturalApiKey = Deno.env.get("BAND_CULTURAL_API_KEY") ?? "";

    const coordinatorUUID = Deno.env.get("BAND_COORDINATOR_AGENT_UUID") ?? "";
    const screeningUUID = Deno.env.get("BAND_SCREENING_AGENT_UUID") ?? "";
    const reviewerUUID = Deno.env.get("BAND_REVIEWER_AGENT_UUID") ?? "";
    const interviewUUID = Deno.env.get("BAND_INTERVIEW_AGENT_UUID") ?? "";
    const culturalUUID = Deno.env.get("BAND_CULTURAL_AGENT_UUID") ?? "";

    // Init Supabase Admin
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseKey);

    const body: OrchestrationRequest = await req.json();
    const { sessionId, jobDescription, jobTitle, candidates } = body;

    if (!sessionId || !candidates || candidates.length === 0) {
      return new Response(JSON.stringify({ error: "Missing sessionId or candidates" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Update session status to analyzing
    await supabase
      .from("recruitment_sessions")
      .update({ status: "analyzing" })
      .eq("id", sessionId);

    // Step 1: Coordinator creates a Band room for this session
    let bandRoomId = "";
    if (coordinatorApiKey) {
      bandRoomId = await bandCreateRoom(coordinatorApiKey);
      if (bandRoomId) {
        // Update session with band_room_id
        await supabase
          .from("recruitment_sessions")
          .update({ band_room_id: bandRoomId })
          .eq("id", sessionId);

        // Add all agents to the room
        const agentsToAdd = [
          { id: screeningUUID, key: screeningApiKey },
          { id: reviewerUUID, key: reviewerApiKey },
          { id: interviewUUID, key: interviewApiKey },
          { id: culturalUUID, key: culturalApiKey },
        ];
        for (const agent of agentsToAdd) {
          if (agent.id) {
            await bandAddParticipant(bandRoomId, coordinatorApiKey, agent.id);
          }
        }

        // Coordinator sends opening message
        const openingMsg = `@Screening-Agent @Adversarial-Reviewer @Interview-Agent @Cultural-Fit-Agent\n\nStarting analysis session for job: "${jobTitle}"\nCandidates to evaluate: ${candidates.map((c) => c.name).join(", ")}\n\nPlease proceed with your evaluations in order.`;
        await bandSendMessage(bandRoomId, coordinatorApiKey, openingMsg, [
          { id: screeningUUID, name: "Screening-Agent" },
          { id: reviewerUUID, name: "Adversarial-Reviewer" },
          { id: interviewUUID, name: "Interview-Agent" },
          { id: culturalUUID, name: "Cultural-Fit-Agent" },
        ]);
      }
    }

    // Step 2: Process each candidate
    for (const candidate of candidates) {
      // Update candidate status to analyzing
      await supabase
        .from("candidates")
        .update({ status: "analyzing" })
        .eq("id", candidate.id);

      let screeningResult: AgentResult = { score: 5, summary: "Analysis unavailable", recommendation: "maybe", rawData: {} };
      let reviewResult: AgentResult = { score: 5, summary: "Review unavailable", recommendation: "maybe", rawData: {} };
      let interviewResult: AgentResult = { score: 5, summary: "Interview unavailable", recommendation: "maybe", rawData: {} };
      let culturalResult: AgentResult = { score: 5, summary: "Cultural assessment unavailable", recommendation: "maybe", rawData: {} };

      // --- Agent 1: Screening ---
      try {
        const { system, user } = getScreeningPrompt(candidate, jobDescription);
        const raw = await callAIMLAPI(aimlApiKey, system, user);
        screeningResult = parseAgentResult(raw, "Screening");

        // Save to DB
        await supabase.from("agent_results").insert({
          session_id: sessionId,
          candidate_id: candidate.id,
          agent_type: "screening",
          score: screeningResult.score,
          summary: screeningResult.summary,
          recommendation: screeningResult.recommendation,
          raw_data: screeningResult.rawData,
        });

        // Log to band_messages_log
        await supabase.from("band_messages_log").insert({
          room_id: bandRoomId || sessionId,
          session_id: sessionId,
          candidate_id: candidate.id,
          message_type: "contextHandoff",
          sender_agent: "screening",
          receiver_agent: "adversarialReview",
          payload: { score: screeningResult.score, summary: screeningResult.summary, recommendation: screeningResult.recommendation },
        });

        // Send Band message as Screening Agent
        if (bandRoomId && screeningApiKey && coordinatorUUID) {
          const msg = `@Coordinator-Agent Screening complete for ${candidate.name}:\n• Score: ${screeningResult.score.toFixed(1)}/10\n• Recommendation: ${screeningResult.recommendation.toUpperCase()}\n• ${screeningResult.summary}`;
          await bandSendMessage(bandRoomId, screeningApiKey, msg, [{ id: coordinatorUUID, name: "Coordinator-Agent" }]);
        }
      } catch (e) {
        console.error("Screening agent failed:", e);
      }

      // --- Agent 2: Adversarial Reviewer (Featherless) ---
      try {
        const { system, user } = getReviewerPrompt(candidate, screeningResult, jobDescription);
        const raw = await callFeatherless(featherlessKey, system, user);
        reviewResult = parseAgentResult(raw, "Reviewer");

        await supabase.from("agent_results").insert({
          session_id: sessionId,
          candidate_id: candidate.id,
          agent_type: "adversarialReview",
          score: reviewResult.score,
          summary: reviewResult.summary,
          recommendation: reviewResult.recommendation,
          raw_data: reviewResult.rawData,
        });

        await supabase.from("band_messages_log").insert({
          room_id: bandRoomId || sessionId,
          session_id: sessionId,
          candidate_id: candidate.id,
          message_type: "reviewResult",
          sender_agent: "adversarialReview",
          receiver_agent: "coordination",
          payload: { score: reviewResult.score, summary: reviewResult.summary, conflict: (reviewResult.rawData as Record<string, unknown>)?.conflict_with_screening ?? false },
        });

        if (bandRoomId && reviewerApiKey && coordinatorUUID) {
          const conflict = (reviewResult.rawData as Record<string, unknown>)?.conflict_with_screening ? "⚠️ CONFLICT DETECTED with screening" : "✅ Consistent with screening";
          const msg = `@Coordinator-Agent Adversarial Review for ${candidate.name}:\n• Score: ${reviewResult.score.toFixed(1)}/10\n• Recommendation: ${reviewResult.recommendation.toUpperCase()}\n• ${conflict}\n• ${reviewResult.summary}`;
          await bandSendMessage(bandRoomId, reviewerApiKey, msg, [{ id: coordinatorUUID, name: "Coordinator-Agent" }]);
        }
      } catch (e) {
        console.error("Adversarial reviewer failed:", e);
      }

      // --- Agent 3: Interview ---
      try {
        const { system, user } = getInterviewPrompt(candidate, jobDescription);
        const raw = await callAIMLAPI(aimlApiKey, system, user);
        interviewResult = parseAgentResult(raw, "Interview");

        await supabase.from("agent_results").insert({
          session_id: sessionId,
          candidate_id: candidate.id,
          agent_type: "technicalInterview",
          score: interviewResult.score,
          summary: interviewResult.summary,
          recommendation: interviewResult.recommendation,
          raw_data: interviewResult.rawData,
        });

        await supabase.from("band_messages_log").insert({
          room_id: bandRoomId || sessionId,
          session_id: sessionId,
          candidate_id: candidate.id,
          message_type: "contextHandoff",
          sender_agent: "technicalInterview",
          receiver_agent: "culturalAssessment",
          payload: { score: interviewResult.score, summary: interviewResult.summary },
        });

        if (bandRoomId && interviewApiKey && coordinatorUUID) {
          const msg = `@Coordinator-Agent Technical Interview simulation for ${candidate.name}:\n• Score: ${interviewResult.score.toFixed(1)}/10\n• Recommendation: ${interviewResult.recommendation.toUpperCase()}\n• ${interviewResult.summary}`;
          await bandSendMessage(bandRoomId, interviewApiKey, msg, [{ id: coordinatorUUID, name: "Coordinator-Agent" }]);
        }
      } catch (e) {
        console.error("Interview agent failed:", e);
      }

      // --- Agent 4: Cultural Fit ---
      try {
        const { system, user } = getCulturalPrompt(candidate, jobDescription);
        const raw = await callAIMLAPI(aimlApiKey, system, user);
        culturalResult = parseAgentResult(raw, "Cultural");

        await supabase.from("agent_results").insert({
          session_id: sessionId,
          candidate_id: candidate.id,
          agent_type: "culturalAssessment",
          score: culturalResult.score,
          summary: culturalResult.summary,
          recommendation: culturalResult.recommendation,
          raw_data: culturalResult.rawData,
        });

        await supabase.from("band_messages_log").insert({
          room_id: bandRoomId || sessionId,
          session_id: sessionId,
          candidate_id: candidate.id,
          message_type: "contextHandoff",
          sender_agent: "culturalAssessment",
          receiver_agent: "coordination",
          payload: { score: culturalResult.score, summary: culturalResult.summary },
        });

        if (bandRoomId && culturalApiKey && coordinatorUUID) {
          const msg = `@Coordinator-Agent Cultural Fit Assessment for ${candidate.name}:\n• Score: ${culturalResult.score.toFixed(1)}/10\n• Recommendation: ${culturalResult.recommendation.toUpperCase()}\n• ${culturalResult.summary}`;
          await bandSendMessage(bandRoomId, culturalApiKey, msg, [{ id: coordinatorUUID, name: "Coordinator-Agent" }]);
        }
      } catch (e) {
        console.error("Cultural agent failed:", e);
      }

      // --- Agent 5: Coordinator Final Report ---
      try {
        const { system, user } = getCoordinatorPrompt(candidate, screeningResult, reviewResult, interviewResult, culturalResult);
        const raw = await callAIMLAPI(aimlApiKey, system, user);
        const coordResult = parseAgentResult(raw, "Coordinator");

        const hasConflict = (coordResult.rawData as Record<string, unknown>)?.has_conflict as boolean ?? false;
        const conflictNote = (coordResult.rawData as Record<string, unknown>)?.conflict_note as string ?? null;
        const overallScore = (
          screeningResult.score * 0.25 +
          reviewResult.score * 0.25 +
          interviewResult.score * 0.35 +
          culturalResult.score * 0.15
        );

        // Save final report
        await supabase.from("final_reports").upsert({
          session_id: sessionId,
          candidate_id: candidate.id,
          screening_score: screeningResult.score,
          technical_score: interviewResult.score,
          cultural_score: culturalResult.score,
          overall_score: overallScore,
          has_conflict: hasConflict,
          conflict_note: conflictNote,
          final_recommendation: coordResult.recommendation,
          summary_notes: coordResult.summary,
        }, { onConflict: "candidate_id" });

        // Save coordinator agent result
        await supabase.from("agent_results").insert({
          session_id: sessionId,
          candidate_id: candidate.id,
          agent_type: "coordination",
          score: overallScore,
          summary: coordResult.summary,
          recommendation: coordResult.recommendation,
          raw_data: coordResult.rawData,
        });

        // Insert into band_messages_log so UI can advance
        await supabase.from("band_messages_log").insert({
          room_id: bandRoomId || sessionId,
          session_id: sessionId,
          candidate_id: candidate.id,
          message_type: "finalEvaluation",
          sender_agent: "coordination",
          receiver_agent: "",
          payload: { score: overallScore, summary: coordResult.summary, recommendation: coordResult.recommendation },
        });

        // Update candidate with overall score and status
        await supabase.from("candidates").update({
          overall_score: overallScore,
          status: "analyzed",
        }).eq("id", candidate.id);

        // Band final report message from Coordinator
        if (bandRoomId && coordinatorApiKey) {
          const mentions = [];
          if (screeningUUID) mentions.push({ id: screeningUUID, name: "Screening-Agent" });
          if (reviewerUUID) mentions.push({ id: reviewerUUID, name: "Adversarial-Reviewer" });
          if (interviewUUID) mentions.push({ id: interviewUUID, name: "Interview-Agent" });
          if (culturalUUID) mentions.push({ id: culturalUUID, name: "Cultural-Fit-Agent" });

          const mentionStr = mentions.map((m) => `@${m.name}`).join(" ");
          const finalMsg = `${mentionStr}\n\n📋 FINAL REPORT - ${candidate.name}\n━━━━━━━━━━━━━━━━━━━━━\n• Overall Score: ${overallScore.toFixed(1)}/10\n• Final Decision: ${coordResult.recommendation.toUpperCase()}\n${hasConflict ? `⚠️ Conflict: ${conflictNote}` : "✅ No conflicts detected"}\n\n${coordResult.summary}`;
          await bandSendMessage(bandRoomId, coordinatorApiKey, finalMsg, mentions.length > 0 ? mentions : [{ id: screeningUUID || "", name: "team" }]);
        }
      } catch (e) {
        console.error("Coordinator agent failed:", e);
      }
    } // end candidates loop

    // Update session status to completed
    await supabase
      .from("recruitment_sessions")
      .update({ status: "completed" })
      .eq("id", sessionId);

    return new Response(
      JSON.stringify({
        success: true,
        sessionId,
        bandRoomId,
        processedCandidates: candidates.length,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Orchestrate session error:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
