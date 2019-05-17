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
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
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
            try database.executeUpdate("create table if not exists calender(month int, day int, content text)", values: nil)
            try database.executeUpdate("insert into calender (month, day, content) values (?, ?, ?)", values: [eventMonth, eventDay, "\(input)"])
            
//            let rs = try database.executeQuery("select x, y, z from test", values: nil)
//            while rs.next() {
//                if let x = rs.string(forColumn: "x"), let y = rs.string(forColumn: "y"), let z = rs.string(forColumn: "z") {
//                    print("x = \(x); y = \(y); z = \(z)")
//                    textView.text.append("x:\(x) y:\(y) z:\(z)")
//                }
//            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()

    }
    
}
