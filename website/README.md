# OS4All - Public Product Information Website

This directory contains the lightweight, responsive public website for the **OS4All** preventive health intelligence project, developed for the **Seva Innovation Challenge**.

---

## 1. Overview & Architecture

- **Entry Point:** `index.html`
- **Styling:** `styles.css` (Deep navy theme, responsive CSS Grid / Flexbox, WCAG AAA compliant contrast, `prefers-reduced-motion` support)
- **Interactivity:** `script.js` (Pure Vanilla JavaScript, zero external dependencies or analytics trackers)
- **Assets:** `assets/logo.svg`, `assets/favicon.svg`
- **Zero Build Step:** 100% static HTML5/CSS3/JS — requires no compilation, npm packages, or server runtimes.

---

## 2. Deploying to Vercel (Step-by-Step)

The `website/` directory is designed to be deployed directly and independently on [Vercel](https://vercel.com):

### Step 1: Connect GitHub Repository
1. Log in to [Vercel](https://vercel.com).
2. Click **Add New...** > **Project**.
3. Import your GitHub repository: `https://github.com/The-kanak/OS4All`.

### Step 2: Configure Project Settings
In the Vercel **Configure Project** screen:

| Setting | Value / Action | Notes |
|---|---|---|
| **Project Name** | `os4all` (or preferred name) | Determines your `.vercel.app` domain |
| **Framework Preset** | `Other` | Pure static website |
| **Root Directory** | `website` | **Crucial:** Click **Edit** next to Root Directory and type or select `website` |
| **Build Command** | *Leave empty / Override OFF* | No build step needed |
| **Output Directory** | *Leave empty / Override OFF* | Serves the directory directly |
| **Install Command** | *Leave empty / Override OFF* | No dependencies |
| **Environment Variables** | *None required* | Zero secrets in client-side code |

### Step 3: Click Deploy
1. Click **Deploy**.
2. Vercel will complete deployment in seconds and generate your public production URL (e.g., `https://os4all.vercel.app`).
3. Enter this live URL into the Seva Innovation Challenge submission form under **Website / Product Link**.

---

## 3. Local Testing & Verification

To preview the website locally without any tools:
- Simply double-click `website/index.html` to open it in Chrome, Edge, Safari, or Firefox.

Or run a local static server:
```powershell
cd website
python -m http.server 3000
# Open http://localhost:3000 in your browser
```

---

## 4. Privacy & Ethical Boundaries

- **Zero Data Collection:** This site collects no patient or user health data.
- **Explicit Medical Notice:** Prominently states that OS4All is an early-stage health awareness project and does not replace qualified medical diagnosis or clinical evaluation.
- **Accurate Feature Labeling:** Clearly distinguishes implemented algorithms from experimental or mock fallback integrations.
