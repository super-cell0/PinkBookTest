//
//  TabBarViewController.swift
//  PinkBookTest
//
//  Created by mac on 2024/1/10.
//

import UIKit
import YPImagePicker

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        var config = YPImagePickerConfiguration()
        let picker = YPImagePicker(configuration: config)
        
        //general configure
        config.isScrollToChangeModesEnabled = false
        config.onlySquareImagesFromCamera = false
        config.albumName = "PinkBookTest"
        //本地化处理后可以使用以下代码
        /*
        if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            config.albumName = appName
        } else {
            config.albumName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
        }
         */
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library, .photo, .video]
        //在相机上面添加的一层view
        config.overlayView = UIView()
        config.maxCameraZoomFactor = 5
        
        //library configure
        config.library.isSquareByDefault = false
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 9
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil
        config.library.preSelectItemOnMultipleSelection = true
        
        //video configure
        config.video.fileType = .mov
        config.video.recordingTimeLimit = 60.0
        config.video.libraryTimeLimit = 60.0
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 60.0
        config.video.trimmerMinDuration = 3.0
        
        if let vc = viewController as? PostViewController {
            let picker = YPImagePicker()
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    print(photo.fromCamera) // Image source (camera or library)
                    print(photo.image) // Final image selected by the user
                    print(photo.originalImage) // original image selected by the user, unfiltered
                }
                picker.dismiss(animated: true, completion: nil)
            }
            
            present(picker, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }

}
