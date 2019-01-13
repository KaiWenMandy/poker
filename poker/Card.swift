//
//  Card.swift
//  poker
//
//  Created by Kai Wen on 2018/12/27.
//  Copyright © 2018年 Kai Wen. All rights reserved.
//

import Foundation
import UIKit

// 一般牌
class Card {
    var order:Int
    var suit:String
    var face:String
    var image:String
    
    static var score:Int = 0
    static var message:String = ""
    
    init ( order:Int, suit:String, face:String ) {
        self.order = order
        self.suit = suit
        self.face = face
        self.image = suit + "_" + face
    }
    
    func action () {
        Card.score += Int(face)!
        Card.message = "+" + face
    }
}

/*
 基本規則：
 
 勝利方式：無法出牌的時候為敗。
 出一張牌之後抽一張牌。
 功能牌有♠A、4、5、10、J、Q、K：
 ♠A - 歸零
 4   - 反轉(出牌順序順時鐘、逆時鐘倒轉)
 5   - 指定
 10 - 加、減10
 J    - Pass
 Q   - 加、減20
 K    - 數字變99
 */

class Card0: Card {
    override func action() {
        Card.score = 0
        Card.message = "歸零！"
    }
}

class Card1: Card {
    override func action() {
        Card.score += 1
        Card.message = "+1"
    }
}

class Card5: Card {
    override func action() {
        Card.message = "指定！"
    }
}

class CardT: Card {
    override func action() {
        if ( Card.score < 90 ) {
            Add()
        }
        else if ( Card.score > 89 ) {
            Sub()
        }
        else {
            print("I'm in the 10.")
            let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            addButton.setTitle("+", for: .normal)
            addButton.setTitleColor(#colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1), for: .normal)
            addButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            addButton.backgroundColor = UIColor.orange
            addButton.layer.cornerRadius = 15
            addButton.layer.borderWidth = 1
            addButton.layer.borderColor = UIColor.brown.cgColor
            addButton.addTarget(self, action: #selector(Add), for: .touchDown)
 
            let subButton = addButton
            subButton.setTitle("-", for: .normal)
            subButton.addTarget(self, action: #selector(Sub), for: .touchDown)
            
            Card.message = "未設定"
        }
    }
    
    @objc func Add () {
        Card.score += 10
        Card.message = "+10"
    }
    
    @objc func Sub () {
        Card.score -= 10
        Card.message = "-10"
    }
}

class CardJ: Card {
    override func action() {
        Card.message = "跳過！"
    }
}


class CardQ: Card {
    override func action() {
        if ( Card.score < 80 ) {
            Add()
        }
        else if ( Card.score > 79 ) {
            Sub()
        }
        else {
            print("I'm in the 20.")
            let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            addButton.setTitle("+", for: .normal)
            addButton.setTitleColor(#colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1), for: .normal)
            addButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            addButton.backgroundColor = UIColor.orange
            addButton.layer.cornerRadius = 15
            addButton.layer.borderWidth = 1
            addButton.layer.borderColor = UIColor.brown.cgColor
            addButton.addTarget(self, action: #selector(Add), for: .touchDown)
        
            let subButton = addButton
            subButton.setTitle("-", for: .normal)
            subButton.addTarget(self, action: #selector(Sub), for: .touchDown)
 
            Card.message = "未設定"
        }
    }
    
    @objc func Add () {
        Card.score += 20
        Card.message = "+20"
    }
    
    @objc func Sub () {
        Card.score -= 20
        Card.message = "-20"
    }
}

class CardK: Card {
    override func action() {
        Card.score = 99
        Card.message = "99！"
    }
}

/*
 血腥規則：
 
 勝利方式：無法出牌的時候為敗。
 出一次牌之後抽一張牌。(這邊是「一次」, 而非「一張」)
 功能牌有A、4、5、7、10、J、Q、K、X：
 A  - 換牌, 出牌之後將自己手上的牌與指定玩家交換, 所以該玩家會拿到少了一張的一副牌, 因為這張牌出了之後並不會再從牌堆裡抽一張牌。
 7  - 抽牌, 出牌後抽指定玩家手上的一張牌, 這張牌出了之後並不會再從牌堆裡抽一張牌；同一輪裡, 一位玩家只能被抽一次。
 4、5、10、J、Q、K維持原樣。
 X  - 複合出牌, ex. 同時出2、3, 可以得到5的效果, 但注意, 即使出兩張牌, 也只能算出一次, 並從牌堆裡抽1張牌
 */

class CardA: Card {
    override func action() {
        // change
        Card.message = "交換！"
    }
}

class Card7: Card {
    override func action() {
        // 抽牌
        Card.message = "抽牌！"
    }
}

class CardX: Card {
    func action ( card1:Card, card2:Card ) {
        
    }
}

/*
 殺戮規則：
 
 勝利方式：無法出牌的時候為敗。
 出一次牌之後抽一張牌。
 遊戲開始時直接從99開始。
 建議可以用2副牌 + 2張Joker進行遊戲。
 功能牌有A、4、5、7、8、9、10、J、Q、k、Joker：
 A、4、5、7、10、J、Q、K維持原樣。
 8 - 抽兩張牌。
 9 - 此回合以及下回合都Pass, 但是出了之後不能從牌堆裡抽牌。
 Joker - 順/逆時鐘換牌。
 */

class Card8: Card {
    override func action() {
        Card.message = "抽牌！"
    }
}

// 其他：尚未設置的牌
class CardO: Card {
    override func action() {
        Card.message = "未設定"
    }
}
