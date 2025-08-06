import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("--uitesting")
        app.launchArguments = ["UITEST"]
        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(" ")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(" ")
        
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tableView = app.tables["ImagesListTableView"]
        
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Таблица не загрузилась")
        
        tableView.swipeUp()
        sleep(2)

        let cellToLike = tableView.cells.element(boundBy: 1)
        
        let likeButton = cellToLike.buttons["LikeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Кнопка лайка не найдена")

        likeButton.tap()
        sleep(2)
        
        likeButton.tap()
        sleep(2)

        cellToLike.tap()
        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Изображение не найдено")
        image.pinch(withScale: 3, velocity: 1) // Zoom in
        image.pinch(withScale: 0.5, velocity: -1) // Zoom out

        app.buttons["BackButton"].tap()
    }

    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["Dariya Issina"].exists)
        XCTAssertTrue(app.staticTexts["@iisssin"].exists)

        let logoutButton = app.buttons["LogoutButton"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()

        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))

        alert.scrollViews.otherElements.buttons["Да"].tap()
    }

}


