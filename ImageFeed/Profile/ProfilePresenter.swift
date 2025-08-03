import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    init(
        view: ProfileViewProtocol? = nil,
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        
        view?.updateProfileDetails(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio ?? ""
        )
        
        profileImageService.fetchProfileImageURL(username: profile.username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let urlString):
                let url = URL(string: urlString)
                DispatchQueue.main.async {
                    self.view?.updateAvatar(url: url)
                }
            case .failure(let error):
                print("Ошибка загрузки аватара: \(error)")
            }
        }
    }
    
    func logoutButtonTapped() {
        view?.showLogoutAlert()
    }
}
