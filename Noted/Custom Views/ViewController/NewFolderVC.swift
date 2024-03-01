//
//  NewFolderVC.swift
//  Noted
//
//  Created by JaredMurray on 2/13/24.
//

import UIKit

protocol NewFolderControllerDelegate: AnyObject {
    func comfirmTapped()
}

class NewFolderVC: UIViewController {

    weak var delegate: NewFolderControllerDelegate?
    
    enum buttonImage: String {
        case confirm = "checkmark.circle"
        case cancel = "xmark.circle"
    }
    
    let containerView = ContainerView()
    let folderName = UITextField()
    let confirmButton = CreateFolderButton(title: "Confirm", image: buttonImage.confirm.rawValue)
    let cancelButton = CreateFolderButton(title: "Cancel", image: buttonImage.cancel.rawValue)
    
    let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubviews(containerView, cancelButton, folderName, confirmButton)
        configureContainerView()
        configureTextField()
        configureCreateFolderButton()
        configureCancelButton()
    }
    
    func configureContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 350),
            containerView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func configureTextField() {
        folderName.translatesAutoresizingMaskIntoConstraints = false
        folderName.placeholder = "Folder name"
        folderName.textAlignment = .center
        folderName.autocorrectionType = .no
        
        NSLayoutConstraint.activate([
            folderName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            folderName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            folderName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            folderName.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureCreateFolderButton() {
        confirmButton.addTarget(self, action: #selector(addFolder), for: .touchUpInside)
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            confirmButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: padding),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            confirmButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureCancelButton() {
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -180),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func addFolder() {
        
        if folderName.text?.count == 0 {
            shakeAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.folderName.attributedPlaceholder = NSAttributedString(string: "Folder name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            }
            
        } else {
            guard let folderName = folderName.text else { return }
            CoreDataManager.shared.createNewFolder(name: folderName, notes: nil)
            delegate?.comfirmTapped()
            self.folderName.resignFirstResponder()
            self.folderName.text = ""
            dismiss(animated: true)
        }
    }
    
    @objc func cancel() {
        dismiss(animated: true)
    }
    
    private func shakeAnimation() {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "position.x")
        shakeAnimation.values = [0, 10, -10, 10, 0]
        shakeAnimation.keyTimes = [0, 0.16, 0.5, 0.83, 1]
        shakeAnimation.duration = 0.4
        shakeAnimation.isAdditive = true
        
        folderName.layer.add(shakeAnimation, forKey: "shake")
        folderName.attributedPlaceholder = NSAttributedString(string: "Folder name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
    }
    
}

#Preview {
    NewFolderVC()
}
