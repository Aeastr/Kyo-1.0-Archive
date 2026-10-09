# About the archive

@Options {
    @TopicsVisualStyle(detailedGrid)
}

This is the original Kyo, before the abandoned initial 2.0 rewrite and the later Renaissance revival.

The source was exported from `Aeastr/KyoApp` at `ef3ed674719c865a25a5e3b724f3be601be9b614` (July 12, 2024). The main project settings are version 1.0.3, build 67. The author confirms 1.0.3 was the final original App Store release; the exact binary-to-commit match has not been established.

The `KyoNeoDatabase` submodule was expanded into a regular folder using its pinned commit, `3ad6d17830bf33ffdb615220e89d160dcd560f44`. Its original files are unchanged. The original `.gitmodules` file is preserved as part of the historical snapshot; this archive does not require a submodule checkout.

The original app implementation, assets, and folder names are preserved, with the compatibility exceptions described below. Bundle, app-group, and iCloud identifiers are changed to the separate archive namespace, and personal signing-team values are excluded. Finder metadata, personal Xcode workspace state, and historical export binaries and signing logs were excluded. The README, licensing and community documents, and this documentation catalog were added for the archive. The [snapshot manifest](../../SOURCE-SNAPSHOT.json) records the original source hashes, the current archive hashes, identifier-related edits, and excluded files.

The later unfinished 2.0 source is not part of this archive. Renaissance is a separate revival, not a continuation of that abandoned release attempt.

The original SymbolPicker dependency was recovered at its pinned commit, `201402a21c37a2c96c41e0b20724764eab1b5d35`, through its upstream fork network after the former repository URL became unavailable. Its source is included under `Source/Dependencies/SymbolPicker` with its MIT license and notices. The stale project reference to the unavailable Desktop StoreKit testing file was removed. These are build-setup repairs, not feature changes.

The project and its original folders now live together under `Source/`, preserving their relative paths. Small compiler and linking repairs are marked with `FIX:` comments. RevenueCat 4.41.0 is included locally with its MIT license and a private initializer moved into the struct declaration. Empty SwiftUI groups received `EmptyView()` additions; their historical comments remain. Redundant Introspect product links were disconnected. A successful build was reported by the author on October 9, 2026. The untouched pre-repair source remains on the private local `original-source` branch.
