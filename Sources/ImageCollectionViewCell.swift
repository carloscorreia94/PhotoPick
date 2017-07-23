//
//  PickLibraryView.swift
//  PhotoPick
//
//  Created by carloscorreia on 23/07/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var imageView: UIImageView!

	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
	}

	// Save cell state
	override var isSelected: Bool {
		get {
			return super.isSelected
		}

		set {
			if (super.isSelected != newValue) {
				super.isSelected = newValue

				if (newValue == true) {
					self.layer.borderWidth = 3
					self.layer.borderColor = UIColor.lightGray.cgColor
				} else {
					self.layer.borderWidth = 0
					self.layer.borderColor = UIColor.black.cgColor
				}
			}
		}
	}
}
