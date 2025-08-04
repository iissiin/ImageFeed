import Foundation
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    
    private var photos: [Photo] = []
    private var selectedIndex: Int?
    
    private let imagesListService = ImagesListService.shared
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(view: ImagesListViewProtocol? = nil) {
        self.view = view
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotos()
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count
        
        guard newCount > oldCount else { return }

        photos = newPhotos
        view?.updateTableViewAnimated()
    }
    
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard photos.indices.contains(indexPath.row) else { return }

        let photo = photos[indexPath.row]
        let isLike = !photo.isLiked

        view?.setLikeButtonEnabled(at: indexPath, isEnabled: false)

        imagesListService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                var updatedPhoto = photo
                updatedPhoto.isLiked = isLike
                self.photos[indexPath.row] = updatedPhoto
                self.view?.reloadCell(at: indexPath)

            case .failure:
                print("Failed to change like")
            }

            self.view?.setLikeButtonEnabled(at: indexPath, isEnabled: true)
        }
    }



    func willDisplayCell(at index: Int) {
        if index >= photos.count - 3 {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didSelectCell(at index: Int) {
        selectedIndex = index
    }

    var selectedImageURL: URL? {
        guard let selectedIndex else { return nil }
        return URL(string: photos[selectedIndex].largeImageURL)
    }

    func configure(cell: ImagesListCell, at index: Int) {
        let photo = photos[index]

        DispatchQueue.main.async {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: URL(string: photo.regularImageURL),
                placeholder: UIImage(named: "placeholder"),
                options: [.transition(.fade(0.2))],
                completionHandler: { result in
                    if case .failure(let error) = result {
                        print("Ошибка загрузки: \(error)")
                        cell.cellImage.image = UIImage(named: "placeholder")
                    }
                }
            )

            cell.dateLabel.text = photo.createdAt.flatMap { self.dateFormatter.string(from: $0) } ?? ""
            cell.setIsLiked(photo.isLiked)
        }
    }
}
