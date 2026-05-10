import SwiftUI

@main
struct OrbitApp: App {
    @StateObject private var store = OrbitStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
