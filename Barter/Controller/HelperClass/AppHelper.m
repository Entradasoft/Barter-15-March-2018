//
//  AppHelper.m
//  Monaqsat
//
//  Created by rentaluser on 4/23/15.
//  Copyright (c) 2015 FourthScreenLabs. All rights reserved.
//

//Frameworks
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Accounts/Accounts.h>
//classes
#import "AppHelper.h"
#import "AppDelegate.h"
#import "Define.h"


@implementation AppHelper
+ (UIImage*)appLogoImage
{
    return [UIImage imageNamed:@"appLogo.png"];
}
+ (AppHelper *)sharedInstance
{
    static AppHelper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        // sharedMyManager.activityIndicatorArray = [[NSMutableArray alloc]init];
        
    });
    return sharedMyManager;
}
+(void)saveToUserDefaults:(id)value withKey:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:value forKey:key];
        [standardUserDefaults synchronize];
    }
}

+(NSString*)userDefaultsForKey:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
    
    if (standardUserDefaults)
        val = [standardUserDefaults objectForKey:key];
    
    return val;
}

/*
+(void)removeFromUserDefaultsWithKey:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [standardUserDefaults removeObjectForKey:key];
    [standardUserDefaults synchronize];
}

+(NSString*)CheckStatus:(NSString*)status
{
    NSString*result;
    if ([status isEqualToString:@"A"]) {
        result=@"Pending";
        
    }
    else if ([status isEqualToString:@"B"])
    {
        result=@"Accepted";
    }
    else if ([status isEqualToString:@"B1"])
    {
        result=@"Under Preparation";
    }
    else if ([status isEqualToString:@"C"])
    {
        result=@"Cancelled";
    }
    else if ([status isEqualToString:@"D"])
    {
        result=@"Cancelled (by Steward)";
    }
    else if ([status isEqualToString:@"E"])
    {
        result=@"Cancelled (by Admin)";
    }
    else if ([status isEqualToString:@"F"])
    {
        result=@"Delivered";
    }
    else if ([status isEqualToString:@"P"])
    {
        result=@"Preparing";
    }
    else if ([status isEqualToString:@"R"])
    {
        result=@"Prepared";
    }
    else if ([status isEqualToString:@"K"]||[status isEqualToString:@""])
    {
        result=@"Accepted";
    }

       return result;
    
}

*/
+(void)getfb:(ACAccountStore *)accountStore
{
    
    if (accountStore == nil)
    {
        accountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType * facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray * permissions = @[@"user_likes",@"user_friends",@"email",@"mobile",@"public_profile",];
    NSDictionary * dict = @{ACFacebookAppIdKey : @"178483605849826", ACFacebookPermissionsKey : permissions, ACFacebookAudienceKey : ACFacebookAudienceEveryone};
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            NSLog(@"granted");
            
            NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
            
            ACAccount *account = [accounts lastObject];
            
            {
                NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/"];
                SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL :url parameters:nil];
                
                // 4. attach an account to the request
                
                [request setAccount :account];
                
                // 5. execute the request
                [request performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse,NSError*error) {
                    
                    if (responseData)
                    {
                        NSError *jsonError =nil;
                        NSDictionary *jsonDict = [ NSJSONSerialization JSONObjectWithData :responseData options : NSJSONReadingAllowFragments error:&jsonError];
                        // caution we're on an arbitrary queue
                        [[
                          NSOperationQueue
                          mainQueue
                          ]
                         addOperationWithBlock
                         :^{
                             NSLog(@"-- json: %@", jsonDict);
                             
                             NSMutableDictionary  *Fbdict=[[NSMutableDictionary alloc]init];
                             if(jsonDict[@"email"]==nil)
                             {
                                 [Fbdict setObject:@"" forKey:@"email"];
                             }
                             else{
                                 [Fbdict setObject:jsonDict[@"email"] forKey:@"email"];
                             }
                             //[Fbdict setObject:jsonDict[@"email"] forKey:@"email"];
                             [Fbdict setObject:jsonDict[@"first_name"] forKey:@"first_name"];
                             [Fbdict setObject:jsonDict[@"last_name"] forKey:@"last_name"];
                             [Fbdict setObject:jsonDict[@"id"] forKey:@"id"];
                             [Fbdict setObject:jsonDict[@"picture"][@"data"][@"url"] forKey:@"profileImage"];
                             [Fbdict setObject:jsonDict[@"gender"] forKey:@"gender"];
                             NSLog(@"fbdict user:%@",jsonDict);
                             [[NSNotificationCenter defaultCenter] postNotificationName:FbDataNotification object:nil userInfo:jsonDict];
                             //                             FaceDict=jsonDict;
                             //                             NSString *Email=FaceDict[@"email"];
                             //                             // NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
                             //                             [dict1 setObject:fbid forKey:@"uniqueId"];
                             //                             [dict1 setObject:SignUpFor forKey:@"loginType"];
                             //                             [AppHelper saveToUserDefaults:Email withKey:@"Email"];
                             //                             [AppHelper saveToUserDefaults:fbid withKey:@"uniqueId"];
                             //                             [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getresponseonhitForSignIn:) name:NotificationSignInInfo object:nil];
                             //                             [[ServiceClass sharedServiceClass] hitServiceForSighInByAF:dict1];
                             //
                             
                         }];
                        
                    }
                    else
                    {
                        //                        UIButton *button = (UIButton *)sender;
                        //                        button.userInteractionEnabled=YES;
                        //                        __weak         UIButton *button2=(UIButton *)[self.view viewWithTag:116];
                        //                        button2.userInteractionEnabled=YES;
                        
                        UIAlertView*    aAlert = [[UIAlertView alloc] initWithTitle:@"Pavi" message:@"Your Facebook account details can't be accessed right now. Please try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [aAlert show];
                        
                    }
                    
                }];
                
            }
        }
        else
        {
            NSLog(@"not granted");
            
            if ([FBSDKAccessToken currentAccessToken])
            {
                
                [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
                
                if ([FBSDKAccessToken  currentAccessToken])
                {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name,last_name,gender, picture.type(normal), email"}]
                     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                         if (!error) {
                             NSLog(@"fetched user:%@",result);
                             NSLog(@"%@",result[@"email"]);
                             NSMutableDictionary  *Fbdict=[[NSMutableDictionary alloc]init];
                             if(result[@"email"]==nil)
                             {
                                 [Fbdict setObject:@"" forKey:@"email"];
                             }
                             else{
                                 [Fbdict setObject:result[@"email"] forKey:@"email"];
                             }
                             // [Fbdict setObject:result[@"email"] forKey:@"email"];
                             [Fbdict setObject:result[@"first_name"] forKey:@"first_name"];
                             [Fbdict setObject:result[@"last_name"] forKey:@"last_name"];
                             [Fbdict setObject:result[@"gender"] forKey:@"gender"];
                             [Fbdict setObject:result[@"id"] forKey:@"id"];
                             [Fbdict setObject:result[@"picture"][@"data"][@"url"] forKey:@"profileImage"];
                             NSLog(@"fbdict user:%@",Fbdict);
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:FbDataNotification object:nil userInfo:Fbdict];
                             
                             
                         }
                     }];
                }
                
                //[self performSelectorOnMainThread:@selector(getUserDetail) withObject:nil waitUntilDone:YES];
            }
            else
            {
                FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
                
                [login logInWithReadPermissions:@[@"user_friends",@"email",@"public_profile",] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    if (error) {
                        // Process error
                    } else if (result.isCancelled) {
                        // Handle cancellations
                    } else {
                        // If you ask for multiple permissions at once, you
                        // should check if specific permissions missing
                        if ([result.grantedPermissions containsObject:@"email"]) {
                            // Do work
                            
                            
                            [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
                            
                            if ([FBSDKAccessToken  currentAccessToken])
                            {
                                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name,last_name,gender, picture.type(normal), email"}]
                                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                     if (!error) {
                                         NSLog(@"fetched user:%@",result);
                                         NSLog(@"%@",result[@"email"]);
                                         NSMutableDictionary  *Fbdict=[[NSMutableDictionary alloc]init];
                                         if(result[@"email"]==nil)
                                         {
                                             [Fbdict setObject:@"" forKey:@"email"];
                                         }
                                         else{
                                             [Fbdict setObject:result[@"email"] forKey:@"email"];
                                         }
                                         // [Fbdict setObject:result[@"email"] forKey:@"email"];
                                         [Fbdict setObject:result[@"first_name"] forKey:@"first_name"];
                                         [Fbdict setObject:result[@"last_name"] forKey:@"last_name"];
                                         [Fbdict setObject:result[@"id"] forKey:@"id"];
                                         [Fbdict setObject:result[@"gender"] forKey:@"gender"];
                                         [Fbdict setObject:result[@"picture"][@"data"][@"url"] forKey:@"profileImage"];
                                         NSLog(@"fbdict user:%@",Fbdict);
                                         [[NSNotificationCenter defaultCenter] postNotificationName:FbDataNotification object:nil userInfo:Fbdict];
                                     }
                                 }];
                            }
                            
                            //[self performSelectorOnMainThread:@selector(getUserDetail) withObject:nil waitUntilDone:YES];
                            
                        }
                    }
                }];
                
            }
            
            
            //[self performSelectorOnMainThread:@selector(FbLoginFromWeb) withObject:nil waitUntilDone:YES];
        }
    }];
    
    
    
    
}

@end
