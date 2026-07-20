# App Privacy — Animal Doku

Companion to [P7.1 Privacy manifest](../stories/phase-7/P7.1-privacy-manifest.md).
Source of truth in the binary: `App/PrivacyInfo.xcprivacy`.

**Date:** 2026-07-19  
**App Store posture:** **Data Not Collected**

## Manifest summary

| Key | Value |
|-----|-------|
| Tracking | `false` (no tracking domains) |
| Collected data types | none (empty) |
| Required-reason APIs | UserDefaults `CA92.1`; System Boot Time `35F9.1` |

### Required-reason API mapping

| API category | Reason | Why declared |
|--------------|--------|----------------|
| `NSPrivacyAccessedAPICategoryUserDefaults` | `CA92.1` | `SettingsStore` persists theme / sound / haptics / high contrast / tutorial locally |
| `NSPrivacyAccessedAPICategorySystemBootTime` | `35F9.1` | `TimerService` / `SystemClock` uses `ProcessInfo.systemUptime` for on-device elapsed play time |

**Not used (no declaration):** File Timestamp, Disk Space, Active Keyboards.

## Third-party SDKs

v1.0 ships **no** SPM / CocoaPods / binary SDKs. No third-party privacy manifests to merge.

## App Store Connect — App Privacy answers

Enter these in App Store Connect → App Privacy (used again in P7.3):

1. **Do you or your third-party partners collect data from this app?** → **No** (“Data Not Collected”).
2. **Tracking** → No (app does not track users across apps/websites).
3. No privacy nutrition-label data categories to list.

### Notes for reviewers / future features

- Local save games (`SaveGameStore`) are device-only JSON files; not “collected” off-device.
- Elapsed time stays on device (win screen / save); boot time itself is never sent anywhere (app is offline).
- If cloud save, analytics, or accounts are added later, update `PrivacyInfo.xcprivacy` and this doc before shipping.

## Privacy policy URL

A hosted privacy policy page is **deferred to P7.3** (App Store submission). For an all-ages, no-data app it may still be wise to publish a short static page at submission time.

## Validation

```bash
plutil -lint App/PrivacyInfo.xcprivacy
xcodebuild test -scheme AnimalDoku \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -only-testing:AnimalDokuTests/PrivacyManifestTests
```

Archive validation (Organizer) should report no privacy-manifest warnings once signing is available for upload.
