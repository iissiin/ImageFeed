import Foundation

protocol ImagesListPresenterProtocol {
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo
    func didSelectCell(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}
