//
//  GroupLeaderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 4/17/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftHTTP
import SwiftEventBus
import ARSLineProgress
class GroupLeaderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   

    @IBOutlet weak var allReviewLbl: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ratingTbaleview: UITableView!
    @IBOutlet weak var leaderImageview: UIImageView!
    var singleGroup: TourGroup?
    @IBOutlet weak var leadeAboutLbl: UILabel!
    @IBOutlet weak var activeGroupLbl: UILabel!
    @IBOutlet weak var leaderEmailLbl: UILabel!
    @IBOutlet weak var leaderGenderLbl: UILabel!
    @IBOutlet weak var leaderBiryhdayLbl: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var leaderNameLbl: UILabel!
    var count: Int = 2
    var ratingsArray: [RatingModel]?
    @IBOutlet weak var tableViewHeightConstrans: NSLayoutConstraint!
    
    
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var genderStack: UIStackView!
    @IBOutlet weak var ageStack: UIStackView!
    @IBOutlet weak var nameStack: UIStackView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var isCompanyView: UIView!
    @IBAction func allReviewClick(_ sender: Any) {
        ProviderInfo.nameProvider = leaderNameLbl.text!
        ProviderInfo.urlRatings = ApiRouts.Api+"/getratings/members/\((MyVriables.currentGroup?.group_leader_id)!)"
        performSegue(withIdentifier: "showAllReview", sender: self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingTbaleview.isHidden = true
        SwiftEventBus.onMainThread(self, name: "newComment") { result in
            self.getRatings()
        }
        ratingTbaleview.delegate = self
        ratingTbaleview.dataSource = self

       // print("Refresh is \((MyVriables.enableGdpr?.parmter)!)")
        SwiftEventBus.onMainThread(self, name: "refresh-rating_reviews") { result in
            ProviderInfo.model_type = "members"
            ProviderInfo.model_id =  (MyVriables.currentGroup?.group_leader_id) != nil ? (MyVriables.currentGroup?.group_leader_id)! : -1
            self.performSegue(withIdentifier: "showAddReview", sender: self)
        }
        self.isCompanyView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "showCompany", sender: self)
        }
        //"refresh\((MyVriables.enableGdpr?.parmter)!)"
         //ratingTbaleview.reloadData()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.singleGroup  = MyVriables.currentGroup!
        ratingTbaleview.delegate = self
        ratingTbaleview.dataSource = self
        ratingTbaleview.isScrollEnabled = false
        ratingTbaleview.separatorStyle = .none
        if MyVriables.currentGroup?.is_company != nil
        {
            if MyVriables.currentGroup?.is_company! == 1
            {
                self.isCompanyView.isHidden = false
                self.companyName.text = MyVriables.currentGroup?.group_leader_company_name != nil ? MyVriables.currentGroup?.group_leader_company_name! : "Company name"
            }

            
        }
        groupNameLbl.text = singleGroup?.translations?.count != 0 ? singleGroup?.translations?[0].title! : "There is no group name"
        activeGroupLbl.text = singleGroup?.translations?.count != 0 ? singleGroup?.translations?[0].title! : ""
        leadeAboutLbl.text = singleGroup?.group_leader_about != nil ? singleGroup?.group_leader_about : "There no description right now"
        if singleGroup?.group_leader_email != nil {
             leaderEmailLbl.text = singleGroup?.group_leader_email != nil ? singleGroup?.group_leader_email : ""
        }else{
            emailStack.isHidden = true
            leaderEmailLbl.text = ""
            emailLbl.text = ""
        }
        if singleGroup?.group_leader_gender != nil {
            leaderGenderLbl.text = singleGroup?.group_leader_gender != nil ? singleGroup?.group_leader_gender : ""
        }else{
            genderStack.isHidden = true
            leaderGenderLbl.text = ""
            genderLbl.text = ""
        }
        if singleGroup?.group_leader_birth_date != nil {
          leaderBiryhdayLbl.text = singleGroup?.group_leader_birth_date != nil ? singleGroup?.group_leader_birth_date : ""
        }else{
            ageStack.isHidden = true
            leaderBiryhdayLbl.text = ""
            ageLbl.text = ""
        }
        
        
        if singleGroup?.group_leader_first_name != nil && singleGroup?.group_leader_last_name != nil {
            leaderNameLbl.text = "\((singleGroup?.group_leader_first_name)!) \((singleGroup?.group_leader_last_name)!)" as String
        }
        do{
            if singleGroup?.group_leader_image != nil{
                var urlString = try ApiRouts.Media + (singleGroup?.group_leader_image)!
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                var url = URL(string: urlString)
                leaderImageview.sd_setImage(with: url!, completed: nil)
            }
        }catch let error {
            print(error)
        }
        
      
        getRatings()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.ratingsArray?.count == 0 {
            tableViewHeightConstrans.constant = 0
            return 0
        }
        else
        {
            if self.ratingsArray?.count == 1 {
                return 1
                
            }
            else
            {
                return 2
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        cell.selectionStyle = .none
        if self.ratingsArray != nil {
         cell.fullNameLbl.text = "\((self.ratingsArray?[indexPath.row].fullname) != nil ? (self.ratingsArray?[indexPath.row].fullname)! : "")"
            cell.reviewLbl.text = "\((self.ratingsArray?[indexPath.row].review)!) "
            cell.ratingNumber.text = "\((self.ratingsArray?[indexPath.row].rating)!) out of 10"
            

//            if self.ratingsArray?[indexPath.row].image_path != nil
//            {
//                var urlString: String = try ApiRouts.Media + (self.ratingsArray?[indexPath.row].image_path)!
//                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
//                if let url = URL(string: urlString) {
//                    cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default user"), completed: nil)
//
//                }
//            }
//            if self.ratingsArray?[indexPath.row].reviewer_id! == MyVriables.currentMember?.id! {
//                cell.removeRate.isHidden = false
//            }
//            else {
//                cell.removeRate.isHidden = true
//            }
//            cell.removeRate.tag = (self.ratingsArray?[indexPath.row].id)!
//            cell.removeRate.addTarget(self,action:#selector(buttonClicked),
//                                      for:.touchUpInside)
        }
        
        return cell
    }
    @objc func buttonClicked(sender:UIButton)
    {
        let VerifyAlert = UIAlertController(title: "Verify", message: "Are you sure you want to remove this rate ?", preferredStyle: .alert)
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
            self.removeRate(reviwerId : sender.tag)
        }))
        VerifyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            print("no")
        }))
        self.present(VerifyAlert, animated: true, completion: nil)
    }
    func removeRate(reviwerId : Int) {
        
        print(ApiRouts.Api+"/ratings/\((reviwerId))")
        ARSLineProgress.show()
        HTTP.DELETE(ApiRouts.Api+"/ratings/\((reviwerId))", parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                ARSLineProgress.hide()

                return //also notify app of failure as needed
            }
            do {
                
                print("removed is \(response.description)")
                
                DispatchQueue.main.sync {
                    ARSLineProgress.hide()
                    self.getRatings()
                }
            }
            catch {
                
            }
        }
    }
    @IBAction func showAddReview(_ sender: Any) {
        //showAddReview
        if  (MyVriables.currentMember?.gdpr?.rating_reviews)! == true {
       ProviderInfo.model_type = "members"
       ProviderInfo.model_id =  (MyVriables.currentGroup?.group_leader_id)!
        performSegue(withIdentifier: "showAddReview", sender: self)
        }else
        {
            var gdprObkectas : GdprObject = GdprObject(title: "Rating & reviews", descrption: "If you choose to rate and write a review on a group leader or a service provider, your review will be displayed next to profile details on the reviews page.", isChecked: (MyVriables.currentMember?.gdpr?.rating_reviews) != nil ? (MyVriables.currentMember?.gdpr?.rating_reviews)! : false, parmter: "rating_reviews", image: "In order to write a review, please approve the review save and usage:")
            MyVriables.enableGdpr = gdprObkectas
            performSegue(withIdentifier: "showEnableModal", sender: self)
            
        }

    }
  // showMember
    func getRatings() {

        let url = ApiRouts.Api+"/ratings?model_id=\((MyVriables.currentGroup?.group_leader_id)!)&model_type=members"
        print("Rating url is === \(url)")
        HTTP.GET(url, parameters:[])
        { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let rates = try JSONDecoder().decode(RatingsStrubs.self, from: response.data)
                self.ratingsArray = rates.ratings
                print("The Array is \(self.ratingsArray!)")
                DispatchQueue.main.sync {
                    self.ratingTbaleview.isHidden = false
                    if self.ratingsArray?.count == 0 {
                        self.count = 0
                        self.ratingTbaleview.reloadData()
                    }
                    else
                    {
                        if self.ratingsArray?.count == 1 {
                            self.count = 1
                            self.ratingTbaleview.reloadData()
                            
                        }
                        else
                        {
                            self.count = 2
                            self.ratingTbaleview.reloadData()
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.setTableViewHeigh()
                    }
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("im here in select ")
////        //tableView.allowsSelection = false
////        var currentMemmber: GroupMember? = GroupMember(id : self.ratingsArray?[indexPath.row].reviewer_id!, email : "", first_name : self.ratingsArray?[indexPath.row].first_name != nil ? self.ratingsArray?[indexPath.row].first_name! : "", last_name : self.ratingsArray?[indexPath.row].last_name != nil ? self.ratingsArray?[indexPath.row].last_name! : "", profile_image : self.ratingsArray?[indexPath.row].image_path != nil ? self.ratingsArray?[indexPath.row].image_path! : nil,companion_number : 0, status : "nil", role : "member")
////        GroupMembers.currentMemmber = currentMemmber
////        performSegue(withIdentifier: "showMember", sender: self)
//    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    fileprivate func setTableViewHeigh() {
        if self.ratingsArray?.count == 0 {
            self.tableViewHeightConstrans.constant = 0
            self.allReviewLbl.isHidden = true
        }
        else
        {
            self.allReviewLbl.isHidden = false
            if self.ratingsArray?.count == 1 {
                var height: CGFloat = 0
                for cell in self.ratingTbaleview.visibleCells {
                    height += cell.bounds.height
                }
                self.tableViewHeightConstrans.constant = height
                
            }
            else
            {
                var height: CGFloat = 0
                for cell in self.ratingTbaleview.visibleCells {
                    height += cell.bounds.height
                }
                self.tableViewHeightConstrans.constant = height
                
            }
            
        }
    }
    
    
}
