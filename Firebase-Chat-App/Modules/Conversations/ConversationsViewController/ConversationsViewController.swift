//
//  ViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 31.07.2024.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

protocol ConversationsViewDelegate: AnyObject {
    func didFetchConversations()
    func didCreateNewConversation(chatVC: UIViewController)
}

class ConversationsViewController: UIViewController {
    let conversationsViewModel = ConversationsViewModel()
    
    let spinner = JGProgressHUD(style: .dark)
    
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationsViewModel.view = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        addSubviews()
        setupTableView()
        conversationsViewModel.fetchConversations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
    }
    
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    @objc func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = {[weak self] result in
            guard let self = self else { return }
            print("\(result)")
            self.conversationsViewModel.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Hello World"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController(otherUserEmail: "asda@gmail.com")
        chatVC.title = "Mehmet Çelebi"
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension ConversationsViewController: ConversationsViewDelegate {
    func didFetchConversations() {
        tableView.isHidden = false
    }
    
    func didCreateNewConversation(chatVC: UIViewController) {
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
