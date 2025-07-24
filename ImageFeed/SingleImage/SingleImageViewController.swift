import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    private var hasLoadedImage = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        imageView.translatesAutoresizingMaskIntoConstraints = true
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !hasLoadedImage {
            loadImage()
            hasLoadedImage = true
        }
    }

    private func loadImage() {
        guard let imageURL = imageURL else { return }

        ProgressHUD.animate()

        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }

            ProgressHUD.dismiss()

            switch result {
            case .success(let imageResult):
                self.imageView.image = imageResult.image
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        
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
        scrollView.layoutIfNeeded()
        
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size

        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height

        let scale = max(hScale, vScale) // 💥 Ключевой момент — делаем aspectFill поведение

        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale

        imageView.frame.size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        // Центрирование картинки по экрану
        let contentWidth = imageView.frame.width
        let contentHeight = imageView.frame.height

        let offsetX = max((contentWidth - visibleSize.width) / 2, 0)
        let offsetY = max((contentHeight - visibleSize.height) / 2, 0)

        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }

}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
