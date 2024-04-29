//
//  DraftNoteWaterfallCell.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/28.
//

import UIKit

class DraftNoteWaterfallCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var isVideoImageView: UIImageView!
    
    var draftNotes: DraftNote? {
        didSet {
            guard let draftNote = draftNotes else { return }
            titleLabel.text = draftNote.draftTitle!.isEmpty ? "无题" : draftNote.draftTitle
            isVideoImageView.isHidden = !draftNote.isVideo
            photoImageView.image = UIImage(data: draftNote.coverPhoto) ?? UIImage(named: "testPhoto")!
            dateLabel.text = draftNote.draftUpdateAt?.formattedDate
        }
    }
    
    
}
