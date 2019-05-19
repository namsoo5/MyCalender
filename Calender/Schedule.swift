//
//  Schedule.swift
//  Calender
//
//  Created by 남수김 on 18/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import Foundation

class Schedule{
    var year: Int!
    var month = Int()
    var day = [Int]()
    var content = [[Int:String]]()
    
    init(year y:Int, month m:Int, day d:Int, content c:String) {
        self.year = y
        self.month = m
        self.day.append(d)
        self.content.append([d:c])
    }
    
    func addDay(day d:Int){
        self.day.append(d)
    }
    
    func getDay(day d: Int) -> Bool {
        return self.day.contains(d)
    }
    
    func getArray() -> [Int] {
        return self.day
    }
    
    func addContent(day d:Int, content c:String){
        self.content.append([d:c])
    }
    
    func getContent() -> [[Int:String]] {
        return self.content
    }

}
