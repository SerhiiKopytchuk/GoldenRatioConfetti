# GoldenRatioConfetti

A SwiftUI and SpriteKit golden ratio confetti effect.

The particle images are bundled with the package, so apps do not need to add or configure any assets.

## Installation

Add this package in Xcode:

```text
https://github.com/SerhiiKopytchuk/GoldenRatioConfetti
```

Then import it where you want to show the confetti:

```swift
import GoldenRatioConfetti
import SwiftUI
```

## Usage

```swift
struct RewardScreen: View {
    @State private var showConfetti = true

    var body: some View {
        ZStack {
            VStack {
                Text("Workout Complete")
                    .font(.largeTitle.bold())

                Text("You earned 100 XP")
                    .foregroundStyle(.secondary)
            }

            if showConfetti {
                GoldenRatioConfetti()
                    .allowsHitTesting(false)
            }
        }
    }
}
```
