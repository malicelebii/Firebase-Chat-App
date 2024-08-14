//
//  NewConversationViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 31.07.2024.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    let searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.placeholder = "Search for users.."
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancel))
    }
    
    @objc func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
}
