# Game Center Setup for Anagram Trainer

To enable the leaderboard, you must configure Game Center in the Apple Developer Portal and App Store Connect.

## 1. Enable Game Center Capability
1. Open the project in Xcode.
2. Select the **AnagramTrainer** target.
3. Go to **Signing & Capabilities**.
4. Click **+ Capability** and search for **Game Center**.

## 2. App Store Connect Configuration
1. Log in to [App Store Connect](https://appstoreconnect.apple.com/).
2. Go to **My Apps** and select **Anagram Trainer**.
3. In the sidebar, under **Services**, select **Game Center**.
4. Click **+** next to **Leaderboards**.
5. Choose **Classic Leaderboard**.
6. Set the following:
   - **Leaderboard ID**: `lettershift_high_scores` (This must match the ID in `GameCenterManager.swift`).
   - **Score Format Type**: Integer.
   - **Score Submission Type**: Best Score.
   - **Sort Order**: High to Low.
7. Click **Save**.

## 3. Sandboxing (iOS 16+)
In modern iOS versions, the Sandbox settings have moved out of the Game Center menu:

1. **Enable Developer Mode**:
   - Go to **Settings > Privacy & Security > Developer Mode**.
   - Turn it on (requires a device restart).
2. **Access Sandbox Settings**:
   - Go to **Settings > Developer** (a new menu at the root of Settings).
   - Scroll to the bottom to find **Sandbox Apple Account**.
   - Sign in with your sandbox tester credentials here.

> [!NOTE]
> These options often only appear on a physical device **after** you have installed a development build via Xcode at least once.

## 4. Troubleshooting

### "Could not load services for GameKit" or "com.apple.gamed invalidated"
The error you are seeing confirms the app lacks the **Game Center Entitlement**.

**To fix this:**
1. In Xcode, select the blue **AnagramTrainer** project icon at the top of the Navigator.
2. Select the **AnagramTrainer** target.
3. Go to the **Signing & Capabilities** tab.
4. Click the **+ Capability** button (top left of the tab).
5. Search for **Game Center** and double-click it.
6. Xcode will automatically create an `.entitlements` file and add the required keys.
7. Clean and Re-run (**Cmd + Shift + K**, then **Cmd + R**).

### "Local player has not been authenticated"
This happens if you are not signed into a Game Center account in the device/simulator settings.
1. On your device/simulator, go to **Settings > Game Center**.
2. Ensure Game Center is **ON**.
3. Sign in with your Apple ID or a Sandbox account.
4. If you are already signed in, try signing out and back in again.
