import XCTest
@testable import ImageFeed

final class ProfilePresenterTests: XCTestCase {
    private var presenter: ProfilePresenter!
    private var view: MockProfileView!
    private var profileService: MockProfileService!
    private var profileImageService: MockProfileImageService!
    
    override func setUp() {
        super.setUp()
        view = MockProfileView()
        profileService = MockProfileService()
        profileImageService = MockProfileImageService()
        presenter = ProfilePresenter(
            view: view,
            profileService: profileService,
            profileImageService: profileImageService
        )
    }
    
    override func tearDown() {
        presenter = nil
        view = nil
        profileService = nil
        profileImageService = nil
        super.tearDown()
    }
    
    func test_viewDidLoad_callsUpdateProfileAndAvatar() {
        // Given
        let testProfile = Profile(
            username: "test",
            name: "Test User",
            loginName: "@test",
            bio: "Test bio"
        )
        profileService.profile = testProfile
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(view.didUpdateProfile, "updateProfileDetails должен быть вызван")
        
        let expectation = XCTestExpectation(description: "Wait for avatar update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.view.didUpdateAvatar, "updateAvatar должен быть вызван")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_logoutButtonTapped_showsLogoutConfirmation() {
        presenter.logoutButtonTapped()
        XCTAssertTrue(view.didShowLogoutAlert, "showLogoutConfirmation должен быть вызван")
    }
}

// MARK: - Mocks

private final class MockProfileView: ProfileViewProtocol {
    var didUpdateProfile = false
    var didUpdateAvatar = false
    var didShowLogoutAlert = false
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        didUpdateProfile = true
    }
    
    func updateAvatar(url: URL?) {
        didUpdateAvatar = true
    }
    
    func showLogoutAlert() {
        didShowLogoutAlert = true
    }
}

private final class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {}
    func clean() {}
    func setProfileForTesting(_ profile: Profile) {
        self.profile = profile
    }
}

private final class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("https://example.com/avatar.jpg"))
    }
    
    func clean() {}
}
