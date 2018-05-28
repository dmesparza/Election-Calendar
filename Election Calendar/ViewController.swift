
//  ViewController.swift
//  Election Calendar

//  Created by Dominic Ruiz-Esparza on 5/3/18.
//  Copyright © 2018 Dominic Ruiz-Esparza. All rights reserved.


import UIKit
import EventKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         //Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         //Dispose of any resources that can be recreated.
    }
    
    var dataController:DataController!
    
    func createEvents() {
        
        for electionEvent in NorthCarolina {
            
            // Get access to the calendar.
            let store: EKEventStore = EKEventStore()
            store.requestAccess(to: .event) { (granted, error) in
                
                if (granted) && (error == nil) {
                    print("create granted \(granted)")
                    print("create store access error \(error.debugDescription)")
                    
                    // Define event and create it.
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let sDate: Date? = dateFormatter.date(from: electionEvent.startDate)
                    let event: EKEvent = EKEvent(eventStore: store)
                    
                    
                    event.title = electionEvent.title
                    event.startDate = sDate
                    event.endDate = sDate
                    event.isAllDay = electionEvent.isAllDay
                    event.notes = electionEvent.notes
                    event.calendar = store.defaultCalendarForNewEvents
                    
                    do {
                        try store.save(event, span: .thisEvent)
                        
                        eventsCreated.append(event.eventIdentifier)
                        try store.commit()
                    } catch let error as NSError{
                        print("Event creation error is \(error).")
                    }
                }
            }
        }
    }
    

    func deleteEvents() {
        
        //Get access to the calendar.
        let store: EKEventStore = EKEventStore()
        store.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                print("delete granted \(granted)")
                print("delete store access error \(error.debugDescription)")
        
                    for deadManWalking in eventsCreated {
                    
                        if let eventToRemove = store.event(withIdentifier: deadManWalking) {
                            print("Deleted event \(eventToRemove)")
                    
                            do {
                                try store.remove(eventToRemove,span: .thisEvent)
                            } catch {
                                print("Delete error is: \(error)")
                            }
                        } else {
                        print("No events to delete.")
                        }
                }
            }
        }
    }
    
    @IBAction func AddElectionEvents(_ sender: UIButton) {
        deleteEvents()
        createEvents()
        print(eventsCreated)
    }
    
    
}
