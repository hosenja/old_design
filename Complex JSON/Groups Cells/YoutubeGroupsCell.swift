//
//  YoutubeGroupCell.swift
//  Snapgroup
//
//  Created by snapmac on 28/01/2019.
//  Copyright © 2019 snapmac. All rights reserved.
//

import UIKit

class YoutubeGroupsCell: UITableViewCell {
    
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
        
        let defaults = UserDefaults.standard
        let currency_type = defaults.string(forKey: "currency_type")
        let current_currency = defaults.float(forKey: "current_currency")

        var price_with_currancy: Float = 1
        if city.images != nil && (city.images?.count)! > 0 {
            let urlPhotot  = ApiRouts.Media + (city.images?[0].path)!
            self.group_image.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
        }else {
            self.group_image.image = UIImage(named: "img-default")
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
            if city.special_price != nil {
                price_with_currancy = (city.special_price)! * current_currency
                self.newPrice.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy)))"
                if city.price != nil {
                    price_with_currancy = ((Float((city.price)!)))! * current_currency

                    self.oldPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy)))))"
                    self.oldPriceView.isHidden = false
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true

                }
            }else{
                if city.price != nil {
                    price_with_currancy = ((Float((city.price)!)))! * current_currency

                    self.newPrice.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", price_with_currancy))))))"
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
    

    
    static func cellHeight() -> CGFloat {
        return 120
    }
}
