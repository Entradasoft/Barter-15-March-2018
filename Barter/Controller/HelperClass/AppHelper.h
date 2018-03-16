//
//  AppHelper.h
//  Monaqsat
//
//  Created by rentaluser on 4/23/15.
//  Copyright (c) 2015 FourthScreenLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@interface AppHelper : NSObject


+(void)saveToUserDefaults:(id)value withKey:(NSString*)key;
+(NSString*)userDefaultsForKey:(NSString*)key;
+(void)removeFromUserDefaultsWithKey:(NSString*)key;
+(NSString*)CheckStatus:(NSString*)status;
+(void)getfb:(ACAccountStore *)accountStore;
@end
