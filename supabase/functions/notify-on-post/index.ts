import { serve } from "https://deno.land/std@0.131.0/http/server.ts";

interface PostPayload {
  type: 'INSERT';
  table: 'posts';
  record: {
    id: string;
    content: string;
    category: string;
    ward_no: number;
    user_id: string;
  };
  schema: 'public';
}

serve(async (req) => {
  try {
    const payload: PostPayload = await req.json();
    const { record } = payload;
    const { category, content, ward_no } = record;

    console.log(`New post in Ward ${ward_no}: ${category}`);

    // Get Firebase Service Account from environment variables
    const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}");

    if (!serviceAccount.project_id) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT secret is not configured correctly.");
    }

    const accessToken = await getAccessToken(serviceAccount);
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

    const message = {
      message: {
        topic: `ward_${ward_no}`,
        notification: {
          title: "नई शिकायत (New Grievance)",
          body: `${category.toUpperCase()} - ${content.substring(0, 50)}${content.length > 50 ? '...' : ''}`,
        },
        data: {
          post_id: record.id,
          ward_no: String(ward_no),
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
    };

    const response = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify(message),
    });

    const result = await response.json();
    console.log("FCM Response:", result);

    return new Response(JSON.stringify({ success: true, result }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error sending notification:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

/**
 * Generates a Google OAuth2 Access Token using the Service Account JSON
 * Optimized using Deno Web Crypto to avoid bundling overhead.
 */
async function getAccessToken(serviceAccount: any): Promise<string> {
  const { client_email, private_key } = serviceAccount;
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: client_email,
    sub: client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope: "https://www.googleapis.com/auth/cloud-platform",
  };

  // Extract base64 encoded key from PEM
  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  const pemContents = private_key.substring(
    private_key.indexOf(pemHeader) + pemHeader.length,
    private_key.indexOf(pemFooter)
  ).replace(/\s/g, "");

  const binaryDerString = atob(pemContents);
  const binaryDer = new Uint8Array(binaryDerString.length);
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i);
  }

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const encodedHeader = btoa(JSON.stringify(header)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const encodedPayload = btoa(JSON.stringify(payload)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const dataToSign = new TextEncoder().encode(`${encodedHeader}.${encodedPayload}`);

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    dataToSign
  );

  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const jwt = `${encodedHeader}.${encodedPayload}.${encodedSignature}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await response.json();
  return data.access_token;
}
