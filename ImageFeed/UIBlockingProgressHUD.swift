import Foundation
import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
    }
    
    static func showWithoutAnimation() {
        window?.isUserInteractionEnabled = false
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
