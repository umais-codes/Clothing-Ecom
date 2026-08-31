// @ts-nocheck
// Supabase Edge Function: init-safepay-session
// Deno TypeScript handler to securely generate Safepay TBT and Tracker tokens

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

declare const Deno: any;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { amount, currency = "PKR" } = await req.json();

    const SAFEPAY_CLIENT_KEY = Deno.env.get("SAFEPAY_CLIENT_KEY") ?? "sec_e0db25ff-9b4e-4f7f-a1df-b6ba9d423e85";
    const SAFEPAY_BASE_URL = "https://sandbox.api.getsafepay.com";

    // 1. Get Time-Based Token (TBT)
    const tokenRes = await fetch(`${SAFEPAY_BASE_URL}/user/v1/auth/token`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ client: SAFEPAY_CLIENT_KEY }),
    });
    const tokenData = await tokenRes.json();
    const tbt = tokenData?.data?.token;

    // 2. Initialize Order Tracker
    const orderRes = await fetch(`${SAFEPAY_BASE_URL}/order/v1/init`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        client: SAFEPAY_CLIENT_KEY,
        amount: Number(amount),
        currency: currency,
        environment: "sandbox",
      }),
    });
    const orderData = await orderRes.json();
    const tracker = orderData?.data?.token;

    if (!tbt || !tracker) {
      throw new Error(`Safepay init failed: ${JSON.stringify({ tokenData, orderData })}`);
    }

    return new Response(
      JSON.stringify({ tbt, tracker }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});
