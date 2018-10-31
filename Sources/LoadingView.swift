//
//  LoadingView.swift
//  PhotoPick
//
//  Created by carloscorreia on 23/07/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit

class LoadingView: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorView.Style.white)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyView: UIVisualEffectView
    
    fileprivate var vController: UIViewController?
    
    init(_ vController: UIViewController, origin: CGPoint? = nil) {
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        self.vController = vController
        super.init(effect: blurEffect)
        self.setup()
        
        vController.view.addSubview(self)
        
        if let or = origin {
            self.frame.origin = or
            
            if or.x == 0 {
                self.center.x = vController.view.center.x
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.text = "A carregar"
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)!
        self.setup()
        
    }
    
    func setup() {
        self.text = "A carregar"
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndictor)
        vibrancyView.contentView.addSubview(label)
        activityIndictor.startAnimating()
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            vibrancyView.backgroundColor = photoPickTintColor
            
            let width = superview.frame.size.width / 2.3
            let height: CGFloat = 50.0
            self.frame = CGRect(origin: CGPoint(x: superview.frame.size.width / 2 - width / 2,
                                                y: superview.frame.height / 2 - height / 2), size: CGSize(width: width, height: height))
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(origin: CGPoint(x: 5, y: height / 2 - activityIndicatorSize / 2), size: CGSize(width:
                activityIndicatorSize, height: activityIndicatorSize))
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(origin: CGPoint(x: activityIndicatorSize + 5,y: 0), size: CGSize(width: width - activityIndicatorSize - 15,height: height))
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
        self.superview!.bringSubview(toFront: self)

        
        if let vc = vController {
            vc.view.isUserInteractionEnabled = false
        }
    }
    
    func hide() {
        self.isHidden = true
        if let vc = vController {
            vc.view.isUserInteractionEnabled = true
        }
    }
}
