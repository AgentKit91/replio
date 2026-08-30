export const dealStates = {
  new: { label: "Needs review", detail: "A new labelled conversation is ready for you." },
  reviewing: { label: "Reviewing", detail: "You are reviewing the opportunity." },
  negotiating: { label: "Negotiating", detail: "The commercial terms are being worked through." },
  awaiting_brand: { label: "Waiting on brand", detail: "You have replied. The brand has the next move." },
  awaiting_creator: { label: "Your reply needed", detail: "The brand has replied and is waiting for you." },
  agreed: { label: "Agreement reached", detail: "Terms are agreed; delivery can begin." },
  declined: { label: "Declined", detail: "You chose not to proceed." },
  lost: { label: "Did not proceed", detail: "The opportunity closed without an agreement." },
  completed: { label: "Work complete", detail: "The collaboration is complete." },
  archived: { label: "Archived", detail: "This deal is archived." },
} as const;

export type DealState = keyof typeof dealStates;

export function dealState(value: string) {
  return dealStates[value as DealState] ?? dealStates.new;
}
