
//  ViewController.swift
//  Election Calendar

//  Created by Dominic Ruiz-Esparza on 5/3/18.
//  Copyright © 2018 Dominic Ruiz-Esparza. All rights reserved.


import UIKit
import EventKit
import CoreData

class ViewController: UIViewController {
    
    var elections: [SavedEvents] = []
    
    var dataController:DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest:NSFetchRequest = SavedEvents.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            elections = result
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         //Dispose of any resources that can be recreated.
    }
    
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
                        try self.dataController.viewContext.save()
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
        
                    for deadManWalking in self.elections {
                    
                        if let eventToRemove = store.event(withIdentifier: deadManWalking.eventIDs!) {
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
