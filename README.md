# Daily Trend Express — Deployment Package

## 1. Project type
**Plain HTML / CSS / JavaScript.** No React, no Vite, no Next.js, no framework at all.
Everything — markup, styles, and app logic — lives in a single self-contained file:

```
index.html   ← the entire website (HTML + <style> + <script>)
```

There are no separate `.css`, `.js`, or image files to lose track of: all images are
generated in-browser as inline SVG, and the only external resource loaded at runtime
is the Google Fonts stylesheet (`fonts.googleapis.com`) referenced in the `<head>`.

## 2. Entry file
`index.html`, at the **root** of the project. This is what every static host looks
for by default.

## 3. Assets check
- CSS: inline, inside `<style>` in `index.html` — nothing missing.
- JavaScript: inline, inside `<script>` in `index.html` — nothing missing.
- Images: generated on the fly as SVG data URIs — no image files to include.
- Fonts: loaded from Google Fonts via `<link>` tags — requires the visitor to have
  normal internet access, same as any website using Google Fonts.
- No broken relative paths, no missing imports, no `node_modules`.

## 4. package.json / build config
**Not applicable.** Since this isn't a React/Vite/Next.js project, there is no
`package.json`, `vite.config.js`, `next.config.js`, or any build tooling — and none
is needed.

## 5. Build command
**None.** The file is deployed exactly as-is.
- Vercel: leave "Build Command" empty (or set it to `echo "no build"` if the field
  won't accept blank).
- Cloudflare Pages: leave "Build command" empty.

## 6. Output / build folder
**The project root itself** (the same folder this `index.html` sits in).
- Vercel → set **Output Directory** to `.`
- Cloudflare Pages → set **Build output directory** to `/`
- Framework preset on both platforms: choose **"Other"** / **"None"**.

## 7. Routing note
The site uses hash-based routes (`#/`, `#/category/...`, `#/article/...`,
`#/admin`). Hash routes are handled entirely by the browser, so **no rewrite
rules, `vercel.json`, or `_redirects` file are required** — a plain static
deploy works immediately, including direct links to `#/admin` etc.

## 8. GitHub → Vercel/Cloudflare steps
1. Create a new GitHub repo (e.g. `daily-trend-express`).
2. Add `index.html` (and this `README.md`) to it, commit, and push.
3. **Vercel:** New Project → Import the GitHub repo → Framework Preset: "Other" →
   Build Command: empty → Output Directory: `.` → Deploy.
4. **Cloudflare Pages:** Create a project → Connect to Git → select the repo →
   Build command: empty → Build output directory: `/` → Save and Deploy.
5. Either platform will give you a live `.vercel.app` / `.pages.dev` URL
   immediately; a custom domain can be attached afterward from the project settings.

## 9. Important — one behavior change once hosted outside Claude
This site was built to run inside Claude's artifact environment, which provides a
built-in shared database (`window.claude.use("db")`) that the Admin dashboard,
comments, and newsletter form use to store data for **every visitor**.

That database only exists on claude.ai. Outside it (Vercel, Cloudflare, GitHub
Pages, etc.), `window.claude` won't exist, and the site **automatically and safely
falls back** to your browser's local storage — nothing crashes. But practically,
this means:

- The site will load and look and work exactly the same for any single visitor.
- Articles you add/edit/delete from `#/admin`, ticker updates, comments, and
  newsletter sign-ups will only be saved **in the browser of the person who made
  the change** — they will not sync to other visitors or persist across devices.
- The 20 seed articles baked into the page will show for everyone, since those are
  part of the file itself.

If you want the Admin dashboard to work for real once deployed publicly — so that
an article you publish is visible to every visitor — you'll need a real backend
(a small database like Supabase/Firebase/Cloudflare D1/KV, plus a few API routes).
That's a separate piece of work from this deployment package; let me know if you'd
like help setting one up.

No design or content changes were made in preparing this package — the file is
identical to what's published on claude.ai (aside from the brand-name fix already
applied: "Daily Trend Express").
