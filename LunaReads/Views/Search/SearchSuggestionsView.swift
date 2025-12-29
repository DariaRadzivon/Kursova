import SwiftUI

struct SearchSuggestionsView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView {   // скролим, коли багато варіантів
            VStack(spacing: 0) {
                ForEach(suggestions, id: \.self) { title in
                    Button {
                        onSelect(title)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColor.blushPink)
                                .font(.system(size: 15))

                            Text(title)
                                .foregroundColor(AppColor.inkBlack)
                                .font(.subheadline)
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)

                    // роздільник між рядками
                    if title != suggestions.last {
                        Divider()
                            .background(AppColor.lavender.opacity(0.3))
                    }
                }
            }
        }
        .frame(maxHeight: 220) // обмеження висоти дропдауну
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.paperWhite)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
    }
}
