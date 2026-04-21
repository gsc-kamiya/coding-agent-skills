---
name: generate-slides
description: Generate professional business slides using Gemini image generation and combine them into a PDF
argument-hint: "[slide count] [output directory]"
---

# Slide Generation (Gemini Image Generation)

Use Gemini's multimodal generation to create presentation slide images and combine them into a PDF.

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md` or environment:

| Variable | Description | Example |
|:--|:--|:--|
| `{GCP_PROJECT}` | Google Cloud project ID | `my-gcp-project` |
| `{COMPANY_NAME}` | Company name for slide footer | `Acme Corp` |
| `{COLOR_PRIMARY}` | Primary color (hex) | `#1A365D` |
| `{COLOR_ACCENT}` | Accent color (hex) | `#0D9488` |
| `{COLOR_BACKGROUND}` | Background color (hex) | `#F7FAFC` |

---

## Arguments

- `$0`: Number of slides (optional: determined from context if omitted)
- `$1`: Output directory (optional: defaults to current directory)

## Model Selection

- **Recommended**: `gemini-3.1-flash-image-preview` (fast, cost-efficient)
- **High quality**: `gemini-3-pro-image-preview` (best text rendering quality)
- **Region**: `global` (required; other regions are not supported)

## Design Standards

| Item | Value |
|:--|:--|
| Primary color | `{COLOR_PRIMARY}` (default: Dark blue `#1A365D`) |
| Accent color | `{COLOR_ACCENT}` (default: Teal `#0D9488`) |
| Background color | `{COLOR_BACKGROUND}` (default: Light gray `#F7FAFC`) |
| Aspect ratio | 16:9 |
| Font | Sans-serif / Gothic |
| Footer | `{COMPANY_NAME} | Confidential` left, page number right |

## Execution Steps

### Step 1: Determine Slide Structure

Design slide structure from user instructions/context. If no instructions are given, use this standard business slide structure:

```
1. Title slide
2. Problem statement
3. Solution overview
4. System architecture / Technical approach
5. Workflow (Before/After)
6. Technical details
7. Pricing / Plans
8. ROI / Investment value
9. Roadmap
10. Team overview
11. Next steps
12. Closing
```

### Step 2: Generate Script

Create `generate_slides.py` in the output directory:

```python
#!/usr/bin/env python3
"""Slide generation script"""
import sys
import time
from pathlib import Path
from io import BytesIO

from google import genai
from google.genai.types import GenerateContentConfig, Modality
from PIL import Image

client = genai.Client(
    vertexai=True,
    project="{GCP_PROJECT}",
    location="global"
)

MODEL = "gemini-3.1-flash-image-preview"
OUTPUT_DIR = Path("{output_directory}")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

COMMON_STYLE = """
Style requirements:
- Professional business presentation slide
- Clean, modern design with plenty of white space
- Color palette: {COLOR_PRIMARY} primary, {COLOR_ACCENT} accent, {COLOR_BACKGROUND} background
- Text rendered clearly and accurately in sans-serif font
- 16:9 aspect ratio (1920x1080)
- Footer: "{COMPANY_NAME} | Confidential" on left, page number on right
- CRITICAL: Do NOT add any company names, logos, or text that is not explicitly listed below.
"""

SLIDES = [
    # (filename, prompt)
    # Define each slide's prompt here
]

def generate_slide(prompt: str, output_path: Path) -> bool:
    try:
        response = client.models.generate_content(
            model=MODEL,
            contents=f"Generate an image of {prompt}\n{COMMON_STYLE}",
            config=GenerateContentConfig(
                response_modalities=[Modality.TEXT, Modality.IMAGE],
            )
        )
        for part in response.candidates[0].content.parts:
            if part.inline_data:
                image = Image.open(BytesIO(part.inline_data.data))
                image.save(output_path)
                print(f"  OK: {output_path}")
                return True
        print(f"  WARN: No image in response for {output_path}")
        return False
    except Exception as e:
        print(f"  ERROR: {e}")
        return False

def combine_to_pdf(slides_dir: Path, output_pdf: Path):
    images = []
    for f in sorted(slides_dir.glob("slide_*.png")):
        img = Image.open(f)
        if img.mode == 'RGBA':
            img = img.convert('RGB')
        images.append(img)
    if images:
        images[0].save(output_pdf, "PDF", save_all=True, append_images=images[1:], resolution=150)
        print(f"PDF generated: {output_pdf} ({len(images)} pages)")

if __name__ == "__main__":
    # To regenerate specific slides: python generate_slides.py 3 5 7
    target_indices = [int(x) - 1 for x in sys.argv[1:]] if len(sys.argv) > 1 else range(len(SLIDES))

    for i in target_indices:
        if 0 <= i < len(SLIDES):
            filename, prompt = SLIDES[i]
            print(f"[{i+1}/{len(SLIDES)}] {filename}")
            generate_slide(prompt, OUTPUT_DIR / filename)
            time.sleep(3)  # Rate limit buffer

    combine_to_pdf(OUTPUT_DIR, OUTPUT_DIR / "slides.pdf")
```

### Step 3: Execute Script

```bash
python3 {output_directory}/generate_slides.py
```

### Step 4: Quality Check

Visually inspect generated slide images:
- Check for hallucinated text (unintended company names, numbers)
- Verify text renders correctly
- Check design consistency

Regenerate problematic slides only:
```bash
python3 generate_slides.py 3 7  # Regenerate slides 3 and 7
```

## Requirements

- Python 3.11+
- `pip install google-genai pillow`
- Access to a Google Cloud project (ADC authentication configured)
- Vertex AI API enabled

## Notes

- Rate limiting: Allow 3 seconds between requests
- `location="global"` is required
- On auth errors: Re-authenticate with `gcloud auth application-default login`
- Always include "CRITICAL: Do NOT add any company names, logos, or text that is not explicitly listed below." in all prompts
