import Foundation
import SwiftUI

struct ReadingListItem: Identifiable, Codable {
    let id: String              // book id
    let title: String
    let author: String
    let thumbnailURL: String?
    var noteImagesData: [Data] = []
    var notes: [ReadingNote]    // кілька текстових нотаток
    
    var uiImage: [UIImage] {
        noteImagesData.compactMap { UIImage(data: $0) }
    }
    
    var hasNoteImages: Bool {
        !noteImagesData.isEmpty
    }
    
    var coverURL: URL? {
        guard var urlString = thumbnailURL else { return nil }
        
        if urlString.hasPrefix("http://") {
            urlString = "https://" + urlString.dropFirst("http://".count)
        }
        
        urlString = urlString.replacingOccurrences(of: "zoom=1", with: "zoom=3")
        
        return URL(string: urlString)
    }
}
