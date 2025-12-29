import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            BookSearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Пошук")
                }

            ReadingListView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Список для читання")
                }
        }
        .accentColor(AppColor.blushPink)
    }
}
