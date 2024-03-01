//
//  ShowFolderButton.swift
//  Noted
//
//  Created by JaredMurray on 1/22/24.
//

import UIKit

class ShowFolderButton: UIButton {
    
    var isOpened = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        set()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(isOpened: Bool) {
        self.init(frame: .zero)
        set()
    }
    
    private func configure() {
        configuration = .borderless()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func set() {
        isOpened.toggle()
        configuration?.image = UIImage(systemName: isOpened ? "folder.fill.badge.minus" : "folder")
    }
}

#Preview {
    ShowFolderButton()
}
