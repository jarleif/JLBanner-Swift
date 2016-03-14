//
//  JLNotificationObject.swift
//  JLNotificationBanner-Swift
//
//  Created by Jared LaSante on 3/14/16.
//  Copyright © 2016 Jared LaSante. All rights reserved.
//

import UIKit

typealias ActionBlock = () -> ()
let kNotificationDisplayTime: Float = 4.0

/*!
*   JLNotificationObject is the object used to define what a banner contains and how it behaves
*   It also includes closures/blocks holding the actions for the left,right and main actions
*/
class JLNotificationObject: NSObject {

    /// The block of code when user taps the left action button
    var leftActionBlock: ActionBlock?
    /// The block of code when user taps the right action button
    var rightActionBlock: ActionBlock?
    /// The block of code when user taps the banner
    var mainActionBlock: ActionBlock?
    
    /// A UIImage for the background of the left action button
    var leftActionBackgroundImage: UIImage?
    /// A UIImage for the background of the right action button
    var rightActionBackgroundImage: UIImage?
    
    /// A UIColor for the background of the left action button
    var leftActionBackgroundColor: UIColor?
    /// A UIColor for the background of the right action button
    var rightActionBackgroundColor: UIColor?
    
    /// A UIImage for the left action button
    var leftActionImage: UIImage?
    /// A UIImage for the right action button
    var rightActionImage: UIImage?
    var rightActionTitle: String?
    
    /// The title of the notification
    var title: String?
    /// The message of the notification
    var message: String?
    /// The date of the notification
    var date: String?
    
    /// Specifies if the banner is animated
    var animated: Bool = true
    /// How long should the banner display for
    var displayTime: Float = kNotificationDisplayTime
    
    /// Should we replace a nil main action with a left or right action?
    var replaceNilMainAction: Bool = true
    
    /// Should the banner dismiss after an action is tapped
    var dismissOnAction: Bool = true
    /// Should the banner dismiss automatically
    var dismissAutomatically: Bool = true
    
}
