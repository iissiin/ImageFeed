import Foundation
import UIKit

func makeOAuthTokenRequest(code: String) -> URLRequest {
    let baseURL = URL(string: "https://unsplash.com")!
    
    let url = URL(
        string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
        relativeTo: baseURL
    )!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    return request
}
