# RevenueCat archive dependency

Runtime sources from RevenueCat 4.41.0, commit `54aaeb5722fbdcddf0403107ba50dc26720fa572`, from https://github.com/RevenueCat/purchases-ios. The upstream MIT license is included.

Only the `RevenueCat` and `RevenueCatUI` products used by this app are included. The package manifest omits upstream tests, examples, unused products, and their dependencies; the original manifest is retained for reference.

For Xcode 27.1, the existing private initializer in `PaywallColor` was moved from an extension into the struct declaration. This prevents a conflicting synthesized initializer without changing its implementation or public API. Other runtime source is unchanged.
