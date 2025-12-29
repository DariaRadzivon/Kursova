import SwiftUI

struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: book.volumeInfo.coverURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColor.lavender.opacity(0.3))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .interpolation(.high)
                        .scaledToFill()
                        .clipped()
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColor.lavender.opacity(0.3))
                        Image(systemName: "book.closed")
                            .foregroundColor(AppColor.inkBlack.opacity(0.7))
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.volumeInfo.title)
                    .font(.headline)
                    .foregroundColor(AppColor.inkBlack)

                if let authors = book.volumeInfo.authors?.joined(separator: ", ") {
                    Text(authors)
                        .font(.subheadline)
                        .foregroundColor(AppColor.inkBlack.opacity(0.7))
                        .lineLimit(2)
                }

                HStack(spacing: 6) {
                    if let category = book.volumeInfo.categories?.first {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(AppColor.softMint.opacity(0.5))
                            )
                            .foregroundColor(AppColor.inkBlack)
                    }

                    if let rating = book.volumeInfo.averageRating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                        .foregroundColor(AppColor.blushPink)
                    }
                }
            }

            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.paperWhite.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
       
       
    }
}
