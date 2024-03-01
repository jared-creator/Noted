//
//  ConfirmButton.swift
//  Noted
//
//  Created by JaredMurray on 2/13/24.
//

import UIKit

class CreateFolderButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, image: String) {
        self.init(frame: .zero)
        set(title: title, image: image)
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        configuration = .tinted()
        configuration?.baseForegroundColor = .systemBlue
        configuration?.buttonSize = .small
        configuration?.cornerStyle = .large
        configuration?.imagePadding = 6
    }
    
    func set(title: String, image: String) {
        configuration?.title = title
        configuration?.image = UIImage(systemName: image)
    }
    
}
