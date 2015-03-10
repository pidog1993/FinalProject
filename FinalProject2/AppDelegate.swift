//
//  AppDelegate.swift
//  FinalProject2
//
//  Created by Huang Ying-Kai on 2015/3/8.
//  Copyright (c) 2015年 Huang Ying-Kai. All rights reserved.
//

import WebKit
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, ServerDelegate {

    @IBOutlet weak var window: NSWindow!
    var server: Server!
    var services: NSMutableArray?
    var message: NSString?
    var isConnectedToService: Bool = false
    var longitude: NSString!
    var latitude: NSString!
    var heading: NSString!
    var pitch: NSString!
    var resetPitchFloat: Float = 0.0
    var resetPitchTimer: NSTimer!
    var textToSend: NSString?
    var selectedRow, connectedRow: NSInteger!
    var tableView: NSTableView!
    var lastMessageHeader: NSString!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    
    func thisIsATest(){
        
        println("test for git")
        
        
        
    }
    
    func thisIsAnotherTest(){
        
        
        println("test 2 for git")
        
        
    }
    
    func thisIsThirdTest(){
        
        println("test 5 for git")
        println("test 6 for git")
    }
    
    
    
//    pragma mark Street View PHP JS Method Call
    
    
    func loadStreetViewWithLatitude(latitudeString: NSString, longitudeString: NSString, headingString: NSString){
        
        self.latitude = latitudeString
        self.longitude = longitudeString
        self.heading = headingString
        var url = NSURL(string: NSString(format: "http://localhost/MapXplorer_Service/streetview.php?latitude=%@&longitude=%@&heading=%@",latitudeString,longitudeString,headingString))
        
        var request = NSURLRequest(URL: url!)
//        webView
    }
    
    
    func adjustBearing(bearingString: NSString){
        
        var numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        var headingNumber: NSNumber! = numberFormatter.numberFromString(bearingString)
//        var jsCallerObject  webView
        var args = NSArray(object: headingNumber)
        
//        jsCallerObject
        
    }
    
    func adjustPitch(pitchString: NSString){
        
        // Call JavaScript function on PHP pitch the street view camera
        var numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        var pitchNumber: NSNumber = numberFormatter.numberFromString(pitchString)!
        // Save the latest pitch float value for later use.
        // when we need to reset the pitch view
        self.resetPitchFloat = pitchNumber.floatValue
        //        var jsCallerObject  webView
        var args = NSArray(object: pitchNumber)
        
        //        jsCallerObject

    }
    
    func resetPitch(){
        
        
        
    }
    func moveForward(){
        
        
        
    }
    
    func moveBackward(){
        
        
        
        
    }
    
    func fastForward(){
        
        
        
        
    }
    
    
//    Server & Client Delegate
    
    func serverRemoteConnectionComplete(server: Server!) {
        self.isConnectedToService = true
        connectedRow = selectedRow
        tableView.reloadData()
    }
    
    func serverStopped(server: Server!) {
        self.isConnectedToService = false
        connectedRow = -1
        tableView.reloadData()
    }
    func server(server: Server!, didNotStart errorDict: [NSObject : AnyObject]!) {
        
    }
    func server(server: Server!, didAcceptData data: NSData!) {
        var localMessage = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if localMessage != nil && localMessage?.length > 0{
            self.message = localMessage
        }else{
            self.message = "No data is received"
        }
        
        var messageComponents = self.message?.componentsSeparatedByString(",")
        
        var messageHeader = NSString(format: "%@",locale: messageComponents?.first as? NSLocale)
     //    messageHeader = NSString(format: "%@",locale: messageComponents?[0] as? NSLocale)

        if messageHeader.isEqualToString("Location"){
            
            NSLog("On Long Press For LOCATION")
            self.latitude = messageComponents?[1] as NSString
            self.longitude = messageComponents?[2] as NSString
            self.heading = messageComponents?[3] as NSString

            // change location of street view
            self.loadStreetViewWithLatitude(self.latitude, longitudeString: self.longitude, headingString: self.heading)
        }else if messageHeader.isEqualToString("Bearing"){
            
            
            if !lastMessageHeader.isEqualToString("Bearing"){
                NSLog("On Acceleration or On Map Touch For ROTATION")
            }
            self.heading = messageComponents?[1] as NSString
            
            // adjust street view bearing
            self.adjustBearing(self.heading)
            
        }else if messageHeader.isEqualToString("Pitch"){
            if !lastMessageHeader.isEqualToString("Pitch"){
                NSLog("On Pan For PITCH")
            }
            self.pitch = messageComponents?[1] as NSString
            self.adjustPitch(self.pitch)
            
        }else if messageHeader.isEqualToString("ResetPitch"){
            self.resetPitch()
            
        }else if messageHeader.isEqualToString("Forward"){
            NSLog("On Pan For MOVING FORWARD")
            self.moveForward()
            
        }else if messageHeader.isEqualToString("Backward"){
            NSLog("On Pan For MOVING BACKWARD")
            self.moveBackward()
            
        }else if messageHeader.isEqualToString("Jump"){
            NSLog("On Shake For JUMP TO NEXT INTERSECTION")
            self.fastForward()
            
        }else if messageHeader.isEqualToString("OnMapTouchBegan"){
            NSLog("On Map Touch Began")
            
        }else if messageHeader.isEqualToString("OnPanTouchBegan"){
            NSLog("On Pan Touch Began")
            
        }else if messageHeader.isEqualToString("OnMapTouchEnd"){
            NSLog("On Map Touch End")
            
        }else if messageHeader.isEqualToString("OnPanTouchEnd"){
            NSLog("On Pan Touch End")
            
        }else if messageHeader.isEqualToString("Notification"){
            
            NSLog("Notification: %@", messageComponents?[1] as String)
            self.displayHUDNotification(messageComponents?[1]as NSString)
        }
        
        self.lastMessageHeader = messageHeader
        
    }
    
    
    func server(server: Server!, lostConnection errorDict: [NSObject : AnyObject]!) {
        
        self.isConnectedToService = false
        self.connectedRow = -1
        tableView.reloadData()
    }
    
    
    func serviceAdded(service: NSNetService!, moreComing more: Bool) {
        self.services?.addObject(service)
        if !more{
            tableView.reloadData()
        }
    }
    
    func serviceRemoved(service: NSNetService!, moreComing more: Bool) {
        self.services?.removeObject(service)
        if !more{
            tableView.reloadData()
        }
    }
    
//    pragma mark JavaScript bridge

    
    override func webView(sender: WebView!, didClearWindowObject windowObject: WebScriptObject!, forFrame frame: WebFrame!){
        windowObject.setValue(self, forKey: "mapXplorer")
        
    }
    
    
    override func webView(sender: WebView!, runJavaScriptAlertPanelWithMessage message: String!, initiatedByFrame frame: WebFrame!) {
        
    }
    
    
    
    
// Extra function for notification
    
    func endNotification(notification: NSString, type: NSString){
        
        var notificationMessage = NSString(format: "Notification,%@,%@",  notification, type)
        var data = notificationMessage.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError? = nil
        self.server?.sendData(data, error:&error)

    }
    func displayHUDNotification(notification: NSString){
        
//        textfield
//        notificationWindow
//        notificationWindow
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "fadeOutHUDNotification", userInfo: nil, repeats: false)
        
    }
    

    func fadeOutHUDNotification(){
//        notificationWindow
        
    }
    
    
    
}

