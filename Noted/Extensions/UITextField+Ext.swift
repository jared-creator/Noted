//
//  UITextField+Ext.swift
//  Noted
//
//  Created by JaredMurray on 2/23/24.
//

import UIKit

extension UITextView {
    
    func configure(view: UIView) {
        guard inputAccessoryView == nil else { return }
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        let textSize = UIBarButtonItem(title: "Font", image: UIImage(systemName: "textformat.size"), target: self, action: #selector(textFont))
        toolBar.items = [textSize, done, done, done, done]
        
        scrollView.addSubview(toolBar)
        scrollView.contentSize = toolBar.frame.size
        inputAccessoryView = scrollView
    }
    
    @objc func doneButtonPressed() {
        resignFirstResponder()
    }
    
    @objc func textFont() {
        print("Tapped")
    }
}
