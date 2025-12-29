import SwiftUI

struct BookFiltersView: View {
    @Binding var filters: BookFilterOptions

    let onApply: () -> Void
    let onClear: () -> Void

    // Статичні списки жанрів і років
    private let genres = [
        "", "Fantasy", "Romance", "Mystery", "Thriller",
        "Classics", "Science Fiction", "Non-fiction", "Poetry", "History"
    ]

    private let years: [String] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (1950...currentYear).reversed().map { String($0) }
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Автор – єдине поле
                VStack(alignment: .leading, spacing: 6) {
                    Text("Автор")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColor.inkBlack)

                    TextField("Наприклад: Jane Austen", text: $filters.author)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColor.paperWhite)
                                .shadow(radius: 1, y: 1)
                        )
                }

                // Жанр
                VStack(alignment: .leading, spacing: 6) {
                    Text("Жанр")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColor.inkBlack)

                    Menu {
                        Picker("Жанр", selection: $filters.genre) {
                            Text("Будь-який").tag("")
                            ForEach(genres, id: \.self) { genre in
                                if !genre.isEmpty {
                                    Text(genre).tag(genre)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(filters.genre.isEmpty ? "Будь-який жанр" : filters.genre)
                                .foregroundColor(
                                    filters.genre.isEmpty
                                    ? AppColor.inkBlack.opacity(0.5)
                                    : AppColor.inkBlack
                                )
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColor.paperWhite)
                                .shadow(radius: 1, y: 1)
                        )
                    }
                }

                // Рік
                VStack(alignment: .leading, spacing: 6) {
                    Text("Рік")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColor.inkBlack)

                    Menu {
                        Picker("Рік", selection: $filters.year) {
                            Text("Будь-який").tag("")
                            ForEach(years, id: \.self) { year in
                                Text(year).tag(year)
                            }
                        }
                    } label: {
                        HStack {
                            Text(filters.year.isEmpty ? "Будь-який рік" : filters.year)
                                .foregroundColor(
                                    filters.year.isEmpty
                                    ? AppColor.inkBlack.opacity(0.5)
                                    : AppColor.inkBlack
                                )
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColor.paperWhite)
                                .shadow(radius: 1, y: 1)
                        )
                    }
                }

                Spacer()

                // Кнопки
                HStack(spacing: 12) {
                    Button {
                        onClear()
                    } label: {
                        Text("Очистити")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColor.blushPink, lineWidth: 1.5)
                            )
                            .foregroundColor(AppColor.blushPink)
                    }

                    Button {
                        onApply()
                    } label: {
                        Text("Застосувати")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppColor.blushPink)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [AppColor.paperWhite, AppColor.softMint.opacity(0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Фільтри")
            .navigationBarTitleDisplayMode(.inline)
        } .onTapGesture {
                    hideKeyboard()
            }
    }
}
