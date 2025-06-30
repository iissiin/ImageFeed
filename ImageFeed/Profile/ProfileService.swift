import Foundation
import UIKit

final class ProfileService {
    private var task: URLSessionTask?
    private var lastToken: String?
    
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    func fetchProfile(
           _ token: String,
           completion: @escaping (Result<Profile, Error>) -> Void
       ) {
           assert(Thread.isMainThread)

           guard lastToken != token else {
               completion(.failure(ProfileServiceError.duplicateRequest))
               return
           }

           task?.cancel()
           lastToken = token

           guard let request = makeRequest(token: token) else {
               completion(.failure(ProfileServiceError.invalidRequest))
               return
           }

           task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
               guard let self = self else { return }

               defer {
                   self.task = nil
                   self.lastToken = nil
               }

               switch result {
               case .success(let profileResult):
                   let profile = Profile(
                       username: profileResult.username,
                       name: "\(profileResult.firstName) \(profileResult.lastName)",
                       loginName: "@\(profileResult.username)",
                       bio: profileResult.bio
                   )
                   self.profile = profile

                   NotificationCenter.default.post(
                       name: Notification.Name("ProfileServiceDidUpdate"),
                       object: nil,
                       userInfo: ["profile": profile]
                   )

                   completion(.success(profile))

               case .failure(let error):
                   print("Network error: \(error)")
                   completion(.failure(error))
               }
           }


           task?.resume()
       }

       private func makeRequest(token: String) -> URLRequest? {
           guard let url = URL(string: "https://api.unsplash.com/me") else {
               return nil
           }

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           return request
       }
}

// MARK: структуры
struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

