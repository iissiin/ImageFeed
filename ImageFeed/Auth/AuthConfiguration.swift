import Foundation
import UIKit

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
