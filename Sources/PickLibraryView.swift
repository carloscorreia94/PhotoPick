//
//  PickLibraryView.swift
//  PhotoPick
//
//  Created by carloscorreia on 23/07/17.
//  Copyright © 2017 carloscorreia94. All rights reserved.
//

import UIKit
import Photos

@objc public protocol PickLibraryViewDelegate: class {
    
    func albumViewCameraRollUnauthorized()
    func albumViewCameraRollAuthorized()
    func getViewController() -> UIViewController
}

class PickLibraryView : UIView, PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let GRID = "GRID".hashValue
    let CELLS = "CELLS".hashValue
    
    var imageView: UIImageView!
    var gridView: GridView!
    
    
    var gridIsActive = false
    
    var collectionViewLayout = CustomImageFlowLayout()
    
    var imageManager = PHCachingImageManager()
    var assets: PHFetchResult<PHAsset>?
    
    
    var optionsLowRes: PHImageRequestOptions!
    var optionsHighRes: PHImageRequestOptions!
    
    var loadingView : LoadingView!
    
    
    weak var delegate: PickLibraryViewDelegate? = nil

    static func instance() -> PickLibraryView {
        
        return UINib(nibName: "PickLibraryView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! PickLibraryView
    }
    
    func initialize() {
        loadingView = LoadingView(delegate!.getViewController(), origin: CGPoint(x: 0, y: self.center.y))
        
        self.backgroundColor = UIColor.darkGray
        
        // Init Images Collection View
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: self.classForCoder))
        collectionView.register(cellNib, forCellWithReuseIdentifier: "imageCell")
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.backgroundColor = UIColor.darkGray
        collectionView.tag = CELLS
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Never load photos Unless the user allows to access to photo album
        checkPhotoAuth()
        
        // Fetch and sort images by date
        let optionsSort = PHFetchOptions()
        optionsSort.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: optionsSort)
        
        scrollView.tag = GRID
        scrollView.delegate = self
        
        // Set double tap zoom
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        
        // Set images options for high resolution
        optionsHighRes = PHImageRequestOptions()
        optionsHighRes.deliveryMode = .highQualityFormat
        optionsHighRes.resizeMode = .none
        optionsHighRes.isSynchronous = false
        optionsHighRes.isNetworkAccessAllowed = true
        optionsHighRes.progressHandler = {
            (progress: Double,
            error: Error?,
            stop: UnsafeMutablePointer<ObjCBool>,
            info: [AnyHashable: Any]?) in
            print(Int(progress * 100))
            
        }
        
        PHPhotoLibrary.shared().register(self)


    }
    
    
    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            
            switch status {
                
            case .authorized:
                
               
                DispatchQueue.main.async {
                    
                    self.delegate?.albumViewCameraRollAuthorized()
                    self.updateLibrary()

                }
                
            case .restricted, .denied:
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.delegate?.albumViewCameraRollUnauthorized()
                })
                
            default:
                
                break
            }
        }
    }

    
    func updateLibrary() {
        print("call update library!")

        let optionsSort = PHFetchOptions()
        optionsSort.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: optionsSort)
        
        
        
        // Setup grid view
        gridView = GridView(frame: scrollView.frame)
        gridView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        gridView.isUserInteractionEnabled = false

        collectionView.reloadData()

    }
    
    /**
     UICollectionView delegate to set numbers of cells needed.
     
     - parameter collectionView: UICollectionView
     - parameter section:        number of items in section
     
     - returns: number of cells
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets == nil ? 0 : assets!.count
    }
    
    /**
     UICollectionView delegate to draw the cells with low resolution.
     
     - parameter collectionView: UICollectionView
     - parameter indexPath:      cell for item at index path
     
     - returns: cell
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                                                               for: indexPath) as! ImageCollectionViewCell
        
        let zeroIndexPath = IndexPath(row: 0, section: 0)
        if zeroIndexPath == indexPath {
            let isReady = PHPhotoLibrary.authorizationStatus() == .authorized

            if isReady && assets!.count > 0 && imageView == nil {
                let photo = assets![(zeroIndexPath as NSIndexPath).row] as! PHAsset
                showImage(photo)
                
                cell.isSelected = true
            }
        }

        
        
        
        let cellWidth = collectionViewLayout.cellWidth
        
        let asset = assets![(indexPath as NSIndexPath).row] as! PHAsset
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: cellWidth, height: cellWidth),
                                  contentMode: .aspectFill,
                                  options: nil) {
                                    (result, _) in
                                    cell.imageView?.image = result
        }
        
        
        return cell
    }
    
    /**
     UICollectionView delegate to know what cells was selected and show the image with the best resolution andn set selected state.
     
     - parameter collectionView: UICollectionView
     - parameter indexPath:      cell for item at index path
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                                                               for: indexPath) as! ImageCollectionViewCell
        
        cell.isSelected = true
        
        let photo = assets![(indexPath as NSIndexPath).row] as! PHAsset
        let isReady = PHPhotoLibrary.authorizationStatus() == .authorized
        if isReady {
            showImage(photo)
        }
    }
    
    /**
     UICollectionView delegate to know what cells was deselected and set deselected state.
     
     - parameter collectionView: UICollectionView
     - parameter indexPath:      cell for item at index path
     */
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                                                               for: indexPath) as! ImageCollectionViewCell
        
        cell.isSelected = false
    }
    
    
    func displayImage(imageRequested: UIImage) {
        // Images doesnt have same size, so we need to create a new imageView for each image
        let imageViewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: imageRequested.size)
        
        imageView?.removeFromSuperview()
        imageView = UIImageView(frame: imageViewFrame)
        imageView.backgroundColor = UIColor.darkGray
        imageView.image = imageRequested
        
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageRequested.size
        
        // Calculate the scale range for each image
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = minScale
        
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minScale * 1.3
        
        centerScrollViewContents()
    }
    
    /**
     Get the image with best resolution and show it on the preview.
     
     - parameter asset: image from library
     */
    func showImage(_ asset: PHAsset) {
        
        loadingView.show()
        let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManager.requestImage(for: asset,
                                  targetSize: imageSize,
                                  contentMode: .aspectFit,
                                  options: optionsHighRes,
                                  resultHandler: {
                                    (result: UIImage?,
                                    info: [AnyHashable: Any]?) in
                                    self.displayImage(imageRequested: result!)
                                    self.loadingView.hide()
        })
        
    }
    
    /**
     Center scroll view content after zooming.
     */
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    /**
     Zoom image with a double tap
     
     - parameter recognizer: UITapGestureRecognizer
     */
    func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        
        let pointInView = recognizer.location(in: imageView)
        
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
        
        scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    /**
     UIScrollView delegate when zooming.
     
     - parameter scrollView: UIScrollView
     
     - returns: image preview
     */
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /**
     UIScrollView delegate after zooming, center the image.
     
     - parameter scrollView: UIScrollView
     */
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    /**
     UIScrollView delegate when dragging the image, show the grid.
     
     - parameter scrollView: UIScrollView
     */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.tag == GRID && !gridIsActive {
            self.addSubview(gridView)
            gridIsActive = true
        }
    }
    
    /**
     UIScrollView delegate after dragging the image, remove the grid.
     
     - parameter scrollView: UIScrollView
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        gridView?.removeFromSuperview()
        gridIsActive = false
    }
    
    /**
     UIScrollView delegate when zooming the image, show the grid.
     
     - parameter scrollView: UIScrollView
     - parameter view:       UIView?
     */
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if scrollView.tag == GRID && !gridIsActive {
            self.addSubview(gridView)
            gridIsActive = true
        }
    }
    
    /**
     UIScrollView delegate after zooming the image, remove the grid.
     
     - parameter scrollView: UIScrollView
     - parameter view:       UIView?
     - parameter scale:      CGFloat
     */
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        gridView?.removeFromSuperview()
        gridIsActive = false
    }
    
    /**
     Crop the image selected in the scroll view.
     
     - returns: cropped image
     */
    func cropImage() -> UIImage? {
        if imageView.image == nil {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        // UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        
        return croppedImage
    }
    
    deinit {
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }

}

extension UIColor {
    
    convenience init(red: UInt32, green: UInt32, blue: UInt32, alphaH: UInt32) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alphaH >= 0 && alphaH <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alphaH) / 255.0)
    }
    
    convenience init(netHex: UInt32) {
        let mask : UInt32 = 0xff
        self.init(red: (netHex >> 16) & mask, green: (netHex >> 8) & mask, blue: netHex & mask, alphaH: (netHex >> 24) & mask)
    }
    
}

extension PickLibraryView {
    //MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        updateLibrary()
    }
}
