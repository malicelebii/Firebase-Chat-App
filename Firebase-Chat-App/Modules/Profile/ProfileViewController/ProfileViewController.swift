//
//  ProfileViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 31.07.2024.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var data = [ProfileView]()
    let profileViewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = createTableHeader()
        setProfileViewData()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (view.width - 150) / 2, y: 75, width: 150, height: 150))
        headerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        profileViewModel.setProfilePicture(for: path, imageView: imageView)
        return headerView
    }
    
    func showLogOutAlert() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure to log out ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            LoginManager().logOut()
            GIDSignIn.sharedInstance.signOut()
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let loginVC = LoginViewController()
                let navigationController = UINavigationController(rootViewController: loginVC)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            } catch {
                print("Failed to log out")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    func setProfileViewData() {
        data.append(ProfileView(viewType: .info, title: "Name: \(UserDefaults.standard.string(forKey: "name") ?? "No name")", handler: nil))
        data.append(ProfileView(viewType: .info, title: "Email: \(UserDefaults.standard.string(forKey: "email") ?? "No email")", handler: nil))
        data.append(ProfileView(viewType: .logout, title: "Logout", handler: { [weak self] in
            self?.showLogOutAlert()
        }))
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        cell.selectionStyle = .none
        if data[indexPath.row].viewType == .logout {
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        data[indexPath.row].handler?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
