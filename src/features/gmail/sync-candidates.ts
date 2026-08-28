import type { GmailHistory } from "./api";

export function changedThreadCandidates(history: GmailHistory[], replioLabelId: string) {
  const candidates = new Map<string, boolean>();
  for (const item of history) {
    for (const added of item.messagesAdded ?? []) {
      const selected = added.message.labelIds?.includes(replioLabelId) ?? false;
      candidates.set(added.message.threadId, (candidates.get(added.message.threadId) ?? false) || selected);
    }
    for (const labelled of item.labelsAdded ?? []) {
      const selected = labelled.labelIds?.includes(replioLabelId) || labelled.message.labelIds?.includes(replioLabelId) || false;
      candidates.set(labelled.message.threadId, (candidates.get(labelled.message.threadId) ?? false) || selected);
    }
  }
  return candidates;
}
