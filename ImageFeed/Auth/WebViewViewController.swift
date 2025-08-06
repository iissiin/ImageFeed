import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    var presenter: WebViewPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.navigationDelegate = self
        presenter?.view = self  
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] _, _ in
            guard let self else { return }
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        }
    }

    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = WebViewRequestHelper.extractCode(from: navigationAction) {
            decisionHandler(.cancel)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}




