import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    private let key = "reading_list_items"

    func loadReadingList() -> [ReadingListItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        do {
            let items = try JSONDecoder().decode([ReadingListItem].self, from: data)
            return items
        } catch {
            print("Decoding error: \(error)")
            return []
        }
    }

    func saveReadingList(_ items: [ReadingListItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Encoding error: \(error)")
        }
    }
}
