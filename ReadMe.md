## ✨ Features
- Loads movies from the `themoviedb` and stores them locally using fileManger
- Have EventStream to update, delete or add movies 
- Show results in a clean SwiftUI UI
- Offline-friendly patterns (cache, persistence-ready)
- Testable architecture (dependency injection + mocks)

## 🧱 Tech Stack

- **iOS**: Swift + SwiftUI
- **Architecture**: MVVM (+ lightweight “composition root”)
- **Networking**: URLSession (or HTTP client abstraction)
- **Persistence**: FileManager / local store abstraction (cache-ready)
- **Testing**: XCTest (unit tests under `FoodoAITests/`)

---

## 🔁 Live Updates / Event Stream (Optional Enhancement)

If you want simulated frequent updates without an API call, you can implement:
- a local `EventStream` that emits random “updated/created/removed” events
- a `Merger` that applies those events into the current list **without changing item order**
- a small UI “toast/banner” saying “Updated from event stream”

This is a clean way to demo real-time list updates while staying offline and testable.

---

## 🚀 Getting Started

1. Clone the repo
2. Open `FoodoAI.xcodeproj` in Xcode :contentReference[oaicite:5]{index=5}
3. Configure environment variables / secrets (see note below)
4. Build & run on simulator or device

## If had more time
- I would like replace using FileManager as a storage with CoreData / SwiftData
- I would have implemented MovieEventStreaming using Test Driven Development or added unit tests
- I would have added more test cases to cover edge cases
- A better strategy for updating the movies instead of bundled movie_events.json
