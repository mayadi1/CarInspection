//
//  API.swift
//  CarInspection
//
//  Created by Mohamed Ayadi on 11/21/19.
//  Copyright © 2019 Mohamed Ayadi. All rights reserved.
//

 import Alamofire

class VehicleAPI {
    
    static let shared = VehicleAPI()
 
    func decodeVin(vin: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        let endpoint = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/\(vin)?format=JSON"
        Alamofire.request(endpoint, parameters: nil, encoding: JSONEncoding.default).responseJSON {
            (response) in
            if let value = response.result.value as? [String: Any],
                let results = value["Results"] as? Array<Dictionary<String, String>>,
                let carData = results.first, let make = carData["Make"], let model = carData["Model"],
                let year = carData["ModelYear"], let transmissionStyle = carData["TransmissionStyle"],
                let bodyClass = carData["BodyClass"] {
                Car.current.make = make
                Car.current.model = model
                Car.current.year = year
                Car.current.transmissionStyle = transmissionStyle
                Car.current.bodyClass = bodyClass
                completionHandler(nil)
            } else {
            completionHandler(response.error)
            }
        }
    }
}

