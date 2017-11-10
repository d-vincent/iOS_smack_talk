//
//  LiveGamesView.swift
//  Smack Talk
//
//  Created by Drew McDonald on 10/18/17.
//  Copyright © 2017 Drew McDonald. All rights reserved.
//

import UIKit

@IBDesignable
class LiveGamesView: UIView {
    @objc var height = 1.0

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 1.0, height: height)
    }
}
