# Google OAuth verification evidence pack

Status: prepared, not submitted. Replio remains External / Testing with one approved test user.

## Console audit (1 September 2026)

- Google Cloud project: `replio-auth-2026`.
- Branding has the app name and support/developer email, but no homepage, Privacy Policy URL, Terms URL or logo.
- Data Access currently declares no scopes. This must be corrected before submission.
- Audience is External / Testing. Verification Center therefore says verification is not required yet.
- Google reports too few project owners/editors.

## Exact scope

Declare only `https://www.googleapis.com/auth/gmail.modify`.

Replio uses it to list/create the `Replio` label; create a label-filtered Gmail watch; read only threads selected with that label; keep later replies in the same Deal; prepare an editable reply; and send only after a separate explicit confirmation. Replio does not request `mail.google.com` and does not scan the whole inbox.

The scope is restricted. Because selected Gmail content is stored and transmitted through Replio's server-side infrastructure, public launch is expected to require Google's restricted-scope verification and an annual third-party security assessment. Closed beta must remain limited to explicitly approved test users until Google approves production access.

## Required public disclosures

The approved Privacy Policy must be on the same owned and verified domain as the app homepage, linked from both the homepage and OAuth consent screen, and state:

> Replio’s use and transfer of information received from Google APIs adheres to the Google API Services User Data Policy, including the Limited Use requirements.

It must accurately disclose the selected-thread data, purposes, processors, retention/deletion, human-access exceptions, and that Google user data is not used for advertising, credit decisions, or training generalised AI/ML models.

## Scope justification for the submission form

Replio is a creator-negotiation assistant. A user deliberately selects a commercial Gmail conversation by applying the `Replio` label. The application uses `gmail.modify` to create/list that label, establish an INCLUDE-filtered watch, retrieve the selected thread, preserve the thread as one Deal, and send a user-reviewed reply only after explicit confirmation. Read access, label management and sending are inseparable parts of this user-facing workflow; the narrower read-only or send-only scopes cannot provide it. Replio neither scans unlabelled mail nor requests permanent-delete access.

## Demonstration video shot list

Record one continuous English-language video showing:

1. The public Replio homepage and linked Privacy Policy.
2. Sign-in, Connect Gmail and the complete Google consent screen with the project/app identity and requested scope visible.
3. Gmail with an ordinary unlabelled message that does not appear in Replio.
4. Applying the `Replio` label to the synthetic test thread.
5. The same thread appearing as one Replio Deal and displaying source-grounded evidence.
6. Starting analysis and showing the editable advice/draft.
7. Editing the draft, reaching the explicit send-confirmation boundary, then confirming with a test recipient.
8. The reply in Gmail's Sent/thread view.
9. Disconnecting Gmail and the account/deal deletion controls.

Use synthetic data and a test recipient; do not expose real creator or brand data.

## Submission sequence

1. Approve and publish legal pages on an owned custom domain.
2. Verify that domain in Google Search Console and add it to Authorized domains.
3. Add the homepage, Privacy Policy, Terms and approved 120x120 logo in Branding.
4. Add `gmail.modify` in Data Access and save.
5. Add a second appropriate project owner/editor and confirm both contacts.
6. Complete the synthetic Gmail E2E and record the video.
7. Move Audience from Testing to Production, open Verification Center, prepare verification, enter the scope justification and video link, and submit.
8. Complete Google's follow-up and the required security assessment. Do not admit non-test beta users until approved.

## Founder/external actions still required

- Choose or purchase the Replio custom domain and verify ownership.
- Approve the final legal text and brand logo.
- Identify the second Google project owner/editor account.
- Authorise the synthetic Gmail data transmission and later the real test send used in the video.
- Approve moving the OAuth app to Production and submitting it.
- Select and pay an approved security assessor if Google confirms the restricted-scope assessment requirement.


