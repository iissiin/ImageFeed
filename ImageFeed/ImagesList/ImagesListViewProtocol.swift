import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func insertRows(at indexPaths: [IndexPath])
    func updateLikeStatus(at indexPath: IndexPath, isLiked: Bool)
    func reloadRow(at indexPath: IndexPath)
    func setPhotos(_ photos: [Photo])
    func getPhotos() -> [Photo]
}
