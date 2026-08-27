# UX and Design System

## Design intent

Replio must feel calm, premium, confident and deliberately designed by a human product team. It must **not** look like a default AI-generated SaaS template. AI should be present through useful results, not through glowing chat boxes, fake thinking animations or novelty gradients.

## Visual rules

- Generous whitespace is functional, not decorative.
- Information density stays low; deeper information is available on demand.
- Typography and hierarchy do most of the work.
- Use one accent system sparingly; colour should encode state/priority, not decorate every card.
- Avoid `card soup`: group related content into coherent surfaces rather than wrapping every value in a rounded rectangle.
- Avoid gratuitous gradients, glassmorphism, giant icons and chatbot conventions.
- Use restrained animation only for state continuity/feedback.
- Do not show fake AI progress steps.
- Never leave a user wondering whether an action registered.

## Component implementation

**Implementation choice:** Tailwind CSS plus accessible primitives (Radix/shadcn or equivalent) is acceptable, but library defaults are not the design. Re-style primitives into a bespoke Replio design system.

Create tokens for:

- spacing;
- type scale;
- radii;
- shadows;
- border/subtle surface values;
- semantic states (action, opportunity, risk, success, neutral);
- motion durations/easing;
- desktop/mobile breakpoints.

Do not freeze a brand colour palette in code until brand assets are confirmed. Keep accent tokens configurable.

## Core responsive layouts

### Desktop

- Persistent left navigation.
- Dashboard centered with comfortable max-width.
- Deal Workspace uses primary analysis pane + conversation pane.
- Founder OS may use denser data surfaces than creator UI but must remain calm.

### Mobile

- Full customer journey must work; no `desktop required`.
- Deal Workspace becomes logical tabs/stacked sections: `Advice` / `Conversation`, with sticky reply access where helpful.
- Avoid horizontal data tables; use responsive records/cards for lists.
- Primary action remains reachable with one hand.

## Accessibility

**Implementation choice:** target WCAG 2.2 AA.

- semantic HTML;
- keyboard operability;
- visible focus;
- sufficient contrast;
- accessible labels/errors;
- reduced motion support;
- screen-reader meaningful statuses;
- no colour-only meaning.

## Perceived performance

- Navigation/data already available should render instantly from server/cache.
- Optimistically acknowledge safe local edits.
- If analysis is running, show a quiet real status such as `Preparing your commercial analysis…` while the rest of the Deal remains usable.
- Progressive AI sections may appear as their validated snapshots complete.
