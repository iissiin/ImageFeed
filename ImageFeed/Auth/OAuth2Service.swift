import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()

    private var task: URLSessionTask?
    private var lastCode: String?
    private let tokenStorage = OAuth2TokenStorage()

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard lastCode != code else { return }
        task?.cancel()
        lastCode = code

        guard let request = AuthHelper.shared.makeAuthTokenRequest(with: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    self?.tokenStorage.token = token
                    completion(.success(token))
                } catch {
                    print("Failed to decode token: \(error)")
                    print(String(data: data, encoding: .utf8) ?? "<no response body>")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network error: \(error)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    private let tokenKey = "bearerToken"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}

// MARK: - AuthHelper

final class AuthHelper {
    static let shared = AuthHelper()

    private init() {}

    func makeAuthTokenRequest(with code: String) -> URLRequest? {
        let components = URLComponents(string: "https://unsplash.com/oauth/token")
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        return request
    }
}
