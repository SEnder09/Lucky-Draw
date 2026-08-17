# ⚔️ Lucky Draw

An iOS application built with **SwiftUI** featuring a medieval fantasy aesthetic and authentic Cantonese localization. Designed to select random candidates with custom group management, inline editing, and smooth animated scrolling.

![iOS 17+](https://img.shields.io/badge/iOS-17.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-red)

---

## 🌟 Key Features

           * **Localized Experience**: Fully localized interface in authentic Cantonese
* **Medieval Fantasy UI**: Custom parchment textures, wax seal triggers, and dynamic color palettes (`#8B0000` crimson, gold, and iron accents).
* **Group Management**: Save, load, and delete custom candidate rosters using `@AppStorage` and JSON encoding.
* **Inline Editing & Fast Rostering**:
  * Edit candidate names inline without deleting and re-entering.
  * Extracted modular subviews (`CandidateRowView`) to ensure rapid SwiftUI compile times and smooth UI rendering.
* **Randomizer Engine**: Animated step-by-step deceleration sequence for generating selection suspense.
* **Haptic Feedback**: Native haptic feedback tied to selection steps (`.sensoryFeedback`).

---

## 🛠️ Tech Stack & Architecture

* **Framework**: SwiftUI
* **Architecture**: Declarative View Decomposition (Component-Driven)
* **Data Persistence**: `@AppStorage`, `JSONEncoder` / `JSONDecoder`
* **State Management**: `@State`, `@Binding`, `@ViewBuilder`
* **UI/UX**: Custom `GeometryReader` textures, haptics, and dynamic animations

---

## 📸 Screenshots

> *Add screenshots of your app running on the iOS Simulator here.*

| Main View | Group Storage Menu |
| :-: | :-: |
| *(Insert Screenshot Link Here)* | *(Insert Screenshot Link Here)* |

---

## 🚀 How to Run locally

1. **Clone the repository**:
   ```bash
   git clone [https://github.com/SEnder09/Lucky-Draw.git](https://github.com/SEnder09/Lucky-Draw.git)
