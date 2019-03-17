//
//  ExampleCell.swift
//  Snapgroup
//
//  Created by snapmac on 27/01/2019.
//  Copyright © 2019 snapmac. All rights reserved.
//

import UIKit

class ExampleCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var title: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
