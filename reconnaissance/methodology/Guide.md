# Web Reconnaissance Guide (Beginner-Friendly)

> **Reconnaissance (recon)** is the information-gathering phase of web security testing.
>
> **Goal:** Discover and document the target’s attack surface (URLs, paths, parameters, technologies, behaviors, and authentication flows) **without** vulnerability scanning, exploitation, or bug-finding steps.

---

## What recon is (and is not)

### What recon is

Recon is the process of discovering and documenting:

- Web applications and environments you are allowed to test
- Entry points (pages, APIs, endpoints)
- Inputs (parameters, request bodies, headers)
- Technologies (frameworks, servers, CDNs, third-party services)
- Application behaviors (redirects, auth flows, error handling)

### What recon is not

During recon, you should avoid actions that are meant to *prove* a vulnerability:

- No exploit attempts
- No vulnerability scanning
- No password guessing, brute forcing, or payload testing
- No aggressive or high-volume automation

If a technique would generate lots of requests, only use it if the program rules explicitly allow it and you can keep it slow and minimal.

---

## Preparation (do this before the steps)

### Confirm scope and rules

Write down:

- **In-scope** domains/apps (and environments like `staging` if allowed)
- **Out-of-scope** assets and third-party services
- **Rate limits** and request restrictions
- **Authentication rules** (test accounts, MFA rules, IP allowlists)
- **Data handling rules** (avoid storing sensitive customer data)

Important:

- You will often face only **one domain** (or a few subdomains) in scope.
- Sometimes, related domains/subdomains exist, but do **not** interact with anything out of scope unless the program rules explicitly allow it.
- Passive OSINT about the organization is usually safer than direct interaction with out-of-scope hosts, but rules always come first.

### Set up a simple note-taking system

Recon produces a lot of data. Keep it organized from the beginning.

Suggested categories:

- Assets: domains/subdomains, app URLs, environments
- Endpoints: pages + API routes
- Parameters: query/form/JSON fields, headers of interest
- Auth: login flows, session cookie names, token types, password reset flow
- Tech: frameworks, server headers, CDNs, third parties

### A simple folder layout (recommended)

Create a dedicated directory for each target, for example:

webPent/
└── reconnaissance/
    └── output/
        └── example.com/
            ├── 01-dns/
            ├── 02-osint/
            ├── 03-history/
            ├── 04-crawling/
            ├── 05-javascript/
            ├── 06-paths-config/
            ├── 07-manual/
            ├── 08-tech/
            └── 09-auth/

Store the output of each tool and each manual step in the matching folder so results remain traceable.

---

## Step 1 — DNS reconnaissance (if allowed)

### Purpose

Understand how the domain is structured at the DNS level and identify related assets.

### What to look for

- Subdomains
- DNS records (A, CNAME, MX, TXT)
- CDN or cloud providers

### Methods

- Passive enumeration only (no brute-force if not allowed)
- Certificate transparency review (often low-noise)

### Tools

- subfinder
- amass (passive mode)
- crt.sh
- dig / nslookup
- whois

Important notes:

- Stay inside scope. If you discover additional assets, treat them as **unconfirmed** until the program explicitly says they are in scope.
- Avoid brute-force subdomain discovery unless it is explicitly allowed.

---

## Step 2 — Google dorking / OSINT

### Purpose

Find publicly exposed information indexed by search engines and public data sources.

### What to look for

- Hidden paths and forgotten pages
- Backup files and exported data (do not download sensitive data)
- Old endpoints or documentation
- Error messages that reveal paths or technologies
- Exposed documents (PDF, DOCX, XLSX)

### Methods

- Search engine queries ("dorks")
- Public data sources (code search, internet exposure snapshots)

### Examples

- `site:example.com inurl:login`
- `site:example.com filetype:pdf`
- `site:example.com inurl:swagger OR inurl:openapi`

### Tools

- Google, Bing, DuckDuckGo
- GitHub search, GitLab search
- urlscan.io (public results)
- Shodan (metadata only)
- SecurityTrails (DNS history)

Browser extensions (optional):

- Wappalyzer (for quick tech hints during browsing)
- Shodan extension (quick domain context; use for metadata)

---

## Step 3 — Historical data (Wayback Machine, GAU)

### Purpose

Discover old endpoints and parameters that are no longer linked but may still exist.

### What to look for

