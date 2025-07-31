import Foundation
import UIKit

enum Constants {
    static let accessKey = "5-YTRs6WN_CMtM23m_UGFu6mROM54mfkQnYnbXhZoCM"
    static let secretKey = "qsqibVlfi6qISE6ZrlW_cZhEdj1VSm50LCxCjXyKn9M"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    
    static let accessScope = "public"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")!
}

struct AuthConfiguration {
    static let standard = AuthConfiguration()

    let authURLString: String
    let accessKey: String
    let redirectURI: String
    let accessScope: String

    private init(
        authURLString: String = "https://unsplash.com/oauth/authorize",
        accessKey: String = Constants.accessKey,
        redirectURI: String = Constants.redirectURI,
        accessScope: String = Constants.accessScope
    ) {
        self.authURLString = authURLString
        self.accessKey = accessKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
    }
}
