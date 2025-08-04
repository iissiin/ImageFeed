import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated()
    func reloadCell(at indexPath: IndexPath)
    func setLikeButtonEnabled(at indexPath: IndexPath, isEnabled: Bool)
}
