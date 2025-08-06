import Foundation
import UIKit

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likes: Int
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, likes, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
