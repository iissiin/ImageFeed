import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var selectedIndexPath: IndexPath?
    private var presenter: ImagesListPresenterProtocol!
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter = ImagesListPresenter(view: self)
        presenter.viewDidLoad()
    }

    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count

        guard newCount > oldCount else {
            return
        }

        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            photos = newPhotos // <-- переместили сюда
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.regularImageURL),
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
        presenter.didSelectCell(at: indexPath) // опционально, если потребуется
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= photos.count - 3 {
            presenter.willDisplayCell(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath)
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
        presenter.didTapLike(at: indexPath)
    }
}


// MARK: - ImagesListViewProtocol
extension ImagesListViewController: ImagesListViewProtocol {
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func updateLikeStatus(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
    }

    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func setPhotos(_ photos: [Photo]) {
        self.photos = photos
    }

    func getPhotos() -> [Photo] {
        return photos
    }
}
