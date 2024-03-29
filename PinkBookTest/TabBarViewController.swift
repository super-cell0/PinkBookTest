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
        
        if let _ = viewController as? PostViewController {
            //TODO: 登陆判断待做
            
            var config = YPImagePickerConfiguration()
            
            //通用配置
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
            config.startOnScreen = .library
            config.screens = [.library, .photo, .video]
            config.maxCameraZoomFactor = 5
            
            //相册配置
            config.library.mediaType = .photo
            config.library.isSquareByDefault = false
            config.library.defaultMultipleSelection = true
            config.library.maxNumberOfItems = 9
            config.library.minNumberOfItems = 1
            config.library.numberOfItemsInRow = 4
            config.library.spacingBetweenItems = 1.0
            config.library.skipSelectionsGallery = false
            config.library.preselectedItems = nil
            config.library.preSelectItemOnMultipleSelection = true
            
            config.gallery.hidesRemoveButton = false
            
            //视频配置
            config.video.fileType = .mp4
            config.video.recordingTimeLimit = 60.0
            config.video.libraryTimeLimit = 60.0
            config.video.minimumTimeLimit = 3.0
            config.video.trimmerMaxDuration = 60.0
            config.video.trimmerMinDuration = 3.0
            
            let picker = YPImagePicker(configuration: config)
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                if cancelled {
                    print("用户取消了照片选取")
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
