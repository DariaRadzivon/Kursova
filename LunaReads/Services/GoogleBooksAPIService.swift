import Foundation

enum GoogleBooksAPIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

final class GoogleBooksAPIService {
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"

    func searchBooks(
        query: String,
        filters: BookFilterOptions,
        page: Int,
        pageSize: Int = 20
    ) async throws -> BooksResponse {
        var q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !filters.author.isEmpty {
            q += "+inauthor:\(filters.author)"
        }
        if !filters.genre.isEmpty {
            q += "+subject:\(filters.genre)"
        }
        if !filters.year.isEmpty {
            // Рік як додатковий текст у запиті
            q += "+\(filters.year)"
        }

        guard !q.isEmpty else {
            return BooksResponse(totalItems: 0, items: [])
        }

        var components = URLComponents(string: baseURL)
        let startIndex = page * pageSize

        components?.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "startIndex", value: String(startIndex)),
            URLQueryItem(name: "maxResults", value: String(pageSize)),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "langRestrict", value: "en")
        ]

        guard let url = components?.url else {
            throw GoogleBooksAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw GoogleBooksAPIError.requestFailed
        }

        do {
            let decoded = try JSONDecoder().decode(BooksResponse.self, from: data)
            return decoded
        } catch {
            throw GoogleBooksAPIError.decodingFailed
        }
    }
}
