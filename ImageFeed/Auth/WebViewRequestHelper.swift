import Foundation
import UIKit
import WebKit

final class WebViewRequestHelper {
    static func makeAuthRequest(from config: AuthConfiguration) -> URLRequest? {
        var urlComponents = URLComponents(string: config.authURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: config.accessKey),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: config.accessScope)
        ]
        guard let url = urlComponents?.url else {
            return nil
        }
        return URLRequest(url: url)
    }

    static func extractCode(from navigationAction: WKNavigationAction) -> String? {
        guard
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }
}

