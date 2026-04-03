const PLAID_ENV = Deno.env.get("PLAID_ENV") ?? "sandbox";
const PLAID_CLIENT_ID = Deno.env.get("PLAID_CLIENT_ID")!;
const PLAID_SECRET = Deno.env.get("PLAID_SECRET")!;

const BASE_URLS: Record<string, string> = {
  sandbox: "https://sandbox.plaid.com",
  development: "https://development.plaid.com",
  production: "https://production.plaid.com",
};

export const PLAID_BASE_URL = BASE_URLS[PLAID_ENV] ?? BASE_URLS.sandbox;

export async function plaidRequest<T>(
  endpoint: string,
  body: Record<string, unknown>,
): Promise<T> {
  const res = await fetch(`${PLAID_BASE_URL}${endpoint}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: PLAID_CLIENT_ID,
      secret: PLAID_SECRET,
      ...body,
    }),
  });

  if (!res.ok) {
    const error = await res.json();
    throw new Error(`Plaid ${endpoint} failed: ${error.error_message ?? res.statusText}`);
  }

  return res.json() as Promise<T>;
}

// --- Plaid response types ---

export interface LinkTokenResponse {
  link_token: string;
  expiration: string;
  request_id: string;
}

export interface ExchangeTokenResponse {
  access_token: string;
  item_id: string;
  request_id: string;
}

export interface PlaidPersonalFinanceCategory {
  primary: string;
  detailed: string;
}

export interface PlaidTransaction {
  transaction_id: string;
  name: string;
  amount: number;
  date: string;
  personal_finance_category: PlaidPersonalFinanceCategory;
  merchant_name: string | null;
}

export interface PlaidSyncResponse {
  added: PlaidTransaction[];
  modified: PlaidTransaction[];
  removed: { transaction_id: string }[];
  next_cursor: string;
  has_more: boolean;
  request_id: string;
}
