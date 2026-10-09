<div>
  <h1>Kyo 1.0 Archive <img src="docs/Images/Kyo-1.0-Archive.png" alt="Original Kyo icon" width="96" height="96" align="right"></h1>
  <p>The original Kyo: a place for your timetable, classes, and tasks.</p>
  <p><img src="https://img.shields.io/badge/iOS-17%2B-000000?logo=apple" alt="iOS 17+"> <img src="https://img.shields.io/badge/iPadOS-17%2B-000000?logo=apple" alt="iPadOS 17+"> <img src="https://img.shields.io/badge/Mac-Designed_for_iPad-000000?logo=apple" alt="Mac (Designed for iPad)"> <img src="https://img.shields.io/badge/Apple_Vision-000000?logo=apple" alt="Apple Vision"> <img src="https://img.shields.io/badge/watchOS-10%2B-000000?logo=apple" alt="watchOS 10+"> <img src="https://img.shields.io/badge/Swift-5_language_mode-F05138?logo=swift&amp;logoColor=white" alt="Swift 5 language mode"></p>
</div>

## Why share this?

This was the original Kyo, and quite a learning experience. It is no longer on the App Store. A lot has changed since I made it, but I still think there is value in letting people see how it worked, learn from it, and try their own ideas.

## Where it fits

This archive covers the 1.0 era, ending with Kyo 1.0.3. An initial 2.0 rewrite was started afterwards and later abandoned. The current [Kyo Renaissance](https://github.com/Aeastr/Kyo) is a later revival, separate from that unfinished rewrite.

The snapshot is from commit `ef3ed674719c865a25a5e3b724f3be601be9b614`, where the project is set to 1.0.3, build 67. It has not been verified against the exact App Store binary. More history is in the [archive notes](docs/KyoLegacy.docc/Archive/Archive.md).

## Yes, the code is rough

I know. There are questionable names, commented-out experiments, and more debug prints than anyone needed. I was learning, and it shows.

Hopefully there is something useful in here, even if some of it is what not to do.

## Changes for this archive

`main` has a few changes to make the old app easier to build and explore today:

- The project and its original folders are collected under `Source/`.
- App, app-group, and iCloud identifiers are separate from the original app. Personal signing details and old export files are excluded.
- Missing dependencies were recovered, and small compiler, linking, and layout repairs were made.
- Purchases were removed and replaced with a local Pro toggle.

Code changes are marked with `FIX:` comments. The [build notes](docs/BUILD-REVIEW.md) record the repairs and what has been tested.

The [original-source branch](https://github.com/Aeastr/Kyo-1.0-Archive/tree/original-source) holds the snapshot before the compiler repairs and Pro changes. It still includes the archive identifiers and dependency setup needed to share it.

## Kyo+ is included

Pro is on by default. The **Pro** toggle in Settings lets you explore both the original free and Kyo+ features, and saves your choice between launches. No purchase or RevenueCat account is needed.

## Building

Open [`Source/KyoNeo.xcodeproj`](Source/KyoNeo.xcodeproj) in Xcode. The main target is `KyoNeo`.

For device signing, create `Source/LocalSigning.xcconfig` with:

```xcconfig
KYO_ARCHIVE_DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

That file is ignored by Git. Configure the archive bundle identifiers, app group, and iCloud container for your account before building.

Remote dependency versions are recorded in `Package.resolved`. The database package and recovered dependencies are included in the repository. See the [build notes](docs/BUILD-REVIEW.md) for toolchain and device checks.

## Platforms

The main project lists iPhone, iPad, Mac (Designed for iPad), and Apple Vision as destinations. It also includes widgets and an Apple Watch app.

The deployment settings are iOS/iPadOS 17, macOS 14, and watchOS 10, with watchOS 10.2 for the complications extension. Configured destinations have not all been tested with current tools.

## More to explore

The [DocC catalog](docs/KyoLegacy.docc/KyoLegacy.md) contains archive and release notes. [Media](Media/README.md) is a home for historical screenshots, social posts, and press material as they are recovered.

## Contributing

This archive is for reading and experimenting. I am not maintaining it as another version of Kyo or accepting feature changes here. Corrections to the documentation are welcome.

## License

Original Kyo code in this archive, including the database package, is available under [GPLv3](LICENSE), with the attribution term in [source notes](SOURCE-NOTES.md). Distributed derivatives must keep the whole covered work under GPLv3 and provide its corresponding source and required notices. Dependencies and artwork have separate terms explained in the source notes.
