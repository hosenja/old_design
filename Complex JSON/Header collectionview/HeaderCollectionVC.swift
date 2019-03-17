//
//  HeaderCollectionVC.swift
//  Snapgroup
//
//  Created by snapmac on 25/11/2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit

class HeaderCollectionVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
 

   
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell2", for: indexPath) as! StoryCollectionViewCell
        return cell
    }
    
   

}
