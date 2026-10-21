# Worked examples

## 1. Final: gaming hybrid, three faces (the Super Battle Golf favourite)
Input to the planner:
```json
{
  "title": "Super Battle Golf",
  "videoType": "gaming-hybrid",
  "story": "Two players attack the one in the middle, who is still holding his golf club.",
  "people": [
    { "name": "Player A", "label": "img1", "role": "centre target, terrified, holding a golf club" },
    { "name": "Player B", "label": "img2", "role": "right, aiming a shotgun at the centre" },
    { "name": "Player C", "label": "img3", "role": "left, aiming a rocket launcher at the centre" }
  ],
  "references": [
    { "label": "img1", "role": "face" }, { "label": "img2", "role": "face" }, { "label": "img3", "role": "face" },
    { "label": "img4", "role": "world" }, { "label": "img5", "role": "world" }, { "label": "img6", "role": "world" },
    { "label": "img7", "role": "polish" },
    { "label": "img8", "role": "prop", "name": "shotgun" }
  ],
  "camera": "18–22 mm wide-angle lens from a low-to-medium camera height",
  "mustHaves": ["big cartoon explosion behind the centre player", "golf club clearly visible"]
}
```
Expected output shape (abridged): opening line → story in capitals ("TWO PLAYERS ATTACK THE ONE IN THE MIDDLE.") → CRITICAL REFERENCE HIERARCHY (img4–6 world; img7 polish; img1–3 faces, one person each; img8 shotgun) → COMPOSITION (img1 centre, img3 left foreground with launcher, img2 right foreground with shotgun, triangle) → one section each for golf club, rocket launcher, shotgun, explosion → ENVIRONMENT → CAMERA → LIGHTING AND COLOUR (same frontal light on all faces, no halos) → FACIAL IDENTITY → CRITICAL RESTRICTIONS ("Exactly THREE photographic human faces"; no text, logos, arrows; no gore; not dark) → FINAL TARGET. This is the structure of the original prompt that "nailed all 3 character references".

## 2. Fix: a small face that drifted (the McDonald's pair)
First final: Jay large in the foreground (perfect), Romell small inside a tent (weak likeness). Fix input:
```json
{
  "target": "the man inside the tent",
  "person": true,
  "copyExpression": true, "expressionNotes": "wide eyes looking sideways, open-mouth surprise",
  "copyPose": true, "heldItems": "the burger beside his face and the drink in his other hand",
  "keepList": "tent position and size, rooftop, Golden Arches, McDonald's building, city background, night sky, police cars",
  "othersList": "the man in the foreground (face, likeness, expression, shush gesture, clothing, pose, position, scale)",
  "controlledAspects": "identity, face, expression, gaze, head shape, hairstyle, facial hair, held items, hands and pose"
}
```
With @img1 = the first final and @img2 = Romell's best photo in that pose. The fix also enlarged him ("do not make him too small inside the tent"), which is the real cause of the drift.

## 3. Explore: title-first, style swap
```json
{ "title": "TGFbro stealth camping on top of McDonalds", "videoType": "irl-stunt",
  "people": ["Jay", "Romell"], "styles": ["tgfbro", "willne", "jayswingler", "sidemen"], "angles": 1 }
```
→ four short directions, one per style, 4 images each (16 images). In 1of10 this title ran 9 times across these 4 styles and 5 were kept; the best became the composition reference for the Magnific final.
