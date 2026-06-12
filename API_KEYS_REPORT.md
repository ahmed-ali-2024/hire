# API Keys & Environment Setup Report

This document details where to place your API keys and how to configure the environment for the **Hire** project.

## 1. Supabase Configuration
The project is currently using the following Supabase URL:
- **URL:** `https://fedbxlfyrtwctmyolioq.supabase.co`

You need to replace `PLACEHOLDER_ANON_KEY` in `lib/main.dart` with your actual **Supabase Anon Key**.

```dart
// lib/main.dart
await Supabase.initialize(
  url: 'https://fedbxlfyrtwctmyolioq.supabase.co',
  anonKey: 'YOUR_ACTUAL_ANON_KEY',
);
```

## 2. Multi-Agent AI Keys
The application stores AI keys in the Supabase database (`user_secrets` table) for security and persistence. Once you have the keys, you can add them through the **Settings** feature (yet to be fully implemented in UI, but the logic is ready).

The required keys are:
- **AIMLAPI Key:** For Screening, Technical Interview, and Cultural Assessment agents.
- **Featherless Key:** For Adversarial Review and Candidate Simulator agents.
- **Band API Key & URL:** For real-time agent coordination.

## 3. Environment Variables (.env)
For production, it is recommended to use a `.env` file. Add the following to your root directory:

```env
SUPABASE_URL=https://fedbxlfyrtwctmyolioq.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
AIMLAPI_BASE_URL=https://api.aimlapi.com/v1
FEATHERLESS_BASE_URL=https://api.featherless.ai/v1
BAND_API_URL=your_band_api_url
```

## 4. Database Schema
Ensure your Supabase project has the following tables as defined in the SDD:
- `recruitment_sessions`
- `candidates`
- `user_secrets`
- `agent_results`
- `band_messages_log`
- `final_reports`
