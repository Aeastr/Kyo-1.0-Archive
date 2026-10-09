# AmethystUI archive dependency

AmethystUI 1.5.1, commit `97bb004adf75eddf75a5aeabfaa4920ae155b368`, from https://github.com/FauxFoxApps/AmethystUI. Original source notices are preserved. Historical upstream build output is excluded.

`FluidTabBar.swift` caches its home-indicator check after appearance instead of reading `UIWindow.safeAreaInsets` during SwiftUI body evaluation. A paused device stack showed the main thread inside that lookup and AttributeGraph update, with the app stuck on a white screen. The original lookup and tab bar appearance are preserved; additions are marked `FIX:`. This repair still needs a device launch check.
