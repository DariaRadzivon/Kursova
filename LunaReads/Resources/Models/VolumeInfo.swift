import Foundation

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let description: String?
    let publishedDate: String?
    let pageCount: Int?
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let imageLinks: ImageLinks?
    
    var coverURL: URL? {
        // беремо thumbnail або smallThumbnail
        guard var urlString = imageLinks?.thumbnail ?? imageLinks?.smallThumbnail else {
            return nil
        }
        
        // http -> https, щоб iOS не блокувала
        if urlString.hasPrefix("http://") {
            urlString = "https://" + urlString.dropFirst("http://".count)
        }
        
        // трошки покращимо якість: zoom=1 -> zoom=2
        urlString = urlString.replacingOccurrences(of: "zoom=1", with: "zoom=2")
        
        return URL(string: urlString)
    }
}


