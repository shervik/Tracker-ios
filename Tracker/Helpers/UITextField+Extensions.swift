//
//  UITextField+Extensions.swift
//  Tracker
//
//  Created by Виктория Щербакова on 31.03.2023.
//

import UIKit

extension UITextField {
    func indent(size:CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX,
                                             y: self.frame.minY,
                                             width: size,
                                             height: self.frame.height)
        )
        self.leftViewMode = .always
    }
}
