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
import AMapLocationKit

class NoteEditViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleCountLabel: UILabel! {
        didSet {
            titleCountLabel.isHidden = true
        }
    }
    @IBOutlet weak var textView: LimitedTextView!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var subChannelLabel: UILabel!
    @IBOutlet weak var speakerImaegView: UIImageView!
    @IBOutlet weak var poiLabel: UILabel!
    @IBOutlet weak var poiImageView: UIImageView!
    
    var channel = ""
    var subChannel = ""
    var poiName = ""
    
    var dragingIndexPath = IndexPath(item: 0, section: 0)
    
    var draftNote: DraftNote?
    var photos = [UIImage(named: "1")!, UIImage(named: "2")!,]
    //var videoURL: URL = Bundle.main.url(forResource: "testVideo", withExtension: "mp4")!
    var videoURL: URL?
    
    var isVideo: Bool { videoURL != nil }
    var textViewAccessoryView: TextViewAccessoryView { textView.inputAccessoryView as! TextViewAccessoryView }
    
    let locationManager = CLLocationManager()
    
    var updateDraftNoteFinished: (() -> ())?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        collectionView.dragInteractionEnabled = true
        
        // 1 软键盘消失
        collectionView.keyboardDismissMode = .onDrag
        
        titleTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        textViewConfig()
        
        textView.delegate = self
        
        //请求定位权限
        locationManager.requestWhenInUseAuthorization()
        AMapLocationManager.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        AMapLocationManager.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        
        AMapSearchAPI.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        AMapSearchAPI.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        
        print(NSHomeDirectory())
        //删掉启动页面的一些资源
        //        do {
        //            try FileManager.default.removeItem(atPath: "\(NSHomeDirectory())/Library/SplashBoard")
        //        } catch {
        //            fatalError()
        //        }
        
        setDraftNoteEditUI()
        
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
        guard titleTextField.markedTextRange == nil else { return }
        if titleTextField.unwrappedText.count > 20 {
            titleTextField.text = String(titleTextField.unwrappedText.prefix(20))
            self.showTextHUD(title: "标题最多输入\(20)个字")
            DispatchQueue.main.async {
                let end = self.titleTextField.endOfDocument
                self.titleTextField.selectedTextRange = self.titleTextField.textRange(from: end, to: end)
            }
            
        }
        titleCountLabel.text = "\(20 - titleTextField.unwrappedText.count)"
    }
    
    //MARK: - 保存草稿
    @IBAction func saveDraftNote(_ sender: Any) {
        guard isValidateNote() else { return }
        //更新草稿
        if let draftNote = draftNote {
            backgroundContext.perform {
                if !self.isVideo {
                    self.handlePhoto(draftNote: draftNote)
                }
                self.handleOthers(draftNote: draftNote)
                
                DispatchQueue.main.async {
                    self.updateDraftNoteFinished?()
                    self.showLoadHUD(title: "更新草稿成功")
                }
            }
            navigationController?.popViewController(animated: true)
            
        } else {
            //开启一个后台线程
            backgroundContext.perform {
                let draftNote = DraftNote(context: backgroundContext)
                // 视频
                if self.isVideo {
                    draftNote.video = try? Data(contentsOf: self.videoURL!)
                }
                // 图片
                self.handlePhoto(draftNote: draftNote)
                
                draftNote.isVideo = self.isVideo
                self.handleOthers(draftNote: draftNote)
                
                DispatchQueue.main.async {
                    self.showTextHUD(title: "保存草稿成功", currentView: false)
                }
            }
            dismiss(animated: true)
        }
        
    }
    
    //MARK: -创建草稿
    func handlePhoto(draftNote: DraftNote) {
        //封面图
        draftNote.coverPhoto = self.photos[0].jpeg(jpegQuality: .high)
        // 所有图片
        var dataPhotos: [Data] = []
        for photo in self.photos {
            if let pngData = photo.pngData() {
                dataPhotos.append(pngData)
            }
        }
        draftNote.photos = try? JSONEncoder().encode(dataPhotos)
    }
    
    func handleOthers(draftNote: DraftNote) {
        DispatchQueue.main.async {
            draftNote.draftTitle = self.titleTextField.exactText
            draftNote.draftText = self.textView.exactText
        }
        draftNote.draftChannel = self.channel
        draftNote.draftSubChannel = self.subChannel
        draftNote.draftPOIName = self.poiName
        draftNote.draftUpdateAt = Date()
        
        appDelegate.saveBackgroundContext()
    }
    
    @IBAction func postNote(_ sender: Any) {
        guard isValidateNote() else { return }
    }
    
    
    ///判断传入图片和字符限制
    func isValidateNote() -> Bool {
        guard !photos.isEmpty else {
            showTextHUD(title: "至少需要传入一张图片")
            return false
        }
        guard textViewAccessoryView.currentTextCount <= kMaxTextViewTextCount else {
            showTextHUD(title: "正文最多输入\(kMaxTextViewTextCount)个字")
            return false
        }
        return true
    }
    
    
    //MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChannelViewController {
            view.endEditing(true)
            vc.channelDelegate = self
        } else if let vc = segue.destination as? POIViewController {
            vc.delegaet = self
            vc.poiName = self.poiName //正向传值
        }
    }
    
}

