//
//  LoginVC.h
//  Barter
//
//  Created by iOS on 09/12/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

@interface LoginVC : UIViewController
// creating object of Dbmanger class to access all methods to do database operation
@property (nonatomic, strong) DBManager *dbManager;
@end
