// Central backend base URL.
//
// Local dev: defaults to the Django dev server on localhost:8000.
// Production: set NEXT_PUBLIC_API_URL in your hosting env (e.g. Vercel) to the
// deployed backend, such as https://<your-space>.hf.space
export const API_BASE = (
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000"
).replace(/\/$/, "");

// Build a full backend URL from a path, e.g. apiUrl("/api/track-numbers/").
export const apiUrl = (path: string): string =>
  `${API_BASE}${path.startsWith("/") ? "" : "/"}${path}`;
