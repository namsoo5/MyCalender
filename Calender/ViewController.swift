//
//  ViewController.swift
//  Calender
//
//  Created by 남수김 on 15/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import UIKit
import FMDB

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var MonthLabel: UILabel!
    
    let Months = ["1월", "2월", "3월", "4월","5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    
    var lastDay = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    var curMonth = ""
    var emptyBox = 3  //이번달 달력 빈칸
    var nextEmptyBox = Int()  //다음달 달력 빈칸
    var beforeEmptyBox = 0  //저번달 달력 빈칸
    var direct = 0   // 다음달, 저번달, 이번달 구분
    var posIndex = 3 // 날짜 인덱스저장
    var leapCount = 3 //윤달체크
    
    var select = -1 //선택날짜 체크
    var selectDay = -1 //다음뷰로 넘길 선택날짜
    
    var tabnum = 0
    
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///
        checkYoon(year: cyear)
        if isYoon {
            lastDay[1] = 29
        }else {
            lastDay[1] = 28
        }
        emptyBox = getStartDay(year: cyear, month: cmonth)
        posIndex = emptyBox
        ///
        
        curMonth = Months[cmonth]
        MonthLabel.text = "\(cyear) \(curMonth)"
        
        sqlite()
        tabmove()
        print("이동이동: \(tabnum)")
        
    }
    
   

    //MARK: - 버튼 처리

    @IBAction func nextBt(_ sender: Any) {
        //다음달달력누를시 선택초기화
        selectDay = -1
        select = -1
        switch curMonth {
        case "12월":
            cmonth = 0  //1월로
            cyear += 1  //1년증가
            direct = 1
            
            checkYoon(year: cyear)
            if isYoon {
                lastDay[1] = 29
            }else {
                lastDay[1] = 28
            }
            
            getStartDayPos()
            curMonth = Months[cmonth] //텍스트수정
            MonthLabel.text = "\(cyear) \(curMonth)"  //라벨수정
            collectionView.reloadData()  // 해당하는 날짜 리로드
            
        default:
            direct = 1
            
            getStartDayPos()
            cmonth += 1
            
            curMonth = Months[cmonth]
            MonthLabel.text = "\(cyear) \(curMonth)"
            collectionView.reloadData()
        }
    }
    @IBAction func beforeBt(_ sender: Any) {
        //다음달달력누를시 선택초기화
        selectDay = -1
        select = -1
        switch curMonth {
        case "1월":
            cmonth = 11
            cyear -= 1
            direct = -1
            
           
            checkYoon(year: cyear)
            if isYoon {
                lastDay[1] = 29
            }else {
                lastDay[1] = 28
            }
            
            getStartDayPos()
            curMonth = Months[cmonth]
            MonthLabel.text = "\(cyear) \(curMonth)"
            collectionView.reloadData()
            
        default:
            cmonth -= 1
            direct = -1
            
            getStartDayPos()
            curMonth = Months[cmonth]
            MonthLabel.text = "\(cyear) \(curMonth)"
            collectionView.reloadData()
        }
    }
    
    @IBAction func addEventBt(_ sender: Any) {
        if selectDay == -1 {
            let alert:UIAlertController = UIAlertController.init(title: "확인", message: "날짜를 선택해주세요", preferredStyle: .alert )
            let ok:UIAlertAction = UIAlertAction.init(title: "확인", style: .default , handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }else {
            performSegue(withIdentifier: "MonthEvent", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MonthEvent"{
            guard let VC:AddEventViewController = segue.destination as? AddEventViewController else {return}
            
            VC.eventDay = selectDay
            VC.eventMonth = cmonth+1
            VC.eventYear = cyear
        }
    }
    
    
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch direct {
        case 0:
            return lastDay[cmonth] + emptyBox
        case 1:
            return lastDay[cmonth] + nextEmptyBox
        case -1:
            return lastDay[cmonth] + beforeEmptyBox
        default:
            fatalError()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as? DateCollectionViewCell else {return UICollectionViewCell()}
        
        //선택상태표시
        if select == indexPath.item{
            cell.backgroundColor = UIColor.gray
        }else {
            cell.backgroundColor = UIColor.clear
        }
        
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
        
        if !cell.eventView.isHidden {
            cell.eventView.isHidden = true
            cell.eventView.backgroundColor = UIColor.clear
        }
        
        for schedule in app.scheduleSet{
            if schedule.year == cyear &&  schedule.month == cmonth+1 && schedule.day == Int(cell.dateLabel.text!)!
            {
            
                    cell.eventView.isHidden = false
                    cell.eventView.backgroundColor = UIColor.red

                
            }
        }
        
        return cell
    }
    
    func getStartDayPos() {
        switch direct {

            
        case 1...:
            nextEmptyBox = (posIndex + lastDay[cmonth]) % 7
            posIndex = nextEmptyBox
            
        case -1:
            beforeEmptyBox = ( 7 - (lastDay[cmonth] - posIndex) % 7)
            if beforeEmptyBox == 7 {
                beforeEmptyBox = 0
            }
            posIndex = beforeEmptyBox
        default:
            fatalError()
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: DateCollectionViewCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell else {return}
        print(cell.dateLabel.text!)
        selectDay = Int(cell.dateLabel.text!)!
        select = indexPath.item
        collectionView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewAppear")
        sqlite()
        self.tabBarController?.selectedIndex = tabnum
        tabsave(tabnum: 0)
        
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
                    //print("year = \(y), month = \(m), day = \(d), content = \(c)")
                    
                    let event = Schedule.init(year: Int(y) ?? 0, month: Int(m) ?? 0, day: Int(d) ?? 0, content: c)
                    app.scheduleSet.append(event)
                    
                    
                }
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        
        self.collectionView.reloadData()
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
    
    func tabmove() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("event.sqlite")
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
           
            
            let rs = try database.executeQuery("select i from tab", values: nil)
            
            while rs.next() {
                if let i = rs.string(forColumn: "i") {
                    print("index: \(i)")
                    tabnum = Int(i)!
                }
                
            }

        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        
        
    }
}

