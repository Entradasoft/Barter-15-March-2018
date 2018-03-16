//
//  DBManager.h
//  Barter
//
//  Created by iOS on 21/02/18.
//  Copyright © 2018 Nikhil Capsitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(NSArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;

@end
