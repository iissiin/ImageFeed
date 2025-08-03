import Foundation
import UIKit

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    func clean()
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}

    private var task: URLSessionTask?
    private var lastUsername: String?

    private(set) var avatarURL: String?
    
    func clean() {
            avatarURL = nil
    }

    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        if lastUsername == username {
            return
        }

        task?.cancel()
        lastUsername = username

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "NoToken", code: 0)))
            return
        }

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }

            defer {
                self.task = nil
                self.lastUsername = nil
            }

            switch result {
            case .success(let decoded):
                let urlString = decoded.profileImage.large
                self.avatarURL = urlString

                completion(.success(urlString))

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": urlString]
                )

            case .failure(let error):
                print("[ProfileImageService]: Ошибка получения URL аватара")
                completion(.failure(error))
            }
        }


        task?.resume()
    }

}


struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
