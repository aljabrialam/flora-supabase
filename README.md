# fLora (Supabase edition)

Send flowers that bloom. Build a 3D bouquet, write a card, add stickers and a photo, and send it as one short link. The recipient opens a sealed envelope and the bouquet blooms on their screen.

Made by [Aljabri Alam](https://www.linkedin.com/in/aljabri-alam/). Based on [flora](https://github.com/aljabrialam/flora).

## Features

- **Short links**: "Send flowers" saves the card to Supabase and gives `/?c=<id>` (10-char random base32 from `crypto.getRandomValues`). If Supabase can't be reached, it falls back to the original `#g…` link, which carries the whole card in the hash.
- **Photo**: attach 1 photo. It's shrunk in the browser (max 1600px JPEG, quality 0.8, under 1.5 MB), uploaded to the `card-photos` bucket at `<id>/<random>.jpg`, and shown to the recipient as a polaroid after the bloom.
- **Opened receipt**: when the recipient taps the seal, `opened_at` is recorded once. The sender sees "Opened" under **My sent flowers** (the envelope button in the top bar). Ids are kept in `localStorage`.
- **Send flowers back**: the recipient's "Make your own" pre-fills To with the sender's name and saves `reply_to` = the original card id.

## Setup

1. Create a Supabase project and run the SQL from the comment block at the top of `index.html` in the SQL editor.
2. Paste your project URL and **anon** key into `SUPABASE_URL` / `SUPABASE_ANON_KEY` at the top of the module script in `index.html`. Never use the service-role key.
3. Deploy as a static site (e.g. Vercel). No build step.

Run locally: `python3 -m http.server 5173` and open http://localhost:5173.

## Stack

`index.html` holds the whole app: three.js r167 with pmndrs/postprocessing and N8AO for the 3D bouquet, motion.dev for the interface, supabase-js v2.45.4 from jsDelivr.
