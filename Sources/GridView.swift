//
//  PickLibraryView.swift
//  PhotoPick
//
//  Created by carloscorreia on 23/07/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit

class GridView: UIView {

	/**
	 Draw a grid to be used when cropping a image

	 - parameter rect: CGRect
	 */

	override func draw(_ rect: CGRect) {

		let numberOfColumns = CGFloat(3.0) // number of columns by default
		let numberOfRows = CGFloat(3.0) // number of rows by default

		let context = UIGraphicsGetCurrentContext()
		context?.setLineWidth(0.5)
		context?.setStrokeColor(UIColor.lightGray.cgColor)

		// calculate column width
		let columnWidth = self.frame.size.width / numberOfColumns

		for i in 1 ..< Int(numberOfColumns) {
			var startPoint = CGPoint()
			var endPoint = CGPoint()

			startPoint.x = columnWidth * CGFloat(i)
			startPoint.y = 0.0

			endPoint.x = startPoint.x
			endPoint.y = self.frame.size.height

			context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
			context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
			context?.strokePath()
		}

		// calclulate row height
		let rowHeight = self.frame.size.height / numberOfRows

		for j in 1 ..< Int(numberOfRows) {
			var startPoint = CGPoint()
			var endPoint = CGPoint()

			startPoint.x = 0.0
			startPoint.y = rowHeight * CGFloat(j)

			endPoint.x = self.frame.size.width
			endPoint.y = startPoint.y

			context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
			context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
			context?.strokePath()
		}
	}
}
