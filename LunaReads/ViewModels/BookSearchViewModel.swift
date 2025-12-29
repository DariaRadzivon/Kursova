import Foundation
import Combine

@MainActor
final class BookSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var filters = BookFilterOptions()
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var canLoadMore: Bool = false

    private let apiService = GoogleBooksAPIService()
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    
    @Published var suggestions: [String] = []

    private var suggestionsTask: Task<Void, Never>?
    @Published var blockSuggestions: Bool = false


    func search() {
        currentPage = 0
        books = []
        canLoadMore = true
        errorMessage = nil

        Task {
            await fetchBooks(reset: true)
        }
    }

    func loadMoreIfNeeded(currentItem: Book?) {
        guard let currentItem else { return }
        let thresholdIndex = books.index(books.endIndex, offsetBy: -5)
        if books.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex,
           canLoadMore,
           !isLoading {
            Task {
                await fetchBooks(reset: false)
            }
        }
    }

    private func fetchBooks(reset: Bool) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !filters.author.isEmpty ||
              !filters.genre.isEmpty ||
              !filters.year.isEmpty else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await apiService.searchBooks(
                query: query,
                filters: filters,
                page: currentPage,
                pageSize: pageSize
            )

            let newBooks = response.items ?? []
            if reset {
                books = newBooks
            } else {
                books.append(contentsOf: newBooks)
            }

            let total = response.totalItems ?? 0
            let loadedCount = books.count
            canLoadMore = loadedCount < total && !newBooks.isEmpty

            if canLoadMore {
                currentPage += 1
            }
        } catch {
            errorMessage = "Щось пішло не так. Спробуй ще раз !!!"
        }
    }
    
    
    
    func queryChanged(_ text: String) {
        // скасовуємо попередній debounce
        suggestionsTask?.cancel()
        if canLoadMore {
            canLoadMore=false
            return
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // якщо дуже мало символів – не показуємо нічого
        guard trimmed.count >= 2 else {
            suggestions = []
            return
        }

        suggestionsTask = Task { [weak self] in
            // невеличкий timeout, наприклад 0.4 секунди
            try? await Task.sleep(nanoseconds: 400_000_000)

            guard !Task.isCancelled else { return }

            await self?.loadSuggestions(for: trimmed)
        }
    }

    private func loadSuggestions(for query: String) async {
        do {
            // Використовуємо наш apiService і маленький "перший пакет" результатів
            let response = try await apiService.searchBooks(
                query: query,
                filters: BookFilterOptions(),   // без фільтрів, лише назва
                page: 0,
                pageSize: 10                    // нам багато не треба, тільки кілька назв
            )

            let books = response.items ?? []
            let titles = books.map { $0.volumeInfo.title }

            // Оновлюємо @Published на головному потоці
            await MainActor.run {
                self.suggestions = Array(Set(titles))
                    .sorted()
                    .prefix(6)
                    .map { String($0.prefix(80)) }
            }
        } catch {
            await MainActor.run {
                self.suggestions = []
            }
        }
    }


}
