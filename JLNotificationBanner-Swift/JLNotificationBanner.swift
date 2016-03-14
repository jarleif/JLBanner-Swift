//
//  JLNotificationBanner.swift
//  JLNotificationBanner-Swift
//
//  Created by Jared LaSante on 3/14/16.
//  Copyright © 2016 Jared LaSante. All rights reserved.
//

import UIKit
import Foundation

let kBannerHeight : CGFloat = 64.0
let kBannerHandleHeight : CGFloat = 8.0
let kBannerPadding : CGFloat = 4.0
let kBannerLeftActionWidth : CGFloat = 56
let kBannerRightActionWidth : CGFloat = 56
let kSlideTiming = 0.30

private let _sharedOverlay = JLNotificationBanner()

/*!
*   JLNotification Banner extends UIWindow and provides a way to show banners on any screen in your app.
*   It also allows for showing if the app is in test mode or not
*/
class JLNotificationBanner: UIWindow, UIGestureRecognizerDelegate {

    var isTestMode: Bool = false
    var testModeLabel: UILabel!
    
    var notificationBG: UIView!
    var bannerCenterContainer: UIView!
    var bannerLeftContainer: UIView!
    var bannerRightContainer: UIView!
    var bannerLeftButton: UIButton!
    var bannerRightButton: UIButton!
    var bannerMainButton: UIButton!
    var constraintBannerLeftWidth: NSLayoutConstraint!
    var constraintBannerRightWidth: NSLayoutConstraint!
    
    var bannerTitleLabel: UILabel!
    var bannerMessageLabel: UILabel!
    var bannerTimeLabel: UILabel!
    
    var showingBanner: Bool = false
    var preVelocity: CGPoint = CGPointZero
    
    var notificationQueue: [JLNotificationObject] = [JLNotificationObject]()
    var isShowingBanner: Bool = false
    var shouldCloseBanner: Bool = true
    var notificationDisplayTimer: NSTimer?
    
    var currentNotification: JLNotificationObject?
    
    /***********************************************
    *  the Banner Singleton
    ***********************************************/
    class var overlay: JLNotificationBanner {
        //Have to set the background here...it is ignored in the init.
        _sharedOverlay.backgroundColor = UIColor(white: 0, alpha: 0)
        return _sharedOverlay
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.windowLevel = UIWindowLevelStatusBar + 1.0
        self.frame = UIApplication.sharedApplication().statusBarFrame
        self.backgroundColor = UIColor(white: 0, alpha: 0)//UIColor(white: 1, alpha: 1)//UIColor.clearColor()
        
        testModeLabel = UILabel(frame: CGRectMake(self.frame.size.width-100,0,100,self.frame.size.height))
        testModeLabel.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        testModeLabel.textAlignment = NSTextAlignment.Center
        testModeLabel.minimumScaleFactor = 0.5
        testModeLabel.text = "Test Mode"
        testModeLabel.textColor = UIColor.whiteColor()
        testModeLabel.backgroundColor = UIColor.redColor()
        addSubview(testModeLabel)
        setTestModeOn(false, animated: false)
        
        //Setup the Notification Banner
        notificationBG = UIView(frame: CGRectMake(0, 0, self.frame.size.width, kBannerHeight+kBannerHandleHeight))
        self.frame = notificationBG.frame
        notificationBG.backgroundColor = UIColor.clearColor()
        notificationBG.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        notificationBG.userInteractionEnabled = true
        
        let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanFrom:")
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delegate = self
        
        notificationBG.addGestureRecognizer(panRecognizer)
        
        let blurToolbar = UIToolbar(frame: notificationBG.frame)
        blurToolbar.translucent = true
        blurToolbar.barStyle = UIBarStyle.Black
        blurToolbar.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        notificationBG.addSubview(blurToolbar)
    
        
        //Setup the notification Handle
        let notificationBGHandle = UIView(frame: CGRectZero)
        notificationBGHandle.backgroundColor = UIColor.lightGrayColor()
        notificationBGHandle.layer.cornerRadius = 3
        notificationBGHandle.translatesAutoresizingMaskIntoConstraints = false
        notificationBG.addSubview(notificationBGHandle)
        