//MARK: - 编辑草稿的UI
extension NoteEditViewController {
    
    func setDraftNoteEditUI() {
        if let draftNoet = draftNote {
            titleTextField.text = draftNoet.draftTitle
            textView.text = draftNoet.draftText
            channel = draftNoet.draftChannel!
            subChannel = draftNoet.draftSubChannel!
            poiName = draftNoet.draftPOIName!
            
            if !subChannel.isEmpty { updateChannelUI() }
            if !poiName.isEmpty { updatePOINameUI() }
        }
    }
    
    func updateChannelUI() {
        speakerImaegView.tintColor = .mainColor
        channelLabel.text = subChannel
        channelLabel.textColor = .mainColor
        subChannelLabel.isHidden = true
    }
    
    func updatePOINameUI() {
        if poiName == "" {
            poiImageView.tintColor = .label
            poiLabel.text = "添加地点"
            poiLabel.tintColor = .label
        } else {
            poiLabel.text = self.poiName
            poiLabel.textColor = .mainColor
            poiImageView.tintColor = .mainColor
        }
    }
    
    func textViewConfig() {
        textView.placeholder = "填写内容"
        //let lineFragmentPadding = textView.textContainer.lineFragmentPadding
        //textView.textContainerInset = UIEdgeInsets(top: 0, left: -lineFragmentPadding, bottom: 0, right: -lineFragmentPadding)
        
        if let textViewAccessoryViewNib = Bundle.main.loadNibNamed("TextViewAccessoryView", owner: nil)?.first as? TextViewAccessoryView {
            textView.inputAccessoryView = textViewAccessoryViewNib
            textViewAccessoryView.doneButton.addTarget(self, action: #selector(resignTextView), for: .touchUpInside)
            textViewAccessoryView.maxTextCountLabel.text = "/\(kMaxTextViewTextCount)"
        }
        
    }
    
}

//MARK: POIViewControllerDelegate
extension NoteEditViewController: POIViewControllerDelegate {
    func updatePOIName(poiName: String) {
        // 数据
        if poiName == "不显示位置" {
            self.poiName = ""
        } else {
            self.poiName = poiName
        }
        // UI
        updatePOINameUI()
    }
}

//MARK: ChannelViewControllerDelegate
extension NoteEditViewController: ChannelViewControllerDelegate {
    func updateChannel(channel: String, subChannel: String) {
        self.channel = channel
        self.subChannel = subChannel
        
        channelLabel.text = subChannel
        speakerImaegView.tintColor = .mainColor
        channelLabel.textColor = .mainColor
        subChannelLabel.isHidden = true
    }
    
    
}

//MARK: UITextViewDelegate
extension NoteEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard textView.markedTextRange == nil else { return }
        textViewAccessoryView.currentTextCount = textView.text.count
    }
}

//MARK: UITextFieldDelegate
extension NoteEditViewController: UITextFieldDelegate {
    // 2 软键盘消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        if range.location >= 20 || (textField.unwrappedText.count + string.count) > 20 {
    //            self.showTextHUD(title: "标题最多输入20个字")
    //            return false
    //        }
    //
    //        return true
    //    }
}

//MARK: UICollectionViewDataSource
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

//MARK: UICollectionViewDelegate
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

//MARK: UICollectionViewDragDelegate
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

//MARK: UICollectionViewDropDelegate
extension NoteEditViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        //if dragingIndexPath.section == destinationIndexPath?.section {}
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

//MARK: SKPhotoBrowserDelegate
extension NoteEditViewController: SKPhotoBrowserDelegate {
    
    func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
        photos.remove(at: index)
        collectionView.reloadData()
        reload()
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension NoteEditViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
}

//MARK: objc监听函数
extension NoteEditViewController {
    
    @objc func resignTextView() {
        textView.resignFirstResponder()
    }
    
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
