//
//  CurrancyClass.swift
//  Snapgroup
//
//  Created by snapmac on 12/02/2019.
//  Copyright © 2019 snapmac. All rights reserved.
//

import Foundation
class Player: NSObject, NSCoding {
    
    private var name: String!
    private var score: Int!
    private var color: String!
    
    var playerName: String {
        get {
            return name
        }
        set {
            name = newValue
        }
    }
    
    var playerScore: Int {
        get {
            return score
        }
        set {
            score = newValue
        }
    }
    
    var playerColor: String {
        get {
            return color
        }
        set {
            color = newValue
        }
    }
    
    init(playerName: String, playerScore: Int, playerColor: String) {
        
        name = playerName
        score = playerScore
        color = playerColor
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let score = aDecoder.decodeObject(forKey: "score") as! Int
        let color = aDecoder.decodeObject(forKey: "color") as! String
        self.init(playerName: name, playerScore: score, playerColor: color)
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(name, forKey: "name")
        aCoder.encode(score, forKey: "score")
        aCoder.encode(color, forKey: "color")
    }
    
}
