import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureBackButton()
        
        showWebView()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button_white")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button_white")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "black_Y")
    }
    
    private func showWebView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let webViewVC = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController else {
            assertionFailure("Не удалось найти WebViewViewController в storyboard")
            return
        }
        webViewVC.delegate = self
        webViewVC.modalPresentationStyle = .fullScreen
        present(webViewVC, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Успешная авторизация")
                    vc.dismiss(animated: true) {
                        guard let self else { return }
                        self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                    }
                case .failure(let error):
                    print("Ошибка при получении токена: \(error)")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }

}

