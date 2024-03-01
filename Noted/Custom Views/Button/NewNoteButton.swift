//
//  NewNoteButton.swift
//  Noted
//
//  Created by JaredMurray on 2/9/24.
//

import UIKit

class NewNoteButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        configuration = .tinted()
        configuration?.title = "New Note"
        configuration?.baseForegroundColor = .systemBlue
        configuration?.buttonSize = .large
        configuration?.cornerStyle = .large
    }
    
}

#Preview {
    NewNoteButton()
}
