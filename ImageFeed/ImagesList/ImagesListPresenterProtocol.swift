import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func didTapLike(at indexPath: IndexPath)
    func willDisplayCell(at index: Int)
    func didSelectCell(at index: Int)
    func configure(cell: ImagesListCell, at index: Int)
    var selectedImageURL: URL? { get }
}
