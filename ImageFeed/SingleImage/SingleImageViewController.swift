import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    private var hasLoadedImage = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !hasLoadedImage {
            loadImage()
            hasLoadedImage = true
        }
    }

    private func loadImage() {
        guard let imageURL = imageURL else {
                    print("❌ imageURL is nil в loadImage()")
                    return
                }
        
        activityIndicator.startAnimating()
                
        imageView.kf.setImage(with: imageURL) { [weak self] result in
               guard let self = self else { return }

               self.activityIndicator.stopAnimating()

               switch result {
               case .success(let imageResult):
                   print("📐 image size: \(imageResult.image.size)")
                   print("📐 imageView frame: \(self.imageView.frame)")
                   print("📐 scrollView frame: \(self.scrollView.frame)")
                   
                   self.imageView.image = imageResult.image
                   self.rescaleAndCenterImageInScrollView(image: imageResult.image)
               case .failure(let error):
                   self.showErrorAlert(message: error.localizedDescription)
               }
           }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
