import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private var isAuthenticating = false
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        guard !isAuthenticating else { return }
        performSegue(withIdentifier: "ShowWebView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView" {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                fatalError("Не удалось подготовить WebViewViewController")
            }
            webViewVC.delegate = self
            
            
        }
    }

}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        isAuthenticating = true
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                UIBlockingProgressHUD.dismiss()
                self.isAuthenticating = false
                
                switch result {
                case .success:
                    print("Успешная авторизация")
                    vc.dismiss(animated: true) {
                        self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                    }
                case .failure(let error):
                    print("Ошибка при получении токена: \(error)")
                    self.showLoginErrorAlert()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

// MARK: - Alert
extension AuthViewController {
    func showLoginErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
