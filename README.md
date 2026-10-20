# Claude skills library

All 160 personal Claude Code skills, shared between Izaak's Macs. This list rebuilds itself after every change.

## How it works

- On each Mac, `~/.claude/skills` **is** this repo. Every 15 minutes a background job saves new or changed skills, pulls the other Mac's changes and pushes (`_sync/sync.sh`, log in `~/Library/Logs/claude-skills-sync.log`).
- Add a skill the normal way (ask Claude, or `npx skills add <repo> -g -a claude-code --copy`). It reaches the other Mac within about 15 minutes.
- Sync straight away: `bash ~/.claude/skills/_sync/sync.sh`.
- **Set up another Mac** (keeps the skills it already has and adds them here):

```bash
gh repo clone bloodbrothercreator/claude-skills /tmp/claude-skills && bash /tmp/claude-skills/_sync/setup-new-mac.sh
```

- Plugins, app plugins and connectors aren't folders, so they're listed in [PLUGINS.md](PLUGINS.md) with the commands to add them.
- `_references/` holds the shared files the LinkedIn skills read and write (your story bank and voice profile). It's linked to `~/.claude/references`.

## Skills by source

- [Ootto-AI/claude-content-skills](#ootto-aiclaude-content-skills) (53)
- [expo/skills](#exposkills) (21)
- [emilkowalski/skill](#emilkowalskiskill) (14)
- [RefoundAI/lenny-skills](#refoundailenny-skills) (12)
- [remotion-dev/skills](#remotion-devskills) (12)
- [sergebulaev/linkedin-skills](#sergebulaevlinkedin-skills) (12)
- [addyosmani/agent-skills](#addyosmaniagent-skills) (6)
- [phuryn/pm-skills](#phurynpm-skills) (6)
- [obra/superpowers](#obrasuperpowers) (5)
- [anthropics/skills](#anthropicsskills) (3)
- [neondatabase/agent-skills](#neondatabaseagent-skills) (3)
- [supabase/agent-skills](#supabaseagent-skills) (2)
- [blader/humanizer](#bladerhumanizer) (1)
- [coreyhaines31/marketingskills](#coreyhaines31marketingskills) (1)
- [Leonxlnx/taste-skill](#leonxlnxtaste-skill) (1)
- [morluto/rea](#morlutorea) (1)
- [openai/skills](#openaiskills) (1)
- [pbakaus/impeccable](#pbakausimpeccable) (1)
- [shadcn/ui](#shadcnui) (1)
- [TexasBedouin/vibe-check](#texasbedouinvibe-check) (1)
- [twostraws/SwiftUI-Agent-Skill](#twostrawsswiftui-agent-skill) (1)
- [vercel-labs/skills](#vercel-labsskills) (1)
- [Homemade or added by hand](#homemade-or-added-by-hand) (1)

### Ootto-AI/claude-content-skills

From [Ootto-AI/claude-content-skills](https://github.com/Ootto-AI/claude-content-skills).

- **`/ab-hook-tester`**: Generates two genuinely distinct hook variants for the same reel so you can post-test which…
- **`/ai-brain`**: Give Claude a permanent, searchable long-term memory using an Obsidian vault as the store
- **`/analytics-readout`**: Reads your reel insights and explains in plain English what to make more of and what to stop — no…
- **`/audience-personas`**: Build evidence-led social audience personas from customer interviews, comments, reviews, or CRM…
- **`/b-roll-shot-list`**: Turns a script into a shoot-ready shot list — every clip, angle and visual you need to film, in…
- **`/best-time-scheduler`**: Recommends the posting times and weekly cadence that fit your audience's actual activity windows
- **`/bio-profile-optimizer`**: Rewrites your bio, name field and pinned-reel order to convert profile visits into follows and…
- **`/campaign-brief`**: Use when a social campaign needs a decision-ready brief before anyone writes posts, books…
- **`/caption-and-hashtags`**: Write the caption, hashtag set, and first comment for a reel or post
- **`/carousel-builder`**: Turns one idea into a swipeable carousel — slide-by-slide copy, a slide 1 that stops the scroll…
- **`/collab-outreach`**: Drafts personalized pitches to creators and brands for collab reels, shoutouts and partnerships
- **`/comment-mining`**: Reads your comments and DMs to surface the questions, objections and exact phrases your audience…
- **`/comment-responder`**: Turn every comment into a lead on autopilot
- **`/community-engagement-plan`**: Use when a team needs a deliberate, human-led plan for participating in comments, communities, or…
- **`/competitor-positioning`**: Use when you need to compare supplied competitor messaging with your approved product facts and…
- **`/competitor-teardown`**: Reverse-engineers a rival account's best posts into the patterns, hooks, and posting cadence…
- **`/content-audit`**: Reviews your last 30 posts to find what is worth doubling down on, what is dead weight, and the…
- **`/content-calendar`**: Turn a batch of ideas (or your content pillars) into a 2-week reel posting calendar with hooks…
- **`/content-factory`**: The whole setup in one command — run the entire reel factory end to end
- **`/content-pillar-builder`**: Defines the 3-5 themes your account posts against, so every reel ladders up to a clear position
- **`/content-repurposer`**: Turn one long-form source (blog post, podcast, YouTube video, webinar, transcript) into a batch…
- **`/content-research`**: Turn Claude into a content research machine for any niche
- **`/cover-thumbnail-brief`**: Writes the cover-frame text and visual brief that makes your reel stop the scroll on the grid and…
- **`/creator-outreach`**: Use when a specific creator has been selected and you need a concise, personal…
- **`/cross-platform-distribution`**: Use when an approved campaign, launch, research finding, or asset needs a deliberate plan across…
- **`/cross-platform-reformatter`**: Reshapes one Instagram reel into a TikTok and a YouTube Short — adjusting hook, length and…
- **`/cta-writer`**: Writes the end-of-reel call to action that drives the exact next step — follow, DM a keyword…
- **`/dm-script-writer`**: Writes the DM flow that turns an inbound comment or lead-magnet request into a booked call or a sale
- **`/going-viral`**: The strategy layer for making short-form video actually go viral — pick the goal, manufacture the…
- **`/hashtag-keyword-research`**: Builds searchable, niche-fit hashtag and keyword sets so your reels surface in Explore and in search
- **`/hook-mining`**: Mine a CSV of REAL top-performing hooks and generate alternatives that keep what made them work…
- **`/influencer-partnerships`**: Use when you need to decide whether a creator partnership is appropriate and prepare a truthful…
- **`/launch-retrospective`**: Use after a social launch, campaign, creator collaboration, or distribution test has enough…
- **`/linkedin-thought-leadership`**: Use when a founder, operator, or subject-matter expert needs a credible LinkedIn point of view…
- **`/on-screen-text-writer`**: Writes the tight caption-style overlays that keep silent viewers watching to the end
- **`/paid-social-brief`**: Use when an approved social campaign needs a media-ready brief for paid distribution, creative…
- **`/positioning-audit`**: Audit a brand's social positioning from its profile, offer, customer proof, and competitor material
- **`/profile-conversion-audit`**: Use when an owned social profile needs an evidence-based audit of whether the right visitor can…
- **`/reel-analyzer`**: Feed Claude any viral reel (a link or a file) and it studies the whole thing — frame by frame…
- **`/reel-builder`**: Turn a teardown (or a rough idea) into a finished, ready-to-shoot reel
- **`/reel-scripter`**: Turn an idea or hook into a full 30-45 second reel script — hook, value beats, payoff, and CTA…
- **`/series-planner`**: Designs a recurring, named reel series — a repeatable format viewers come back for and follow so…
- **`/social-analytics-report`**: Use when you need to turn supplied social performance data into a decision about what to keep…
- **`/social-listening`**: Use when you need to turn a supplied set of comments, DMs, reviews, community posts, or call…
- **`/social-proof-mining`**: Use when you need to locate and prepare already-approved customer evidence for a social campaign…
- **`/story-sequencer`**: Plans a multi-frame Instagram Story arc with polls, questions and a clear tap-through to your…
- **`/trend-spotter`**: Scans what is breaking in your niche right now — formats, sounds, angles — and tells you which…
- **`/ugc-creator-brief`**: Writes a clear brief for a creator or freelancer to film a reel for you — hook, beats, dos and…
- **`/utm-campaign-plan`**: Use when a campaign needs a consistent, approved way to label links so the team can distinguish…
- **`/viral-carousel`**: Finds the carousels that actually went viral in your niche, fetches every slide, breaks down why…
- **`/viral-hook-writer`**: Write scroll-stopping hooks for a short-form video (the first 1-3 seconds)
- **`/virality`**: Plan, script and review short-form videos (Instagram Reels, TikTok, YouTube Shorts) so they…
- **`/x-thread-strategy`**: Use when a real lesson, analysis, launch explanation, or resource needs a structured X thread…

### expo/skills

From [expo/skills](https://github.com/expo/skills).

- **`/eas-app-stores`**: Build and submit iOS and Android apps with EAS to TestFlight, the App Store, or Google Play
- **`/eas-hosting`**: Deploy Expo websites and Expo Router API routes to EAS Hosting - export the web bundle, run eas…
- **`/eas-observe`**: Use for anything related to EAS Observe - adding `expo-observe` to an Expo project…
- **`/eas-simulator`**: Run and control a user's app on a remote iOS/Android simulator hosted on EAS cloud
- **`/eas-update-insights`**: Check the health of published EAS Update: crash rates, install/launch counts, unique users…
- **`/eas-update`**: Configure and use EAS Update for over-the-air JavaScript and asset updates with expo-updates and…
- **`/eas-workflows`**: Helps understand and write EAS workflow YAML files for Expo projects
- **`/expo-animation`**: Build animations in React Native and Expo, making the decisions in the order that determines…
- **`/expo-data-fetching`**: Use when implementing or debugging ANY network request, API call, or data fetching
- **`/expo-design-system`**: Build and maintain a design system inside an Expo app - a reusable theme of design tokens (color…
- **`/expo-dev-client`**: Build and distribute Expo development clients locally or via TestFlight for internal testing
- **`/expo-dom`**: Use Expo DOM components to run web code in a webview on native and as-is on web
- **`/expo-examples`**: Expo's official example projects - the expo/examples repo of ~70 `with-*` integrations (Stripe…
- **`/expo-module`**: Guide for creating and writing Expo native modules and views using the Expo Modules API (Swift…
- **`/expo-native-ui`**: Build beautiful, native-feeling Expo screens
- **`/expo-overview`**: Entry point and router for every Expo or EAS task
- **`/expo-project-structure`**: Folder structure for a new Expo app
- **`/expo-router`**: Navigation and routing for Expo Router
- **`/expo-ui`**: Build native UI with the @expo/ui package: real SwiftUI on iOS and Jetpack Compose on Android
- **`/expo-upgrade`**: Guidelines for upgrading Expo SDK versions and fixing dependency issues
- **`/expo-web-to-native`**: Migrate an existing web React app to a native iOS/Android app with Expo

### emilkowalski/skill

From [emilkowalski/skill](https://github.com/emilkowalski/skill).

- **`/animate-expo`**: Build animations in React Native and Expo, making the decisions in the order that determines…
- **`/animate`**: Build an animation from scratch, making the decisions in the order that determines whether it…
- **`/animation-performance`**: Keep web animations inside the frame budget — animate composite-only properties, keep motion off…
- **`/animation-vocabulary`**: Reverse-lookup glossary that turns a vague description of a web animation or motion effect into…
- **`/ask-sonner`**: Guide to Sonner, the React toast library — install and wire up the Toaster, pick the right…
- **`/break-ui`**: Try to break a piece of UI by feeding it worst-case data — long names, unbreakable emails…
- **`/emil-design-eng`**: This skill encodes Emil Kowalski's philosophy on UI polish, component design, animation…
- **`/find-animation-opportunities`**: Search a codebase or UI for places that don't animate but should, and reject everything that…
- **`/improve-animations`**: Survey a codebase's animation and motion code as a senior motion advisor, then produce a…
- **`/mobile-native`**: Make a web app feel native on a phone — the small CSS and meta-tag fixes that separate "a website…
- **`/pick-ui-library`**: Pick the right library for a given frontend task from a curated, opinionated list — numbers, OTP…
- **`/prototype`**: Build multiple genuinely different versions of a UI piece you describe, rendered behind a visual…
- **`/review-animations`**: Reviews animation and motion code against a high craft bar derived from Emil Kowalski's design…
- **`/write-swift`**: How to write modern Swift well — modeling with value types, Swift 6 data-race safety and…

### RefoundAI/lenny-skills

From [RefoundAI/lenny-skills](https://github.com/RefoundAI/lenny-skills).

- **`/customer-interviews`**: Help users conduct high-impact customer interviews that move beyond surface-level feature…
- **`/idea-validation`**: Help users de-risk new product bets by testing core assumptions, building low-fidelity…
- **`/launch-planning`**: Help users plan, coordinate, and execute product launches that cut through market noise
- **`/measuring-pmf`**: Help users objectively assess where their product stands on the PMF spectrum by triangulating…
- **`/north-star-metrics`**: Help users define, validate, and operationalize a North Star Metric that bridges the gap between…
- **`/positioning`**: Help users define the strategic context for their product by identifying the right competitive…
- **`/pricing-strategy`**: Help users validate willingness-to-pay, select the right value metrics, and continuously optimize…
- **`/referrals-word-of-mouth`**: Help users build sustainable growth engines by transitioning from accidental word-of-mouth to…
- **`/retention-engagement`**: Help users identify the drivers of long-term retention and implement behavioral mechanics that…
- **`/roadmap-prioritization`**: Help users move from reactive feature-building to strategic resource allocation by applying…
- **`/user-onboarding-activation`**: Help users reach their first moment of core value by optimizing the first-run experience…
- **`/writing-prds`**: Help users transform abstract ideas into actionable project specs that align engineering and…

### remotion-dev/skills

From [remotion-dev/skills](https://github.com/remotion-dev/skills).

- **`/remotion-best-practices`**: Router for all Remotion skills
- **`/remotion-captions`**: Transcribing, displaying and animating captions
- **`/remotion-create`**: Create a new Remotion video
- **`/remotion-docs`**: Search Remotion documentation
- **`/remotion-interactivity`**: Structure Remotion markup for interactivity
- **`/remotion-maps`**: Remotion Map animation knowledge
- **`/remotion-markup`**: Content, animation and effects best practices
- **`/remotion-multimedia`**: Interacting with Mediabunny
- **`/remotion-render`**: Export a Remotion video
- **`/remotion-saas`**: Build an app with Remotion
- **`/remotion-studio`**: Preview a Remotion video
- **`/remotion-upgrade`**: Upgrade Remotion, and related packages

### sergebulaev/linkedin-skills

From [sergebulaev/linkedin-skills](https://github.com/sergebulaev/linkedin-skills).

- **`/linkedin-comment-drafter`**: Draft a LinkedIn comment on someone else's post from its URL, or reshare (repost) it to your feed…
- **`/linkedin-content-planner`**: Generate a 7-day LinkedIn content plan from a theme, audience, and pillars
- **`/linkedin-employee-advocacy`**: Stand up and run a LinkedIn employee advocacy program for a marketing or sales team
- **`/linkedin-engager-analytics`**: Pull the people who liked or commented on any LinkedIn post and segment them by ICP fit (peer /…
- **`/linkedin-hook-extractor`**: Reverse-engineer the hook formula from a viral LinkedIn post URL. Returns which of the 20…
- **`/linkedin-humanizer`**: Remove AI tells from LinkedIn posts/comments: 2026 vocabulary density, reveal bridges, staccato…
- **`/linkedin-interviewer`**: Interview the user for the raw material their posts are made of
- **`/linkedin-post-writer`**: Draft a new LinkedIn post from scratch using one of 20 2026 hook formulas (anaphora, R.I.P.…
- **`/linkedin-profile-optimizer`**: Audit and rewrite a LinkedIn profile end-to-end for 2026: headline, About 7-step, Featured…
- **`/linkedin-reply-handler`**: Draft a reply to one LinkedIn comment from its URL, or sweep a whole thread from just the post…
- **`/linkedin-repurposer`**: Repurpose existing content into a native LinkedIn post
- **`/linkedin-thread-monitor`**: Track which of your LinkedIn comments earned author replies

### addyosmani/agent-skills

From [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).

- **`/api-and-interface-design`**: Guides stable API and interface design
- **`/ci-cd-and-automation`**: Automates CI/CD pipeline setup
- **`/frontend-ui-engineering`**: Builds production-quality, accessible, responsive user-facing UIs
- **`/performance-optimization`**: Optimizes application performance across frontend, backend, queries, and databases
- **`/security-and-hardening`**: Hardens code against vulnerabilities
- **`/shipping-and-launch`**: Prepares production launches

### phuryn/pm-skills

From [phuryn/pm-skills](https://github.com/phuryn/pm-skills).

- **`/create-prd`**: Create a lean, decision-ready Product Requirements Document with an 8-section template: summary…
- **`/interview-script`**: Create a structured customer interview script with JTBD probing questions, warm-up, core…
- **`/opportunity-solution-tree`**: Build an Opportunity Solution Tree (OST) to structure product discovery — map a desired outcome…
- **`/pre-mortem`**: Run a pre-mortem risk analysis on a PRD or launch plan
- **`/prioritize-features`**: Prioritize a backlog of feature ideas based on impact, effort, risk, and strategic alignment with…
- **`/user-stories`**: Create user stories following the 3 C's (Card, Conversation, Confirmation) and INVEST criteria…

### obra/superpowers

From [obra/superpowers](https://github.com/obra/superpowers).

- **`/brainstorming`**: Use this before any creative work - creating features, building components, adding functionality…
- **`/subagent-driven-development`**: Use when executing implementation plans with independent tasks in the current session
- **`/systematic-debugging`**: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
- **`/using-superpowers`**: Use when starting any conversation - establishes how to find and use skills, requiring skill…
- **`/writing-plans`**: Use when you have a spec or requirements for a multi-step task, before touching code

### anthropics/skills

From [anthropics/skills](https://github.com/anthropics/skills).

- **`/canvas-design`**: Create beautiful visual art in .png and .pdf documents using design philosophy
- **`/frontend-design`**: Guidance for distinctive, intentional visual design when building new UI or reshaping an existing…
- **`/webapp-testing`**: Toolkit for interacting with and testing local web applications using Playwright

### neondatabase/agent-skills

From [neondatabase/agent-skills](https://github.com/neondatabase/agent-skills).

- **`/neon-auth`**: Add authentication to a new app
- **`/neon-object-storage`**: S3-compatible object storage that branches with your database, so each branch gets its own copy…
- **`/neon-postgres-branches`**: Choose and create the right Neon branch type for testing and development

### supabase/agent-skills

From [supabase/agent-skills](https://github.com/supabase/agent-skills).

- **`/supabase-postgres-best-practices`**: Postgres best practices maintained by Supabase, for Postgres running anywhere
- **`/supabase`**: Use when doing ANY task involving Supabase

### blader/humanizer

From [blader/humanizer](https://github.com/blader/humanizer).

- **`/humanizer`**: Rewrite AI-sounding text so it reads like the writer without changing what it says

### coreyhaines31/marketingskills

From [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills).

- **`/copywriting`**: When the user wants to write, rewrite, or improve marketing copy for any page, including…

### Leonxlnx/taste-skill

From [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill).

- **`/design-taste-frontend`**: tasteskill v2, the anti-slop frontend skill

### morluto/rea

From [morluto/rea](https://github.com/morluto/rea).

- **`/reverse-engineer-anything`**: Reverse engineer native, managed, Electron/JavaScript, packaged, firmware, and browser targets…

### openai/skills

From [openai/skills](https://github.com/openai/skills).

- **`/security-threat-model`**: Repository-grounded threat modeling that enumerates trust boundaries, assets, attacker…

### pbakaus/impeccable

From [pbakaus/impeccable](https://github.com/pbakaus/impeccable).

- **`/impeccable`**: Use when the user wants to design, redesign, shape, critique, audit, polish, simplify, harden…

### shadcn/ui

From [shadcn/ui](https://github.com/shadcn/ui).

- **`/shadcn`**: Manages shadcn components and projects — adding, searching, fixing, debugging, styling, and…

### TexasBedouin/vibe-check

From [TexasBedouin/vibe-check](https://github.com/TexasBedouin/vibe-check).

- **`/vibe-check`**: Turn a complete beginner's app idea into a buildable plan, then keep them oriented while they build

### twostraws/SwiftUI-Agent-Skill

From [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill).

- **`/swiftui-pro`**: Comprehensively reviews SwiftUI code for best practices on modern APIs, maintainability, and…

### vercel-labs/skills

From [vercel-labs/skills](https://github.com/vercel-labs/skills).

- **`/find-skills`**: Helps users discover and install agent skills when they ask questions like "how do I do X", "find…

### Homemade or added by hand

Made for BBM, or added without the installer.

- **`/apple-design`**: Apple's approach to interface design and fluid, physical motion, translated for the web
