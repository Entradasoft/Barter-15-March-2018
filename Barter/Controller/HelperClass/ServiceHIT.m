//
//  ServiceHIT.m
//  Cheeky Monkey
//
//  Created by Vikas Rajput on 12/10/17.
//  Copyright © 2017 Entrdasoft. All rights reserved.
//

#import "ServiceHIT.h"
#import "AppDelegate.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "MBProgressHUD.h"
#import "Define.h"
#import "AppHelper.h"


@interface ServiceHIT ()

@end

@implementation ServiceHIT

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
+ (ServiceHIT *)sharedInstance
{
    static ServiceHIT *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        // sharedMyManager.activityIndicatorArray = [[NSMutableArray alloc]init];
        
    });
    return sharedMyManager;
}

-(void)POSTService:(NSString*)url Params:(NSDictionary*)param Occurance:(NSString*)HitingQuant
{
    
    //  NSString*MainUrl =  @"http://192.168.2.120/pg_rating/Service.svc/"; //sudiksha
    NSString*MainUrl =  @"http://192.168.2.46/rating/Service.svc/";
    if ([[AppDelegate getAppDelegate] checkInternateConnection])
    {
        NSString*urlString=[NSString stringWithFormat:@"%@%@",MainUrl,url];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        [manager POST:urlString parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSError *error = nil;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (JSON==nil) {
                [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Server Error" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            }
            else{
                if ([HitingQuant isEqualToString:@"1"]) {
                    
                    
                    [self.delegate ResponseData:JSON];
                }
                else if ([HitingQuant isEqualToString:@"2"])
                {
                    [self.delegate SecondTimeResponseData:JSON];
                }
            }
            
            // NSLog(@"%@",JSON);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            //  UIView * topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //   [[AppDelegate getAppDelegate]alertview_withoutBytton:@"Server Error"];
            
        }];
    }
    else
    {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:APP_NAME message:@"Connection Error. Please check your internet connection and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}
/*
 -(void)GetService:(NSString *)urlstr
 {
 if ([[AppDelegate getAppDelegate] checkInternateConnection])
 {
 NSURL *url = [NSURL URLWithString:@"https://example.com"];
 
 NSURLRequest *request = [NSURLRequest requestWithURL:url];
 
 AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
 initWithRequest:request];
 
 [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
 
 
 NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
 
 NSLog(@"%@", string);
 
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 
 NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
 }];
 
 }
 else
 {
 
 UIAlertView*alert=[[UIAlertView alloc]initWithTitle:APP_NAME message:@"Connection Error. Please check your internet connection and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Setting", nil];
 [alert show];
 }
 }
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
