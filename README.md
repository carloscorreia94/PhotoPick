## PhotoPick


# In Development! 

Still, you can already use it by adding the following to your Podfile.

```
use_frameworks!
pod 'PhotoPick', :git => 'https://github.com/carloscorreia94/PhotoPick.git', :branch => 'master', submodules: true
```

## Usage Method
Import PhotoPick ```import PhotoPick``` and give PhotoPickDelegate to the view controller.  

```Swift
let photoPick = PhotoPickViewController()
photoPick.delegate = self
self.presentViewController(photoPick, animated: true, completion: nil)
```

#### Delegate methods

```Swift
// Return the image which is selected from camera roll or is taken via the camera.
func pickImageSelected(_ image: UIImage, source: PickMode) {

  print("Image selected")
}


// Method called if user doesn't allow camera access.
func pickCameraRollUnauthorized() {

  print("Camera roll unauthorized")
}
```

#### Color Change

```Swift
photoPickTintColor: UIColor // tint color

photoPickBackgroundColor: UIColor // background color
```
