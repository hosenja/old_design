//
//  ImageMeTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 5/7/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class ImageMeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var meImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
