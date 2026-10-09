# Archive build review

## October 9, 2026

An initial Debug build was attempted with Xcode 27.1 for the connected iPhone 17 Pro Max. Package resolution failed before compilation because the original `Aeastr/NeoSymbolPicker` repository was unavailable. The pinned revision is `201402a21c37a2c96c41e0b20724764eab1b5d35`; the project links its `SymbolPicker` product. The exact commit was subsequently recovered through the upstream fork network and included as a local dependency, with its MIT license preserved. No replacement implementation has been substituted, and no app was installed or launched.

The archive now uses the separate `com.example.kyoarchive` bundle namespace, `group.com.example.kyoarchive` app group, and `iCloud.com.example.kyoarchive` container. Companion identifiers and Watch companion references are updated consistently. Signing-team values are blank; a development team must be supplied locally for a device build. The archive must not be installed using the original app's identifiers or data containers.

Historical export binaries, packaging logs, and signing summaries were excluded. They are unrelated to building from source. The source snapshot manifest retains original hashes and records the archive identifier edits and excluded files.

Project and entitlement plist checks, namespace consistency checks, and source-manifest checks passed. These checks do not establish build or runtime correctness. The stale reference to an unavailable Desktop StoreKit testing configuration was removed.

A signed retry resolved the packages but failed because the new archive app-group and iCloud container were not present in the provisioning profiles. An unsigned iPhone compilation then failed in the original RevenueCat 4.41 SDK with `invalid redeclaration of synthesized memberwise init(stringRepresentation:)` under Xcode 27.1. The Xcode 26.6 retry stopped before compilation because its required watchOS 26.5 SDK was not installed. None of these attempts succeeded or installed an app.
