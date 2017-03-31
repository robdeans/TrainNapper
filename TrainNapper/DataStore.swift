//
//  JSONSerializer.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import Foundation
import RealmSwift


typealias StationDictionary = [String:Station]


final class DataStore {
    
    static let sharedInstance = DataStore()
    
    let realm = try! Realm()
    
    var user: User! = User()
    
    func addUserToRealm() {
        try! realm.write {
            realm.add(user)
        }
    }

    
    var stationsDictionary = StationDictionary()
    
}

// MARK: Train Data Methods
extension DataStore {
    
    func getJSONStationsDictionary(with jsonFilename: String, completion: @escaping ([String : [String : Any]]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: jsonFilename, ofType: "json") else { print("error unwrapping json file path"); return }
        
        do {
            let data = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            
            guard let stationDictionary = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String : [String : Any]] else { print("error typecasting json dictionary"); return }
            completion(stationDictionary)
        } catch {
            print("error reading data from file in json serializer")
        }
    }
    
    func populateLIRRStationsFromJSON() {

        getJSONStationsDictionary(with: "LIRRStations") { lirrJSON in
            if let stationsDictionary = lirrJSON["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.stationsDictionary[station.name] = station
                }
            }
        }
    }
    
    func populateMetroNorthStationsFromJSON() {

        getJSONStationsDictionary(with: "MetroNorthStations") { (metroNorthJSON) in
            if let stationsDictionary = metroNorthJSON["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.stationsDictionary[station.name] = station
                }
            }
        }
    }
    
    func populateNJTStationsFromJSON() {

        getJSONStationsDictionary(with: "NJTransit") { njTransitJSON in
            if let stationsDictionary = njTransitJSON["stops"]?["stop"] as? [[String : Any]] {
                for station in stationsDictionary.map({ Station(jsonData: $0) }) {
                    self.stationsDictionary[station.name] = station
                }
            }
        }
    }
    
    func populateAllStations() {
        stationsDictionary = [String:Station]()
        populateLIRRStationsFromJSON()
        populateMetroNorthStationsFromJSON()
        populateNJTStationsFromJSON()
    }
}
