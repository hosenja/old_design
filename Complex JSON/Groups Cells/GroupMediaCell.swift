//
//  GroupMediaCell.swift
//  Snapgroup
//
//  Created by snapmac on 25/12/2018.
//  Copyright © 2018 Black. All rights reserved.
//

import UIKit

class GroupMediaCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .red
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBOutlet weak var daysCount: UILabel!
    @IBOutlet weak var group_label: UILabel!
    @IBOutlet weak var group_image: UIImageView!
    @IBOutlet weak var group_date: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var slashImage: UIImageView!
    @IBOutlet weak var oldPriceView: UIView!
    @IBOutlet weak var viewPrice: UIStackView!


    public func makeCity(_ city: GroupItemObject){
        
        if city.images != nil && (city.images?.count)! > 0 {
            let urlPhotot  = ApiRouts.Media + (city.images?[0].path)!
            self.group_image.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
        }else {
            if city.image != nil {
                let urlPhotot  = ApiRouts.Media + (city.image)!
                
                self.group_image.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
            }else {
                self.group_image.image = UIImage(named: "img-default")
            }
           // self.group_image.image = UIImage(named: "img-default")
        }
        if city.translations != nil && (city.translations?.count)! >  0 {
            self.group_label.text = (city.translations?[0].title)!
            
        }
        if city.rotation != nil && (city.rotation)! == "reccuring"
        {
          self.daysCount.text = ""
            self.group_date.text = city.frequency != nil ? "\((city.frequency)!.capitalizingFirstLetter()) Tour": ""
        }else
        {
            self.daysCount.text = "\((city.days)!) Days"
            self.group_date.text = "\(city.start_date!.split(separator: "-")[2]) \(getMonthName(month: String(city.start_date!.split(separator: "-")[1]))) \(city.start_date!.split(separator: "-")[0]) "
            
        }
        if city.prices != nil && (city.prices?.count)! > 0 {
            if city.prices?[0].special_price != nil {
                self.newPrice.text = "£\((Int((city.prices?[0].special_price!)!)))"
                
                if city.prices?[0].price != nil {
                    self.oldPrice.text = "£\((((city.prices?[0].price)!)))"
                    self.oldPriceView.isHidden = false
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true

                }
            }else{
                if city.prices?[0].price != nil {
                    self.newPrice.text = "£\((((city.prices?[0].price)!)))"
                    self.oldPriceView.isHidden = true
                    self.oldPrice.text = ""
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    self.newPrice.text = ""

                }
            }
        }
    }
    func getMonthName(month: String) -> String{
        switch month {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        case "12":
            return "Dec"
        default:
            return "null"
        }
    }
    
    func setCityState(_ state: FCityState){
//        if state == .Paid {
//            imgState.image = UIImage(named: "icon-locked")
//        }
//        else if state == .Offline {
//            imgState.image = UIImage(named: "icon-available-offline")
//        }
//        else {
//            imgState.image = nil
//        }
    }
    
    
    static func cellHeight() -> CGFloat {
        return 140
    }
}
