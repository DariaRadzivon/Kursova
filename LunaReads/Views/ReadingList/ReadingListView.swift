import SwiftUI

struct ReadingListView: View {
    @EnvironmentObject private var viewModel: ReadingListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    VStack(spacing: 12) {
                        Text("Твій список поки порожній.")
                            .font(.headline)
                            .foregroundColor(AppColor.inkBlack)
                        Text("Додай книжку з пошуку й створюй свою затишну бібліотеку 💕")
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppColor.inkBlack.opacity(0.7))
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            NavigationLink {
                                ReadingListDetailView(itemID: item.id)
                            } label: {
                                ReadingListRowView(item: item)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteItems(at: indexSet)
                        }
                    }
                    .scrollContentBackground(.hidden)

                }
            }
            .background(
                LinearGradient(colors: [AppColor.paperWhite, AppColor.blushPink.opacity(0.15)],
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
            )
            .navigationTitle("Список для читання")
        }
    }
}
