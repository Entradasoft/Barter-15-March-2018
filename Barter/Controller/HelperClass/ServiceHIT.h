//
//  ServiceHIT.h
//  Cheeky Monkey
//
//  Created by Vikas Rajput on 12/10/17.
//  Copyright © 2017 Entrdasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ServiceHitDrlegate <NSObject>
-(void)ResponseData:(NSDictionary*)Response;
-(void)SecondTimeResponseData:(NSDictionary*)Response;

@end
@interface ServiceHIT : UIViewController
@property(nonatomic,weak)id <ServiceHitDrlegate>delegate;
+ (ServiceHIT *)sharedInstance;
-(void)POSTService:(NSString*)url Params:(NSDictionary*)param Occurance:(NSString*)HitingQuant;
-(void)GetService:(NSString*)url;
@end
