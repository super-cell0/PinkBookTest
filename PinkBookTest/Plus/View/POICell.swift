//
//  POICell.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/22.
//

import UIKit

class POICell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var poi = ["", ""]{
        didSet {
            titleLabel.text = poi[0]
            addressLabel.text = poi[1]
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
