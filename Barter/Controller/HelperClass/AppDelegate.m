//
//  AppDelegate.m
//  Barter
//
//  Created by Nikhil Capsitech on 23/11/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "IQKeyboardManager.h"
#import "Reachability.h"
#import "CSNotificationView.h"
#import "AppHelper.h"
#import "ViewController.h"
#import "SignUP.h"
#import "Define.h"
#import "LoginVC.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    
    NSString *latitude;
    NSString *longitude;
    NSTimer*timerr;
    UIAlertView*aler;
}
@property (nonatomic, strong) CLGeocoder *myGeocoder;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:2.0];
    // this method is used for making cancle button text, white in color in search bar in all class.
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor whiteColor],
                                                                                                  UITextAttributeTextColor,
                                                                                                  [UIColor whiteColor],
                                                                                                  UITextAttributeTextShadowColor,
                                                                                                  [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                                                                  UITextAttributeTextShadowOffset,
                                                                                                  nil]
                                                                                        forState:UIControlStateNormal];
    
    
    
    
    
    [application setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        
        statusBar.backgroundColor = [UIColor whiteColor];//set whatever color you like
    }
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"first"];
    
    
     [FIRApp configure];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MFSideMenuContainerViewController *container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    // UIViewController *rightSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"rightSideMenuViewController"];
    
    [container setLeftMenuViewController:leftSideMenuViewController];
    //   [container setRightMenuViewController:rightSideMenuViewController];
    [container setCenterViewController:navigationController];
    UIImage *backBtn = [UIImage imageNamed:@"back.png"];
    backBtn = [backBtn imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [UINavigationBar appearance].backItem.title=@"";
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

    [UINavigationBar appearance].backIndicatorImage = backBtn;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backBtn;
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //  [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(74/255.0) green:(170/255.0) blue:(109/255.0) alpha:1]];
    
    [[UINavigationBar appearance] setBarTintColor:RgbColor];
    NSString*loginCheck=[AppHelper userDefaultsForKey:@"login"];
   
    if ([loginCheck isEqualToString:@"login"]) {
        
       

            ViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ViewController"];
            
            UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
            
            [container setCenterViewController:navigation];
            
        }
    else
    {
        LoginVC* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginVC"];
        
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        
        [container setCenterViewController:navigation];
    }
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        
        
        CLLocation *location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        latitude = [NSString stringWithFormat:@"%.12f", coordinate.latitude];
        longitude = [NSString stringWithFormat:@"%.12f", coordinate.longitude];
        
        CLLocation *location1 = [[CLLocation alloc]
                                 initWithLatitude:latitude.floatValue
                                 longitude:longitude.floatValue];
        
        self.myGeocoder = [[CLGeocoder alloc] init];
        
        [self.myGeocoder
         reverseGeocodeLocation:location1
         completionHandler:^(NSArray *placemarks, NSError *error) {
             if (error == nil &&
                 [placemarks count] > 0){
                 placemark = [placemarks lastObject];
                 NSString*    vendorLocation=[NSString stringWithFormat:@"%@ %@",
                                              placemark.locality,
                                              placemark.subLocality];
                 NSLog(@"%@",vendorLocation);
                 
                 
                 
             }
         }];
        
        
        
    }
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            
            placemark = [placemarks lastObject];
            NSString*sss= [NSString stringWithFormat:@"%@ , %@ , %@",[placemark thoroughfare],[placemark locality],[placemark administrativeArea]];
            NSString*locationstr=[NSString stringWithFormat:@"%@ %@",
                                  placemark.locality,
                                  placemark.subLocality  ];
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:locationstr forKey:@"location"];
            [prefs setObject:latitude forKey:@"latitude"];
            [prefs setObject:longitude forKey:@"longitude"];
            [prefs synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"location" object:nil];
            
        }
        else {
            
            NSLog(@"%@", error.debugDescription);
            
        }
        
    } ];
    
    [ locationManager stopUpdatingLocation];
    
}

- (void)gpsManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
}

+ (AppDelegate*) getAppDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
-(void)alert:(NSString*)alertTitle message:(NSString*)alertMessage cancelButtonTitle:(NSString*)cnclTitle otherButtonTitles:(NSString*)othrTitle
{
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:cnclTitle otherButtonTitles:othrTitle, nil];
    [alert show];
}

-(void)alertview_withoutBytton:(NSString*)msg
{
    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
    [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:2.0f];
}
-(void)dismissAlert:(UIAlertView *) alertView
{
    [alertView dismissWithClickedButtonIndex:nil animated:YES];
    
}
-(void)NotificationAlert:(UINavigationController*)nav message:(NSString *)Msg
{
    [CSNotificationView showInViewController:nav
                                   tintColor:[UIColor colorWithRed:165.0/255.0 green:42.0/255.0 blue:42.0/255.0 alpha:1.0]
                                       image:nil
                                     message:Msg
                                    duration:1.5f];
}
- (BOOL) checkInternateConnection
{
    Reachability *reg = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reg currentReachabilityStatus];
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        return NO;
    else
        return YES;
}



@end
