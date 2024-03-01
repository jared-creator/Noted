//
//  SaveNoteButton.swift
//  Noted
//
//  Created by JaredMurray on 1/31/24.
//

import UIKit

class SaveNoteButton: UIButton {

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
        configuration?.title = "Save"
        configuration?.baseForegroundColor = .systemBlue
        configuration?.buttonSize = .small
        configuration?.cornerStyle = .dynamic
    }
}

#Preview {
    SaveNoteButton()
}
