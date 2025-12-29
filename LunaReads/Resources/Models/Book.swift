import Foundation

struct Book: Identifiable, Codable {
    let id: String
    let volumeInfo: VolumeInfo
}
