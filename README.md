# CustomTab — navigation sample with a custom TabBar

This repository is a minimal sample showing how to build a **custom TabBar (UIKit)** while keeping **a separate navigation stack per tab**, with the ability to **programmatically switch tabs and show a specific screen (deep navigation)**.

## Problem

In real-world apps you often need:

- A **separate** `UINavigationController` **stack per tab** (so each tab “remembers” its own flow).
- The ability to **switch a tab and open a non-root screen**, e.g. “open Profile → Profile details”.
- Correct **back swipe / back button** behavior and keeping the stack in sync with app state.
- A custom TabBar with its own shape/animations, without relying on `UITabBarController`.

## Architecture

### `TabRouter` (navigation state)

`CustomTab/Routing/TabRouter.swift`

- Stores:
  - `selectedTab: TabIdentifier`
  - `stacksByTab: [TabIdentifier: [ScreenRoute]]`
- Public API:
  - `selectTab(_:animated:)`
  - `selectTab(_:setStack:animated:)`
  - `push(_:animated:)`
  - `pop(animated:)`
  - `setStack(_:for:animated:)`
  - `syncStackFromNavigator(_:for:)`
- Uses **Observation** (`@Observable`) instead of `ObservableObject/@Published`.

### `ScreenRoute` (a screen as data)

`CustomTab/Routing/ScreenRoute.swift`

A screen in the stack is **data**, not a `View`:

- `tab: TabIdentifier`
- `id: String` (e.g. `"main.details"`)
- `params: [String: AnyHashable]`

This lets you build/replace stacks without keeping `AnyView` inside the model.

### `RouteViewFactory` (route → SwiftUI view mapping)

`CustomTab/Routing/RouteViewFactory.swift`

- Uses `@ViewBuilder` to map `screen.id` to a concrete SwiftUI screen.
- No `AnyView` here.

### `CustomTabController` (UIKit container + one UINavigationController per tab)

`CustomTab/TabBar/CustomTabController.swift`

- Creates **one `UINavigationController` per tab**.
- Observes `TabRouter` intent and performs:
  - `setViewControllers` for `setStack`
  - `pushViewController/popViewController` for `push/pop`
- Uses `UINavigationControllerDelegate` to sync the real UIKit stack back into `TabRouter` (`syncStackFromNavigator`) so back-swipe stays correct.
- Hides the custom tabbar on detail screens (when stack depth > 1).

### `CustomTabBarView` (custom TabBar)

`CustomTab/TabBar/CustomTabBarView.swift`

- A UIKit view with a custom shape/notch and an animated indicator.
- The accent color in the current version is **orange**.

## Screens structure

`CustomTab/Screens/`

- `Main/` — Main root + details
- `Lobby/` — Lobby root + details
- `Menu/` — Menu root
- `Bonuses/` — Bonuses root + details
- `Profile/` — Profile root + details

These screens are intentionally simple and exist only to demonstrate navigation scenarios.

## How to run

- Open `CustomTab.xcodeproj` in Xcode.
- Run on an iOS Simulator.

## Navigation scenarios (examples)

- **Push** within a tab:
  - `Main` → `Main details`
- **Deep navigation to another tab**:
  - `router.selectTab(.profile, setStack: [.profileRoot, .profileDetails], animated: true)`

## Frameworks used

- **SwiftUI**
- **UIKit**
- **Foundation**
- **Observation** (Swift `@Observable`)

