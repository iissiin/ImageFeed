import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewProtocol?
    private let imagesListService = ImagesListService.shared

    init(view: ImagesListViewProtocol) {
        self.view = view
    }

    var photosCount: Int {
        return imagesListService.photos.count
    }

    func photo(at indexPath: IndexPath) -> Photo {
        return imagesListService.photos[indexPath.row]
    }

    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        imagesListService.fetchPhotosNextPage()
    }

    @objc private func didChangePhotos() {
        guard let view = view else { return }

        let newPhotos = imagesListService.photos
        let oldCount = view.getPhotos().count
        let newCount = newPhotos.count

        guard newCount > oldCount else { return }

        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        view.setPhotos(newPhotos)
        view.insertRows(at: indexPaths)
    }

    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row >= imagesListService.photos.count - 3 {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didSelectCell(at indexPath: IndexPath) {
        // логика останется в контроллере, только selectedIndexPath хранится
    }

    func didTapLike(at indexPath: IndexPath) {
        guard var photo = try? view?.getPhotos()[indexPath.row] else { return }

        UIBlockingProgressHUD.show()

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let newLikeStatus = !photo.isLiked

            let success = true // здесь будет реальный запрос

            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                if success {
                    photo.isLiked = newLikeStatus
                    var updatedPhotos = self.imagesListService.photos
                    updatedPhotos[indexPath.row] = photo
                    self.view?.setPhotos(updatedPhotos)
                    self.view?.updateLikeStatus(at: indexPath, isLiked: newLikeStatus)
                }
            }
        }
    }
}
