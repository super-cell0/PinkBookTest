//
//  NoteEditViewController.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/8.
//

import UIKit
import YPImagePicker
import MBProgressHUD
import SKPhotoBrowser
import AVKit

class NoteEditViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleCountLabel: UILabel! {
        didSet {
            titleCountLabel.isHidden = true
        }
    }
    @IBOutlet weak var textView: UITextView!
    
    var dragingIndexPath = IndexPath(item: 0, section: 0)
    
    var photos = [UIImage(named: "1")!, UIImage(named: "2")!,]
    //var videoURL: URL = Bundle.main.url(forResource: "testVideo", withExtension: "mp4")!
    var videoURL: URL?
    var isVideo: Bool { videoURL != nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        collectionView.dragInteractionEnabled = true
        
        // 1 软键盘消失
        //collectionView.keyboardDismissMode = .onDrag
        
        titleTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func titleTextFieldEditingDidBegin(_ sender: Any) {
        titleCountLabel.isHidden = false
    }
    
    @IBAction func titleTextFieldEditingDidEnd(_ sender: Any) {
        titleCountLabel.isHidden = true
    }
    
    //点击软键盘的完成按钮收起键盘
    @IBAction func titleTextFieldDidEndOnExit(_ sender: Any) {
        
    }
    
    
    @IBAction func titleTextFieldEditingChanged(_ sender: Any) {
        titleCountLabel.text = "\(20 - titleTextField.unwrappedText.count)"
    }
    
    
    
}

extension NoteEditViewController: UITextFieldDelegate {
    
    // 2 软键盘消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location >= 20 || (textField.unwrappedText.count + string.count) > 20 {
            self.showTextHUD(title: "标题最多输入20个字")
            return false
        }
        
        return true
    }
    
}

extension NoteEditViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoItemID, for: indexPath) as! PhotoItem
        
        cell.photoImageView.image = photos[indexPath.item]
        cell.contentView.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kPhotoFooterID, for: indexPath) as! PhotoFooter
            
            footer.footerAddButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            
            return footer
        default:
            fatalError("collectionview Footer error")
        }
    }
    
    
}

extension NoteEditViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isVideo {
            let playerVC = AVPlayerViewController()
            playerVC.player = AVPlayer(url: videoURL!)
            present(playerVC, animated: true) {
                playerVC.player?.play()
            }
            
        } else {
            // 1. create SKPhoto Array from UIImage
            var images = [SKPhoto]()
            for photo in photos {
                let skPhoto = SKPhoto.photoWithImage(photo)
                images.append(skPhoto)
            }
            
            // 2. create PhotoBrowser Instance, and present from your viewController.
            let browser = SKPhotoBrowser(photos: images)
            browser.delegate = self
            browser.initializePageIndex(indexPath.item )
            
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayDeleteButton = true
            present(browser, animated: true, completion: {})
            
        }
    }
    
}

extension NoteEditViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //dragingIndexPath = indexPath
        let photosIndexPath = photos[indexPath.item]
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: photosIndexPath))
        dragItem.localObject = photosIndexPath
        return [dragItem]
    }
    //若需要拖拽多个 实现itemsForAddingTo
    //若需要拖拽时改变cell外观 需要实现dragPreviewParametersForItemAt
    
}

extension NoteEditViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        //        if dragingIndexPath.section == destinationIndexPath?.section {
        //
        //        }
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if coordinator.proposal.operation == .move,
           let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath,
           let destinationIndexPath = coordinator.destinationIndexPath {
            
            collectionView.performBatchUpdates {
                photos.remove(at: sourceIndexPath.item)
                photos.insert(item.dragItem.localObject as! UIImage, at: destinationIndexPath.item)
                collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
            }
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    
}


extension NoteEditViewController: SKPhotoBrowserDelegate {
    
    func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
        photos.remove(at: index)
        collectionView.reloadData()
        reload()
    }
}

extension NoteEditViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
}

extension NoteEditViewController {
    
    @objc func addPhoto() {
        if photos.count < 9 {
            var config = YPImagePickerConfiguration()
            
            //通用配置
            config.startOnScreen = .library
            config.screens = [.library]
            
            //相册配置
            config.library.mediaType = .photo
            config.library.isSquareByDefault = false
            config.library.defaultMultipleSelection = true
            config.library.maxNumberOfItems = (9 - photos.count)
            config.library.minNumberOfItems = 1
            config.library.numberOfItemsInRow = 4
            config.library.spacingBetweenItems = 1.0
            config.library.skipSelectionsGallery = false
            config.library.preselectedItems = nil
            config.library.preSelectItemOnMultipleSelection = true
            
            config.gallery.hidesRemoveButton = false
            
            let picker = YPImagePicker(configuration: config)
            
            picker.didFinishPicking { [unowned picker] items, _ in
                
                for item in items {
                    if case let .photo(photo) = item {
                        self.photos.append(photo.image)
                    }
                }
                
                self.collectionView.reloadData()
                
                picker.dismiss(animated: true, completion: nil)
            }
            
            present(picker, animated: true, completion: nil)
        } else {
            self.showTextHUD(title: "最多只能选择\(9)张照片")
        }
    }
    
}
