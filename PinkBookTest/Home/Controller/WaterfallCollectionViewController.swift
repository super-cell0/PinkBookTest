//
//  WaterfallCollectionViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import XLPagerTabStrip
import CoreData


class WaterfallCollectionViewController: UICollectionViewController, CHTCollectionViewDelegateWaterfallLayout, IndicatorInfoProvider {
    
    var channel = ""
    let photos = [UIImage(named: "testPhoto")!, UIImage(named: "testPhoto")!]
    var draftNotes: [DraftNote] = []
    
    var isMyDraft = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.minimumColumnSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
        layout.itemRenderDirection = .leftToRight
        
        if isMyDraft {
            navigationItem.title = "本地草稿"
        }
        
        getDraftNotes()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isMyDraft {
            return draftNotes.count
        } else {
            return photos.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isMyDraft {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDraftNoteWaterfallCellID, for: indexPath) as! DraftNoteWaterfallCell
            cell.draftNotes = self.draftNotes[indexPath.item]
            cell.deleteButton.tag = indexPath.item
            cell.deleteButton.addTarget(self, action: #selector(deleteDraftNoteAlert), for: .touchUpInside)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWatefallCellID, for: indexPath) as! WaterfallCollectionViewCell
        
            cell.imageView.image = photos[indexPath.item]
        
            return cell

        }
    }
    
    @objc func deleteDraftNoteAlert(sender: UIButton) {
        let indexPath = sender.tag
        let alertController = UIAlertController(title: "提示", message: "确认删除该草稿吗？", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "取消", style: .cancel)
        let action2 = UIAlertAction(title: "确认", style: .destructive) { _ in
            backgroundContext.perform {
                // 数据
                let draftNoteIndex = self.draftNotes[indexPath]
                backgroundContext.delete(draftNoteIndex)
                appDelegate.saveBackgroundContext()
                self.draftNotes.remove(at: indexPath)
                // UI
                DispatchQueue.main.async {
//                    self.collectionView.performBatchUpdates {
//                        self.collectionView.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
//                    }
                    self.collectionView.reloadData()
                    self.showTextHUD(title: "删除草稿成功")
                }
            }
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        present(alertController, animated: true)
        
    }


}

extension WaterfallCollectionViewController {
    //MARK: - 跳转到笔记编辑页面
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isMyDraft {
            let draftNote = self.draftNotes[indexPath.item]
            if let photoData = draftNote.photos,
               let photoDataArray = try? JSONDecoder().decode([Data].self, from: photoData) {
                
                let photos = photoDataArray.map { UIImage(data: $0) ?? UIImage(named: "testPhoto")! }
                let videoURL = FileManager.default.save(data: draftNote.video, directoryName: "video", fileName: "\(UUID().uuidString).mp4")
                let vc = storyboard?.instantiateViewController(identifier: kNoteEditViewControllerID) as! NoteEditViewController
                
                vc.draftNote = draftNote
                vc.photos = photos
                vc.videoURL = videoURL
                vc.updateDraftNoteFinished = {
                    self.getDraftNotes()
                    //self.collectionView.reloadData()
                }
                
                navigationController?.pushViewController(vc, animated: true)
                
            } else {
                showTextHUD(title: "加载草稿失败")
            }
        } else {
            
        }
    }
    
    //MARK: - 取出草稿数据
    func getDraftNotes() {
        let request = DraftNote.fetchRequest() as NSFetchRequest<DraftNote>
        //分页加载
        //request.fetchOffset = 0
        //request.fetchLimit = 20
        //筛选
        //request.predicate = NSPredicate(format: "title = %@", "ios")
        
        let sortDescriptor = NSSortDescriptor(key: "draftUpdateAt", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        request.propertiesToFetch = ["coverPhoto", "draftTitle", "draftUpdateAt", "isVideo"]
        
        showLoadHUD()
        backgroundContext.perform {
            if let draftNotes = try? backgroundContext.fetch(request) {
                self.draftNotes = draftNotes
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.hideLoadHUD()
            }
        }
    }
    
}

extension WaterfallCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellW = (UIScreen.main.bounds.width - 4 * 3) / 2
        var cellH: CGFloat = 0
        if isMyDraft {
            let draftNote = draftNotes[indexPath.item]
            let image = UIImage(data: draftNote.coverPhoto) ?? UIImage(named: "testPhoto")!
            let imageHeight = image.size.height
            let imageWidth = image.size.width
            let imageRatio = imageHeight / imageWidth
            let stack: CGFloat = 60.33 + 16
            cellH = cellW * imageRatio + stack
        } else {
            cellH = photos[indexPath.item].size.height
        }
        
        return CGSize(width: cellW, height: cellH)
    }

}

extension WaterfallCollectionViewController {
    
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
    return IndicatorInfo(title: channel)
    }

}
