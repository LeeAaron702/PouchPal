# PouchPal - Manual Setup Checklist

Tasks that require Xcode UI and cannot be automated. Complete these before submitting to the App Store.

---

## ☐ 1. Create App Icon (REQUIRED)

You need a 1024x1024 PNG image for your app icon.

**Steps:**
1. Create or commission a 1024x1024 PNG app icon
2. In Xcode, navigate to `PouchPal > Assets.xcassets > AppIcon`
3. Drag your icon to the "All Sizes" slot
4. Optionally add dark mode and tinted variants

**Design suggestions for PouchPal:**
- Leaf or plant icon (matches the welcome screen)
- Soft blue/teal gradient background
- Clean, rounded design that matches iOS style

---

## ☐ 2. Enable App Groups Capability (REQUIRED for Widgets)

**For Main App Target:**
1. Select `PouchPal` project in navigator
2. Select `PouchPal` target (not the project)
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Search for and add "App Groups"
6. Click the "+" under App Groups
7. Add: `group.com.leeaaronsoftware.pouchpal.shared`
8. Ensure the checkbox is checked

---

## ☐ 3. Create Widget Extension Target (REQUIRED for Widgets)

**Steps:**
1. File → New → Target
2. Search for "Widget Extension"
3. Select "Widget Extension" and click Next
4. Configure:
   - Product Name: `PouchPalWidget`
   - Team: Your team
   - Bundle Identifier: `com.LeeAaronSoftware.PouchPal.PouchPalWidget`
   - ☑ Include Configuration App Intent (for interactive widgets)
5. Click Finish
6. When prompted to activate scheme, click "Activate"

**After creating the widget target:**
1. Select the new `PouchPalWidget` target
2. Go to "Signing & Capabilities"
3. Add "App Groups" capability
4. Add the SAME group: `group.com.leeaaronsoftware.pouchpal.shared`
5. Replace the generated widget code with the code from `PouchPalWidget/PouchPalWidget.swift`

---

## ☐ 4. Configure Info.plist in Xcode

The Info.plist file was created but needs to be linked in Xcode:

1. Select `PouchPal` target
2. Go to "Build Settings" tab
3. Search for "Info.plist File"
4. Set the value to: `PouchPal/Info.plist`

Or alternatively, copy the keys from the created Info.plist into Xcode's Info tab.

---

## ☐ 5. Take App Store Screenshots

**Required sizes:**
- iPhone 6.7" (1290 x 2796 pixels) - iPhone 15 Pro Max
- iPhone 6.5" (1284 x 2778 pixels) - iPhone 14 Plus  
- iPhone 5.5" (1242 x 2208 pixels) - iPhone 8 Plus
- iPad Pro 12.9" (2048 x 2732 pixels) - if supporting iPad

**Suggested screenshots:**
1. Home screen with progress ring showing ~60% progress
2. History view with several days of entries
3. Insights view showing weekly chart
4. Settings view
5. Home screen widget showcase
6. Onboarding welcome screen

**Tips:**
- Use Simulator with "Device Bezels" enabled in Window menu
- Hide status bar info: Features → Status Bar → Show Network Badge: Off
- Set a consistent time: Features → Status Bar → Override Time
- Use light and dark mode variants

---

## ☐ 6. Host Privacy Policy

Upload the `PRIVACY_POLICY.md` content to a public URL.

**Options:**
- GitHub Pages (free): Create a repo and enable GitHub Pages
- Your personal website
- Notion public page
- Google Sites (free)

**Required URL format for App Store Connect:**
`https://yourdomain.com/pouchpal/privacy`

---

## ☐ 7. Create Support Contact

Set up support resources:

**Option A - Email:**
- Create email: `support@yourdomain.com` or `pouchpal.support@gmail.com`
- Update `PRIVACY_POLICY.md` with the email

**Option B - Website:**
- Create a simple support page with FAQ
- Include contact form or email link

---

## ☐ 8. App Store Connect Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: PouchPal
   - Primary Language: English (U.S.)
   - Bundle ID: `com.LeeAaronSoftware.PouchPal`
   - SKU: `pouchpal-ios-1`
4. Click Create

**In the app page:**
- Upload screenshots
- Fill in description, keywords, subtitle from `APP_STORE_METADATA.md`
- Add Privacy Policy URL
- Add Support URL
- Set age rating (4+)
- Set pricing (Free)

---

## ☐ 9. Archive and Upload Build

1. In Xcode: Product → Archive
2. Wait for archive to complete
3. In Organizer window, select the archive
4. Click "Distribute App"
5. Select "App Store Connect"
6. Follow prompts to upload

---

## ☐ 10. Submit for Review

In App Store Connect:
1. Select your uploaded build
2. Complete all required fields
3. Add review notes (see `APP_STORE_METADATA.md`)
4. Click "Add for Review"
5. Click "Submit to App Review"

---

## Quick Reference - Bundle IDs

| Target | Bundle ID |
|--------|-----------|
| Main App | `com.LeeAaronSoftware.PouchPal` |
| Widget | `com.LeeAaronSoftware.PouchPal.PouchPalWidget` |
| Tests | `com.LeeAaronSoftware.PouchPalTests` |
| App Group | `group.com.leeaaronsoftware.pouchpal.shared` |

---

## Estimated Time

| Task | Time |
|------|------|
| App Icon | 1-4 hours (or commission) |
| App Groups setup | 5 minutes |
| Widget target setup | 15 minutes |
| Screenshots | 30-60 minutes |
| Host privacy policy | 15 minutes |
| App Store Connect setup | 30 minutes |
| Archive & upload | 15 minutes |
| **Total** | **~3-6 hours** |
