
//  ViewController.swift
//  Election Calendar

//  Created by Dominic Ruiz-Esparza on 5/3/18.
//  Copyright © 2018 Dominic Ruiz-Esparza. All rights reserved.


import UIKit
import EventKit
import CoreData

class ViewController: UIViewController {

    var moc:NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var elections = [SavedEvent]()
    let fetchRequest:NSFetchRequest<SavedEvent> = SavedEvent.fetchRequest()
    
    var isEmpty : Bool {
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedEvent")
            let count  = try moc.count(for: request)
            return count == 0 ? true : false
        } catch {
            return true
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moc = appDelegate?.persistentContainer.viewContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         //Dispose of any resources that can be recreated.
    }
    
    func createEvents(eventsCreated: (Bool) -> Void) {
        
        for electionEvent in NorthCarolina {
            
            // Get access to the calendar.
            let store: EKEventStore = EKEventStore()
            store.requestAccess(to: .event) { (granted, error) in
                
                if (granted) && (error == nil) {
                    print("create granted \(granted)")
                    print("create store access error \(error.debugDescription)")
                    
                    // Define EKevent and save it.
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
                        try store.commit()
                        print("Event created.")
                    } catch let error as NSError {
                        print("Event creation error is \(error).")
                    }
                }
            }
        }
        eventsCreated(true)
    }
    
    

    func deleteEvents() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sDate: Date? = dateFormatter.date(from: (NorthCarolina.first?.startDate)!)
        
        let store: EKEventStore = EKEventStore()
        store.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                print("delete granted \(granted)")
                print("delete store access error \(error.debugDescription)")
                
                // Get the appropriate calendar.
                var calendar = Calendar.current
                
                // Create the start date components
                var oneDayAgoComponents = DateComponents()
                oneDayAgoComponents.day = -1
                var oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date(), wrappingComponents: false)
                
                // Create the end date components.
                var oneYearFromNowComponents = DateComponents()
                oneYearFromNowComponents.year = 1
                var oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date(), wrappingComponents: false)
                
                // Create the predicate from the event store's instance method.
                var predicate: NSPredicate? = nil
                if let anAgo = oneDayAgo, let aNow = oneYearFromNow {
                    predicate = store.predicateForEvents(withStart: sDate!, end: aNow, calendars: nil)
                }
                
                // Fetch all events that match the predicate.
                var events = EKEventStore().events(matching: predicate!)
                if let aPredicate = predicate {
                    events = store.events(matching: aPredicate)
                }
                
                for item in events {
                    if item.notes == "electionCal" {
                        do {
                            try store.remove(item, span: .thisEvent)
                            print("Event \(item.eventIdentifier) deleted.")
                        } catch let error as NSError {
                            print("Event deletion error is \(error).")
                        }
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func AddElectionEvents(_ sender: UIButton) {
        let handlerBlock: (Bool) -> Void = {
            if $0 {
                self.deleteEvents()
                print("All events deleted.")
            }
        }
        
        createEvents(eventsCreated: handlerBlock)
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
}
