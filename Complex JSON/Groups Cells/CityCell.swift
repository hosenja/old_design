//
//  CityCell.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage

class CityCell: UITableViewCell {

    static let className = "CityCell"
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var saleGroup: UIView!
    @IBOutlet weak var dailyFrequency: UILabel!
    @IBOutlet weak var dailyLbl: UILabel!
    @IBOutlet weak var dailyView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var intrestedLbl: UILabel!
    /// pprice stack
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var oldPriceView: UIView!
    @IBOutlet weak var viewPrice: UIStackView!
    @IBOutlet weak var allPriceView: UIView!
    
    // prce with currency
    @IBOutlet weak var oldPriceCurrency: UILabel!
    @IBOutlet weak var newPriceCurrency: UILabel!
    @IBOutlet weak var oldPriceViewCurrency: UIView!
    @IBOutlet weak var viewPriceCurrency: UIView!
    
    
    
    var openVideoIntro : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func makeCity(_ city: GroupItemObject){
       
        self.labelName.text = (city.translations?[0].title)!
        if city.images != nil && (city.images?.count)! > 0 {
            let urlPhotot  = ApiRouts.Media + (city.images?[0].path)!
            self.imgBackground.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
        }else {
            self.imgBackground.image = UIImage(named: "img-default")
        }
        self.viewPrice.isHidden = false
        let defaults = UserDefaults.standard
        let currentCurrency = defaults.string(forKey: "currentCurrency")
        if city.prices != nil && (city.prices?.count)! > 0 {
            getCurrencyType(currencyType: currentCurrency!, city: city)
        }else {
            self.viewPriceCurrency.isHidden = true
            self.allPriceView.isHidden = true
        }
        if city.interested != nil && city.interested! != 0 {
            
            self.intrestedLbl.text = "\((city.interested)!) people interested"
        }else {
            
            self.intrestedLbl.text = "25 people interested"
        }
        if city.rotation != nil && (city.rotation)! == "reccuring"
        {
            
            self.dateLbl.text = city.frequency != nil ? "\((city.frequency)!.capitalizingFirstLetter()) Tour": ""
            if city.frequency != nil
            {
                self.dailyView.isHidden = false
                self.dailyLbl.text = city.frequency != nil ? "\((city.frequency)!.capitalizingFirstLetter()) Tour": ""
            }else
            {
                self.dailyLbl.text = ""
            }
        }else
        {
            self.dailyView.isHidden = true
            self.dateLbl.text = "\(city.start_date!.split(separator: "-")[2]) \(getMonthName(month: String(city.start_date!.split(separator: "-")[1]))) \(city.start_date!.split(separator: "-")[0]) , \((city.days)!) Days"

        }
        
        
    }
    func getCurrencyType(currencyType: String, city: GroupItemObject)  {
        let defaults = UserDefaults.standard
        let currency_type = defaults.string(forKey: "currency_type")
        let current_currency = defaults.float(forKey: "current_currency")
        var price_with_currancy: Float = 1
        
        var flag: Bool = false
        print("currencyType \(currencyType)")
        for currency in (city.prices?[0].currencies)! {
            
            if currency.type == currencyType {
                flag = true
                self.viewPriceCurrency.isHidden = true
                if (currency.special_price)  != nil{
                    
                    self.newPrice.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", currency.special_price!)))"
                    if currency.price != nil {
                      
                        self.oldPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", (currency.price)!)))))"
                        self.oldPriceView.isHidden = false
                    }else
                    {
                        self.oldPrice.text = ""
                        self.oldPriceView.isHidden = true
                        
                    }
                }else {
                    if currency.price != nil {
                       
                        self.newPrice.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", (currency.price)!))))))"
                        self.oldPriceView.isHidden = true
                        self.oldPrice.text = ""
                    }else
                    {
                        self.oldPrice.text = ""
                        self.oldPriceView.isHidden = true
                        self.newPrice.text = ""
                        
                    }
                }
                return
                
            }
        }
        if !flag {
            if currencyType == "gbp" {
            self.viewPriceCurrency.isHidden = true
            }else {
                self.viewPriceCurrency.isHidden = false
            }
            if (city.prices?[0].currencies?[0].special_price)  != nil{
                 price_with_currancy = (city.prices?[0].currencies?[0].special_price)! * current_currency
                self.newPrice.text = "£\(((city.prices?[0].currencies?[0].special_price)!))"
                self.newPriceCurrency.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy)))"
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    self.oldPriceCurrency.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy)))))"
                    self.oldPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                    self.oldPriceView.isHidden = false
                     self.oldPriceViewCurrency.isHidden = false
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    self.oldPriceViewCurrency.isHidden = true
                    
                }
            }else {
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    
                    self.newPriceCurrency.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy)))))"
                    self.newPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                    self.oldPriceView.isHidden = true
                     self.oldPriceViewCurrency.isHidden = true
                    self.oldPrice.text = ""
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    self.oldPriceViewCurrency.isHidden = true
                    self.newPrice.text = ""
                    
                }
            }
           
        }
        
    }

    @IBAction func actionPlayVideo(_ sender: Any) {
        if openVideoIntro != nil {
            openVideoIntro!()
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
    // get th
    
    static func cellHeight() -> CGFloat {
        return 330
    }
}
