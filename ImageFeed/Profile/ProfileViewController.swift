import Foundation
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        profileServiceObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("ProfileServiceDidUpdate"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let profile = notification.userInfo?["profile"] as? Profile else { return }
            self.updateProfileDetails(profile)
            self.loadAvatarForUsername(profile.username)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile)
            loadAvatarForUsername(profile.username)
        }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = profileServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func updateProfileDetails(_ profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }
    
    private func loadAvatarForUsername(_ username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            switch result {
            case .success(let urlString):
                DispatchQueue.main.async {
                    self?.updateAvatar()
                }
            case .failure(let error):
                print("Ошибка загрузки URL аватара: \(error)")
            }
        }
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            avatarImageView.image = UIImage(named: "Stub")
            return
        }

        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub"),
            options: [
                .processor(RoundCornerImageProcessor(cornerRadius: 35)),
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }
    
    private func logout() {
        ProfileLogoutService.shared.logout()

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let splashViewController = SplashViewController() 
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }


    @objc
    private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.logout()
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))

        present(alert, animated: true)
    }


    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = UIColor(named: "black_Y")
        setupAvatarImageView()
        setupNameLabel()
        setupUsername()
        setupDescriptionLabel()
        setupLogoutButton()
    }

    private func setupAvatarImageView() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Stub")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        avatarImageView = imageView
    }

    private func setupNameLabel() {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            label.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
        nameLabel = label
    }

    private func setupUsername() {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        loginNameLabel = label
    }

    private func setupDescriptionLabel() {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            label.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
        descriptionLabel = label
    }

    private func setupLogoutButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        logoutButton = button
    }
}
