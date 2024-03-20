//
//  ContainerVC.swift
//  Noted
//
//  Created by JaredMurray on 1/25/24.
//

import UIKit

class ContainerVC: UIViewController {

    enum MenuState {
        case opened, closed
    }
    
    private var menuState: MenuState = .closed
    
    let menuVC = MenuVC()
    let homeVC = HomeVC()
    var navVC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        addChildVCs()
    }

    private func addChildVCs() {
        let navVC = UINavigationController(rootViewController: homeVC)
        let nav = UINavigationController(rootViewController: menuVC)
        
        menuVC.delegate = self
        addChild(nav)
        view.addSubview(nav.view)
        nav.didMove(toParent: self)
        
        homeVC.delegate = self
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        self.navVC = navVC
    }
    
}

extension ContainerVC: HomeViewControllerDelegate {
    func didTapSaveButton() {
        let newNote = CoreDataManager.shared.fetchNotes()
        self.menuVC.updateUI(with: newNote)
    }
    
    func didTapMenuButton() {
        toggleMenu(completion: nil)
    }
    
    func toggleMenu(completion: (() -> Void)?) {
        switch menuState {
        case .closed:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navVC?.view.frame.origin.x = self.homeVC.view.frame.size.width - 100
            } completion: { [weak self] done in
                guard let self else { return }
                if done {
                    self.homeVC.view.isUserInteractionEnabled = false
                    self.menuState = .opened
                }
            }
        case .opened:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navVC?.view.frame.origin.x = 0
            } completion: { [weak self] done in
                guard let self else { return }
                if done {
                    self.homeVC.view.isUserInteractionEnabled = true
                    self.menuState = .closed
                    completion?()
                }
            }
        }
    }
}

extension ContainerVC: MenuViewControllerDelegate {
    
    func didSelect(note: Notes?) {
        toggleMenu { [weak self] in
            guard let self else { return }
            guard let note = note else {
                DispatchQueue.main.async {
                    self.homeVC.title = "Untitled"
                    self.homeVC.textView.text = nil
                    self.homeVC.isFromMenuView = false
                    self.homeVC.folderButton.set()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.homeVC.title = note.title
                self.homeVC.textView.text = note.bodyText
                self.homeVC.folderButton.set()
                self.homeVC.isFromMenuView = true
                self.homeVC.currentNote = note
            }
        }
    }
}
