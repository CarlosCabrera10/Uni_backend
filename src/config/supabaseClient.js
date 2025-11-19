import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  throw new Error("Missing SUPABASE_URL or SUPABASE_KEY in environment");
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

export default supabase;

// Connectivity test: perform a lightweight HTTP GET to the PostgREST root
// using the provided API key. This only checks network reachability and
// that the Supabase instance responds; it does NOT access database tables.
(async () => {
  try {
    const restRoot = SUPABASE_URL.replace(/\/$/, "") + "/rest/v1/";
    const res = await fetch(restRoot, {
      method: "GET",
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`
      }
    });

    if (res && typeof res.status === "number") {
      console.log(`Supabase reachable (HTTP ${res.status}). Connectivity OK.`);
    } else {
      console.warn("Supabase reachable but response status unknown.");
    }
  } catch (err) {
    console.error("Supabase connectivity test failed:", err.message || err);
  }
})();
