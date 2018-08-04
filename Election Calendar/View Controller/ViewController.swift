
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
    
    func createEvents() {
        
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
                        print("Saved an event to the store.")
                    } catch let error as NSError {
                        print("Event creation error is \(error).")
                    }
                    
                    // Define Core Data event and save it.
                    let electionEvent = SavedEvent(context: self.moc)
                    print("Here's electionEvent \(electionEvent).")
                    electionEvent.eventIDs = event.eventIdentifier
                    print("Here's eventIDs \(electionEvent.eventIDs!).")
                    self.appDelegate?.saveContext()
                    
                    do {
                        try self.moc.save()
                    } catch let error as NSError {
                        print("Event creation error is \(error).")
                    }
                }
            }
        }
    }

    func deleteEvents() {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "SavedEvent", into: moc) as! SavedEvent
        
        entity.setValue(String.self, forKey: "eventIDs")
        
        if let id: String? = entity.eventIDs as String {
            
        }

        // Get access to the calendar.
        let store = EKEventStore()
        store.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                print("delete granted \(granted)")
                print("delete store access error \(error.debugDescription)")
                
                for thing in entity.eventIDs! {
                    
                    if let event:EKEvent? = store.event(withIdentifier: thing) {
                        
                        do {
                            try store.remove(event, span: .thisEvent)
                            try self.moc.save()
                        } catch let error as NSError {
                            print("First deletion error is \(error).")
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    
    @IBAction func AddElectionEvents(_ sender: UIButton) {
        deleteEvents()
        createEvents()
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
}
