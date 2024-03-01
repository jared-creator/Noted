//
//  HomeVC.swift
//  Noted
//
//  Created by JaredMurray on 1/25/24.
//

import UIKit

protocol HomeViewControllerDelegate: AnyObject {
    func didTapMenuButton()
    func didTapSaveButton()
}

class HomeVC: UIViewController {

    weak var delegate: HomeViewControllerDelegate?
    var currentNote: Notes?
    
    let textView = UITextView()
    let folderButton = ShowFolderButton(isOpened: false)
    let saveButton = SaveNoteButton()
    
    var isFromMenuView = false
    var noteInBackground = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Untitled"
        configureFolderButton()
        configureTextView()
        configureSaveButton()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: folderButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    func saveNewNote() {
        if isFromMenuView == true {
            guard let currentNote = currentNote else { return }
            currentNote.bodyText = textView.text
            currentNote.title = title
            CoreDataManager.shared.save()
        } else {
            guard !textView.text.isEmpty else {
                let alert = UIAlertController(title: "Such emptiness", message: "Make some changes to save", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
            }
            guard let bodyText = textView.text else { return }
            guard let title = title else { return }
            CoreDataManager.shared.createNewNote(title: title, bodyText: bodyText, folder: nil)
        }
    }
    
    @objc func didTapMenuButton() {
        textView.resignFirstResponder()
        delegate?.didTapMenuButton()
        folderButton.set()
        grayOutBackgroundView()
    }

    @objc func saveButtonTapped() {
        changeTitle()
        saveNewNote()
        delegate?.didTapSaveButton()
    }
    
    func grayOutBackgroundView() {
        noteInBackground.toggle()
        view.backgroundColor = noteInBackground ? .systemGray6 : .systemBackground
        textView.backgroundColor = noteInBackground ? .systemGray6 : .systemBackground
    }
    
    func configureTextView() {
        view.addSubview(textView)
        textView.delegate = self
        textView.configure(view: view)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func configureFolderButton() {
        folderButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
    }
    
    func configureSaveButton() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
}

extension HomeVC {
    
    func changeTitle() {
        if self.textView.text.isEmpty {
            self.title = "Untitled"
        } else {
            if let firstWord = textView.text.components(separatedBy: .whitespaces).first {
                self.title = firstWord
            }
        }
    }
}

extension HomeVC: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
       changeTitle()
    }
}