- Deprecated APIs
- Old admin-like paths
- Legacy parameters and old file locations

### Methods

- URL harvesting from archives
- Deduplication and categorization (API vs pages vs files)

### Tools

- Wayback Machine (web.archive.org)
- gau
- waybackurls

Safety note: collect URLs from archives first; only manually check a small, relevant subset on the live target.

---

## Step 4 — Crawling

### Purpose

Map reachable pages and endpoints from the live application by following links.

### What to look for

- Linked pages
- Forms (field names and actions)
- API endpoints observed in normal usage

### Methods

- Controlled crawling (low concurrency)
- Respect scope, robots guidance, and rate limits

### Tools

- Burp Suite crawler / spider (if available)
- OWASP ZAP spider
- hakrawler
- katana

---

## Step 5 — JavaScript analysis

### Purpose

Extract endpoints, behaviors, and hidden functionality from client-side code.

### What to look for

- API routes and base paths
- Parameters (query keys, JSON field names)
- Tokens or keys (record only; do not use them)
- Feature flags and environment URLs

### Methods

- Manual review of key bundles
- Automated endpoint extraction (keep it offline when possible)

### Tools

- Browser DevTools (Sources + Network)
- LinkFinder
- JSParser

Browser extensions (optional):

- Link Gopher (extract links from the current page)
- JSON Viewer (makes API responses easier to read)

---

## Step 6 — Directory and configuration discovery

### Purpose

Find unlinked paths, configuration files, and common directories.

### What to look for

- Admin panels and management paths (do not attempt logins)
- Configuration and metadata files
- Debug/status endpoints (observe only)

### Methods

- Start with known, low-noise locations
- If (and only if) explicitly allowed: controlled wordlist-based discovery with a low request rate

Low-noise locations to check (within scope):

- `/robots.txt`
- `/sitemap.xml`
- `/.well-known/`
- `/security.txt`
- `/manifest.json`

### Tools

- Browser
- Burp Suite / OWASP ZAP (for viewing responses and headers)
- curl or httpie
- ffuf (only if allowed, low rate)
- dirsearch (only if allowed, low rate)
- gobuster (only if allowed, low rate)

---

## Step 7 — Manual inspection

### Purpose

Understand application behavior that tools cannot detect.

### What to look for

- Hidden UI logic (what appears only after certain actions)
- Request patterns and important endpoints
- Error handling and redirects
- Client-side validation behavior (observe only)

### Methods

- Browser DevTools (Network/Storage)
- Proxy observation and manual replay for documentation

### Tools

- Chrome / Firefox DevTools
- Burp Suite (proxy mode)
- OWASP ZAP (proxy mode)

Browser extensions (optional):

- FoxyProxy (quickly switch proxy settings)

---

## Step 8 — Technology fingerprinting (informational only)

### Purpose

Identify technologies used for context only (do not use this step to target known CVEs).

### Important note

Most CVE-based attacks are out of scope in many programs. This step is for understanding the stack and documenting what you see.

### What to identify

- Web server (when visible)
- Frameworks and platforms (frontend/backend)
- CDN / WAF (when visible)
- Third-party services (auth providers, payments, analytics)

### Tools

- Wappalyzer (Chrome/Firefox extension)
- WhatWeb
- BuiltWith (web)
- Nuclei (tech templates only, and only if allowed)

---

## Step 9 — Authentication flow mapping

### Purpose

Understand how authentication works without attacking it.

### What to map

- Login flow
- Password reset flow
- Session handling (cookies/tokens) and lifetime
- Logout behavior

### Methods

- Observe requests during normal usage
- Compare pre-auth and post-auth behavior

### Tools

- Burp Suite
- Browser DevTools

---

## Recon deliverables (what you should have at the end)

- **Asset inventory:** in-scope domains/subdomains and environment URLs
- **Endpoint catalog:** pages and API routes, grouped by feature
- **Parameter inventory:** parameters/fields per endpoint (no testing)
- **Auth flow map:** login/reset/MFA endpoints and request sequence
- **Tech profile:** technologies, CDNs/WAFs (when visible), third parties

---

## Recon stopping point

Stop recon when:

- New manual browsing/crawling rarely finds new endpoints
- You understand authentication flows and session behavior
- You have a consolidated list of URLs, endpoints, and parameters
- You can explain the app’s main features and technology stack

This guide intentionally stops here.
