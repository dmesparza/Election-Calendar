
//  ViewController.swift
//  Election Calendar

//  Created by Dominic Ruiz-Esparza on 5/3/18.
//  Copyright © 2018 Dominic Ruiz-Esparza. All rights reserved.


import UIKit
import EventKit
import CoreData

class ViewController: UIViewController {
    
    var elections: [SavedEvents] = []
    
    fileprivate let dataController = DataController(modelName: "Elections")

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    let electionID = SavedEvents(context: self.dataController.managedObjectContext)
                    
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
                    
                    electionID.eventIDs = event.eventIdentifier
                    
                    do {
                        try electionID.managedObjectContext?.save()
                        print("And saved its ID \(electionID.eventIDs).")
                        print("These are now objects saved in Core Data.")
                        
                    } catch {
                        let saveError = error as NSError
                        print("Unable to save eventID to Core Data.")
                        print("\(saveError), \(saveError.localizedDescription)")
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
                
                let fetchRequest:NSFetchRequest<SavedEvents> = SavedEvents.fetchRequest()
                guard let eventsToBeDeleted = try? self.dataController.managedObjectContext.fetch(fetchRequest) else {
                    print("We couldn't fetch any objects to be deleted.")
                    return
                }
                
                    for deadManWalking in eventsToBeDeleted {
                        
                        guard let eventToRemove = store.event(withIdentifier: (deadManWalking.eventIDs)!) else {
                            print("Ain't no event here, Chief.")
                            return
                        }
                        do {
                            try store.remove(eventToRemove,span: .thisEvent)
                            print("Deleted Calendar event with eventID \(deadManWalking.eventIDs)")
                        } catch {
                            print("Delete error is: \(error)")
                        }
                        self.dataController.managedObjectContext.delete(deadManWalking)
                        print("And deleted its eventID from Core Data.")
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
