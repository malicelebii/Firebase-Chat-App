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
        tableView.register(ConversationsTableViewCell.self, forCellReuseIdentifier: ConversationsTableViewCell.identifier)
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
        conversationsViewModel.getAllConversations()
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
        return conversationsViewModel.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsTableViewCell.identifier, for: indexPath) as! ConversationsTableViewCell
        cell.accessoryType = .disclosureIndicator
        let model = conversationsViewModel.conversations[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let email = conversationsViewModel.conversations[indexPath.row].othetUserEmail
        let conversationId = conversationsViewModel.conversations[indexPath.row].id
        let chatVC = ChatViewController(otherUserEmail: email, id: conversationId)
        chatVC.title = conversationsViewModel.conversations[indexPath.row].name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let alertController = UIAlertController(title: "Delete Conversation", message: "Are you sure to delete this conversation ?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {[weak self] action in
                guard let self = self else { return }
                let conversationId = conversationsViewModel.conversations[indexPath.row].id
                conversationsViewModel.deleteConversation(conversationId: conversationId)
                self.conversationsViewModel.conversations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        default:
            break
        }
    }
}

extension ConversationsViewController: ConversationsViewDelegate {
    func didFetchConversations() {
        tableView.isHidden = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    func didCreateNewConversation(chatVC: UIViewController) {
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
