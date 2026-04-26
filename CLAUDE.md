# Levitas — Project Instructions

## Brand Guidelines

Always respect the Levitas brand book (see `Levitas Brand Book.pdf` in this folder).

### Colors
- **Primary dark blue:** `#324051` — use for backgrounds, headers, primary UI elements
- **Accent blue:** `#54748D` — use for highlights, icons, secondary elements
- No other brand colors. Do not introduce grays, greens, or other palettes without discussion.

### Typography
- **Primary font:** Buttershine Serif — headings, display text, marketing copy
- **Secondary font:** Garet Book — body text, UI labels, form fields, navigation
- Do not substitute other fonts.

### Logo Rules
- Never distort, squeeze, rotate, or recolor the logo
- Never add drop shadows or change spacing
- Never change the typeface in the logo
- Always maintain the exclusion/protection zone around the logo

### Tone of Voice
- Professional but approachable — expert without being cold
- Friendly and empathetic — acknowledge complexity, offer clarity
- Transparent and honest — straightforward communication
- Trustworthy — emphasize reliability and security

### Brand Values
Efficiency · Innovation · Customer Service · Transparency · Diversification · Competitiveness

---

## Deployment

- Stack: Ruby on Rails 7, PostgreSQL, Redis, Sidekiq
- Deployed on Unraid at `http://10.0.1.73:3001`
- Deploy workflow: push to `master` → GitHub Actions builds → pushes to `ghcr.io/philipusgood/levitas:latest` → Update All in Compose Manager on Unraid
