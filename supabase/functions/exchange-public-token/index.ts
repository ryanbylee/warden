import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { plaidRequest, type ExchangeTokenResponse } from "../_shared/plaid.ts";

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

    // Plain client for JWT verification (getUser requires no global auth header)
    const anonClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
    );
    const jwt = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await anonClient.auth.getUser(jwt);
    if (authError || !user) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    // User-context client for DB operations so RLS policies are satisfied
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { public_token, institution_name } = await req.json();
    if (!public_token) {
      return Response.json({ error: "Missing public_token" }, { status: 400 });
    }

    const data = await plaidRequest<ExchangeTokenResponse>("/item/public_token/exchange", {
      public_token,
    });

    const { error: insertError } = await supabase.from("connected_accounts").insert({
      user_id: user.id,
      plaid_item_id: data.item_id,
      access_token: data.access_token,
      institution_name: institution_name ?? null,
    });

    if (insertError) {
      throw new Error(`DB insert failed: ${insertError.message}`);
    }

    return Response.json({ success: true, item_id: data.item_id });
  } catch (err) {
    return Response.json({ error: (err as Error).message }, { status: 500 });
  }
});
