import Foundation
import UIKit

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likes: Int
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
