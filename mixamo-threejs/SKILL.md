---
name: mixamo-threejs
description: Use when bringing Mixamo characters and animations into a Three.js web page - downloading them from mixamo.com (incl. driving the site in Chrome), converting FBX to small GLB files, and playing the moves with AnimationMixer. Covers the gotchas that make Mixamo models invisible, frozen in T-pose or sitting in the air.
---

# Mixamo characters in Three.js

A worked pipeline (first built for ~/Projects/sandbox/agent-office: see its `tools/` and `public/office.js`).

## 1. Download (mixamo.com, needs the user's Adobe sign-in)
- The user signs in themselves. Adobe may show a "join team / skip" profile screen: that's their call.
- Decline optional cookies ("Don't Enable").
- Characters: FBX Binary, T-pose. Moves: FBX Binary, **Without Skin**, 30 fps, tick **In Place** for walks.
- Driving the page from JS works (`.product-character` / `.product-animation` cards, the `DOWNLOAD` buttons, the
  "USE THIS CHARACTER" confirm). Selects are React-controlled: set the value with the native setter
  (`Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype, 'value').set`) and dispatch `change`.
- Wait for the preview to load before clicking Download, one item at a time; keep each JS call under ~40 s.
- Chrome blocks the 3rd+ automatic download until the user allows "multiple downloads" for the site.
- Files land in ~/Downloads with names like `Ch07_nonPBR.fbx` (not the character's name): check who's who from
  rendered thumbnails before mapping anyone to a role. Mixamo's licence allows use, not redistribution: gitignore them.

## 2. Convert (in a browser page, no extra dependencies)
- FBXLoader → swap materials for `MeshStandardMaterial` with the diffuse map only → GLTFExporter
  (`binary: true, maxTextureSize: 512`, `texture.userData.mimeType = 'image/jpeg'` unless it needs alpha).
- **Wait for embedded textures to decode** after `loadAsync` (poll `texture.image.width`), or export fails with
  "No valid image data found".
- Moves: keep `.quaternion` tracks and the hips position (match `/Hips\.position$/`: rigs are named
  `mixamorig7Hips` etc.), keep every other keyframe, round values, cap long clips (~15 s), one JSON for all.
- Then shrink geometry: `npx -y @gltf-transform/cli@4 optimize in.glb out.glb --compress meshopt
  --texture-compress false --simplify-ratio 0.35 --simplify-error 0.002` (~10 MB → <1 MB). Load with
  `GLTFLoader().setMeshoptDecoder(MeshoptDecoder)` (three/addons/libs/meshopt_decoder.module.js). Gzip the JSON.

## 3. Play (gotchas, all seen for real)
- **Bone names carry a rig number** (`mixamorig7Hips` in moves vs `mixamorigHips` in models): strip
  `/^mixamorig\d+/` → `mixamorig` on both track names and bone names, or nothing binds (T-pose).
- **Each mesh has its own copy of the skeleton** after export (`Hips_1`, `Hips_2`): rebind every SkinnedMesh to one
  set of bones by base name (`mesh.bind(new Skeleton(mapped, mesh.skeleton.boneInverses), mesh.bindMatrix)`), or
  hair/clothes don't move.
- **Invisible people**: Mixamo flags most materials transparent; with an empty alpha channel `alphaTest` cuts
  everything. Keep alpha cut-outs only for hair/lashes/brows.
- Rig scales differ (one model ~180 units tall, another ~380): normalise height from the bounding box and rescale
  the hips position track by `modelHips.y / clipHips.y` per rig.
- Sitting moves lower the hips to Mixamo's chair height (~0.45 m); raise the model for higher seats (beanbags).
- Clone per instance with `SkeletonUtils.clone`; set `frustumCulled = false` on skinned meshes.
- Moves Mixamo lacks (eating, coughing, scratching): borrow one arm's tracks from a move that has the hand near the
  face (find the moment the forearm is furthest from rest), hold it (`timeScale = 0`) and blend it in by weight
  over the base move; the mixer averages by weight, so 8 against 1 is mostly the gesture.
- Check which hand a move uses before borrowing it (Mixamo's "Drinking" is left-handed).
