//
//  AppDelegate.h
//  Barter
//
//  Created by Nikhil Capsitech on 23/11/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
#import <FirebaseAuth/FirebaseAuth.h>
#import <Firebase.h>
#import <MapKit/MapKit.h>
#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
+ (AppDelegate*) getAppDelegate;

-(void)alert:(NSString*)alertTitle message:(NSString*)alertMessage cancelButtonTitle:(NSString*)cnclTitle otherButtonTitles:(NSString*)othrTitle;
-(void)alertview_withoutBytton:(NSString*)msg;
- (BOOL) checkInternateConnection;;
-(void)NotificationAlert:(UINavigationController*)nav message:(NSString *)Msg;
@property (strong, nonatomic) UIWindow *window;


@end

