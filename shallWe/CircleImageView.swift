//
//  CircleImageView.swift
//  shallWe
//
//  Created by 北川雄太 on 2018/08/25.
//  Copyright © 2018年 Shunsuke Ueyama. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

    @IBInspectable var borderWidth :  CGFloat = 0.1
    @IBInspectable var borderColor :  UIColor = UIColor.black

    override var image: UIImage? {
        didSet{
            layer.masksToBounds = false
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            layer.cornerRadius = frame.height/2
            clipsToBounds = true
        }
    }
}
