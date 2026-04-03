import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { plaidRequest, type PlaidSyncResponse } from "../_shared/plaid.ts";

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

    const { item_id } = await req.json();
    if (!item_id) {
      return Response.json({ error: "Missing item_id" }, { status: 400 });
    }

    // Look up the connected account
    const { data: account, error: lookupError } = await supabase
      .from("connected_accounts")
      .select("access_token, cursor")
      .eq("user_id", user.id)
      .eq("plaid_item_id", item_id)
      .single();

    if (lookupError || !account) {
      return Response.json({ error: "Connected account not found" }, { status: 404 });
    }

    // Paginate through all available transaction updates
    let cursor = account.cursor ?? "";
    const allAdded: PlaidSyncResponse["added"] = [];
    const allModified: PlaidSyncResponse["modified"] = [];
    const allRemoved: PlaidSyncResponse["removed"] = [];

    let hasMore = true;
    while (hasMore) {
      const page = await plaidRequest<PlaidSyncResponse>("/transactions/sync", {
        access_token: account.access_token,
        cursor: cursor || undefined,
      });

      allAdded.push(...page.added);
      allModified.push(...page.modified);
      allRemoved.push(...page.removed);
      cursor = page.next_cursor;
      hasMore = page.has_more;
    }

    // Persist the new cursor
    const { error: updateError } = await supabase
      .from("connected_accounts")
      .update({ cursor, updated_at: new Date().toISOString() })
      .eq("user_id", user.id)
      .eq("plaid_item_id", item_id);

    if (updateError) {
      throw new Error(`Cursor update failed: ${updateError.message}`);
    }

    return Response.json({
      added: allAdded.map(simplify),
      modified: allModified.map(simplify),
      removed: allRemoved.map((r) => r.transaction_id),
    });
  } catch (err) {
    return Response.json({ error: (err as Error).message }, { status: 500 });
  }
});

function simplify(t: PlaidSyncResponse["added"][number]) {
  return {
    transaction_id: t.transaction_id,
    name: t.merchant_name ?? t.name,
    amount: t.amount,
    date: t.date,
    personal_finance_category: t.personal_finance_category,
  };
}
