# Branding Assets (P5.4)

## App icon

| Item | Path |
|------|------|
| Catalog entry | `Assets.xcassets/AppIcon.appiconset` |
| Source | `AppIcon.png` (1024×1024, opaque RGB, no alpha) |

Xcode generates all required iPhone home-screen sizes from the single 1024×1024 marketing icon (`idiom: universal`, `platform: ios`).

### Updating the icon

1. Export a **1024×1024** PNG with **no transparency**.
2. Soft pastel palette; motif readable at ~60pt (frog on a soft puzzle board).
3. Replace `AppIcon.appiconset/AppIcon.png` and keep `Contents.json` filename in sync.
4. Archive and validate in Xcode Organizer — confirm no missing-icon warnings.

## Launch screen

| Item | Path |
|------|------|
| Storyboard | `App/LaunchScreen.storyboard` |
| Background color | `Assets.xcassets/LaunchBackground.colorset` |
| Logo | `Assets.xcassets/LaunchLogo.imageset` |

Centered logo + “Animal Doku” wordmark on the cream GDD background. Static only (no animation).

Project setting: `INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen`.
