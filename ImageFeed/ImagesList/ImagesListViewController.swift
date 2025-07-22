import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var selectedIndexPath: IndexPath?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNotificationObserver()
        fetchInitialPhotos()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    private func fetchInitialPhotos() {
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map {
                    IndexPath(row: $0, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(0.2))], // Плавное появление
            completionHandler: { [weak self] result in
                switch result {
                case .success:
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                case .failure(let error):
                    print("Ошибка загрузки: \(error)")
                    cell.cellImage.image = UIImage(named: "placeholder")
                }
            }
        )
        
        cell.dateLabel.text = photo.createdAt.flatMap { dateFormatter.string(from: $0) } ?? ""
        
        cell.setIsLiked(photo.isLiked)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = selectedIndexPath
            else {
                assertionFailure("Invalid segue destination or indexPath")
                return
            }

            let photo = photos[indexPath.row]
            print("🔍 prepare segue: row \(indexPath.row), imageURL: \(photo.largeImageURL)")
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= photos.count - 3 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)
        imagesListCell.delegate = self
        
        return imagesListCell
    }
}

// MARK: - ImagesListCellDelegate


extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var photo = photos[indexPath.row]
        photo.isLiked.toggle()
        photos[indexPath.row] = photo

        cell.setIsLiked(photo.isLiked)

        print("❤️")
    }
}
//extension ImagesListViewController: ImagesListCellDelegate {
//    func imageListCellDidTapLike(_ cell: ImagesListCell) {
//        // Получаем indexPath
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        let photo = photos[indexPath.row]
//
//        // Блокируем UI и показываем лоадер
//        UIBlockingProgressHUD.show()
//
//        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
//            DispatchQueue.main.async {
//                UIBlockingProgressHUD.dismiss()
//
//                guard let self = self else { return }
//
//                switch result {
//                case .success:
//                    // Синхронизируем данные
//                    self.photos = self.imagesListService.photos
//
//                    // Обновляем конкретную ячейку (если она на экране)
//                    if let updatedCell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
//                        let updatedPhoto = self.photos[indexPath.row]
//                        updatedCell.setIsLiked(updatedPhoto.isLiked)
//                    }
//
//                case .failure(let error):
//                    print("❌ Ошибка при смене лайка: \(error.localizedDescription)")
//
//                    let alert = UIAlertController(
//                        title: "Ошибка",
//                        message: "Не удалось изменить состояние лайка. Попробуйте позже.",
//                        preferredStyle: .alert
//                    )
//                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
//                    self.present(alert, animated: true)
//                }
//            }
//        }
//    }
//}


