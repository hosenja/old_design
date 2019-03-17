//
//  EditPhoneNumberModal.swift
//  Snapgroup
//
//  Created by snapmac on 05/12/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import CountryPickerView
import PhoneNumberKit
import TTGSnackbar
import SwiftHTTP
import SwiftEventBus
class EditPhoneNumberModal: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    var contryCodeString : String = ""
    var contryCode : String = ""
    var phoneNumber: String = ""
    @IBOutlet weak var countyCodePickerView: CountryPickerView!
    @IBOutlet weak var phoneLbl: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        countyCodePickerView.delegate = self
        countyCodePickerView.dataSource = self
        countyCodePickerView.font =  UIFont(name: "Arial", size: 14)!
        countyCodePickerView.textColor = Colors.grayColor
        countyCodePickerView.showPhoneCodeInView = true
        countyCodePickerView.showCountryCodeInView = false
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        let country = cpv.selectedCountry
        contryCodeString = country.phoneCode
        contryCode = country.code
        if MyVriables.currentPhoneNumber == nil || MyVriables.currentPhoneNumber == "" || MyVriables.currentPhoneNumber == "Phone" {
            
        }else {
            phoneLbl.text = MyVriables.currentPhoneNumber!
            let phoneNUmber12 = MyVriables.currentPhoneNumber!
            let phoneNumberKit2 = PhoneNumberKit()
            do {
                let phoneNumber = try phoneNumberKit2.parse(phoneNUmber12)
                print("phone number before parsing \(phoneNumber.countryCode)  \(contryCodeString)")
                self.phoneLbl.text = self.phoneLbl.text?.deletingPrefix("+\(phoneNumber.countryCode)")
                countyCodePickerView.setCountryByCode("+\(phoneNumber.countryCode)")
                countyCodePickerView.setCountryByPhoneCode("+\(phoneNumber.countryCode)")
                
            }
            catch {
            }
        }
        
    }
    func isValidPhone(phone: String) -> Bool {
        let phoneNumberKit = PhoneNumberKit()
        do {
            print("phone number   \(phone)")
            
            let phoneNumber = try phoneNumberKit.parse(phone)
            print("phone number before parsing \(phoneNumber)")
            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(phone, withRegion: contryCode, ignoreType: true)
            print("phone number after parsing \(phoneNumberCustomDefaultRegion)")
            return true
        }
        catch {
            
            let snackbar = TTGSnackbar(message: "Phone Number is eror please enter a valditae phone number ", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
            print("Generic parser error")
            return false
        }
        print("Phone is \(phone)")
        
        return false
    }

    @IBAction func savePhone(_ sender: Any) {
        
        
        //api/members/{member_id}/phone?no_password=true
        DispatchQueue.global(qos: .userInitiated).async {
            // Do long running task here
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                if self.isValidPhone(phone: self.contryCodeString+self.phoneLbl.text!)
                {
                    
                    //print("\(self.contryCodeString)\(self.phoneNumberFeild.text!)")
                    self.phoneNumber = self.contryCodeString+self.phoneLbl.text!
                    if self.contryCodeString == "+972" {
                        if self.phoneLbl.text!.count > 4 && self.phoneLbl.text![0...0] == "0" {
                            self.phoneLbl.text!.remove(at: self.phoneLbl.text!.startIndex)
                            self.phoneLbl.text = "\(self.contryCodeString)\(self.phoneLbl.text!)"
                            print("yes im inside \(self.phoneNumber)")
                            
                            
                        }
                    }
                    let VerifyAlert = UIAlertController(title: "Verify", message: "is this is your phone number? \n \(self.phoneNumber)", preferredStyle: .alert)
                    
                    
                    VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
                        let defaults = UserDefaults.standard
                        let id = defaults.integer(forKey: "member_id")
                        print(ApiRouts.Web + "/api/members/\(id)/phone?no_password=true")
                        
                        HTTP.PUT(ApiRouts.Api + "/members/\(id)/phone?no_password=true", parameters: ["phone" : self.phoneNumber, "country_code" : self.contryCodeString]) { response in
                            if response.error != nil {
                                DispatchQueue.main.async {
                                    let snackbar = TTGSnackbar(message: "The phone number you selected is already linked to a different account.", duration: .middle)
                                    snackbar.icon = UIImage(named: "AppIcon")
                                    snackbar.show()
                                }
                                print("error \(response.error?.localizedDescription)")
                                return
                            }
                            print ("successed")
                            DispatchQueue.main.sync {
                                //
                                self.setToUserDefaults(value: self.phoneNumber, key: "phone")
                                print("Phone number is \(self.phoneNumber)")
                                
                                SwiftEventBus.post("UpdatePhone", sender: self.phoneNumber)
                                SwiftEventBus.post("changeProfileInfo")
                               // self.checkCurrentUser()
                                self.dismiss(animated: false, completion: nil)
                                
                            }
                            //do things...
                        }
                        
                        
                        
                    }))
                    VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
                        print("no")
                        
                        
                        
                    }))
                    self.present(VerifyAlert, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    func setToUserDefaults(value: Any?, key: String){
        if value != nil {
            let defaults = UserDefaults.standard
            defaults.set(value!, forKey: key)
        }
        else{
            let defaults = UserDefaults.standard
            
            defaults.set("no value", forKey: key)
        }
        
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
         MyVriables.currentPhoneNumber = ""
        self.dismiss(animated: false, completion: nil)
    }
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        contryCodeString = country.phoneCode
        contryCode = country.code
        print("contryCodeString \(contryCodeString)  contryCode  \(contryCode)")
    }
    

}
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
