import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { plaidRequest, type LinkTokenResponse } from "../_shared/plaid.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return Response.json({ error: "Missing authorization header" }, { status: 401 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
    );

    const jwt = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(jwt);
    if (authError || !user) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const data = await plaidRequest<LinkTokenResponse>("/link/token/create", {
      user: { client_user_id: user.id },
      client_name: "Warden",
      products: ["transactions"],
      country_codes: ["US"],
      language: "en",
    });

    return Response.json({ link_token: data.link_token });
  } catch (err) {
    return Response.json({ error: (err as Error).message }, { status: 500 });
  }
});
