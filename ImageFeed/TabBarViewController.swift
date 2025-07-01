import Foundation
import UIKit

final class TabBarViewController: UITabBarController {
       override func awakeFromNib() {
           super.awakeFromNib()
           let storyboard = UIStoryboard(name: "Main", bundle: .main)
           let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
           let profileViewController = ProfileViewController()
           profileViewController.tabBarItem = UITabBarItem(
               title: "",
               image: UIImage(named: "ProfileViewController"),
               selectedImage: nil
           )
           self.viewControllers = [imagesListViewController, profileViewController]
       }
   }
