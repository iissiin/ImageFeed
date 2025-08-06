import Foundation
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

   func logout() {
       cleanCookies()
//       OAuth2TokenStorage.shared.removeToken()
       ProfileService.shared.clean()
       ProfileImageService.shared.clean()
       ImagesListService.shared.clean()
   }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
    
    
}
    
