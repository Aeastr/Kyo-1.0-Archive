# Archive build review

## October 9, 2026

An initial Debug build was attempted with Xcode 27.1 for the connected iPhone 17 Pro Max. Package resolution failed before compilation because the original `Aeastr/NeoSymbolPicker` repository was unavailable. The pinned revision is `201402a21c37a2c96c41e0b20724764eab1b5d35`; the project links its `SymbolPicker` product. The exact commit was subsequently recovered through the upstream fork network and included as a local dependency, with its MIT license preserved. No replacement implementation has been substituted, and no app was installed or launched.

The archive now uses the separate `com.example.kyoarchive` bundle namespace, `group.com.example.kyoarchive` app group, and `iCloud.com.example.kyoarchive` container. Companion identifiers and Watch companion references are updated consistently. Personal signing-team values are excluded; a development team must be supplied locally for a device build. The archive must not be installed using the original app's identifiers or data containers.

Historical export binaries, packaging logs, and signing summaries were excluded. They are unrelated to building from source. The source snapshot manifest retains original hashes and records the archive identifier edits and excluded files.

Project and entitlement plist checks, namespace consistency checks, and source-manifest checks passed. These checks do not establish build or runtime correctness. The stale reference to an unavailable Desktop StoreKit testing configuration was removed.

A signed retry resolved the packages but failed because the new archive app-group and iCloud container were not present in the provisioning profiles. An unsigned iPhone compilation then failed in the original RevenueCat 4.41 SDK with `invalid redeclaration of synthesized memberwise init(stringRepresentation:)` under Xcode 27.1. The Xcode 26.6 retry stopped before compilation because its required watchOS 26.5 SDK was not installed. None of these attempts succeeded or installed an app.

## Compatibility repairs and successful build

The author reported a successful Xcode build on October 9, 2026, after the following focused repairs. Installation and runtime behaviour have not been independently verified.

- RevenueCat 4.41.0 is included locally. Its existing private `PaywallColor` initializer was moved into the struct declaration to prevent a conflicting synthesized initializer. Only the two runtime products used by Kyo are included; the upstream manifest and MIT license are retained.
- Empty groups in `PlannerSettings.swift` and `ShareSheet.swift` received explicit `EmptyView()` content. Original commented-out code remains.
- The app now links only the default Introspect product, avoiding redundant static and dynamic links to the same target.

All archive edits to source and project configuration have searchable `FIX:` comments. The project and its neighbouring folders were moved together to `Source/`, without changing their relative paths. A local ignored signing configuration preserves device signing while keeping team IDs out of committed files. The pre-repair snapshot is preserved on the local `original-source-private` branch and in a private backup bundle.

## Kyo+ archive access

Kyo+ is enabled locally at launch and returned as active by the shared entitlement check. The two screens with separate local access state also default to unlocked. The original purchase UI is bypassed with an archive explanation; SDK configuration, offerings, membership management, and support account-ID lookup are skipped. Original purchase implementations remain in source, and additions have `FIX:` comments. This unlock was added after the author’s successful build and has not yet been verified on a device.

The remote `original-source` branch points to the sanitized snapshot before compiler repairs and the Kyo+ unlock. It retains the original app implementation with archive identifiers and recovered dependency setup. The untouched local branch and backup were not published.

## Launch regression after the Kyo+ unlock

The author reported a white screen after the unlock changes. A paused device stack passed through the existing AmethystUI home-indicator lookup and SwiftUI AttributeGraph, but this does not establish the trigger. The archive entitlement callback now delivers on the next main-queue turn, retaining the asynchronous timing of the original purchase check. Launch also avoids rewriting an already-enabled access flag. AmethystUI remains unchanged. Device verification is pending.

## Permanent Kyo+ access

The callback-based archive unlock has been replaced by read-only `true` access values and constant bindings. Active purchase-status requests and their callbacks have been removed, along with SDK setup and launch-time entitlement writes. This avoids making entitlement state changes during view updates. Historical source remains on `original-source`; the dependency itself is unchanged. Device verification is still pending.

## RevenueCat removed from main

RevenueCat and RevenueCatUI imports, package products, vendored SDK source, historical purchase UI, membership actions, and support-account ID lookup have been removed. The archive keeps a small Kyo+ included-access view and permanent unlocked access. The original branch retains the original purchase implementation and dependency setup.

## White screen investigation

A running iPhone build showed a white screen and layout-cycle warnings. Pausing it in Xcode showed the main thread in `AG::Graph::UpdateStack::push_slow`, reached through `UIWindow.safeAreaInsets`, `FluidTabBar.hasHomeIndicator`, and the tab bar’s `safeAreaInset`. After resuming, Xcode reported about 99% CPU. The database had already loaded.

AmethystUI 1.5.1 is now included locally with a targeted repair: the original window-inset lookup runs asynchronously after appearance and its result is cached for view evaluation. The original lookup logic and bar remain. Device verification of this repair is pending.

## Compilation after purchase SDK removal

An unsigned Debug build for the connected iPhone destination succeeded with Xcode 27.1 after removing RevenueCat, replacing its three sidebar `onChangeOf` helpers with native SwiftUI `onChange`, and applying the deferred AmethystUI inset lookup. Device installation and repeat-launch verification are still pending.

## Local Pro toggle

Pro now defaults to on and can be switched off in Settings to explore the original free feature gates. App screens and controls share the `archivePlusEnabled` AppStorage value; changes persist between launches. The archive access sheet also exposes the same toggle. No purchase callbacks or SDK setup are restored. The historical downgrade handler is retained, so switching Pro off resets appearance preferences as the original app did. Source validation is recorded separately from the pending device check.

The unsigned Debug build for the iPhone destination passed with Xcode 27.1 after connecting the saved Pro toggle. On-device toggle interaction, persistence after relaunch, and repeat-launch behaviour remain to be checked.

The original `NavigationHandler` downgrade handler has been restored verbatim from `original-source`, including its existing font-condition logic. It now responds to the local Pro toggle. This restoration received source comparison and syntax checks; a device check has not been repeated.
