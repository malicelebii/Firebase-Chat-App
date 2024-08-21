//
//  ChatViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 13.08.2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

protocol ChatViewDelegate: AnyObject {
    func didCreateConversation()
    func didFetchMessages()
    var otherUserEmail: String { get}
    var conversationId: String? { get }
}

class ChatViewController: MessagesViewController  {
    let chatViewModel = ChatViewModel()
    var otherUserEmail: String
    var conversationId: String?
    var isNewConversation = false
    
    init(otherUserEmail: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = otherUserEmail
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            chatViewModel.getAllMessagesForConversation(with: conversationId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatViewModel.view = self
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
    }
    
    func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            guard let self = self else { return }
            self.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: {[weak self] action in
            guard let self = self else { return }
            self.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: {[weak self] action in
            guard let self = self else { return }
            self.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { action in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] action in
            guard let self = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            let picker = UIImagePickerController()
             picker.sourceType = .photoLibrary
             picker.delegate = self
             picker.allowsEditing = true
             self.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like to attach from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] action in
            guard let self = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Video Library", style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        present(actionSheet, animated: true)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = chatViewModel.selfSender, let messageId = chatViewModel.createMessageId() else { return }
        
        print("Sending \(text)")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        // Send Message
        if isNewConversation {
            chatViewModel.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title)
        }else {
            guard let conversationId = conversationId, let name = self.title else { return }
            chatViewModel.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, message: message)
        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = chatViewModel.selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatViewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatViewModel.messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl)
        default:
            break
        }
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = chatViewModel.messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

extension ChatViewController: ChatViewDelegate {
    func didFetchMessages() {
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else { return }
            self.messagesCollectionView.reloadDataAndKeepOffset()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func didCreateConversation() {
        self.isNewConversation = false
    }
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = image.pngData(), let name = self.title else { return }
        
        // Upload image
        chatViewModel.uploadMessagePhoto(with: imageData, name: name)
        // Send message
    }
}
