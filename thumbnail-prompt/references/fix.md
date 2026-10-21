# Fix: targeted correction template

Based on Izaak's correction prompt for the McDonald's thumbnail, which turned a weak second face into a keeper. Fill the `{}` slots; send @img1 = the image to fix, @img2 = the correct reference (and @img3 for a second reference if needed). Render with GPT Image 2 edit at high.

---

Use @img1 as the base thumbnail and preserve its overall composition.
Use @img2 as the EXACT visual reference for {target}.

This is a targeted correction.

MOST IMPORTANT INSTRUCTION
{target} in @img1 does not match @img2 closely enough. Replace {target}'s appearance in @img1 so that it closely matches @img2.
Do not loosely reinterpret @img2. Do not create a similar-looking {person|object}.

{IF person}
MATCH @img2
Match exactly: facial likeness, face shape, haircut and hairline, eyebrows, eyes, nose, mouth shape, facial hair, skin tone and facial proportions.
{IF copyExpression} Copy the expression and gaze from @img2: {expressionNotes}. Do not invent a different expression. {END}
{IF copyPose} Copy the pose and hand positions from @img2, including {heldItems}. {END}
SCALE
Do not make {target} small. Keep the face large enough that the identity and expression read clearly at thumbnail size.
{END}

{IF object}
MATCH @img2
Match its shape, proportions, colours, details and design language exactly. Do not make it generic.
{END}

PRESERVE @img1
Keep everything else in @img1 almost identical: 16:9 composition, camera angle, lighting, colours, background, {keepList}.
Do not change {othersList}. Do not regenerate or alter them.

REFERENCE PRIORITY
@img1 controls: composition, environment, lighting, camera angle, {othersList}.
@img2 controls all aspects of {target}: {controlledAspects}.
If @img1 and @img2 conflict regarding {target}, FOLLOW @img2.

Do not add text, logos, arrows or borders.

FINAL RESULT
The image should look essentially identical to @img1, except {target} now matches @img2 as closely as possible.
