import SwiftUI

@main
struct LunaReadsApp: App {
    @StateObject private var readingListVM = ReadingListViewModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(readingListVM)
                
        }
    }
}
