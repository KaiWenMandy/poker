//
//  ViewController1.swift
//  poker
//
//  Created by Kai Wen on 2018/12/26.
//  Copyright © 2018年 Kai Wen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewControllerC1: UIViewController {

    // ----------普通版---------- //
    /////
    @IBOutlet var playerImages: [UIImageView]! // 玩家的牌組
    @IBOutlet var bankerImages: [UIImageView]! // 對手的牌組
    @IBOutlet weak var groupImage: UIImageView! // 牌組
    @IBOutlet weak var centerImage: UIImageView! // 中間
    @IBOutlet weak var scoreLabel: UILabel! // 旁邊的總分
    @IBOutlet var msgLabels: [UILabel]! // 訊息
    @IBOutlet weak var messageLabel: UILabel! // 訊息
    @IBOutlet weak var messageButton: UIButton! // 訊息
    
    // 材料
    let face = [ "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" ] // 點數
    let suit = [ "Club", "Diamond", "Heart", "Spade" ] // 花色
    var cardOrder:[Card] = [] // 原牌組
    var cardGroup:[Card] = [] // 板上的牌組
    var cardCenter:[Card] = [] // 中間已經出的牌組
    var cardPlayer:[Card] = [] // 玩家的牌組
    var cardBanker:[Card] = [] // 對手的牌組
    var countGroup = 52
    var countCenter = 0
    var fouseImage:Int?
    var round:Bool = true
    
    // 音效
    var cardAV: AVAudioPlayer?
    var groupAV: AVAudioPlayer?
    
    // ----------開始---------- //
    /////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 前置
        for i in 0...51 {
            let num = i % 13
            
            switch ( num ) {
            case 0:     // 1
                if ( i/13 == 3 ) {
                    cardOrder.append(Card0(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
                }
                else {
                    cardOrder.append(Card1(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
                }
            case 4:
                cardOrder.append(Card5(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
            case 12:    // cardK
                cardOrder.append(CardK(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
            case 11:    // cardQ
                cardOrder.append(CardQ(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
            case 10:    // cardJ
                cardOrder.append(CardJ(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
            case 9:     // card10
                cardOrder.append(CardT(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
            default:    // card
                cardOrder.append(Card(order: i, suit: suit[ i / 13 ], face: face[ i % 13 ]))
            }
        }
        for i in 0...4 {
            playerImages[i].center.x = 70
            bankerImages[i].center.x = 70
            playerImages[i].center.y = 448
            bankerImages[i].center.y = 448
            playerImages[i].image = UIImage(named: "Back")
            bankerImages[i].image = UIImage(named: "Back")
            
        }
        
        // 觸碰
        for i in 0...4 {
            let singleTap = UITapGestureRecognizer(target: self, action: #selector( singleImageTap ))
            playerImages[i].tag = i
            playerImages[i].addGestureRecognizer(singleTap)
            playerImages[i].isUserInteractionEnabled = true
        }
        
        // 音效
        var path = Bundle.main.path(forResource: "click.mp3", ofType: nil)
        var url = URL(fileURLWithPath: path!)
        do {
            cardAV = try AVAudioPlayer(contentsOf: url)
        } catch {
            print( "Can't not found the audio click.mp3" )
        }
        path = Bundle.main.path(forResource: "yisell.mp3", ofType: nil)
        url = URL(fileURLWithPath: path!)
        do {
            groupAV = try AVAudioPlayer(contentsOf: url)
        } catch {
            print( "Can't not found the audio duble_clicks.mp3" )
        }
        
        newGame()
    }
    
    // ----------點擊出牌---------- //
    /////
    @objc func singleImageTap ( recognizer:UITapGestureRecognizer, order:Int ) {
        
        if ( round ){ // 玩家回合才能出牌
            
            // 先抓目標tag
            let tapImage = recognizer.view as! UIImageView
            if ( fouseImage == nil ) {                  // 先判斷是否為無目標
                UIView.animate(withDuration: 0.5) {
                    tapImage.center.y -= 30
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fouseImage = tapImage.tag
                }
            }
            else if ( tapImage.tag == fouseImage! ) {   // 點擊兩下出牌
                
                // 出牌
                cardPlayer[tapImage.tag].action()
                scoreLabel.text = String(Card.score)
                msgLabels[0].text = Card.message
                cardAV?.play()
                UIView.animate(withDuration: 0.5) {
                    self.playerImages[tapImage.tag].center.x = 207
                    self.playerImages[tapImage.tag].center.y = 448
                }
                
                // 判斷是否超過，有超過就結束
                if ( Card.score > 99 ) {
                    
                    for i in 0...4 {
                        playerImages[i].isUserInteractionEnabled = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.messageLabel.text = "您輸了！"
                        self.messageLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                        self.messageButton.setTitle("重新一次", for: .normal)
                        self.messageButton.isEnabled = true
                        self.messageButton.backgroundColor = UIColor(red:0.00, green:0.60, blue:1.00, alpha:1.0)
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.drawCard(tag: tapImage.tag)
                        self.fouseImage = nil
                        self.round = false
                        //self.messageLabel.text = ""
                        self.messageButton.setTitle("", for: .normal)
                        self.msgLabels[1].text = ""
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.opponentAI()
                    }
                }
            }
            else {                                      // 點擊其他換牌
                UIView.animate(withDuration: 0.5) {
                    self.playerImages[self.fouseImage!].center.y += 30
                    tapImage.center.y -= 30
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fouseImage = tapImage.tag
                }
            }
        }
        else {
           // messageLabel.text = "目前並非您的回合"
            self.messageButton.setTitle("目前並非您的回合", for: .normal)
        }
    }
    
    // ----------拿牌---------- //
    /////
    func drawCard ( tag:Int ) {
        
        // 發牌
        if ( round ) { // 如果是玩家回合
            
            // 前置
            countCenter += 1
            centerImage.image = playerImages[tag].image
            playerImages[tag].center.x = 70
            cardCenter.append(cardPlayer[tag])
            
            cardPlayer[tag] = cardGroup[countGroup - 1]
            playerImages[tag].image = UIImage(named: cardPlayer[tag].image)
            countGroup -= 1
            UIView.animate(withDuration: 1) {
                self.playerImages[tag].center.x = CGFloat(297 - tag * 45)
                self.playerImages[tag].center.y = 725
            }
        }
        else { // 對手回合
            countCenter += 1
            centerImage.image = bankerImages[tag].image
            bankerImages[tag].center.x = 70
            cardCenter.append(cardBanker[tag])
            
            cardBanker[tag] = cardGroup[countGroup - 1]
            bankerImages[tag].image = UIImage(named: "Back")
            countGroup -= 1
            UIView.animate(withDuration: 1) {
                self.bankerImages[tag].center.x = CGFloat(117 + tag * 45)
                self.bankerImages[tag].center.y = 175
            }
        }
        
        // 之後判斷有沒有出玩牌
        if ( countGroup == 0 ) {
            
            // 資料處理
            cardGroup = cardCenter.shuffled()
            cardCenter = []
            countGroup = countCenter
            countCenter = 0
            
            // 圖片處理
            groupImage.image = nil
            centerImage.image = UIImage(named: "Back")
            groupAV?.play()
            UIView.animate(withDuration: 0.5) {
                self.centerImage.center.x = 70
                self.centerImage.center.y = 448
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.groupImage.image = UIImage(named: "Back")
                self.centerImage.image = nil
                self.centerImage.center.x = 207
                self.centerImage.center.y = 448
            }
        }
        //msgLabels[0].text = String(countGroup)
        //msgLabels[1].text = String(countCenter)
    }
    
    // ----------對手出牌---------- //
    /////
    func opponentAI () {
        
        // 目標tag
        let num = Int.random(in: 0...4)
        bankerImages[num].image = UIImage(named: cardBanker[num].image)
        if ( cardBanker[num].face == "Q" ) {
            if ( Card.score < 79 ) {
                Card.score += 20
                Card.message = "+20"
            }
            else {
                Card.score -= 20
                Card.message = "-20"
            }
        }
        else if ( cardBanker[num].face == "10" ) {
            if ( Card.score < 89 ) {
                Card.score += 10
                Card.message = "+10"
            }
            else {
                Card.score -= 10
                Card.message = "-10"
            }
        }
        else {
            cardBanker[num].action()
        }
        msgLabels[1].text = Card.message
        scoreLabel.text = String(Card.score)
        cardAV?.play()
        UIView.animate(withDuration: 1) {
            self.bankerImages[num].center.x = 207
            self.bankerImages[num].center.y = 448
        }
        
        // 判斷
        if ( Card.score > 99 ) {
            
            for i in 0...4 {
                playerImages[i].isUserInteractionEnabled = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.messageLabel.text = "您贏了！"
                self.messageLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                self.messageButton.setTitle("重新一次", for: .normal)
                self.messageButton.isEnabled = true
                self.messageButton.backgroundColor = UIColor(red:0.00, green:0.60, blue:1.00, alpha:1.0)
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.drawCard(tag: num)
                self.round = true
                self.msgLabels[0].text = ""
                //self.messageLabel.text = "目前為您的回合"
                self.messageButton.setTitle("目前為您的回合", for: .normal)
            }
        }
    }
    
    // ----------其他---------- //
    /////
    func orderCard ( this:Card, that:Card ) -> Bool {
        return this.order < that.order
    }
    
    // ----------新遊戲---------- //
    /////
    func newGame () {
        
        // 初始資料
        countGroup = 52
        countCenter = 0
        Card.score = 0
        scoreLabel.text = String(Card.score)
        cardGroup = cardOrder.shuffled() // 洗牌
        messageLabel.text = ""
        messageButton.setTitle("", for: .normal)
        messageLabel.backgroundColor = nil
        messageButton.isEnabled = false
        messageButton.backgroundColor = nil
        centerImage.image = nil
        
        // 先發10張牌
        for i in 0...9 {
            if ( i % 2 == 0 ) {
                cardPlayer.append(cardGroup[countGroup - 1])
                countGroup -= 1
            }
            else {
                cardBanker.append(cardGroup[countGroup - 1])
                countGroup -= 1
            }
        }
        cardPlayer = cardPlayer.sorted(by: orderCard)
        for i in 0...4 {
            playerImages[i].image = UIImage(named: cardPlayer[i].image)
        }
        groupAV?.play()
        UIView.animate(withDuration: 1) {
            for i in 0...4 {
                self.playerImages[i].center.x = CGFloat(297 - i * 45)
                self.playerImages[i].center.y = 725
                self.bankerImages[i].center.x = CGFloat(117 + i * 45)
                self.bankerImages[i].center.y = 175
            }
        }
        
        // 決定誰先出
        round = Bool.random()
        if ( !round ) {
            //scoreLabel.text = "B"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.opponentAI()
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.messageButton.setTitle("目前為您的回合", for: .normal)
            }
        }
    }
    
    
    @IBAction func newGameButton(_ sender: Any) {
        msgLabels[0].text = ""
        msgLabels[1].text = ""
        fouseImage = nil
        for i in 0...4 {
            playerImages[i].center.x = 70
            bankerImages[i].center.x = 70
            playerImages[i].center.y = 448
            bankerImages[i].center.y = 448
            playerImages[i].image = UIImage(named: "Back")
            bankerImages[i].image = UIImage(named: "Back")
            playerImages[i].isUserInteractionEnabled = true
        }
        newGame()
    }
}