        var constraint = NSLayoutConstraint(item: notificationBGHandle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: notificationBG, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        notificationBG.addConstraint(constraint)
        constraint = NSLayoutConstraint(item:notificationBGHandle, attribute:NSLayoutAttribute.Bottom, relatedBy:NSLayoutRelation.Equal, toItem:notificationBG, attribute:NSLayoutAttribute.Bottom, multiplier:1.0, constant:-4.0)
        notificationBG.addConstraint(constraint)
        constraint = NSLayoutConstraint(item:notificationBGHandle, attribute:NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:35.0)
        notificationBG.addConstraint(constraint)
        constraint = NSLayoutConstraint(item:notificationBGHandle, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:6.0)
        notificationBG.addConstraint(constraint)
        
        //Setup the Left Container
        bannerLeftContainer = UIView(frame: CGRectZero)
        bannerLeftContainer.backgroundColor = UIColor.clearColor()
        bannerLeftContainer.layer.cornerRadius = 3;
        bannerLeftContainer.clipsToBounds = true
        bannerLeftContainer.translatesAutoresizingMaskIntoConstraints = false
        notificationBG.addSubview(bannerLeftContainer)
        
        constraint = NSLayoutConstraint(item:bannerLeftContainer, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:notificationBG, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerLeftContainer, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:notificationBG, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraintBannerLeftWidth = NSLayoutConstraint(item:bannerLeftContainer, attribute:NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:kBannerLeftActionWidth)
        notificationBG.addConstraint(constraintBannerLeftWidth)
        
        constraint = NSLayoutConstraint(item:bannerLeftContainer, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:kBannerLeftActionWidth)
        notificationBG.addConstraint(constraint)
        
        //Setup the Left Action Button
        bannerLeftButton = UIButton()
        bannerLeftButton.backgroundColor = UIColor.redColor()
        bannerLeftButton.layer.cornerRadius = 3;
        bannerLeftButton.clipsToBounds = true
        bannerLeftButton.translatesAutoresizingMaskIntoConstraints = false
        bannerLeftButton.addTarget(self, action: "handleLeftAction", forControlEvents: UIControlEvents.TouchUpInside)
        bannerLeftContainer.addSubview(bannerLeftButton)
        
        constraint = NSLayoutConstraint(item:bannerLeftButton, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:bannerLeftContainer, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:0.0)
        bannerLeftContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerLeftButton, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:bannerLeftContainer, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:0.0)
        bannerLeftContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerLeftButton, attribute:NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.Equal, toItem: bannerLeftContainer, attribute:NSLayoutAttribute.Width, multiplier:1.0, constant:0.0)
        bannerLeftContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerLeftButton, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: bannerLeftContainer, attribute:NSLayoutAttribute.Height, multiplier:1.0, constant:0.0)
        bannerLeftContainer.addConstraint(constraint)
        
        
        //Setup the Right Container
        bannerRightContainer = UIView(frame: CGRectZero)
        bannerRightContainer.backgroundColor = UIColor.whiteColor()
        bannerRightContainer.layer.cornerRadius = 3
        bannerRightContainer.clipsToBounds = true
        bannerRightContainer.translatesAutoresizingMaskIntoConstraints = false
        notificationBG.addSubview(bannerRightContainer)
        
