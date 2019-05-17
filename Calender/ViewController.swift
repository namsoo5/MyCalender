//
//  ViewController.swift
//  Calender
//
//  Created by 남수김 on 15/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var MonthLabel: UILabel!
    
    let Months = ["1월", "2월", "3월", "4월","5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    //let weeks = ["Sun","Mon", "Tue", "Wen", "Thur", "Fri", "Sat"]
    var lastDay = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    var curMonth = ""
    var emptyBox = 3  //이번달 달력 빈칸
    var nextEmptyBox = Int()  //다음달 달력 빈칸
    var beforeEmptyBox = 0  //저번달 달력 빈칸
    var direct = 0   // 다음달, 저번달, 이번달 구분
    var posIndex = 3 // 날짜 인덱스저장
    var leapCount = 3 //윤달체크
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curMonth = Months[month]
        MonthLabel.text = "\(year) \(curMonth)"
        
    }

    //MARK: - 버튼 처리

    @IBAction func nextBt(_ sender: Any) {
        switch curMonth {
        case "12월":
            month = 0  //1월로
            year += 1  //1년증가
            direct = 1
            
            //윤달체크
            if leapCount < 5 {
                leapCount += 1
            }
            if leapCount == 4 {
                lastDay[1] = 29
            }
            if leapCount == 5 {
                leapCount = 1
                lastDay[1] = 28
                
            }
            
            getStartDayPos()
            curMonth = Months[month] //텍스트수정
            MonthLabel.text = "\(year) \(curMonth)"  //라벨수정
            collectionView.reloadData()  // 해당하는 날짜 리로드
            
        default:
            direct = 1
            
            getStartDayPos()
            month += 1
            
            curMonth = Months[month]
            MonthLabel.text = "\(year) \(curMonth)"
            collectionView.reloadData()
        }
    }
    @IBAction func beforeBt(_ sender: Any) {
        switch curMonth {
        case "1월":
            month = 11
            year -= 1
            direct = -1
            
            //윤달체크
            if leapCount > 0 {
                leapCount -= 1
            }
            if leapCount == 0 {
                lastDay[1] = 29
                leapCount = 4
            }
            else {
    
                lastDay[1] = 28
                
            }
            
            getStartDayPos()
            curMonth = Months[month]
            MonthLabel.text = "\(year) \(curMonth)"
            collectionView.reloadData()
            
        default:
            month -= 1
            direct = -1
            
            getStartDayPos()
            curMonth = Months[month]
            MonthLabel.text = "\(year) \(curMonth)"
            collectionView.reloadData()
        }
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch direct {
        case 0:
            return lastDay[month] + emptyBox
        case 1:
            return lastDay[month] + nextEmptyBox
        case -1:
            return lastDay[month] + beforeEmptyBox
        default:
            fatalError()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as? DateCollectionViewCell else {return UICollectionViewCell()}
        
        cell.backgroundColor = UIColor.clear
        
        //가린거 풀어주기
        if cell.isHidden {
            cell.isHidden = false
        }
        //색바꾼거 풀어주기
        cell.dateLabel.textColor = UIColor.black
        
        switch direct {
        case 0:
            cell.dateLabel.text = "\(indexPath.item + 1 - emptyBox)"
        case 1:
            cell.dateLabel.text = "\(indexPath.item + 1 - nextEmptyBox)"
        case -1:
            cell.dateLabel.text = "\(indexPath.item + 1 - beforeEmptyBox)"
        default:
            fatalError()
        }
        
        // 빈칸출력
        if Int(cell.dateLabel.text!)! < 1 {
            cell.isHidden = true
        }
        
        switch indexPath.item {
        case 0,7,14,21,28,35:  //주말표시
            cell.dateLabel.textColor = UIColor.red
        default:
            break
        }
        
        return cell
    }
    
    func getStartDayPos() {
        switch direct {
//        case 0:
//            switch day{
//            case 1...7:
//                emptyBox = weekday - day
//            case 8...14:
//                emptyBox = weekday - day - 7
//            case 14...21:
//                emptyBox = weekday - day - 14
//            case 21...28:
//                emptyBox = weekday - day - 21
//            case 29...31:
//                emptyBox = weekday - day - 28
//            default:
//                break
//            }
//            posIndex = emptyBox
            
        case 1...:
            nextEmptyBox = (posIndex + lastDay[month]) % 7
            posIndex = nextEmptyBox
            
        case -1:
            beforeEmptyBox = ( 7 - (lastDay[month] - posIndex) % 7)
            if beforeEmptyBox == 7 {
                beforeEmptyBox = 0
            }
            posIndex = beforeEmptyBox
        default:
            fatalError()
        }
    
    }
    
}

