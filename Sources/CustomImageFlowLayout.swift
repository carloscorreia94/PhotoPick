//
//  PickLibraryView.swift
//  PhotoPick
//
//  Created by carloscorreia on 23/07/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout {

	var cellWidth: CGFloat = 0
	var numberOfColumns: CGFloat = 4 // number of columns by default

	override init() {
		super.init()
		setupLayout()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupLayout()
	}

	// Get the cell size to fit in a row
	override var itemSize: CGSize {
		set {
		}
		get {
			cellWidth = (self.collectionView!.frame.width - (numberOfColumns - 1)) / numberOfColumns
			return CGSize(width: cellWidth, height: cellWidth)
		}
	}

	/**
	 Setup grid layout
	 */
	func setupLayout() {
		minimumInteritemSpacing = 1
		minimumLineSpacing = 1
		scrollDirection = .vertical
	}
}
