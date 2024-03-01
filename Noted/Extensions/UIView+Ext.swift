//
//  ViewController+Ext.swift
//  Noted
//
//  Created by JaredMurray on 1/22/24.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
