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

var FirstEvent = testEvent(title: "Registration Day", startDate: "2018-05-30", endDate: "2018-05-30", isAllDay: true, notes: "Updated info.")
var SecondEvent = testEvent(title: "Election Day", startDate: "2018-06-06", endDate: "2018-06-06", isAllDay: true, notes: "Initial info.")
var ThirdEvent = testEvent(title: "Recall Day", startDate: "2018-06-13", endDate: "2018-06-13", isAllDay: true, notes: "Initial info.")

var NorthCarolina = [FirstEvent,SecondEvent,ThirdEvent]
