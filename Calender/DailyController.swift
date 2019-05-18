//
//  DailyController.swift
//  Calender
//
//  Created by 남수김 on 15/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit

class DailyController: UIViewController, UITableViewDataSource {
    
    var dday = day
    var lastDay = [31,28,31,30,31,30,31,31,30,31,30,31]
    var leapCount = 3 //윤달체크
    
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = "\(dyear)년 \(dmonth+1)월 \(dday)일"
        
      
    }
    
    //MARK: - 버튼클릭
    
    @IBAction func beforeBt(_ sender: Any) {
        dday -= 1
        if dday < 1 {
            checkbeforeYear(dday)
        }
        dateLabel.text = "\(dyear)년 \(dmonth+1)월 \(dday)일"
    }
    
    @IBAction func nextBt(_ sender: Any) {
        dday += 1
        if dday > lastDay[dmonth] {
            checkNextYear(dday)
        }
        dateLabel.text = "\(dyear)년 \(dmonth+1)월 \(dday)일"
    }
    
    //MARK: - tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "dailyCell", for: indexPath)
        
        cell.textLabel?.text = "test"
        
        return cell
    }
    
    
    //MARK: - 날짜계산
    
    func checkNextYear(_ inputdate :Int){
        switch dmonth {
        case 11:
            if inputdate >= lastDay[dmonth] {
                dmonth = 0  //1월로
                dyear += 1  //1년증가
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
            }
            
        default:
            dmonth += 1
            
        }
        dday = 1
    }
    //년도가 달라지는경우 체크
    func checkbeforeYear(_ inputdate :Int){
        switch dmonth {
        case 0:
            if inputdate <= 1{
                dmonth = 11
                dyear -= 1
                
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
            }
            
        default:
            dmonth -= 1
            
        }
        
        dday = lastDay[dmonth]
    }

}
