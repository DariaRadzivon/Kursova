import SwiftUI

struct ReadingListRowView: View {
    let item: ReadingListItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: item.coverURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColor.lavender.opacity(0.3))
                        ProgressView()
                    }

                case .success(let image):
                    image
                        .resizable()
                        .interpolation(.high)                // чіткіше
                        .scaledToFill()                      // заповнює весь фрейм
                        .clipped()                           // обрізаємо зайве, щоб не було білих полів

                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColor.lavender.opacity(0.3))
                        Image(systemName: "book.closed")
                    }

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 90, height: 130)                    // збільшила розмір
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(AppColor.inkBlack)

                Text(item.author)
                    .font(.subheadline)
                    .foregroundColor(AppColor.inkBlack.opacity(0.7))

                if item.hasNoteImages {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                        Text("Є фото-нотатки")
                            .font(.caption)
                    }
                    .foregroundColor(AppColor.inkBlack)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
