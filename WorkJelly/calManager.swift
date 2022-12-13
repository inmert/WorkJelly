//
//  calendarManager.swift
//  Pineapple
//
//  Created by Priyan Rai on 12/13/22.
//

import SwiftUI
import EventKit
import Combine
import Foundation
import SwiftUI

class EventKitManager: ObservableObject {
    
    var eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    
    
    
    init() {
        requestAccessToCalendar()
    }
    
    func requestAccessToCalendar() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .denied, .restricted:
            print("Access denied")
        case .notDetermined:
            eventStore.requestAccess(to: .event) {(granted, error) in
                DispatchQueue.main.async {
                    if granted {
                        return
                    } else {
                        print("Access denied")
                    }
                    
                }
            }
        case .authorized:
            return
        default:
            break
        }
    }
    
    func insertEvent(store: EKEventStore, data:[dateCard]) {
        
        let dateForm = DateFormatter()
        dateForm.locale = Locale(identifier: "en_US_POSIX")
        dateForm.dateFormat = "EEEE MMMM d yyyy h:mm aa"
        dateForm.timeZone = TimeZone.current
        
        for i in data{
            print(i.event)
            print(i.timeStart)
            print(i.timeEnd)
            let start = dateForm.date(from: i.timeStart)
            let end = dateForm.date(from: i.timeEnd)
            
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.calendar = eventStore.defaultCalendarForNewEvents
            newEvent.title = i.event
            newEvent.startDate = start
            newEvent.endDate = end
            newEvent.location = i.location
            do {
                try store.save(newEvent, span: .thisEvent, commit: true)
            } catch {
                print("Error saving event in calendar")             }
        }
    }
}

