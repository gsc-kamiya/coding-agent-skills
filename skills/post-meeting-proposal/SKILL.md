---
name: post-meeting-proposal
description: Create a proposal package (doc + slides + email draft) based on the first meeting transcript, grounded in the prospect's own words
argument-hint: "[prospect name] [transcript file path] [company intro PDF path]"
disable-model-invocation: true
---

# Post-Meeting Proposal Creation

Create a proposal package based on the first-meeting transcript, grounded in what the prospect actually said.

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{COMPANY_NAME}` | Your company name | `Acme Corp` |
| `{SALES_DIR}` | Sales documents directory | `sales/` |
| `{GH_USER}` | GitHub username for push | `my-github-user` |
| `{GCP_PROJECT}` | GCP project for Gemini image generation | `my-gcp-project` |
| `{COLOR_PRIMARY}` | Slide primary color | `#1A365D` |
| `{COLOR_ACCENT}` | Slide accent color | `#0D9488` |
| `{COLOR_BACKGROUND}` | Slide background color | `#F7FAFC` |
| `{SENDER_NAME}` | Your name for email signature | `Your Name` |
| `{SENDER_TITLE}` | Your title | `CEO` |
| `{SENDER_EMAIL}` | Your email | `you@company.com` |
| `{SENDER_PHONE}` | Your phone (optional) | `+1-555-0100` |
| `{COMPANY_URL}` | Company website URL | `https://company.com` |
| `{TEAM_CREDENTIALS}` | Team credentials/certifications for slides | `AWS Solutions Architect x2, etc.` |

---

## Core Principle: "Prospect's Words First"

> **Every challenge description in the proposal must be based on what the prospect actually said in the meeting.**
> - Lead reports are background info only. Do not use them in the proposal.
> - Do not use AI analysis to "identify core challenges." One meeting is not enough to know the prospect's true problems.
> - Structure: What the prospect said -> What we can do about it. Simple.
> - Use technical terms only if the prospect used them first. Do not introduce jargon.

### Anti-Patterns (Lessons from Lost Deals)

- **Presumptuous problem analysis**: "Your core challenge is..." -> Never assume after one meeting
- **Information overload**: 13 slides + 13-section estimate + long email -> Keep it concise after a first meeting
- **AI-sounding text**: Template-like phrasing, over-structured -> Write naturally, as a human would
- **Sending prototypes after first meeting is forbidden**: Winning deals come from discovery first, proposal second. Prototypes after a first meeting undermine pricing ("If it's already built, why this price?"). Proposals only after meeting 1; prototypes from meeting 2 onward.
- **Rephrasing prospect's words**: If the prospect said "it's a pain," don't write "operational efficiency challenge." Use their exact words.

## Arguments

- `$0`: Prospect name
- `$1`: Transcript file path (CSV/text)
- `$2`: Company intro PDF path

## Execution Steps

### Step 0: Meeting Retrospective

Read the transcript and analyze the meeting:

**What Went Well (Keep)**:
- Quality of preparation, moments where the prospect responded positively
- Actions that built trust

**What Could Improve (Problem)**:
- Overuse of jargon, insufficient attention to prospect understanding
- Missed opportunities to dig deeper on prospect statements
- Areas where our side talked too much

**Improvements for Next Time (Try)**:
- 3 specific improvement actions

Present this retrospective to the user before proceeding to Step 1.

### Step 1: Parse Transcript — Organize Around Prospect's Exact Words

Read `$1` and organize the following, **quoting the prospect's own words verbatim**:

- **Challenges the prospect described**: Quote with quotation marks, add minimal context in parentheses
- **What the prospect hopes for**: Expectations mentioned during the meeting
- **Current workflow/systems**: Only what was mentioned (do not extrapolate)
- **Budget/timeline signals**: Only if mentioned
- **Agreed next actions**: What was agreed in the meeting
- **Prospect's vocabulary**: Note specific words/phrases for reuse in the proposal

**Prohibited**:
- Do not copy lead report content as challenges
- Do not perform "core challenge" or "fundamental bottleneck" analysis
- Do not fill in gaps with assumptions

### Step 2: Write Proposal Document (MD)

Save to: `{SALES_DIR}/proposals/{prospect_name}_proposal_{date}.md`

```
## Document Structure (7 sections max)
1. Thank you & purpose of this document
2. What we heard in the meeting (organized around prospect's words)
3. Proposed direction ("Here's what we could do")
4. Suggested approach (just the first step)
5. Estimated budget (first step only, not tiered pricing)
6. About {COMPANY_NAME} (brief)
7. Next steps
```

**Budget approach**:
- After a first meeting, present only the "first step" budget
- Tiered pricing (good/better/best) comes in meeting 2+ when requirements are clear
- First step (PoC/deep-dive/sample validation): typically a small, scoped engagement

