//
//  AppInfoHandler.swift
//  uTime
//
//  Created by Matthew Jagiela on 10/31/19.
//  Copyright © 2019 Matthew Jagiela. All rights reserved.
//

import Cocoa

@objc class AppInfoHandler: NSObject {
    @objc var internetInfo: InternetInformation?
    override init() {
        print("Init")
        super.init()
        if let jsonURL = URL(string: "https://raw.githubusercontent.com/matthewjagiela/uApps-JSON/master/uAppsInfo.json") {
            URLSession.shared.dataTask(with: jsonURL) { data, _, error in
                if let fetchedData = data {
                    let decoder = JSONDecoder()
                    do {
                        self.internetInfo = try decoder.decode(InternetInformation.self, from: fetchedData)
                        print("Internet Decoder = \(self.internetInfo?.uAppsNews)")
            
                    } catch {
                        print("An Error Has Occured \(error)")
                    }
                }
            }.resume()
        }
        
    }
}
open class InternetInformation: NSObject, Decodable {
    @objc public var uTimeVersion: String?
    @objc public var uAppsNews: String?
    enum CodingKeys: String, CodingKey {
        case uTimeVersion = "uTime_Legacy"
        case uAppsNews =  "uApps_News"
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uTimeVersion = try? container.decode(String.self, forKey: .uTimeVersion)
        uAppsNews = try? container.decode(String.self, forKey: .uAppsNews)
    }
}
