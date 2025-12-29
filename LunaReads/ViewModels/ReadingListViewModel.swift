import Foundation
import UIKit
import Combine
import SwiftUI

@MainActor
final class ReadingListViewModel: ObservableObject {
    @Published private(set) var items: [ReadingListItem] = []
    
    private let persistence = PersistenceService.shared
    
    init() {
        load()
    }
    
    func load() {
        let loaded = persistence.loadReadingList()
        // про всяк випадок – якщо старі дані без notes
        items = loaded.map { item in
            if item.notes.isEmpty {
                var copy = item
                copy.notes = []
                return copy
            } else {
                return item
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }
    
    
    func toggleBook(_ book: Book) {
        if let index = items.firstIndex(where: { $0.id == book.id }) {
            items.remove(at: index)
        } else {
            let authors = book.volumeInfo.authors?.joined(separator: ", ") ?? "Невідомий автор"
            let thumbnail = book.volumeInfo.coverURL?.absoluteString
            let newItem = ReadingListItem(
                id: book.id,
                title: book.volumeInfo.title,
                author: authors,
                thumbnailURL: thumbnail,
                noteImagesData: [],   // ✅ порожній масив фото
                notes: []
            )
            
            items.append(newItem)
        }
        save()
    }
    
    func isInReadingList(_ book: Book) -> Bool {
        items.contains(where: { $0.id == book.id })
    }
    
    func item(withID id: String) -> ReadingListItem? {
        items.first(where: { $0.id == id })
    }
    
    // MARK: - Фото
    
    func attachNoteImage(to itemID: String, image: UIImage) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else { return }

        // ✅ додаємо ще одне фото, а не замінюємо старе
        items[index].noteImagesData.append(jpegData)
        save()
    }

    
    func removeNoteImage(from itemID: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].noteImagesData.removeAll()
        save()
    }

    func removeNoteImage(from itemID: String, imageData: Data) {
        guard let itemIndex = items.firstIndex(where: { $0.id == itemID }) else { return }

        if let imageIndex = items[itemIndex].noteImagesData.firstIndex(of: imageData) {
            items[itemIndex].noteImagesData.remove(at: imageIndex)
            save()
        }
    }
    
    // MARK: - Нотатки
    
    func addNote(to itemID: String, text: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let note = ReadingNote(text: trimmed)
        items[index].notes.insert(note, at: 0)
        save()
    }
    
    func updateNote(in itemID: String, note: ReadingNote, newText: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        guard let noteIndex = items[index].notes.firstIndex(of: note) else { return }
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items[index].notes[noteIndex].text = trimmed
        save()
    }
    
    func deleteNote(in itemID: String, note: ReadingNote) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].notes.removeAll { $0.id == note.id }
        save()
    }
    
    // MARK: - Persistence
    
    private func save() {
        persistence.saveReadingList(items)
    }
}
