import SwiftUI

struct BookResultsView: View {
    let books: [Book]
    let isLoading: Bool
    let loadMore: (Book?) -> Void

    var body: some View {
        List {
            ForEach(
                books.filter { book in
                    let hasCover = book.volumeInfo.coverURL != nil
                    let hasDescription = !(book.volumeInfo.description?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty ?? true)
                    return hasCover && hasDescription
                }
            ) { book in

                NavigationLink {
                    BookDetailView(book: book)
                } label: {
                    BookRowView(book: book)
                        .onAppear {
                            loadMore(book)
                        }
                }.listRowBackground(Color.clear)
            }

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollContentBackground(.hidden)
       
    }
}
