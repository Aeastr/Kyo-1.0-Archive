# FluidTabBar Documentation

## TabItem
The `TabItem` struct is an essential component of the AmethystUI framework, specifically designed for use with the `FluidTabBar`. It represents an individual tab within the tab bar and encapsulates various attributes and functionalities associated with each tab. The `TabItem` struct comes in two versions, each tailored to accommodate different types of content: one for tabs with icons and another for tabs with Rive animations.

### TabItem with Icon

**Description:**


- This version of `TabItem` is used when you want to create a tab with an associated icon.
- `label` is a required parameter, representing the text label for the tab.
- `icon` is the name of the icon image to be displayed within the tab.
- `color` specifies the color of the tab item; the default is teal.
- `content` is a ViewBuilder closure that provides the main content view for the tab.
- `secondaryAction` is an optional closure that triggers an action when the tab is pressed while active.

You can construct a tab item like

```swift
TabItem(
    label: "Favorites",                   // Label for the second tab
    icon: "star.fill",                    // Icon for the Favorites tab
    color: .blue,                         // Color of the second tab
    content: {
        favoritesView()                    // Content view for the Favorites tab
    }
)
```


### TabItem with Rive Animation

**Description:**


- This version of `TabItem` is used when you want to create a tab with an associated Rive animation.
- `label` is a required parameter, representing the text label for the tab.
- `riveView` is a `RiveViewModel` object that defines the Rive animation to be displayed within the tab.
- `color` specifies the color of the tab item; the default is teal.
- `content` is a ViewBuilder closure that provides the main content view for the tab.
- `secondaryAction` is an optional closure that triggers an action when the tab is pressed while active.

**Note:** Both versions of `TabItem` automatically generate a unique identifier (`id`) using a UUID

These `TabItem` structs are crucial components for constructing a fluid and interactive tab bar using the AmethystUI framework. Whether you choose to use icons or Rive animations, these versatile tab items allow you to create a dynamic and engaging user interface experience.

You can construct rive tab items like

```swift
TabItem(
    label: "Explore",                      // Label for the first tab
    riveView: RiveViewModel(               // Rive animation view model
        fileName: "explore_anim",         // Name of the Rive file
        stateMachineName: "explore_sm",   // Name of the Rive state machine
        artboardName: "explore_ab"        // Name of the Rive artboard
    ),
    color: .green,                        // Color of the tab
    content: {
        exploreView()                      // Content view for the Explore tab
    }
),
```

----

# FluidTabBar Struct


The `FluidTabBar` struct is a versatile and customisable tab bar component provided by the AmethystUI framework. It enables the creation of fluid tab bars with various styles and animations, making it suitable for navigation and user interaction within your app.

## Tab Item Handling


The `FluidTabBar` struct uses an array of `TabItem` instances to define the tabs within the tab bar. Each `TabItem` represents a single tab with customisable content, icons, labels, and actions. The tabs can be selected and interacted with by the user.

## Fluid Animation and Interaction

- The tab bar supports fluid animations when switching between tabs.
- Users can interact with the tab bar by tapping on tabs or dragging horizontally (on iOS devices).

## Styling Options

- You can customise the appearance of the tab bar by adjusting properties like `color`, `animateIcons`, and `pageAnimation`.
	- `animateIcons` will only effect `TabItems` that have a rive animation
- The `barType` property allows you to choose between a regular tab bar style and a progressive blur style.

### Usage


To use the `FluidTabBar` in your app, create an instance of it with the desired configuration and include it in your view hierarchy. Make sure to provide an array of `TabItem` instances to represent the tabs and bind the `selectedIndex` to control the selected tab.

```swift
FluidTabBar(
    tabItems: [/* TabItem instances */],
    selectedIndex: $selectedTabIndex
)
```


```swift
struct TabBarExample: View {
    @State private var selectedTabIndex = 0
    
    var body: some View {
        // Example FluidTabBar
        FluidTabBar(
            tabItems: [
                TabItem(label: "Home", icon: "house.fill", color: .blue) {
                    // Content for the Home tab
                    Text("Home Tab Content")
                },
                TabItem(
                    label: "Explore",                   
                    riveView: RiveViewModel(         
                        fileName: "explore_anim",     
                        stateMachineName: "explore_sm", 
                        artboardName: "explore_ab"
                                           ),
                    color: .green,                       
                    content: {
                        Text("Explore Tab Content")
                    }
                ),
                TabItem(label: "Profile", icon: "person.fill", color: .purple) {
                    // Content for the Profile tab
                    Text("Profile Tab Content")
                }
            ],
            selectedIndex: $selectedTabIndex
        )
    }
}
```


FluidTabBar has 3 more properties 

### pageAnimation


`pageAnimation` is a property that defines the type of animation used when transitioning between different tab views in a `FluidTabBar`. It can take on the following values:


- `.full`: This option indicates that a full-page animation will be used. When switching between tabs, the entire content of the page will slide horizontally to reveal the new tab's content. This creates a smooth sliding effect between tabs.
- `.fade`: When this option is selected, a fading animation is applied during tab transitions. The current tab's content gradually fades out, while the new tab's content fades in. This creates a visually pleasing crossfade effect between tabs.
- `.none`: If you choose this option, no animation will be applied when switching between tabs. The tab content will switch instantly without any visual transition effects.

### showTabBar


`showTabBar` is a property that allows you to control the visibility of the tab bar within a `FluidTabBar`. It is of type `Binding<Bool>?`, meaning it can be optional and is typically used to dynamically show or hide the tab bar based on certain conditions in your app.


- When `showTabBar` is `nil` (the default), the visibility of the tab bar is not controlled externally. It remains visible by default.
- When you provide a binding to a `Bool` value, such as `$isTabBarVisible`, you can control the tab bar's visibility programmatically. Setting the bound `Bool` to `true` will show the tab bar, while setting it to `false` will hide it. This can be useful for scenarios where you want to temporarily hide the tab bar, such as during certain app interactions or transitions.

### type


`type` is a property that defines the style or type of the `FluidTabBar`. It can take on the following values:


- `.regular`: This option represents a standard or regular tab bar style. It typically includes tabs with icons or labels and is well-suited for most tab bar designs.
- `.progressiveBlur`: When you choose this option, the tab bar will have a progressive blur effect. This effect might involve background blurring or other visual enhancements, providing a unique and stylish appearance for the tab bar.

You can select the appropriate `type` based on your design preferences and the overall visual style you want to achieve for your tab bar.

![image](https://res.craft.do/user/full/105e14e1-a19a-1ac9-bb8e-47edceb8af3d/doc/F779A09C-2E21-4614-AE35-E9DE6CEE5ECE/221D89F6-F544-4487-B401-8A6CB49C53C2_2/LKR812zvbzeyVrOiAInhRKRHFKxvheArFle9IYJmFWgz/CleanShot%202023-10-04%20at%208.50.302x.png)

`.regular` 

![image](https://res.craft.do/user/full/105e14e1-a19a-1ac9-bb8e-47edceb8af3d/doc/F779A09C-2E21-4614-AE35-E9DE6CEE5ECE/71ABBF31-156A-4A82-AA22-F5ED1F37EA97_2/ywpo395Yy4idPblaAzFG4NlYR8fp9iElQAIwx2cR9sgz/CleanShot%202023-10-04%20at%208.51.102x.png)

`.progressiveBlur`
