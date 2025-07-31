import Foundation
import UIKit

protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let shouldHideProgress = abs(newValue - 1.0) <= 0.0001
        view?.setProgressValue(Float(newValue))
        view?.setProgressHidden(shouldHideProgress)
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}


