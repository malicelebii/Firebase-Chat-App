//
//  NewConversationViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 31.07.2024.
//

import UIKit
import JGProgressHUD

protocol NewConversationViewDelegate: AnyObject {
    func didSearchUser()
}

class NewConversationViewController: UIViewController {
    let newConversationViewModel = NewConversationViewModel()
    let spinner = JGProgressHUD(style: .dark)
    
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.placeholder = "Search for users.."
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newConversationViewModel.view = self
        addSubviews()
        setupTableView()
        setupSearchBar()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancel))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    @objc func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newConversationViewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = newConversationViewModel.users[indexPath.row]["name"]
        cell.textLabel?.text = user
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        spinner.show(in: view)
        newConversationViewModel.searchUsers(query: text)
    }
}

extension NewConversationViewController: NewConversationViewDelegate {
    func didSearchUser() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.spinner.dismiss()
            self.tableView.reloadData()
        }
    }
}
