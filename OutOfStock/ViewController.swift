//
//  ViewController.swift
//  OutOfStock
//
//  Created by abhishek.b.shukla on 10/03/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import UIKit


struct ForcastModel: Codable{
    let status: String
    let data : [String: Int]
}

struct OrderModel: Codable{
    let status: String
    let data : [String: Int]
}

typealias OnCompletion = (_ data: Data, _ error: Error) -> Void

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        outofstock(year: "2014") { (outOfStockProducts) in
            print("OutOfStockProducts are : \(String(describing: outOfStockProducts))")
        }
    }

    // Find all products for which
    // the forecast for `year` is lower than the
    // actual orders for the same `year`
    // Create an array of strings containing
    // the names of these products,
    // and call `handler(array)` with this array
    func outofstock(year: String, handler: @escaping ([String]?) -> Void) {

        let group = DispatchGroup()
        var forecastModel: ForcastModel?
        var orderModel : OrderModel?
        
        //Call ForecastAPI
        group.enter()
        let forecastURLString = "http://myserver.com/api/forecast/\(year)/"
        getAPIResponse(for: forecastURLString) { (data, error) in

            do{
                forecastModel = try JSONDecoder().decode(ForcastModel.self, from: data)
                group.leave()
            } catch let error {
                print("Decoding Error : \(error)")
                group.leave()
            }
        }
        
        //Call OrderAPI
        group.enter()
        let orderURLString = "http://myserver.com/api/orders/\(year)/"
        getAPIResponse(for: orderURLString) { (data, error) in
            
            do{
                orderModel = try JSONDecoder().decode(OrderModel.self, from: data)
                group.leave()
            } catch let error {
                print("Decoding Error : \(error)")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            
            //Find Out of Stocks products
            let outOfStockProducts = forecastModel?.data.flatMap({ (forecast) -> [String] in
                return (orderModel?.data.compactMap({ (order) -> String? in
                    return ((order.key == forecast.key) && (order.value > forecast.value)) ? order.key : nil
                }))!
            })
            
            if let outOfStockProducts = outOfStockProducts{
                handler(outOfStockProducts)
            }else{
                handler(nil)
            }
        }
    }
    
    
    func getAPIResponse(for urlString:String, completion: @escaping OnCompletion) {
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                
                //Use Mock data in case of failure
                let mockData = self.getMockAPIResponse(for: urlString)
                completion(mockData!, error)
                
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    //self.handleServerError(response)
                    return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "appliation/json", let data = data{
                completion(data, error!)
            }
        }
        task.resume()
    }

    private func getMockAPIResponse(for fileURL: String) -> Data?{
        let fileName: String?
        
        if fileURL.contains("forecast"){
            fileName = "Forecast"
        }else if fileURL.contains("orders"){
            fileName = "Order"
        }else{
            return nil
        }
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch let error{
                print("Error : \(error)")
                return nil
            }
        }
        
        return nil
    }

}

