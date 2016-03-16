//
//  SocketIOManager.swift
//  real-time-location-socket-io
//
//  Created by Henry Chan on 3/15/16.
//  Copyright © 2016 Henry Chan. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import CoreLocation

class SocketIOManager {
    
    static let sharedInstance = SocketIOManager()
    
    var socket = SocketIOClient(socketURL: NSURL(string: "http://10.6.0.81:3000")!, options: [.Log(true), .ForcePolling(true)])
    
    func connect () {
        
        socket.on("connected") {data, ack in
            self.socket.emit("response", "Hello!")
        }
        
        socket.connect()
    }
    
    
    func connectToServerWithNickname(nickname: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
        
        listenForOtherMessages()
        

    }
    
    func updateUserLocation(location:CLLocation) {
        let coordinates = ["lat":location.coordinate.latitude, "long":location.coordinate.longitude]
        socket.emit("userLocationUpdated", coordinates)
    }
    
    func listenForOtherMessages() {
        socket.on("locationsWereUpdated") {( dataArray, ack) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("locationsWereUpdated", object: dataArray[0])
//            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
    }
}
