
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
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<SavedEvents> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<SavedEvents> = SavedEvents.fetchRequest()
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to retrieve eventIDs from Core Data.")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        //let fetchRequest:NSFetchRequest<SavedEvents> = SavedEvents.fetchRequest()
        //if let result = try? dataController.viewContext.fetch(fetchRequest) {
        //    elections = result
        //}
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
                        try store.commit()
                        print("Saved an event with ID \(event.eventIdentifier) to the store.")
                    } catch let error as NSError {
                        print("Event creation error is \(error).")
                    }

                    let idToSave = self.fetchedResultsController.object(at: IndexPath)
                    idToSave.eventIDs = event.eventIdentifier
                    do {
                        try self.dataController.viewContext.save()
                        print("AND saved eventID \(idToSave.eventIDs!) to Core Data.")
                    } catch {
                        fatalError("Failure to save context \(error).")
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
                    
                        if let eventToRemove = store.event(withIdentifier: (deadManWalking.eventIDs)!) {
                            do {
                                try store.remove(eventToRemove,span: .thisEvent)
                                print("Deleted Calendar event with eventID \(deadManWalking.eventIDs!)")
                            } catch {
                                print("Delete error is: \(error)")
                            }
                            do {
                                self.dataController.viewContext.delete(deadManWalking)
                                try self.dataController.viewContext.save()
                                print("AND deleted its eventID!")
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
        if elections.count > 0 {
            self.deleteEvents()
        }
        createEvents()
        print("These is/are \(elections.count) events saved in Core Data.")
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
}
