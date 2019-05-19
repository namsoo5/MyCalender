//
//  AddEventViewController.swift
//  Calender
//
//  Created by 남수김 on 18/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//
import FMDB
import UIKit

class AddEventViewController: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eventTextView: UITextView!
    
    var eventMonth = Int()
    var eventDay = Int()
    var eventYear = Int()
    
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dayLabel.text = "\(eventDay)월"
        monthLabel.text = "\(eventMonth)일"
       
    }
    

    @IBAction func cancelBt(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func saveBt(_ sender: Any) {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("event.sqlite")
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        do {
            
            
            let input:String = eventTextView.text ?? " "
            try database.executeUpdate("create table if not exists calender(year int, month int, day int, content text)", values: nil)
            try database.executeUpdate("insert into calender (year, month, day, content) values (?, ?, ?, ?)", values: [eventYear, eventMonth, eventDay, "\(input)"])
            
            let action: UIAlertController = UIAlertController.init(title: "완료", message: "저장되었습니다.", preferredStyle: .alert)
            //ok 누르면 창닫힘
            let ok: UIAlertAction = UIAlertAction.init(title: "확인", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
            })
            action.addAction(ok)
            present(action, animated: true, completion: nil)
            
        } catch {
            print("failed: \(error.localizedDescription)")
            
            let action: UIAlertController = UIAlertController.init(title: "실패", message: "전송도중 오류가 발생했습니다.", preferredStyle: .alert)
            //ok 누르면 창닫힘
            let ok: UIAlertAction = UIAlertAction.init(title: "확인", style: .default, handler: nil)
            action.addAction(ok)
            present(action, animated: true, completion: nil)
        }
        
        database.close()

    }
    
}
