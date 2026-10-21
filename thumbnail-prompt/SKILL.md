---
name: thumbnail-prompt
description: >
  Writes YouTube thumbnail image prompts in Blood Brother Media's proven house format for GPT Image 2,
  Magnific, Nano Banana or the Thumbnail Studio prototype: the long structured "Final" brief (one job per
  reference picture, face-identity rules, composition, props, camera, lighting, restrictions, final target),
  quick title-first "Explore" directions, a targeted "Fix" correction prompt for one person or prop in an
  existing thumbnail, and a review checklist. Use whenever Izaak or the team want a thumbnail prompt, want to
  turn a video title or 1of10 idea into a Magnific prompt, need to fix a face or prop that came out wrong,
  ask "write the prompt for this thumbnail", mention @img references, face swaps onto game characters,
  TGFbro / Jay and Romell thumbnails, or are building the Thumbnail Studio's planner, even if they don't say
  "skill". Not for Instagram reel covers (that's cover-thumbnail-brief).
---

# Thumbnail prompt

This captures what made Izaak's best thumbnails work: 11 favourite Magnific results (all GPT Image 2 at high quality with plain reference photos, where the prompt did the work) and 579 1of10 generations. Background lives in the ideas repo: `exports/2026-10-21-thumbnail-teardown-v2.md` and `exports/2026-10-21-thumbnail-brain-v1/`.

## Pick the mode
- **Final**: they have a title or idea, people, and reference pictures, and want the real thumbnail. Read `references/planner.md` and write the prompt in that format. Most requests are this.
- **Explore**: they only have a title (or want several directions, styles or camera angles). Read `references/explore.md`.
- **Fix**: a thumbnail is nearly right but one face or prop is off. Read `references/fix.md`.
- **Review**: they want a generated image checked. Read `references/reviewer.md` and look at the image against the brief and face photos.

`references/menu.json` lists the video types, reference roles, story patterns, layouts and camera presets to offer as choices. `references/examples.md` has worked inputs.

## Gather the inputs (ask only for what's missing)
1. Title or what the video is about, and the game if it's gaming.
2. Who's in it, and which uploaded picture is each person's face. One picture per person.
3. Every other reference picture and its job: composition (an inspiration thumbnail, often from 1of10), world/gameplay, thumbnail polish (a house thumbnail), character or monster, prop, product, environment.
4. The story in one line. If they don't have one, suggest three from `storyPatterns` in the menu and let them pick.

Number the references as Magnific will: `@img1`, `@img2`… in upload order. If you don't know the order, ask, because every rule in the prompt hangs on those labels.

## Why the format works (keep these even when shortening)
- **One job per picture, stated with "ONLY".** GPT Image 2 blends everything it's shown; naming each picture's job stops an inspiration thumbnail's faces or a gameplay HUD leaking in.
- **One face per picture, and "never use faces from the other references".** This is the main thing that kept three-person thumbnails accurate.
- **Big faces.** Likeness drifts when a face is small or far away (the tent face needed a fix pass). Give the main face 35–45% of the frame and keep the others readable.
- **Emotion through eyes, posture and hands**, not stretched mouths or giant eyes, so identity survives.
- **Same frontal light on every face, no halos or rim glows.** Izaak added this after outlines appeared around heads.
- **Exact counts and a "Do not" list.** Models add extra people and text unless told not to.
- **Story in capitals at the start and a final-target paragraph at the end** keep the image about one readable idea.

## Output
Give the prompt in a single code block so it can be pasted straight into Magnific or the studio, then one or two lines on which settings to use (GPT 2 / GPT Image 2, high for finals, 16:9, one image) and the reference order it assumes. Keep finals under about 9,500 characters, since Magnific cuts prompts at 10,000.

Faces are only for people BBM works with who've agreed. If someone asks for a real person who isn't BBM talent, say so and leave them out.
