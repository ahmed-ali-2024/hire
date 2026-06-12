-- Create Custom Types
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'session_status') THEN
        CREATE TYPE session_status AS ENUM ('pending', 'analyzing', 'completed', 'failed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'candidate_status') THEN
        CREATE TYPE candidate_status AS ENUM ('pending', 'analyzing', 'analyzed', 'accepted', 'rejected', 'reviewRequested');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'agent_type') THEN
        CREATE TYPE agent_type AS ENUM ('screening', 'adversarialReview', 'technicalInterview', 'culturalAssessment', 'coordination');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'agent_recommendation') THEN
        CREATE TYPE agent_recommendation AS ENUM ('accept', 'reject', 'maybe');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'band_message_type') THEN
        CREATE TYPE band_message_type AS ENUM ('contextHandoff', 'reviewRequest', 'reviewResult', 'finalEvaluation', 'coordinatorSync');
    END IF;
END $$;

-- 1. API Keys Settings (user_secrets)
CREATE TABLE IF NOT EXISTS public.user_secrets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    aiml_api_key TEXT NOT NULL,
    featherless_key TEXT NOT NULL,
    band_api_key TEXT NOT NULL,
    band_api_url TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_user_secrets UNIQUE (user_id)
);

-- 2. Recruitment Sessions Table
CREATE TABLE IF NOT EXISTS public.recruitment_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    job_title TEXT NOT NULL,
    job_description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- stores session_status values as text for simplicity in client-side mapping
    band_room_id TEXT,
    candidates_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Candidates Table
CREATE TABLE IF NOT EXISTS public.candidates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.recruitment_sessions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    cv_text TEXT NOT NULL,
    file_name TEXT NOT NULL,
    overall_score DOUBLE PRECISION,
    status TEXT NOT NULL DEFAULT 'pending', -- stores candidate_status values as text
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Agent Results Table
CREATE TABLE IF NOT EXISTS public.agent_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.recruitment_sessions(id) ON DELETE CASCADE,
    candidate_id UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    agent_type TEXT NOT NULL, -- stores agent_type values
    score DOUBLE PRECISION NOT NULL,
    summary TEXT NOT NULL,
    recommendation TEXT NOT NULL, -- stores agent_recommendation values
    raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Band Messages Log Table (For Realtime Panel)
CREATE TABLE IF NOT EXISTS public.band_messages_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id TEXT NOT NULL,
    session_id UUID NOT NULL REFERENCES public.recruitment_sessions(id) ON DELETE CASCADE,
    candidate_id UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    message_type TEXT NOT NULL, -- stores band_message_type values
    sender_agent TEXT NOT NULL, -- stores agent_type values
    receiver_agent TEXT NOT NULL, -- stores agent_type values
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Final Reports Table
CREATE TABLE IF NOT EXISTS public.final_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.recruitment_sessions(id) ON DELETE CASCADE,
    candidate_id UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    screening_score DOUBLE PRECISION NOT NULL,
    technical_score DOUBLE PRECISION NOT NULL,
    cultural_score DOUBLE PRECISION NOT NULL,
    overall_score DOUBLE PRECISION NOT NULL,
    has_conflict BOOLEAN NOT NULL DEFAULT false,
    conflict_note TEXT,
    final_recommendation TEXT NOT NULL, -- stores agent_recommendation values
    summary_notes TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_candidate_report UNIQUE (candidate_id)
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.user_secrets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.band_messages_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.final_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policies for user_secrets
CREATE POLICY "Users can manage their own secrets" ON public.user_secrets
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policies for recruitment_sessions
CREATE POLICY "Users can manage their own sessions" ON public.recruitment_sessions
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policies for candidates
CREATE POLICY "Users can manage candidates of their sessions" ON public.candidates
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = candidates.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = candidates.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    );

-- Policies for agent_results
CREATE POLICY "Users can manage agent results of their sessions" ON public.agent_results
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = agent_results.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = agent_results.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    );

-- Policies for band_messages_log
CREATE POLICY "Users can manage band messages of their sessions" ON public.band_messages_log
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = band_messages_log.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = band_messages_log.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    );

-- Policies for final_reports
CREATE POLICY "Users can manage final reports of their sessions" ON public.final_reports
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = final_reports.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.recruitment_sessions
            WHERE recruitment_sessions.id = final_reports.session_id
            AND recruitment_sessions.user_id = auth.uid()
        )
    );

-- Enable Realtime for band_messages_log and recruitment_sessions
ALTER PUBLICATION supabase_realtime ADD TABLE public.band_messages_log;
ALTER PUBLICATION supabase_realtime ADD TABLE public.recruitment_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.candidates;
