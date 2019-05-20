//
//  DailyController.swift
//  Calender
//
//  Created by 남수김 on 15/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit
import FMDB

class DailyController: UIViewController, UITableViewDataSource {
    
    var dday = day
    var lastDay = [31,28,31,30,31,30,31,31,30,31,30,31]
    var leapCount = 3 //윤달체크
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
     var contentSet = [String]()
    
    @IBOutlet weak var tableView: UITableView!
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
        tableView.reloadData()
        
    }
    
    @IBAction func nextBt(_ sender: Any) {
        dday += 1
        if dday > lastDay[dmonth] {
            checkNextYear(dday)
        }
        dateLabel.text = "\(dyear)년 \(dmonth+1)월 \(dday)일"
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dailyEvent"{
            guard let vc:AddEventViewController = segue.destination as? AddEventViewController else {return}
            
            vc.eventDay = dday
            vc.eventMonth = dmonth+1
            vc.eventYear = dyear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sqlite()
         tabsave(tabnum: 2)
        self.tableView.reloadData()
    }
    //MARK: - tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentSet.removeAll()
        
        for schedule in app.scheduleSet{
            if schedule.year == dyear && schedule.month == dmonth+1 && schedule.day == dday
            {
                contentSet.append(schedule.content)
            }
        }
        return contentSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "dailyCell", for: indexPath)
        
        cell.textLabel?.text = contentSet[indexPath.row]
        
        
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
    
    func sqlite(){
        
        app.scheduleSet.removeAll()
        
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("event.sqlite")
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            // try database.executeUpdate("drop table calender", values: nil)
            
            try database.executeUpdate("create table if not exists calender(year int, month int, day int, content text)", values: nil)
            
            let rs = try database.executeQuery("select year, month, day, content from calender", values: nil)
            while rs.next() {
                if let y = rs.string(forColumn: "year"), let m = rs.string(forColumn: "month") , let d = rs.string(forColumn: "day") , let c = rs.string(forColumn: "content") {
                    
                    let event = Schedule.init(year: Int(y) ?? 0, month: Int(m) ?? 0, day: Int(d) ?? 0, content: c)
                    app.scheduleSet.append(event)

                }
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        
    }

    func tabsave(tabnum n: Int){
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("event.sqlite")
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            // try database.executeUpdate("drop table tab", values: nil)
            
            try database.executeUpdate("create table if not exists tab(i int)", values: nil)
            try database.executeUpdate("insert into tab (i) values (?)", values: [n])
            
            let rs = try database.executeQuery("select i from tab", values: nil)
            if rs.columnCount > 0 {
                let i:Int = rs.long(forColumn: "i")
                try database.executeUpdate("update tab set i = ? where i = ?", values: [n, i])
            }
            
            
            print("tabnum: \(n)저장" )
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        
        
    }
}
