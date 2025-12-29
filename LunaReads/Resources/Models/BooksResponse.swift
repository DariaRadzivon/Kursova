import Foundation

struct BooksResponse: Codable {
    let totalItems: Int?
    let items: [Book]?
}
