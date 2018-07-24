//
//  Calendars.swift
//  Election Calendar
//
//  Created by Dominic Ruiz-Esparza on 5/8/18.
//  Copyright © 2018 Dominic Ruiz-Esparza. All rights reserved.
//

import Foundation
import EventKit

struct testEvent {
    var title: String
    var startDate: String
    var endDate: String
    var isAllDay: Bool
    var notes: String
}

var FirstEvent = testEvent(title: "Registration Day", startDate: "2018-07-22", endDate: "2018-07-22", isAllDay: true, notes: "Initial info.")
var SecondEvent = testEvent(title: "Election Day", startDate: "2018-06-27", endDate: "2018-06-27", isAllDay: true, notes: "Initial info.")
var ThirdEvent = testEvent(title: "Recall Day", startDate: "2018-07-04", endDate: "2018-07-04", isAllDay: true, notes: "Initial info.")

var NorthCarolina = [FirstEvent]
