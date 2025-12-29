import SwiftUI

struct BookDetailView: View {
    let book: Book
    @EnvironmentObject private var readingListVM: ReadingListViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                coverImage.onTapGesture {
                    hideKeyboard()
            }
                infoSection.onTapGesture {
                    hideKeyboard()
            }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [AppColor.paperWhite, AppColor.softMint.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(book.volumeInfo.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    readingListVM.toggleBook(book)
                } label: {
                    Image(systemName: readingListVM.isInReadingList(book) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(AppColor.blushPink)
                }
                .accessibilityLabel(
                    readingListVM.isInReadingList(book)
                    ? "Видалити з списку для читання"
                    : "Додати до списку для читання"
                )
            }
        }
    }

    // MARK: - Обкладинка

    private var coverImage: some View {
        Group {
            if let url = book.volumeInfo.coverURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColor.lavender.opacity(0.4))
                            .frame(height: 280)
                            .overlay(ProgressView())

                    case .success(let image):
                        image
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)

                    case .failure:
                        placeholderCover

                    @unknown default:
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }
        }
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColor.lavender.opacity(0.35))
                .frame(height: 280)

            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(AppColor.inkBlack.opacity(0.6))
        }
        .shadow(radius: 8)
    }

    // MARK: - Інформація про книгу

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let authors = book.volumeInfo.authors?.joined(separator: ", ") {
                Text(authors)
                    .font(.headline)
                    .foregroundColor(AppColor.inkBlack.opacity(0.85))
            }

            HStack(spacing: 12) {
                if let published = book.volumeInfo.publishedDate {
                    Label(published, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(AppColor.inkBlack.opacity(0.7))
                }

                if let pages = book.volumeInfo.pageCount {
                    Label("\(pages) стор.", systemImage: "book")
                        .font(.subheadline)
                        .foregroundColor(AppColor.inkBlack.opacity(0.7))
                }
            }

            if let categories = book.volumeInfo.categories, !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppColor.softMint.opacity(0.5))
                                )
                                .foregroundColor(AppColor.inkBlack)
                        }
                    }
                }
            }

            if let rating = book.volumeInfo.averageRating {
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.subheadline)
                }
                .foregroundColor(AppColor.blushPink)
            }

            Divider()
                .padding(.vertical, 4)

            Text("Опис")
                .font(.headline)
                .foregroundColor(AppColor.inkBlack)

            Text(book.volumeInfo.description ?? "Немає опису цієї книги.")
                .font(.body)
                .foregroundColor(AppColor.inkBlack.opacity(0.9))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColor.paperWhite.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}
