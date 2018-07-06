
//  ViewController.swift
//  Election Calendar

//  Created by Dominic Ruiz-Esparza on 5/3/18.
//  Copyright © 2018 Dominic Ruiz-Esparza. All rights reserved.


import UIKit
import EventKit
import CoreData

class ViewController: UIViewController {
    
    var elections = [SavedEvent]()
    var moc:NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moc = appDelegate?.persistentContainer.viewContext
    }
    
    func loadData(){
        
        let electionRequest:NSFetchRequest<SavedEvent> = SavedEvent.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "eventIDs", ascending: false)
        electionRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try elections = moc.fetch(electionRequest)
        } catch {
            print("Could not load data")
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
                    
                    electionEvent.eventIDs = event.eventIdentifier
                    
                    self.appDelegate?.saveContext()
                    print(self.elections)
                }
            }
        }
    }

    func deleteEvents() {
        
        loadData()
        
        for deletableEvent in elections {
            
            // Get access to the calendar.
            let store: EKEventStore = EKEventStore()
            store.requestAccess(to: .event) { (granted, error) in
                
                if (granted) && (error == nil) {
                    print("create granted \(granted)")
                    print("create store access error \(error.debugDescription)")
                    
                    let deletableEvent = SavedEvent(context: self.moc)
                    let event: EKEvent = EKEvent(eventStore: store)
                    let identifier = deletableEvent.eventIDs
                    
                    func event(withIdentifier identifier: String) -> EKEvent {
                        let identifier = deletableEvent.eventIDs
                        return event
                    }
                    
                    do {
                        try store.remove(event, span: .thisEvent)
                    } catch let error as NSError {
                        print("Event creation error is \(error).")
                    }
                    
                    self.elections.remove(at: 0)
                    
                }
            }
        }
    }
    
    
    @IBAction func AddElectionEvents(_ sender: UIButton) {
        //deleteEvents()
        createEvents()
        print(self.elections)
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
}