**Tone rules**:
- "We'll solve your X problem" -> "Here's an approach we could take for X"
- "Your challenges" -> "What we heard in the meeting"
- "Our strengths" -> Keep to a minimum. Share when asked.
- Overall tone: "We understand. Let's figure this out together."

### Step 3: Generate Proposal Slides (Gemini Image Generation)

**Slide structure (8 slides max)**:
1. Title (prospect name, {COMPANY_NAME}, date)
2. What we heard (quoting prospect's words)
3. Proposed direction
4. Suggested approach (first step)
5. Conceptual diagram (architecture or Before/After workflow)
6. Estimated budget & timeline
7. {COMPANY_NAME} team introduction
8. Next steps

If the meeting content is thin, 5-6 slides is fine. Do not pad to fill slides.

**Slide generation script**:
Save to: `{SALES_DIR}/scripts/generate_{prospect}_slides.py`

```python
model = "gemini-3.1-flash-image-preview"  # or gemini-3-pro-image-preview for higher quality
project = "{GCP_PROJECT}"  # Your GCP project with Vertex AI enabled
location = "global"
output_dir = "{SALES_DIR}/proposals/{prospect_name}_slides/"
```

**Design rules**:
- Color palette: {COLOR_PRIMARY} primary, {COLOR_ACCENT} accent, {COLOR_BACKGROUND} background
- 16:9 aspect ratio
- All prompts include: "CRITICAL: Do NOT add any company names, logos, or text that is not explicitly listed below."
- Footer: "{COMPANY_NAME} | Confidential" left, page number right

**Team slide (slide 7) rules**:
- Include {TEAM_CREDENTIALS} (certifications, awards, experience)
- List member titles and roles accurately
- Part-time or advisory members: note as "Advisor" or "Joining as needed"

**Slide tone rules (important)**:
- Never criticize or point out the prospect's problems in a judgmental tone
- Avoid: "not started," "lacking," "underutilized," "no resources"
- Use collaborative framing:
  - Bad: "Quality data collection not started" -> Good: "Opportunity to enhance accuracy through data-driven quality assessment"
  - Bad: "No resources available" -> Good: "Physically challenging within the current team structure"
- **Use the prospect's own words in slides**: If they said "this part is really tough," use that exact phrase

```bash
python3 {SALES_DIR}/scripts/generate_{prospect}_slides.py
```

After generation, visually inspect all slides for hallucinated text.

### Step 4: Place Company Intro PDF

Copy `$2` to `{SALES_DIR}/proposals/`.

### Step 5: Draft Follow-Up Email

Use `mcp__google_workspace__draft_gmail_message`.

**Recipient**: Prospect contact identified in Step 1
- If unknown: search with `mcp__google_workspace__search_gmail_messages`

**Subject**: "Thank you for your time today"

**Format**: `body_format="html"`, `include_signature=false`

**Email principles**:
- **Keep it short.** Readable without scrolling (~150 words max)
- **Don't repeat what's in the attachments.** They can read the materials
- **No bullet-point lists.** Write naturally, like a human email
- **Be clear about the next meeting date**

**Body template (HTML)**:
```html
<div style="font-family: sans-serif; font-size: 14px; color: #333;">
<p>{Contact Name},</p>

<p>Thank you for taking the time to meet today.</p>

<p>{One natural sentence referencing something memorable from the meeting. Quoting the prospect's words is great here.}</p>

<p>Based on our conversation, I've put together a brief introduction and initial proposal for your review.<br>
I'd love to hear your thoughts once you've had a chance to look through them.</p>

<p>Looking forward to our next meeting on {date/time}.</p>

<p>Best regards,<br>
<b>{SENDER_NAME}</b><br>
{SENDER_TITLE} | {COMPANY_NAME}</p>

<p>{SENDER_PHONE}<br>
{SENDER_EMAIL} | <a href="{COMPANY_URL}">{COMPANY_URL}</a></p>
</div>
```

**Attachments**: Company intro PDF + proposal slides PDF

**Important**: NEVER use `send_gmail_message`. Use `draft_gmail_message` ONLY.

### Step 6: Git Commit & Push

```bash
git add {SALES_DIR}/proposals/... {SALES_DIR}/scripts/...
git commit -m "add: {prospect_name} proposal materials"
GH_TOKEN=$(gh auth token --user {GH_USER}) git push origin main
```

## Final Checklist

- [ ] Proposal is grounded in the prospect's actual words (not AI analysis/assumptions)
- [ ] Proposal has 7 sections or fewer
- [ ] Slides are 8 or fewer
- [ ] Email is ~150 words or less
- [ ] No jargon (unless the prospect used it)
- [ ] Tone is collaborative, not presumptuous
- [ ] Gmail draft created
- [ ] No confidential internal data (cost rates, margins) included

## Notes

- Gemini image generation uses `gemini-3.1-flash-image-preview` on `{GCP_PROJECT}` (must have Vertex AI API enabled)
- Rate limiting: 3-second intervals between slide generation
- **Never send emails** — draft creation only
- Never include internal cost/rate/margin information
