import Foundation
import UIKit

final class ImagesListService {
    // MARK: - Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private var task: URLSessionTask?

    private let perPage = 10
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    func clean() {
            photos = []
            lastLoadedPage = 0
            task?.cancel()
            task = nil
        }

    // MARK: - Fetch Photos
    func fetchPhotosNextPage() {
        guard task == nil else { return }

        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")

        task = session.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.task = nil }

            guard let self = self else { return }

            if let data = data {
                do {
                    let photoResults = try self.decoder.decode([PhotoResult].self, from: data)
                    let newPhotos = photoResults.map { Photo(from: $0) }

                    DispatchQueue.main.async {
                        self.photos += newPhotos
                        self.lastLoadedPage = nextPage

                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self.photos]
                        )
                    }
                } catch {
                    print("Ошибка декодирования: \(error)")
                }
            } else if let error = error {
                print("Ошибка запроса: \(error)")
            }
        }

        task?.resume()
    }
    
    // MARK: - Like/Unlike
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "No token", code: 401)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = self.session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Server error", code: 0)))
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                }

                completion(.success(()))
            }
        }

        task.resume()
    }

}


// MARK: - struct
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        
        let formatter = ISO8601DateFormatter()
        self.createdAt = result.createdAt.flatMap { formatter.date(from: $0) }
        
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
