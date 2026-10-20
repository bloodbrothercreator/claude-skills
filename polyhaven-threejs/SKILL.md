---
name: polyhaven-threejs
description: Use when a Three.js scene needs realistic free (CC0) furniture, props or surface textures - finding them on Poly Haven through its API, downloading and shrinking them for the web, and swapping them in without breaking a stylised fallback.
---

# Poly Haven assets in Three.js

Worked example: ~/Projects/sandbox/agent-office (`tools/fetch-env.sh`, `prop`/`fillProps`/`applySurfaces` in `public/office.js`).

## Find
- Everything is CC0, no account. List: `curl -s "https://api.polyhaven.com/assets?t=models"` (or `t=textures`),
  each with `categories`. Files: `curl -s https://api.polyhaven.com/files/<id>` → `gltf['1k']['gltf']` (url plus an
  `include` map of .bin/texture files) or, for textures, `Diffuse` / `nor_gl` / `Rough` → `['1k']['jpg']`.
- Use curl: the API returns 403 to Python's default urllib user agent.
- Model file listings also carry texture keys, so tell models and textures apart by your own list, not by keys.
- Look before you trust a name: "painted_concrete" is worn green paint; some "plant" assets are spread-out patches of
  many plants (calathea, pachira). Render a contact sheet with sizes and a +Z arrow before placing anything.
- Poly Haven has no modern office desks or office chairs; plan to keep your own for those.

## Shrink (88 MB → under 10 MB for ~35 models + 9 texture sets)
- Models: `npx -y @gltf-transform/cli@4 optimize in.gltf out.glb --compress meshopt --texture-compress webp
  --texture-size 512` (WebP works out of the box). Load with `GLTFLoader().setMeshoptDecoder(MeshoptDecoder)`.
- Textures: `sips -s format jpeg -s formatOptions 80 -Z 512` (macOS built-in).
- Mention the total download size and ask before downloading.

## Place
- Models face +Z with their base at their own bounding-box minimum. Fit them by a target width or height
  (scale from the box), and allow width + height together to stretch e.g. a too-tall table to desk height.
- Keep a stylised fallback: build the old block piece in a `pixelOnly` group and a `prop` placeholder next to it;
  fill placeholders when the GLBs arrive and toggle visibility. With the files missing, the scene still works.
- Surfaces: tag procedural canvas textures with what they depict (planks, tiles, speckle, wallpaper) and swap in a
  matching PBR set (map + normalMap + roughnessMap, repeat per surface) tinted towards the original colour
  (`lerp(white, 0.45)`). Tell floors from walls by bounding-box height. Mid-tone wall textures need a brightness
  boost (`color.multiplyScalar(1.6)`) or they read as grey.
