# Deploying SignWave (free)

SignWave has two parts that deploy to **two different hosts**:

| Part | Host | Why |
| --- | --- | --- |
| `frontend/` (Next.js) | **Vercel** (Hobby = free) | Vercel is built for Next.js |
| `backend/` (Django + ML) | **Hugging Face Spaces** (free CPU, 16 GB RAM) | The TensorFlow/PyTorch/MediaPipe stack is multi-GB and needs real RAM — it cannot run on Vercel's serverless functions |

Deploy the **backend first**, then point the frontend at it.

---

## 1. Backend → Hugging Face Spaces

1. Create an account at <https://huggingface.co>.
2. **New → Space.** Choose **Docker** as the SDK (blank template), make it **Public**, free **CPU basic** hardware.
3. Push this repo to the Space (it has a `Dockerfile` at the root that builds the backend):
   ```bash
   git remote add space https://huggingface.co/spaces/<your-username>/<space-name>
   git push space main
   ```
   (Or upload the files via the Space's web UI.)
4. In the Space's **README.md**, make sure the metadata header has `app_port: 7860`:
   ```yaml
   ---
   title: SignWave Backend
   sdk: docker
   app_port: 7860
   ---
   ```
5. The Space will build (this takes a while — it installs the ML stack and copies the 849 MB
   `reference_signs` data) and then boot. First boot also downloads the SigLIP model.
6. When it's running, your backend URL is: `https://<your-username>-<space-name>.hf.space`

The Dockerfile already sets `DEBUG=False`, `ALLOWED_HOSTS=*`, and `CORS_ALLOW_ALL=True`, so the
API accepts requests from any frontend origin.

> Free Spaces sleep after ~48h of inactivity; the first visit afterward takes ~30s to wake.
> CPU inference is slower than a local GPU but fine for a demo.

---

## 2. Frontend → Vercel

1. On Vercel, import the GitHub repo, but set the **Root Directory** to `frontend`
   (deploy only the Next.js app — ignore the backend service Vercel detected).
2. Under **Environment Variables**, add:
   ```
   NEXT_PUBLIC_API_URL = https://<your-username>-<space-name>.hf.space
   ```
   (the backend URL from step 1, no trailing slash).
3. Deploy. Vercel gives you a URL like `https://sign-wave.vercel.app`.

---

## 3. Lock CORS down (optional, recommended)

`CORS_ALLOW_ALL=True` is fine for a quick demo. To restrict the backend to only your Vercel
site, in the **Space settings → Variables** set:

```
CORS_ALLOW_ALL=False
FRONTEND_URL=https://sign-wave.vercel.app
```

Then restart the Space.

---

## Notes / limitations

- **Accounts are disabled** in this build (demo mode): the login page auto-enters a guest, and
  progress saving / multiplayer rooms (which use Firebase) are inert. Lessons, games, and webcam
  detection all work.
- The webcam requires **HTTPS** in production — both Vercel and HF Spaces serve HTTPS, so this is fine.
- If you later want progress/multiplayer, configure Firebase via `NEXT_PUBLIC_FIREBASE_*` env vars
  in Vercel and re-enable the auth gate in `frontend/proxy.ts`.
