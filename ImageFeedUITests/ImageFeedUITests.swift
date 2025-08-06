import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    private let sleepTimeout: UInt32 = 3
    
    override func setUpWithError() throws {
        continueAfterFailure = false
//        app.launchArguments.append("--uitesting")
        app.launch()
    }

//    func testAuth() throws {
//        app.buttons["Authenticate"].tap()
//        
//        let webView = app.webViews["UnsplashWebView"]
//        
//        XCTAssertTrue(webView.waitForExistence(timeout: 5))
//
//        let loginTextField = webView.descendants(matching: .textField).element
//        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
//        
//        loginTextField.tap()
//        loginTextField.typeText("issina080208@gmail.com")
//        webView.swipeUp()
//        
//        let passwordTextField = webView.descendants(matching: .secureTextField).element
//        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
//        
//        passwordTextField.tap()
//        
//        // 💤 ВРЕМЯ ДЛЯ РУЧНОГО ВВОДА ПАРОЛЯ
//        sleep(10) // У тебя есть 10 секунд чтобы ввести пароль вручную
//        
//        webView.swipeUp()
//        webView.buttons["Login"].tap()
//        
//        let tablesQuery = app.tables
//        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
//        
//        XCTAssertTrue(cell.waitForExistence(timeout: 5))
//    }
    
    func testFeed() throws {
        // Ждем загрузки данных
        let tablesQuery = app.tables["ImagesListTableView"]
        XCTAssertTrue(tablesQuery.waitForExistence(timeout: 5))
        
        // Ждем появления хотя бы одной ячейки
        let firstCell = tablesQuery.cells["ImageCell_0"]
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        // Свайп вверх для подгрузки новых данных
        firstCell.swipeUp()
        
        // Ждем появления второй ячейки
        let secondCell = tablesQuery.cells["ImageCell_1"]
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))
        
        // Находим кнопку лайка во второй ячейке
        let likeButton = secondCell.buttons["like button"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
        
        // Лайк/анлайк
        likeButton.tap() // Первый тап - лайк
        sleep(1) // Ждем обновления состояния
        likeButton.tap() // Второй тап - анлайк
        sleep(1) // Ждем обновления состояния
        
        // Тап по ячейке для открытия SingleImageViewController
        secondCell.tap()
        
        // Проверяем, что открылся экран с изображением
        let imageView = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(imageView.waitForExistence(timeout: 3))
        
        // Зумим изображение
        imageView.pinch(withScale: 3, velocity: 1)
        imageView.pinch(withScale: 0.5, velocity: -1)
        
        // Возвращаемся назад
        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        
        // Проверяем, что вернулись на экран ленты
        XCTAssertTrue(tablesQuery.waitForExistence(timeout: 3))
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
