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

var year = calendar.component(.year , from: date)
var cyear = calendar.component(.year , from: date)
var dyear = calendar.component(.year , from: date)
