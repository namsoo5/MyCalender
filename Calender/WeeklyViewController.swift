//
//  WeeklyViewController.swift
//  Calender
//
//  Created by 남수김 on 15/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit
import FMDB

class WeeklyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource {
    
   
    let Months = ["1월", "2월", "3월", "4월","5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    var lastDay = [31,28,31,30,31,30,31,31,30,31,30,31]
 
    var curMonth = ""

    var leapCount = 3 //윤달체크
    
    var selectCell = UICollectionViewCell() //선택날짜 cell
    var selectDay = -1 //다음뷰로 넘길 선택날짜
    var selectMon = -1
    var contentSet = [String]()
    var tableFirstDay = 0
    var WeekFirstDay = 0
    var beforeMonthDay = Int()
    var direct = -2 //현상태 리로드시 체크 플레그
    
    var beforeMonth = Int()
    
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curMonth = Months[month]
        monthLabel.text = "\(year) \(curMonth)"
        
        checkYoon(year: year)
        if isYoon {
            lastDay[1] = 29
        }else {
            lastDay[1] = 28
        }
        
        WeekFirstDay = day - weekday + 1  //현재날짜가 포함된 주의 처음
        tableFirstDay = WeekFirstDay
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        sqlite()
        if direct != -2 {  // 리로드시 인덱스 오류 수정
            WeekFirstDay = beforeMonthDay
            if WeekFirstDay+7 > lastDay[month] {
                month -= 1
            }
            
        }
        self.collectionView.reloadData()
        self.tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weekEvent"{
            guard let VC:AddEventViewController = segue.destination as? AddEventViewController else {return}
           
            VC.eventMonth = selectMon
            
            VC.eventDay = selectDay
            VC.eventYear = year
        }
    }
    

    //MARK: - 버튼
    
    @IBAction func addEvent(_ sender: Any) {
        direct = 0
        if selectDay == -1 {
            let alert:UIAlertController = UIAlertController.init(title: "확인", message: "날짜를 선택해주세요", preferredStyle: .alert )
            let ok:UIAlertAction = UIAlertAction.init(title: "확인", style: .default , handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }else {
            performSegue(withIdentifier: "weekEvent", sender: self)
        }
    }
    
    @IBAction func beforeBt(_ sender: Any) {
        direct = -1
        selectDay = -1
        WeekFirstDay -= 7
        
        
        if WeekFirstDay < 1 {   // 저번달로 넘어 가는경우
            checkbeforeYear(WeekFirstDay)
            WeekFirstDay = lastDay[month] + WeekFirstDay
            
            curMonth = Months[month]
            monthLabel.text = "\(year) \(curMonth)"
        }
        
        beforeMonthDay = WeekFirstDay  // 리로드시 오류해결 저장
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    @IBAction func nextBt(_ sender: Any) {
        direct = 1
        selectDay = -1
        WeekFirstDay += 7
        beforeMonthDay = WeekFirstDay  // 리로드시 오류해결 저장
        collectionView.reloadData()
        tableView.reloadData()
    }
    //MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        contentSet.removeAll()
        
        
        for schedule in app.scheduleSet{
            if schedule.year == year{
                
                var start = tableFirstDay
                var startmonth = month
                
                for i in 0..<7{
                    
                    if start+i > lastDay[month] {
                        let newday = start - lastDay[month]
                        start = newday
                        startmonth += 1
                        
                        
                    }
                    if schedule.day == start+i && schedule.month == startmonth + 1 {
                        contentSet.append(schedule.content)
                        break
                    }
                }
            }
        }
        
        return contentSet.count
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "weekCell", for: indexPath)
        
        cell.textLabel?.text = contentSet[indexPath.row]
        
        return cell
    }
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 7
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekdayCell", for: indexPath) as? DateCollectionViewCell else {fatalError()}
        
        cell.backgroundColor = UIColor.clear
        
        
        if WeekFirstDay + indexPath.item > lastDay[month] {   //다음달로 넘어 가는경우
            checkNextYear(WeekFirstDay + indexPath.item)
            
            
            curMonth = Months[month]
            monthLabel.text = "\(year) \(curMonth)"
            cell.weekdayLabel.text = "\(WeekFirstDay+indexPath.item)"
            cell.month = month+1
        }else{
             cell.weekdayLabel.text = "\(WeekFirstDay + indexPath.item)"
            cell.month = month+1
            
        }
        
        if indexPath.item == 0{
            tableFirstDay = Int(cell.weekdayLabel.text!)!
            print("save: \(tableFirstDay)")
            self.tableView.reloadData()
        }
        
 
        if !cell.eventWeekView.isHidden {
            cell.eventWeekView.isHidden = true
            cell.eventWeekView.backgroundColor = UIColor.clear
        }
        
        for schedule in app.scheduleSet{
            if schedule.year == year && schedule.month == month+1 && schedule.day == Int(cell.weekdayLabel.text!)!
            {
                

                    cell.eventWeekView.isHidden = false
                    cell.eventWeekView.backgroundColor = UIColor.red

            }
        }
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell: DateCollectionViewCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell else {return}
        
        print("\(selectDay) 선택")
        selectCell.backgroundColor = UIColor.clear
        selectCell = cell
        selectCell.backgroundColor = UIColor.gray
        selectDay = Int(cell.weekdayLabel.text!)!
        selectMon = cell.month
    
    }
 
    //년도가 달라지는경우체크
    func checkNextYear(_ inputdate :Int){
        beforeMonth = month
        print("\(curMonth) check")
        switch curMonth {
        case "12월":
            if inputdate >= lastDay[month] {
                month = 0  //1월로
                year += 1  //1년증가
  
                checkYoon(year: year)
                if isYoon {
                    lastDay[1] = 29
                }else {
                    lastDay[1] = 28
                }
                
                WeekFirstDay = WeekFirstDay - lastDay[month]
            }
            
        default:
            month += 1
            WeekFirstDay = WeekFirstDay - lastDay[month-1]
    
        
        }
    }
    //년도가 달라지는경우 체크
    func checkbeforeYear(_ inputdate :Int){
        beforeMonth = month
        switch curMonth {
        case "1월":
            if inputdate <= 1{
                month = 11
                year -= 1
                
                checkYoon(year: year)
                if isYoon {
                    lastDay[1] = 29
                }else {
                    lastDay[1] = 28
                }
                
    
            }
            
        default:

            month -= 1
  
        
        }
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
                    print("year = \(y), month = \(m), day = \(d), content = \(c)")
                    
                    let event = Schedule.init(year: Int(y) ?? 0, month: Int(m) ?? 0, day: Int(d) ?? 0, content: c)                    
                    app.scheduleSet.append(event)

                }
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    
    }
   
}
