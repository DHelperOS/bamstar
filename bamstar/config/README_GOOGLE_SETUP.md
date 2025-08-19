Guide: Google OAuth files and where to place them

This repo contains exported Google OAuth client JSONs in `bamstar/config`.

Files included (from Google Cloud):
- `client_secret_323579487620-apn1b5g60dfq321ari19dsjibaotrk5c.apps.googleusercontent.com.json` (web client)
- `client_secret_323579487620-hbaq7eftaobh228qmilgo2p0f76bggso.apps.googleusercontent.com.json` (installed/android client)

What to do:

1) Web
- A copy of the web client JSON was placed at `web/google_client_secret_web.json` for convenience.
- Ensure the Web client in Google Cloud has the following:
  - Authorized redirect URI: `https://<YOUR_SUPABASE_PROJECT>.supabase.co/auth/v1/callback`
  - Authorized JavaScript origins: your app origin (e.g. `http://localhost:5173` or `https://app.yourdomain.com`)
- In Supabase Dashboard → Authentication → Providers → Google, set the Client ID/Secret to the Web client values.

2) Android
- Google requires a `google-services.json` file at `android/app/google-services.json` for many integrations.
- The included `client_secret_...installed.json` is not `google-services.json`. To generate `google-services.json`:
  - In Google Cloud Console (Credentials), create an OAuth client for Android and register your package name and SHA-1 fingerprint.
  - In Firebase Console (recommended), add an Android app to your Firebase project using the same package name; Firebase will provide a `google-services.json` that you can download.
  - Place the downloaded `google-services.json` at `android/app/google-services.json`.
- Ensure the Android OAuth client in Google Cloud has the correct package name and SHA-1.

3) If you plan to support native Google Sign-In
- Make sure the appropriate client IDs are present in `.env` (web and android). The code expects:
  - `NEXT_PUBLIC_GOOGLE_WEB_CLIENT_ID`
  - `GOOGLE_ANDROID_CLIENT_ID`
  - `GOOGLE_IOS_CLIENT_ID` (optional for now)

4) Bridge approach for mobile web OAuth
- If you don't want to set up native sign-in immediately, use the "bridge" approach: host a small static page that forwards the Supabase redirect to your app scheme (see earlier guidance).

If you'd like, I can:
- Add the `google-services.json` placeholder into `android/app/` (if you provide it),
- Or help create the Firebase app + instructions to export `google-services.json` for you.

Security note: Do not commit long-lived secrets (client_secret) into git for public repos. These files are included here for convenience in this private project only.
