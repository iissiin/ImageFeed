import Foundation
import SwiftKeychainWrapper

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}

    private var task: URLSessionTask?
    private var lastCode: String?
    private let tokenStorage = OAuth2TokenStorage()

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            DispatchQueue.main.async {
                completion(.failure(AuthServiceError.invalidRequest))
            }
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = AuthHelper.shared.makeAuthTokenRequest(with: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlSessionError))
            }
            return
        }

        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }

            defer {
                self.task = nil
                self.lastCode = nil
            }

            switch result {
            case .success(let response):
                let token = response.accessToken
                DispatchQueue.main.async {
                    self.tokenStorage.token = token
                    completion(.success(token))
                }
            case .failure(let error):
                print("[OAuth2Service]: Ошибка авторизации")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }


}

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let tokenKey = "OAuthToken"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }

    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
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
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        return request
    }
    
    func authRequest() -> URLRequest? {
        WebViewRequestHelper.makeAuthRequest(from: AuthConfiguration.standard)
    }
}
