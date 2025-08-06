import XCTest
@testable import ImageFeed

// MARK: - Тесты
final class ImagesListViewControllerTests: XCTestCase {
    var viewController: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!

    override func setUp() {
            super.setUp()

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController

            presenterSpy = ImagesListPresenterSpy()
            viewController.presenter = presenterSpy

            viewController.loadViewIfNeeded()
    }

    func testViewDidLoad_CallsPresenterViewDidLoad() {
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testTableViewNumberOfRows_ReturnsPresenterPhotosCount() {
        presenterSpy.photosCount = 20

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        viewController.configure(presenterSpy)
        viewController.loadViewIfNeeded()

        viewController.setPhotos((0..<20).map { _ in presenterSpy.photo(at: IndexPath(row: 0, section: 0)) })

        let tableView = FakeTableView()
        tableView.dataSource = viewController

        let numberOfRows = viewController.tableView(tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(numberOfRows, 20)
    }



    func testWillDisplayCell_CallsPresenterWillDisplay() {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = UITableViewCell()

        viewController.tableView(FakeTableView(), willDisplay: cell, forRowAt: indexPath)

        XCTAssertEqual(presenterSpy.willDisplayIndexPath, indexPath)
    }

    func testReloadRows_PerformsReload() {
        let tableView = FakeTableView()
        viewController.setValue(tableView, forKey: "tableView")

        let indexPaths = [IndexPath(row: 0, section: 0)]
        viewController.reloadRows(at: indexPaths)

        XCTAssertEqual(tableView.reloadedRows, indexPaths)
    }

    func testInsertRows_PerformsInsert() {
        let tableView = FakeTableView()
        viewController.setValue(tableView, forKey: "tableView")

        let indexPaths = [IndexPath(row: 0, section: 0)]
        viewController.insertRows(at: indexPaths)

        XCTAssertEqual(tableView.insertedRows, indexPaths)
    }
}

// MARK: - Шпионы и подделки

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol?
    var viewDidLoadCalled = false
    var photosCount = 0

    var willDisplayIndexPath: IndexPath?
    var didSelectCellIndexPath: IndexPath?
    var didTapLikeIndexPath: IndexPath?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photo(at indexPath: IndexPath) -> Photo {
        return Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            regularImageURL: "",
            isLiked: false
        )
    }

    func didSelectCell(at indexPath: IndexPath) {
        didSelectCellIndexPath = indexPath
    }

    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayIndexPath = indexPath
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeIndexPath = indexPath
    }
}


final class ImagesListCellSpy: UITableViewCell {
    var setImageCalled = false

    func setImage(from photo: Photo) {
        setImageCalled = true
    }
}

final class FakeTableView: UITableView {
    var reloadedRows: [IndexPath] = []
    var insertedRows: [IndexPath] = []

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadedRows = indexPaths
    }

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertedRows = indexPaths
    }
}