        constraint = NSLayoutConstraint(item:bannerRightContainer, attribute:NSLayoutAttribute.Trailing, relatedBy:NSLayoutRelation.Equal, toItem:notificationBG, attribute:NSLayoutAttribute.Trailing, multiplier:1.0, constant:-kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerRightContainer, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:notificationBG, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraintBannerRightWidth = NSLayoutConstraint(item:bannerRightContainer, attribute:NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:kBannerRightActionWidth)
        notificationBG.addConstraint(constraintBannerRightWidth)
        
        constraint = NSLayoutConstraint(item:bannerRightContainer, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:kBannerLeftActionWidth)
        notificationBG.addConstraint(constraint)
        
        //Setup the Right Action Button
        bannerRightButton = UIButton()
        bannerRightButton.backgroundColor = UIColor.redColor()
        bannerRightButton.layer.cornerRadius = 3;
        bannerRightButton.clipsToBounds = true
        bannerRightButton.translatesAutoresizingMaskIntoConstraints = false
        bannerRightButton.addTarget(self, action:"handleRightAction", forControlEvents:UIControlEvents.TouchUpInside)
        bannerRightContainer.addSubview(bannerRightButton)
        
        constraint = NSLayoutConstraint(item:bannerRightButton, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:bannerRightContainer, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:0.0)
        bannerRightContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerRightButton, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:bannerRightContainer, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:0.0)
        bannerRightContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerRightButton, attribute:NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.Equal, toItem: bannerRightContainer, attribute:NSLayoutAttribute.Width, multiplier:1.0, constant:0.0)
        bannerRightContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerRightButton, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: bannerRightContainer, attribute:NSLayoutAttribute.Height, multiplier:1.0, constant:0.0)
        bannerRightContainer.addConstraint(constraint)
        
        
        //Setup the Center container
        bannerCenterContainer = UIView(frame: CGRectZero)
        bannerCenterContainer.backgroundColor = UIColor.clearColor()
        bannerCenterContainer.translatesAutoresizingMaskIntoConstraints = false
        notificationBG.addSubview(bannerCenterContainer)
        
        constraint = NSLayoutConstraint(item:bannerCenterContainer, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:bannerLeftContainer, attribute:NSLayoutAttribute.Trailing, multiplier:1.0, constant:0)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerCenterContainer, attribute:NSLayoutAttribute.Trailing, relatedBy:NSLayoutRelation.Equal, toItem:bannerRightContainer, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:0)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerCenterContainer, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:notificationBG, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerCenterContainer, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:kBannerHeight-2*kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        
        
        
        //Setup the Banner title label
        bannerTitleLabel = UILabel()
        bannerTitleLabel.backgroundColor = UIColor.clearColor()
        bannerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bannerTitleLabel.text = "Title"
        bannerTitleLabel.textColor = UIColor.whiteColor()
        bannerTitleLabel.font = UIFont.systemFontOfSize(16)
        bannerTitleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        bannerTitleLabel.minimumScaleFactor = 10.0/16.0
        bannerTitleLabel.adjustsFontSizeToFitWidth = true
        bannerCenterContainer.addSubview(bannerTitleLabel)
        
        constraint = NSLayoutConstraint(item:bannerTitleLabel, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:bannerCenterContainer, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerTitleLabel, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:bannerCenterContainer, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:0.0)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerTitleLabel, attribute:NSLayoutAttribute.Trailing, relatedBy:NSLayoutRelation.Equal, toItem: bannerCenterContainer, attribute:NSLayoutAttribute.Trailing, multiplier:1.0, constant:-kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        var labelSize = CGSizeZero
        if let labelText = bannerTitleLabel.text {
            labelSize = labelText.boundingRectWithSize( CGSizeMake(bannerTitleLabel.frame.size.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:bannerTitleLabel.font], context:nil).size
        }
        
        constraint = NSLayoutConstraint(item:bannerTitleLabel, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:1.0, constant:labelSize.height)
        notificationBG.addConstraint(constraint)
        
        //Setup the Banner message label
        bannerMessageLabel = UILabel()
        bannerMessageLabel.backgroundColor = UIColor.clearColor()
        bannerMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        bannerMessageLabel.text = "A longer MessageText that should take up two lines of code"
        bannerMessageLabel.textColor = UIColor.whiteColor()
        bannerMessageLabel.numberOfLines = 2
        bannerMessageLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        bannerMessageLabel.font = UIFont.systemFontOfSize(16)
        bannerMessageLabel.minimumScaleFactor = 10.0/16.0
        bannerMessageLabel.adjustsFontSizeToFitWidth = true
        
        bannerCenterContainer.addSubview(bannerMessageLabel)
        
        constraint = NSLayoutConstraint(item:bannerMessageLabel, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:bannerCenterContainer, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerMessageLabel, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:bannerTitleLabel, attribute:NSLayoutAttribute.Bottom, multiplier:1.0, constant:0.0)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerMessageLabel, attribute:NSLayoutAttribute.Trailing, relatedBy:NSLayoutRelation.Equal, toItem: bannerCenterContainer, attribute:NSLayoutAttribute.Trailing, multiplier:1.0, constant:-kBannerPadding)
        notificationBG.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerMessageLabel, attribute:NSLayoutAttribute.Bottom, relatedBy:NSLayoutRelation.Equal, toItem: bannerCenterContainer, attribute:NSLayoutAttribute.Bottom, multiplier:1.0, constant:0.0)
        notificationBG.addConstraint(constraint)
        
        //Setup the main Banner Action Button
        bannerMainButton = UIButton()
        bannerMainButton.backgroundColor = UIColor.clearColor()
        bannerMainButton.clipsToBounds = true
        bannerMainButton.translatesAutoresizingMaskIntoConstraints = false
        bannerMainButton.addTarget(self, action:"handleMainAction", forControlEvents:UIControlEvents.TouchUpInside)
        bannerCenterContainer.addSubview(bannerMainButton)
        
        constraint = NSLayoutConstraint(item:bannerMainButton, attribute:NSLayoutAttribute.Leading, relatedBy:NSLayoutRelation.Equal, toItem:bannerCenterContainer, attribute:NSLayoutAttribute.Leading, multiplier:1.0, constant:0.0)
        bannerCenterContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerMainButton, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:bannerCenterContainer, attribute:NSLayoutAttribute.Top, multiplier:1.0, constant:0.0)
        bannerCenterContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerMainButton, attribute:NSLayoutAttribute.Width, relatedBy:NSLayoutRelation.Equal, toItem: bannerCenterContainer, attribute:NSLayoutAttribute.Width, multiplier:1.0, constant:0.0)
        bannerCenterContainer.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item:bannerMainButton, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem: bannerCenterContainer, attribute:NSLayoutAttribute.Height, multiplier:1.0, constant:0.0)
        bannerCenterContainer.addConstraint(constraint)
        
        //Setup the Time Label
        /*bannerTimeLabel = [[UILabel alloc]init];
        [bannerTimeLabel setBackgroundColor:[UIColor clearColor]];
        bannerTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [bannerTimeLabel setText:@"30m ago"];
        [bannerTimeLabel setTextColor:[UIColor whiteColor]];
        [bannerTimeLabel setFont:[UIFont systemFontOfSize:12]];
        [bannerTimeLabel setMinimumScaleFactor:10.0/12.0];
        [bannerTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [bannerTimeLabel setAdjustsLetterSpacingToFitWidth:YES];
        
        [bannerCenterContainer addSubview:bannerTimeLabel];
        
        // constraint = NSLayoutConstraint(item:bannerTimeLabel attribute:NSLayoutAttribute.Leading relatedBy:NSLayoutRelationEqual toItem:bannerTitleLabel attribute:NSLayoutAttribute.Trailing multiplier:1.0f constant:0.0f];
        //Currently not using Time label so set its width to become 0
        constraint = NSLayoutConstraint(item:bannerTimeLabel attribute:NSLayoutAttribute.Leading relatedBy:NSLayoutRelationEqual toItem:bannerCenterContainer attribute:NSLayoutAttribute.Trailing multiplier:1.0f constant:0.0f];
        [_notificationBG.addConstraint(constraint];
        
        constraint = NSLayoutConstraint(item:bannerTimeLabel attribute:NSLayoutAttribute.Top relatedBy:0.0f toItem:bannerTitleLabel attribute:NSLayoutAttribute.Top multiplier:1.0f constant:0.0f];
        [_notificationBG.addConstraint(constraint];
        
        constraint = NSLayoutConstraint(item:bannerTimeLabel attribute:NSLayoutAttribute.Trailing relatedBy:NSLayoutRelationEqual toItem:bannerCenterContainer attribute:NSLayoutAttribute.Trailing multiplier:1.0f constant:0.0f];
        [_notificationBG.addConstraint(constraint];
        
        constraint = NSLayoutConstraint(item:bannerTimeLabel attribute:NSLayoutAttribute.Bottom relatedBy:NSLayoutRelationEqual toItem: bannerTitleLabel attribute:NSLayoutAttribute.Bottom multiplier:1.0f constant:0.0f];
        [_notificationBG.addConstraint(constraint];
        */
        addSubview(notificationBG)
        notificationBG.hidden = true
        userInteractionEnabled = true
        
        notificationQueue = [JLNotificationObject]()
        self.closeBannerAnimated(false)
        
        //Setup Notification to detect change in orientation
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"statusBarDidChangeFrame:", name:UIApplicationDidChangeStatusBarFrameNotification, object:nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
//        super.init(coder: aDecoder)
    }
    
    //MARK: Gesutre Recognizer Delegate
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer
        {
            return true
        }
        return false
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    //MARK: Visibility
    /*!
    *   @fn setOverlayVisible
    *   @brief  A function to set the window overlay to be visible or hidden
    *   @param BOOL Specifies if the window should be visible or not
    */
    func setOverlayVisible(becomeVisible : Bool)
    {
        if becomeVisible
        {
            showOverlay()
        }
        else
        {
            hideOverlay()
        }
    }
    /*!
    *   @fn showOverlay
    *   @brief  A function to set the window overlay to be visible
    */
    func showOverlay()
    {
        self.hidden = false
    }
    /*!
    *   @fn hideOverlay
    *   @brief  A function to set the window overlay to be hidden
    */
    func hideOverlay()
    {
        if !isShowingBanner && !isTestMode
        {
            self.hidden = true
        }
    }

    //MARK: Test Mode
    func toggleTestMode()
    {
        setTestModeOn(!isTestMode, animated: true)
    }
    
    func setTestModeOn(turnOn: Bool, animated: Bool)
    {
        isTestMode = turnOn
        if turnOn
        {
            if !isShowingBanner
            {
                self.frame = UIApplication.sharedApplication().statusBarFrame
            }
            showOverlay()
        }
        if animated
        {
            var animationOption = UIViewAnimationOptions.TransitionCurlDown;
            if !turnOn
            {
                animationOption = UIViewAnimationOptions.TransitionCurlUp;
            }
            UIView.transitionWithView(testModeLabel, duration: 0.8, options: animationOption, animations: { () -> Void in
                self.testModeLabel.hidden = !self.isTestMode
                }, completion: { (finished) -> Void in
                    if finished && !turnOn
                    {
                        self.hideOverlay()
                    }
            })
        }
        else
        {
            testModeLabel.hidden = !isTestMode
        }
    }
    
    //MARK: Adding Notifications
    func pushNotificationWithTitle(title: String, message: String)
    {
        dispatch_async(dispatch_get_main_queue()) {
            let object = JLNotificationObject()
            object.title = title
            object.message = message
            self.pushNotification(object, animated: true)
        }
    }
    
    func pushNotification(notificationObject: JLNotificationObject, animated: Bool)
    {
        dispatch_async(dispatch_get_main_queue()) {
            notificationObject.animated = animated
            self.notificationQueue.insert(notificationObject, atIndex: 0)
            if !self.isShowingBanner
            {
                self.checkForNotificationToShow()
            }
        }
    }
    
    func pushNotificationImmediately(notificationObject: JLNotificationObject, animated: Bool)
    {
        dispatch_async(dispatch_get_main_queue()) {
            notificationObject.animated = animated;
            self.notificationQueue.append(notificationObject)
            if self.isShowingBanner
            {
                self.closeBannerAnimated()
            }
            else
            {
                self.checkForNotificationToShow()
            }
        }
    }
    
    /*!
    *   @fn checkForNotificationToShow
    *   @brief  A function to check if it should show another notification
    */
    func checkForNotificationToShow()
    {
        if notificationQueue.count > 0 && !isShowingBanner
        {
            self.showNotification(notificationQueue.last!)
            notificationQueue.removeLast()
        }
    }
    /*!
    *   @fn showNotification
    *   @brief  A function to display the notification object
    *   @param JLNotificationObject The notification object to display
    */
    func showNotification(notificationObject: JLNotificationObject)
    {
        self.hidden = false
        notificationBG.hidden = false
        if !isShowingBanner
        {
            //Make sure banner frame is correct based on the orientation
            switch UIApplication.sharedApplication().statusBarOrientation {
            case UIInterfaceOrientation.LandscapeLeft:
                self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x, UIApplication.sharedApplication().statusBarFrame.origin.y,kBannerHeight+kBannerHandleHeight, UIApplication.sharedApplication().statusBarFrame.size.height)
                break
            case UIInterfaceOrientation.LandscapeRight:
                self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x-(kBannerHeight+kBannerHandleHeight-20), UIApplication.sharedApplication().statusBarFrame.origin.y, (kBannerHeight+kBannerHandleHeight),UIApplication.sharedApplication().statusBarFrame.size.height)
                break
            case UIInterfaceOrientation.PortraitUpsideDown:
                self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x, UIApplication.sharedApplication().statusBarFrame.origin.y, UIApplication.sharedApplication().statusBarFrame.size.width, kBannerHeight+kBannerHandleHeight)
                break
            default://Portrait
                self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x, UIApplication.sharedApplication().statusBarFrame.origin.y, UIApplication.sharedApplication().statusBarFrame.size.width, kBannerHeight+kBannerHandleHeight)
                break
            }
        }
        isShowingBanner = true
        //Configure the left Action Button
        if notificationObject.leftActionBackgroundImage != nil || notificationObject.leftActionBackgroundColor != nil || notificationObject.leftActionImage != nil
        {
            if let leftBGColor = notificationObject.leftActionBackgroundColor
            {
                bannerLeftButton.backgroundColor = leftBGColor
            }
            if let leftBGImage = notificationObject.leftActionBackgroundImage
            {
                bannerLeftButton.setBackgroundImage(leftBGImage, forState: UIControlState.Normal)
            }
            if let leftActionImage = notificationObject.leftActionImage
            {
                bannerLeftButton.setImage(leftActionImage, forState: UIControlState.Normal)
                constraintBannerLeftWidth.constant = kBannerLeftActionWidth;
            }
        }
        else
        {
            constraintBannerLeftWidth.constant = 0
        }
        
        if notificationObject.leftActionBlock != nil
        {
            bannerLeftButton.userInteractionEnabled = true
        }
        else
        {
            bannerLeftButton.userInteractionEnabled = false
        }
        
        //Configure the right Action Button
        if notificationObject.rightActionBackgroundImage != nil || notificationObject.rightActionBackgroundColor != nil || notificationObject.rightActionImage != nil
        {
            if let rightBGColor = notificationObject.rightActionBackgroundColor
            {
                bannerRightButton.backgroundColor = rightBGColor
            }
            if let rightBGImage = notificationObject.rightActionBackgroundImage
            {
                bannerRightButton.setBackgroundImage(rightBGImage, forState: UIControlState.Normal)
            }
            if let rightActionImage = notificationObject.rightActionImage
            {
                bannerRightButton.setImage(rightActionImage, forState: UIControlState.Normal)
                constraintBannerRightWidth.constant = kBannerRightActionWidth;
            }
        }
        else
        {
            constraintBannerRightWidth.constant = 0
        }
        
        if notificationObject.rightActionBlock != nil
        {
            bannerRightButton.userInteractionEnabled = true
        }
        else
        {
            bannerRightButton.userInteractionEnabled = false
        }
        
        //Configure the main Action Block
        if notificationObject.mainActionBlock != nil
        {
            bannerMainButton.userInteractionEnabled = true
        }
        else
        {
            bannerMainButton.userInteractionEnabled = false
        }
        
        currentNotification = notificationObject
        if notificationObject.animated
        {
            UIView.transitionWithView(bannerCenterContainer, duration: 0.8, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.bannerMessageLabel.text = notificationObject.message
                self.bannerTitleLabel.text = notificationObject.title
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    if(finished)
                    {
                        self.moveBannerToOriginalPosition()
                    }
            })
        }
        else
        {
            bannerMessageLabel.text = notificationObject.message
            bannerTitleLabel.text = notificationObject.title
            self.layoutIfNeeded()
            notificationBG.frame = CGRectMake(0, 0, notificationBG.frame.size.width, notificationBG.frame.size.height)
        }
        if notificationObject.dismissAutomatically
        {
            notificationDisplayTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(notificationObject.displayTime), target: self, selector: "closeBanner", userInfo: nil, repeats: false)
        }
    }
    
    /*!
    *   @fn moveBannerToOriginalPosition
    *   @brief  A function to move the banner to its original position
    */
    func moveBannerToOriginalPosition()
    {
        
    UIView.animateWithDuration(kSlideTiming, delay:0, options:[UIViewAnimationOptions.BeginFromCurrentState,UIViewAnimationOptions.CurveEaseOut], animations:{()-> Void in
            self.notificationBG.frame = CGRectMake(0, 0, self.notificationBG.frame.size.width, self.notificationBG.frame.size.height);
        }, completion: nil)
    }
    
    /*!
    *   @fn closeBanner
    *   @brief  A helper function to close the banner
    */
    func closeBanner()
    {
        closeBannerAnimated()
    }
    
    /*!
    *   @fn closeBannerAnimated
    *   @brief  A function to close the banner
    *   @param BOOL Specifies if the notification should be animated or not
    */
    func closeBannerAnimated(animated: Bool = true)
    {
        self.layer.removeAllAnimations()
        currentNotification = nil
        if let timer = notificationDisplayTimer
        {
            timer.invalidate()
            notificationDisplayTimer = nil
        }
        if animated
        {
            UIView.animateWithDuration(kSlideTiming, delay: 0, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseIn], animations: { () -> Void in
                self.notificationBG.frame = CGRectMake(0, -self.notificationBG.frame.size.height, self.notificationBG.frame.size.width, self.notificationBG.frame.size.height)
                }, completion: { (finished) -> Void in
                    if (finished) {
                        self.isShowingBanner = false
                        self.hideOverlay()
                        self.checkForNotificationToShow()
                        self.notificationBG.hidden = false
                    }
            })
        }
        else
        {
            notificationBG.frame = CGRectMake(0, -notificationBG.frame.size.height, notificationBG.frame.size.width, notificationBG.frame.size.height)
            isShowingBanner = false
            hideOverlay()
            checkForNotificationToShow()
        }
    }
    //MARK: Button Actions
    /*!
    *   @fn handleLeftAction
    *   @brief  A function for when the left action button is clicked
    */
    func handleLeftAction()
    {
        if let notification = currentNotification, leftAction = notification.leftActionBlock
        {
            leftAction()
            if notification.dismissOnAction
            {
                self.closeBannerAnimated()
            }
        }
    }
    
    /*!
    *   @fn handleRightAction
    *   @brief  A function for when the right action button is clicked
    */
    func handleRightAction()
    {
        if let notification = currentNotification, rightAction = notification.rightActionBlock
        {
            rightAction()
            if notification.dismissOnAction
            {
                self.closeBannerAnimated()
            }
        }
    }
    
    /*!
    *   @fn handleMainAction
    *   @brief  A function for when the main action button is clicked
    */
    func handleMainAction()
    {
    //If there isn't a main notificationAction, but there is a right action, make tapping the banner use the right or left button action
        if let notification = currentNotification
        {
            if notification.mainActionBlock == nil
            {
                if let leftAction = notification.leftActionBlock
                {
                    notification.mainActionBlock = leftAction
                }
                if let rightAction = notification.rightActionBlock
                {
                    notification.mainActionBlock = rightAction
                }
            }
            if let mainBlock = notification.mainActionBlock
            {
                mainBlock()
                if notification.dismissOnAction
                {
                    self.closeBannerAnimated()
                }
            }
        }
    }
    
    /*!
    *   @fn handlePanFrom
    *   @brief  A function for the handling the pan gesture on the banner
    *   @param UIPanGestureRecognizer The pan gesture
    */
    func handlePanFrom(sender: UIPanGestureRecognizer)
    {
        sender.view?.layer.removeAllAnimations()
        let translatedPoint : CGPoint = sender.translationInView(self)
        let velocity : CGPoint = sender.velocityInView(sender.view)
        if sender.state == UIGestureRecognizerState.Began
        {
            if let timer = notificationDisplayTimer
            {
                timer.invalidate()
                notificationDisplayTimer = nil
            }
            sender.view?.bringSubviewToFront(sender.view!)
        }
        
        if sender.state == UIGestureRecognizerState.Ended
        {
            if velocity.y < -150
            {
                self.closeBannerAnimated()
                return
            }
            
            let gestureCheckHeight = sender.view!.frame.size.height//+[sender view].frame.origin.y;
            let notifCheckHeight = notificationBG.frame.size.height//*2/3;
            if gestureCheckHeight <= notifCheckHeight
            {
                self.closeBannerAnimated()
            }
            else
            {
                self.moveBannerToOriginalPosition()
                if let notification = currentNotification where notification.dismissAutomatically
                {
                    notificationDisplayTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(notification.displayTime), target:self, selector:"closeBanner", userInfo:nil, repeats:false)
                }
            }
        }
        
        if sender.state == UIGestureRecognizerState.Changed
        {
            // Allow dragging only in y-coordinates by only updating the y-coordinate with translation position.
            let centerPosY = sender.view!.center.y + translatedPoint.y
            if centerPosY <= notificationBG.frame.size.height/2
            {
                sender.view!.center = CGPointMake(sender.view!.center.x,centerPosY)
                
                sender.setTranslation(CGPointMake(0,0), inView:notificationBG)
            }
            // If you needed to check for a change in direction, you could use this code to do so.
            if(velocity.x*preVelocity.x + velocity.y*preVelocity.y > 0) {
            // NSLog(@"same direction");
            } else {
            // NSLog(@"opposite direction");
            }
            preVelocity = velocity
        }
    }
    
    
    
    //MARK: Orientation Helper
    func degreesToRadians (degrees: Double)->CGFloat {
        return CGFloat(degrees * M_PI / 180)
    }
    /*!
    *   @fn transformForOrientation
    *   @brief  A function for rotating the banner with the screen
    *   @param UIInterfaceOrientation The current orientation of the screen
    */
    func transformForOrientation(orientation : UIInterfaceOrientation)
    {
//        NSLog(@"%@", NSStringFromCGRect([[UIApplication sharedApplication] statusBarFrame]));
        
        switch (orientation) {
        case UIInterfaceOrientation.LandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(-degreesToRadians(90))
            self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x, UIApplication.sharedApplication().statusBarFrame.origin.y, self.frame.size.width, UIApplication.sharedApplication().statusBarFrame.size.height)
            break
        case UIInterfaceOrientation.LandscapeRight:
            self.transform = CGAffineTransformMakeRotation(degreesToRadians(90))
            self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x-self.frame.size.width+20, UIApplication.sharedApplication().statusBarFrame.origin.y, self.frame.size.width, UIApplication.sharedApplication().statusBarFrame.size.height)
                break
            case UIInterfaceOrientation.PortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(degreesToRadians(180))
                self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x, UIApplication.sharedApplication().statusBarFrame.origin.y, UIApplication.sharedApplication().statusBarFrame.size.width, self.frame.size.height)
                break
        default:
            self.transform = CGAffineTransformMakeRotation(degreesToRadians(0))
            self.frame = CGRectMake(UIApplication.sharedApplication().statusBarFrame.origin.x, UIApplication.sharedApplication().statusBarFrame.origin.y, UIApplication.sharedApplication().statusBarFrame.size.width, self.frame.size.height)
            break
        }
    }
    
    func statusBarDidChangeFrame(notification: NSNotification)
    {
    
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        self.transformForOrientation(orientation)
    }
    
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
