import Foundation
import UIKit

final class OAuth2TokenStorage {
    private let key = "OAuth2Token"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
