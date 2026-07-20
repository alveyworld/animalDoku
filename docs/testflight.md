# TestFlight Beta — Animal Doku

Runbook for [P7.2 TestFlight beta](../stories/phase-7/P7.2-testflight-beta.md).

**Marketing version:** `1.0` (`CFBundleShortVersionString`)  
**Build:** increment `CURRENT_PROJECT_VERSION` in Xcode before each upload  
**Bundle ID:** `com.animaldoku.AnimalDoku`  
**Export compliance:** `ITSAppUsesNonExemptEncryption = NO` (no non-exempt encryption)

## Engineering readiness (in-repo)

| Item | Status |
|------|--------|
| App icon (P5.4) | Required in archive |
| Privacy manifest (P7.1) | `App/PrivacyInfo.xcprivacy` |
| UI-test launch hooks | **DEBUG-only** (`AppLaunchConfiguration`) |
| Version scheme | Marketing `1.0`, build integer per upload |
| `ExportOptions.plist` | App Store Connect upload + automatic signing |
| Archive script | `scripts/archive-release.sh` |

## One-time App Store Connect setup (operator)

1. Enroll / sign in to [App Store Connect](https://appstoreconnect.apple.com) with the Apple Developer Program team.
2. Create the app record: name **Animal Doku**, bundle ID **com.animaldoku.AnimalDoku**, SKU of your choice.
3. In Xcode → Signing & Capabilities → AnimalDoku target: enable **Automatically manage signing**, select your **Team** (fills `DEVELOPMENT_TEAM`).
4. Confirm App Privacy answers match [`docs/app-privacy.md`](app-privacy.md) (**Data Not Collected**).

## Archive & upload

```bash
# Set once per shell (or configure the team in Xcode)
export DEVELOPMENT_TEAM=YOUR_TEAM_ID

# Archive + hygiene checks (icon / PrivacyInfo / version)
./scripts/archive-release.sh

# Or archive and upload in one step
./scripts/archive-release.sh --upload
```

Alternatively: **Product → Archive** in Xcode → **Distribute App → App Store Connect → Upload**.

After processing finishes in TestFlight, assign the build to groups.

## Groups & review

| Group | Action |
|-------|--------|
| **Internal** | Add team members; install immediately after processing |
| **External** | Create group, add testers, submit build for **Beta App Review** with the “What to Test” notes below |

Recommended order: internal first → fix blockers → external beta review.

## What to Test (paste into TestFlight)

```text
Animal Doku — beta checklist

Core loop
- [ ] Open Home, pick an Easy puzzle, play until win
- [ ] Tap empty cells to mark (X); double-tap to place/remove animal
- [ ] Drag across cells to paint/clear marks
- [ ] Undo / Redo / Reset / Hint
- [ ] Confirm win screen shows elapsed time; Play Again resets

Settings & a11y
- [ ] Change theme (Frogs / Dogs / Foxes)
- [ ] Toggle Sound, Haptics, High Contrast
- [ ] Rotate device — app stays portrait
- [ ] (Optional) VoiceOver: cell labels + Mark / Place actions

Devices
- Prefer one smaller phone (SE-class) and one large phone if available

Feedback
- Use TestFlight “Send Beta Feedback” (screenshot + note) for bugs
```

## Feedback & crash triage

1. App Store Connect → TestFlight → **Crashes** / **Feedback**.
2. File blockers against the relevant story (or a new bug story) before **P7.3**.
3. Expire a bad build in TestFlight; bump `CURRENT_PROJECT_VERSION` and re-upload.

### Triage log (fill during beta)

| Date | Source | Issue | Severity | Story / follow-up | Status |
|------|--------|-------|----------|-------------------|--------|
| | | | | | |

## Open decisions (P7.2)

1. Internal + external beta — **start internal, then external**.
2. First upload — **manual** (script or Organizer); automate CI later.

## GA gate before P7.3

- [ ] No crash-on-launch in beta pool
- [ ] No open P0/P1 from triage log
- [ ] Privacy answers + manifest still accurate
