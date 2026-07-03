# GoldenRatioConfetti

A lightweight SwiftUI + SpriteKit confetti animation built around a golden-ratio spiral path.

It creates a premium celebration effect where particles follow a spiral motion, spread naturally, flutter like falling leaves, and finish with a gravity-like fall.

Perfect for:

- completion screens
- streak milestones
- level-up moments
- reward animations
- onboarding success states
- gamified iOS apps

## Preview

https://github.com/user-attachments/assets/942fe9e9-5a81-4a25-ac28-7ce9b8d4b42e



## Features

- SwiftUI-friendly API
- SpriteKit-powered particles
- Golden-ratio spiral motion
- Natural randomized spread
- Depth-based scale and opacity
- Flutter rotation
- Gravity-like ending motion
- Transparent background
- Bundled particle assets
- No external dependencies

## Requirements

- iOS 15+
- SwiftUI
- SpriteKit
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode:

1. Open your project
2. Go to File -> Add Package Dependencies
3. Paste the repository URL:

```text
https://github.com/SerhiiKopytchuk/GoldenRatioConfetti
```

4. Add GoldenRatioConfetti to your app target

## Usage

```swift
import SwiftUI
import GoldenRatioConfetti

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GoldenRatioConfetti()
                .allowsHitTesting(false)
        }
    }
}
```

You can place it over any screen:

```swift
ZStack {
    CompletionView()

    GoldenRatioConfetti()
        .allowsHitTesting(false)
}
```

## Particle Assets

The particle images are bundled with the package, so apps do not need to add or configure any assets.

GoldenRatioConfetti includes six transparent PNG particles:

- Particle_1
- Particle_2
- Particle_3
- Particle_4
- Particle_5
- Particle_6

## How It Works

The animation has two phases.

First, particles follow a golden-ratio spiral path with randomized spread, wave motion, rotation, and depth variation.

Then, each particle transitions into a gravity-like falling phase, making the ending feel more physical and natural instead of stopping abruptly.

## Customization

You can customize the effect by changing constants inside `GoldenRatioConfetti.swift`:

```swift
private static let particleCount = 56
private static let spiralDuration: TimeInterval = 3.4
private static let endSpread: CGFloat = 430
private static let verticalSpreadRatio: CGFloat = 0.50
```

Useful tweaks:

```swift
// More particles
private static let particleCount = 80

// Faster animation
private static let spiralDuration: TimeInterval = 2.6

// Wider final spread
private static let endSpread: CGFloat = 520

// More vertical randomness
private static let verticalSpreadRatio: CGFloat = 0.65
```

## Performance Notes

GoldenRatioConfetti uses SpriteKit under SwiftUI through `SpriteView`.

For best performance:

- use small particle textures
- avoid very large PNGs
- keep particle count reasonable
- use the animation only when needed
- remove the view after the celebration finishes if your screen keeps running for a long time

## Example

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

## License

MIT License.

Feel free to use it in personal and commercial projects.

## Credits

Created with SwiftUI and SpriteKit.

Inspired by natural falling motion, golden-ratio spirals, and premium reward animations.
