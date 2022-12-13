//
//  ContentView.swift
//  Pineapple
//
//  Created by Priyan Rai on 12/12/22.
//

import SwiftUI
import Vision
import PhotosUI
import EventKit
import EventKitUI

struct dateCard {
    var event = ""
    var location = ""
    var timeStart = ""
    var timeEnd = ""
    
}

struct ContentView: View {
    @State var selectedItems: PhotosPickerItem?
    @State var selectedPhotoData: Data?
    @StateObject var store = EventKitManager()
    @State private var showingAlert = false
    
    
    
    func recogText(image: UIImage?)
    {
        guard let cgImage = image?.cgImage else {return}
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {return}
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string}).joined(separator: ",")
            processText(text: text)
        }
        
        request.recognitionLevel = VNRequestTextRecognitionLevel.fast
        
        do {
            try handler.perform([request])
        }
        catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func processText(text:String)
    {
        let match = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        
        let items = text.split(separator: ",")
        var chosenIt = [Int]()
        var output =  [dateCard]()
        
        var counter = 0
        
        for i in items{
            if match.contains(String(i)){
                if items[counter+2] != "No events" &&
                    !match.contains(String(items[counter+2])){
                    chosenIt.append(counter)
                }
            }
            counter += 1
        }
        
        for i in chosenIt{
            
            var dc = dateCard()
            let currYear = Date.now.formatted(.dateTime.year())
            var startDate = String(items[i])
            var endDate = String(items[i])
            
            startDate.append(String(items[i+1]))
            endDate.append(String(items[i+1]))
            
            startDate += " "
            endDate += " "
            
            startDate.append(String(currYear))
            endDate.append(String(currYear))
            
            startDate += " "
            endDate += " "
            
            startDate.append(String(items[i+2]))
            endDate.append(String(items[i+3]))
            
            dc.event = String(items[i+4])
            dc.timeStart = startDate
            dc.timeEnd = endDate
            dc.location = String(items[i+5])
            output.append(dc)
        }
        
        store.insertEvent(store: store.eventStore, data: output)
    }
    
    var body: some View {
        VStack{
            //Icon
            mainImage()
            
            //Button
            PhotosPicker(selection: $selectedItems, matching: .images) {
                Label("Select a photo", systemImage: "photo")
            }
            .tint(.blue)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .onChange(of: selectedItems) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                        if let selectedPhotoData,
                           let image = UIImage(data: selectedPhotoData)
                        {
                            let _ = recogText(image: image)
                            showingAlert = true
                        }
                    }
                        
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Success"), message: Text("Import to Calendar Successful"), dismissButton: .default(Text("Ok")))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
