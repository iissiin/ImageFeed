import Foundation

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(url: URL?)
    func showLogoutAlert()
}

protocol ProfilePresenterProtocol {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func logoutButtonTapped()
}
