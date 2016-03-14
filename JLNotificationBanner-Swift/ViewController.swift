//
//  ViewController.swift
//  JLNotificationBanner-Swift
//
//  Created by Jared LaSante on 3/14/16.
//  Copyright © 2016 Jared LaSante. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        JLNotificationBanner.overlay.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testModeButton(sender : AnyObject)
    {
        JLNotificationBanner.overlay.toggleTestMode()
    }
    
    @IBAction func showBanner(sender : AnyObject)
    {
        let newObj : JLNotificationObject = JLNotificationObject()
        newObj.title = "Test Title"
        newObj.message = "Test Message text goes here and can expand on to a second line"
        newObj.rightActionBackgroundImage = JLUtils.imageWithGradient([UIColor(red: 0.3882, green: 0.6902, blue: 0.8902, alpha: 1.0),UIColor(red: 0.3059, green: 0.5804, blue: 0.8039, alpha: 1.0)], imageHeight: kBannerRightActionWidth)
        newObj.rightActionImage = UIImage(named:"ic_phone")
        newObj.rightActionBlock = {
            let alert = UIAlertView(title: "Test Message", message: "This is a test of the right action", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        newObj.mainActionBlock = {
            let alert = UIAlertView(title:"Main Test Message",
            message:"This is a test of the main action",
            delegate:nil,
            cancelButtonTitle:"OK")
            alert.show()
        }
//        JLNotificationBanner.overlay.backgroundColor = UIColor(white: 0, alpha: 0)
        JLNotificationBanner.overlay.pushNotification(newObj, animated: true)
    }
    
    @IBAction func showBannerNow(sender : AnyObject)
    {
        let newObj = JLNotificationObject()
        newObj.title = "Immediate Banner Notification Title"
        newObj.message = "This message is immediately shown and must be manually dismissed"
        newObj.leftActionBackgroundColor = UIColor.redColor()
        newObj.leftActionImage = UIImage(named: "ic_phone")
        newObj.dismissOnAction = false
        newObj.dismissAutomatically = false
        newObj.leftActionBlock = {
            let alert = UIAlertView(title:"Test Message",
            message:"This is a test of the left action",
            delegate:nil,
            cancelButtonTitle:"OK")
            alert.show()
        }
        newObj.mainActionBlock = {
            let alert = UIAlertView(title:"Main Test Message",
            message:"This is a test of the main action",
            delegate:nil,
            cancelButtonTitle:"OK")
            alert.show()
        }
        JLNotificationBanner.overlay.pushNotificationImmediately(newObj, animated:true)
    }
    
    @IBAction func showPlainBanner(sender : AnyObject)
    {
        let newObj = JLNotificationObject()
        newObj.title = "Plain Test Title"
        newObj.message = "Plain test message without any side buttons and can expand on to a second line"
        newObj.mainActionBlock = {
            let alert = UIAlertView(title:"Main Test Message",
            message:"This is a test of the main action",
            delegate:nil,
            cancelButtonTitle:"OK")
            alert.show()
        }
        
        JLNotificationBanner.overlay.pushNotification(newObj, animated:true)
    }
}

