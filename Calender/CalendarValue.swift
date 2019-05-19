//
//  CalendarValue.swift
//  Calender
//
//  Created by 남수김 on 16/05/2019.
//  Copyright © 2019 ns. All rights reserved.
//

import Foundation

let date = Date()
let calendar = Calendar.current

let day = calendar.component(.day, from: date)
let weekday = calendar.component(.weekday , from: date)   //1 -일요일   7-토요일
var month = calendar.component(.month , from: date)-1
var cmonth = calendar.component(.month, from: date)-1
var dmonth = calendar.component(.month, from: date)-1

var year = calendar.component(.year , from: date)  //주간에서사용
var cyear = calendar.component(.year , from: date)
var dyear = calendar.component(.year , from: date)  //일간에서사용




let months: [Int] = [31,28,31,30,31,30,31,31,30,31,30,31]
var isYoon: Bool = false
var startDay: Int = 0

var allday = Int()

func checkYoon(year y: Int) {
    if ( y % 4 == 0 && y % 100 != 0 ) || y % 400 == 0 {
        isYoon = true
    }else{
        isYoon = false
    }
}

func getStartDay(year y: Int, month m: Int) -> Int{
// 작년까지 총 날짜 수
    allday = ((y-1) + (y-1)/4 - (y-1)/100 + (y-1)/400)
    
    // 지난달 까지 총 날짜 수
    for i in 0..<m {
        allday += months[i]
    }
    
    if isYoon && m > 1 {
        allday += 1
    }
    
    startDay = ((allday + 1) % 7)   // 0 : 일요일
    
    return startDay
}
