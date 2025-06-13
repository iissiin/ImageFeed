import Foundation
import UIKit

final class OAuth2Service {
    
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - Singleton
    static let shared = OAuth2Service()

    private init() {}

    // MARK: - Создание URLRequest
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Ошибка: неверный URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return request
    }

    // MARK: - Запрос токена
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Сетевая ошибка: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                self?.tokenStorage.token = tokenResponse.accessToken
                DispatchQueue.main.async {
                    completion(.success(tokenResponse.accessToken))
                }
            } catch {
                print("Ошибка декодирования токена: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
}
