//
//  WeeklyViewController.swift
//  Calender
//
//  Created by 남수김 on 15/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit

class WeeklyViewController: UIViewController, UICollectionViewDataSource {
   
    let Months = ["1월", "2월", "3월", "4월","5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    var lastDay = [31,28,31,30,31,30,31,31,30,31,30,31]
 
    var curMonth = ""
//    var emptyBox = 3  //이번달 달력 빈칸
//    var nextEmptyBox = Int()  //다음달 달력 빈칸
//    var beforeEmptyBox = 0  //저번달 달력 빈칸
//    var direct = 0   // 다음달, 저번달, 이번달 구분
//    var posIndex = 3 // 날짜 인덱스저장
    var leapCount = 3 //윤달체크 
    
    var WeekFirstDay = 0
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curMonth = Months[month]
        monthLabel.text = "\(year) \(curMonth)"
        WeekFirstDay = day - weekday + 1  //현재날짜가 포함된 주의 처음
       
    }
    

    //MARK: - 버튼
    
    @IBAction func beforeBt(_ sender: Any) {
      
        WeekFirstDay -= 7
        if WeekFirstDay < 1  {
            checkbeforeYear(WeekFirstDay)
            WeekFirstDay = lastDay[month] + WeekFirstDay
            
            curMonth = Months[month]
            monthLabel.text = "\(year) \(curMonth)"
        }
        collectionView.reloadData()
    }
    
    @IBAction func nextBt(_ sender: Any) {
       
        WeekFirstDay += 7

        
        collectionView.reloadData()
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 7
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekdayCell", for: indexPath) as? DateCollectionViewCell else {fatalError()}
        //다음달이 되는경우
        if WeekFirstDay + indexPath.item > lastDay[month] {
            checkNextYear(WeekFirstDay + indexPath.item)
            WeekFirstDay = 1 - indexPath.item
            

            curMonth = Months[month]
            monthLabel.text = "\(year) \(curMonth)"
            
        }
      //  switch direct {
     //   case -1...1:
            cell.weekdayLabel.text = "\(WeekFirstDay + indexPath.item)"
     //   default:
      //      fatalError()
      //  }
        
        if !cell.eventWeekView.isHidden {
            cell.eventWeekView.isHidden = true
            cell.eventWeekView.backgroundColor = UIColor.clear
        }
        
        for schedule in app.scheduleSet{
            if schedule.year == year &&  schedule.month == month+1
            {
                
                if schedule.getDay(day: Int(cell.weekdayLabel.text!)!) {
                    cell.eventWeekView.isHidden = false
                    cell.eventWeekView.backgroundColor = UIColor.red
                }
                
            }
        }
        
        
        return cell
        
    }
    
//
//    func getStartDayPos() {
//        switch direct {
//
//        case 1...:
//            nextEmptyBox = (posIndex + lastDay[month]) % 7
//            posIndex = nextEmptyBox
//
//        case -1:
//            beforeEmptyBox = ( 7 - (lastDay[month] - posIndex) % 7)
//            if beforeEmptyBox == 7 {
//                beforeEmptyBox = 0
//            }
//            posIndex = beforeEmptyBox
//        default:
//            fatalError()
//        }
//
//    }
    //년도가 달라지는경우체크
    func checkNextYear(_ inputdate :Int){
        switch curMonth {
        case "12월":
            if inputdate >= lastDay[month] {
                month = 0  //1월로
                year += 1  //1년증가
//                direct = 1
                
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
     //           getStartDayPos()
                
                
            }
            
        default:
//            direct = 1
            month += 1
     //       getStartDayPos()
        
        }
    }
    //년도가 달라지는경우 체크
    func checkbeforeYear(_ inputdate :Int){
        switch curMonth {
        case "1월":
            if inputdate <= 1{
                month = 11
                year -= 1
//                direct = -1
                
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
                
    //            getStartDayPos()
            }
            
        default:
//            direct = -1
            month -= 1
  //          getStartDayPos()
        
        }
    }
}
