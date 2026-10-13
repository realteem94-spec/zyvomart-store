// ZyvoMart Supabase Configuration

const SUPABASE_URL = "https://fdcpttikdhgacvbvgiaz.supabase.co";

// Supabase Dashboard → Project Settings → API Keys
// Copy only the publishable key (sb_publishable_...).
// Never put the service_role or secret key in this file.

const SUPABASE_PUBLISHABLE_KEY = "PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE";

const supabaseClient = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_PUBLISHABLE_KEY
);
