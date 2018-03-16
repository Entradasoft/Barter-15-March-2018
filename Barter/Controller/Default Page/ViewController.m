//
//  ViewController.m
//  Barter
//
//  Created by iOS on 22/11/17.
//  Copyright © 2017 Entradasoft. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "AppHelper.h"
#import "MBProgressHUD.h"
#import "Define.h"
#import "ServiceHIT.h"
#import "HOMECELL.h"
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>
#import "SelectDishVC.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LoginVC.h"
#import "DBManager.h" // for using sqlite

@interface ViewController ()<ServiceHitDrlegate,CLLocationManagerDelegate,UISearchBarDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    
    NSMutableArray*DataArr;
    IBOutlet UITableView*DataTAble;
    // Parameter for getDataForDefaultPage
    NSString *latitude;
    NSString *longitude;
    NSMutableArray*distanceArr;
    NSMutableArray*categoryArr;
    NSMutableArray*offset;
    NSMutableArray*operatr;
    NSMutableArray *lowerboundDistance;
    NSMutableArray *higherboundDistance;
    NSMutableArray *categoryArrayOriginal;
    NSMutableArray *tableDataFilter;
    // end Parameter
    int categoryIndex;
    NSMutableArray*FinalArray;
    BOOL isFiltered;
    
    IBOutlet UIView*defaultPopUpView;
    IBOutlet UIView*defaultDataPopView;
    IBOutlet UIView*LogoutView;
    UIRefreshControl *refreshControl;
    UIAlertView *alert;


    
}
// creating object of Dbmanger class to access all methods to do database operation
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) CLGeocoder *myGeocoder;
@end

@implementation ViewController

- (IBAction)plusButton:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaultPopUpView.hidden=YES;
    defaultDataPopView.layer.cornerRadius=8;
    defaultDataPopView.layer.masksToBounds=YES;
    
    LogoutView.hidden = YES;
    LogoutView.layer.cornerRadius = 8;
    LogoutView.layer.masksToBounds = YES;

    // drop shadow in view
    [LogoutView.layer setShadowColor:[UIColor blackColor].CGColor];
    [LogoutView.layer setShadowOpacity:0.9];
    [LogoutView.layer setShadowRadius:3.0];
    [LogoutView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    //self.title=@"Home";
    distanceArr = [[NSMutableArray alloc]init];
    
    DataArr=[[NSMutableArray alloc]init];
    FinalArray=[[NSMutableArray alloc]init];
    categoryArrayOriginal = [[NSMutableArray alloc] init];
    categoryIndex  = 4;
    
    offset = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInteger:0],[NSNumber numberWithInteger:0],[NSNumber numberWithInteger:0],[NSNumber numberWithInteger:0],[NSNumber numberWithInteger:0], nil];
    
    operatr = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1], nil];
    
    // initailizing lowerbound value
    lowerboundDistance = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:0.00],[NSNumber numberWithFloat:0.00],[NSNumber numberWithFloat:0.00],[NSNumber numberWithFloat:0.00],[NSNumber numberWithFloat:0.00], nil];
    
    // initailizing lowerbound value
    higherboundDistance = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:40.00],[NSNumber numberWithFloat:40.00],[NSNumber numberWithFloat:40.00],[NSNumber numberWithFloat:40.00],[NSNumber numberWithFloat:40.00], nil];
    
    
    // navigation Bar
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBar.hidden = YES;
    
    
    // end of navigation Bar
    
    
    //calling methods for location
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    // end
    
    // pull down to refresh
    refreshControl = [[UIRefreshControl alloc]init];
    [DataTAble addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    // end of pull down to refresh
    _SearchBar.delegate = self;
    _SearchBar.showsCancelButton = YES;
    
    
    // for using sqlite , we have write this line of code below
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Barter.sql"];
    
}
// This method is used for getting data from filter page and showing data as according
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;   //it hides navigation bar
    
    
    // *********** check the page and get the data *****************
    if([_pageCheck isEqualToString:@"Apply Filter"]){
        // getting every selected filter Subcategory from sqlite
        NSString *query = [NSString stringWithFormat:@"SELECT subCategoryID FROM FilterDetails where status = '1'"];
        NSArray *countOfEachCategory = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
        
        // getting data about relevance,rating and Trending
        NSUserDefaults *vk = [NSUserDefaults standardUserDefaults];
        NSString *radioButton = [vk valueForKey:@"radioButtonOnFilter"];// relevance or rating or trending if blank make it as relevance
        
        // getting data about city and locality
        NSString *selectedCity = [vk valueForKey:@"cityOnFilter"];
        NSString *selectedLocality = [vk valueForKey:@"localityOnFilter"];
        
        // here we have data, now as per services i have to send it as perameter.
        
        
        
        // end of services
    }

    
    
    
}
// getting full data for default page

-(void)getDataForDefaultPage{
    
    if([[AppDelegate getAppDelegate] checkInternateConnection] ){
        
        if(distanceArr.count == 0){
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Distance service gives blank data"];
        }
        else if(categoryArr.count == 0){
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"category service gives blank data"];
        }
        else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDictionary *dict =@{
                                  @"latitude": @"28.6174944", // Replace with latitude variable before testing
                                  @"longitude":@"77.3894659", // Replace with longitude variable before testing
//
//                                  @"latitude": latitude, // Replace with latitude variable before testing
//                                  @"longitude":longitude,
                                  @"lowerbound":[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%.2f", [[lowerboundDistance objectAtIndex:0]floatValue]],[NSString stringWithFormat:@"%.2f", [[lowerboundDistance objectAtIndex:1]floatValue]],[NSString stringWithFormat:@"%.2f", [[lowerboundDistance objectAtIndex:2]floatValue]],[NSString stringWithFormat:@"%.2f", [[lowerboundDistance objectAtIndex:3]floatValue]],[NSString stringWithFormat:@"%.2f", [[lowerboundDistance objectAtIndex:4]floatValue]], nil],
                                  @"distance":[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%.2f", [[higherboundDistance objectAtIndex:0]floatValue]],[NSString stringWithFormat:@"%.2f", [[higherboundDistance objectAtIndex:1]floatValue]],[NSString stringWithFormat:@"%.2f", [[higherboundDistance objectAtIndex:2]floatValue]], [NSString stringWithFormat:@"%.2f", [[higherboundDistance objectAtIndex:3]floatValue]],[NSString stringWithFormat:@"%.2f", [[higherboundDistance objectAtIndex:4]floatValue]],nil],
                                  
                                  @"offset":[[NSArray alloc]initWithObjects:[offset objectAtIndex:0],[offset objectAtIndex:1],[offset objectAtIndex:2],[offset objectAtIndex:3],[offset objectAtIndex:4], nil],
                                  
                                  
                                  @"operatr":[[NSArray alloc]initWithObjects:[operatr objectAtIndex:0],[operatr objectAtIndex:1],[operatr objectAtIndex:2],[operatr objectAtIndex:3],[operatr objectAtIndex:4], nil],
                                  
                                  @"category":[[NSArray alloc]initWithObjects:[categoryArr objectAtIndex:0],[categoryArr objectAtIndex:1],[categoryArr objectAtIndex:2],[categoryArr objectAtIndex:3],[categoryArr objectAtIndex:4], nil]
                                  };
            
            
            [ServiceHIT sharedInstance].delegate=self;
            [[ServiceHIT sharedInstance]POSTService:DefaultScreen Params:dict Occurance:@"2"];
        }
    }
    else{
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}

-(void)SecondTimeResponseData:(NSDictionary *)Response{
    if([[AppDelegate getAppDelegate] checkInternateConnection]){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString*str=[Response valueForKey:@"OrderRatingResult"];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        DataArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(DataArr.count != 0){
            
            [self makingDataInMultipleOfThree];
        }
    }
    else{
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}

-(void)makingDataInMultipleOfThree{
    NSMutableDictionary*dict1 = [[NSMutableDictionary alloc]init];
    NSMutableDictionary*dict2 = [[NSMutableDictionary alloc]init];
    
    for (int i =0 ; i < 5; i++) {
        @try{
            dict1 =  [DataArr objectAtIndex:3*i];
            int x = [[dict1 valueForKey:@"rmnu_cat"] intValue] ;
            
            for (int j =0 ; j < 3; j++) {
                @try{
                    dict2 =  [DataArr objectAtIndex:3*i+j];
                    int y = [[dict2 valueForKey:@"rmnu_cat"] intValue] ;
                    if(x != y){
                        
                        NSMutableArray *dictFirst = [[NSMutableArray alloc]init];// dictionary for first part and adding a blank dictionary
                        NSMutableDictionary *dictBlank = [[NSMutableDictionary alloc]init];// blank dictionary
                        dictBlank = @{
                                      @"rmnu_cat":[NSNumber numberWithInt:x],
                                      @"genreid":[NSNumber numberWithInt:-999]
                                      };
                        
                        [dictFirst addObjectsFromArray:[DataArr subarrayWithRange:NSMakeRange(0, (3*i+j))]];
                        [dictFirst addObject:dictBlank];
                        int dataArrCount = (int)[DataArr count];
                        for(int k =3*i+j ; k< dataArrCount; k++){
                            [dictFirst addObject:[DataArr objectAtIndex:k]];
                        }
                        DataArr = @[];
                        DataArr =  [NSMutableArray array];
                        [DataArr addObjectsFromArray:dictFirst];
                        
                    }
                    
                }
                @catch(NSException *e){
                    NSMutableArray *previousData = [[NSMutableArray alloc]initWithArray:DataArr];
                    NSMutableDictionary *dictBlank = [[NSMutableDictionary alloc]init];// blank dictionary
                    dictBlank = @{
                                  @"rmnu_cat":[NSNumber numberWithInt:x],
                                  @"genreid":[NSNumber numberWithInt:-999]
                                  };
                    
                    DataArr =  [NSMutableArray array];
                    
                    [DataArr addObjectsFromArray:previousData];
                    [DataArr addObject:dictBlank];


                }
            }
        }
        @catch(NSException *e){
           
        }
        
    }
    [self checkCategory];
}



-(void)checkCategory{
    NSUInteger count = [DataArr count] / 3;
    int dataArrCount = (int)[DataArr count];
    NSUInteger distanceArrCount = [distanceArr count] - 1;
    int index = 0 ;
    int checker = 0 ;
    // end of adding blank data
    
    if(dataArrCount <= 12){
        NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
        
        for (int i = 0; i < count; i++) {
            dict =  [DataArr objectAtIndex:3*i];
            int x = [[categoryArr objectAtIndex:(i)]intValue];
            int y = [[dict valueForKey:@"rmnu_cat"] intValue] ;
            // if category doesn't match within loop
            if(x != y){
                double higherBoundCurrentValue = [[higherboundDistance objectAtIndex:i] doubleValue];
                // getting index of higherboundcurrent value in distance array to increase distance
                for (int j =0; j < [distanceArr count]; j++) {
                    double distanceObject = [[distanceArr objectAtIndex:j] doubleValue];
                    if (distanceObject == higherBoundCurrentValue) {
                        index = j;
                    }
                }
                int operatorCurrentValue = [[operatr objectAtIndex:i] intValue];
                // distance within max limit and opeartr = 1
                if(index <=  distanceArrCount && (index+1) <= distanceArrCount && operatorCurrentValue >= 0){
                    index++;
                    [lowerboundDistance replaceObjectAtIndex:i withObject:[higherboundDistance objectAtIndex:i]];
                    [higherboundDistance replaceObjectAtIndex:i withObject:[distanceArr objectAtIndex:index]];
                    [offset replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                    checker = 1;
                    [self getDataForDefaultPage];
                    break;
                }
                // if distance reaches at max limit
                else{
                    
                    if(operatorCurrentValue == 1 ){
                        operatorCurrentValue-=1;
                        [lowerboundDistance replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.00]];
                        [higherboundDistance replaceObjectAtIndex:i withObject:[distanceArr objectAtIndex:0]];
                        [offset replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                        [operatr replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:operatorCurrentValue]];
                        checker = 1;
                        [self getDataForDefaultPage];
                        break;

                    }
                    // changing Category and reseting parameter
                    else if(operatorCurrentValue == 0){
                        NSUInteger categoryArrayCount = [categoryArr count];
                        if(categoryIndex <= categoryArrayCount - 2){
                            categoryIndex++;
                            int cat = [[categoryArr objectAtIndex:categoryIndex] intValue];
                            [categoryArr replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:cat]];
                            [lowerboundDistance replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.00]];
                            [higherboundDistance replaceObjectAtIndex:i withObject:[distanceArr objectAtIndex:0]];
                            [offset replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                            [operatr replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:1]];
                            checker = 1;
                            [self getDataForDefaultPage];
                            break;
                        }
                        else{
                            
                            // **************************** Exhaust all category ************************
                            // in this case, i am just reseting the parameter for the missing category to initial like below
//
//                     [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"No more Data."];
                            
                           // [categoryArr replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:y]];
                            [lowerboundDistance replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.00]];
                            [higherboundDistance replaceObjectAtIndex:i withObject:[distanceArr objectAtIndex:0]];
                            [offset replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                            [operatr replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:1]];
                            checker = 1;
                            [self getDataForDefaultPage];
                            break;
       
                        }
                    }
                }
                // End of Checking Category of product with category Array
            }
        }
        if(checker == 0){
            [self missingCategory]; // if all data matched then forward contact to get missig data data y calling missing category method.
        }
}

else{
    [self FilterData];
}

}


-(void)missingCategory{
    
    int index = 0 ;
    int say=0; // here say=1 means category available
    int dataArrCountAfterChange = (int)[DataArr count];
     NSUInteger distanceArrCount = [distanceArr count] - 1;
    // loop for missing elements
    for (int k=dataArrCountAfterChange / 3; k < 5; k++) {
        if (say == 0) {
            double higherBoundCurrentValue = [[higherboundDistance objectAtIndex:k] doubleValue];
            // getting index of higherboundcurrent value in distance array to increase distance
            for (int j =0; j < [distanceArr count]; j++) {
                double distanceObject = [[distanceArr objectAtIndex:j] doubleValue];
                if (distanceObject == higherBoundCurrentValue) {
                    index = j;
                }
            }
            int operatorCurrentValue = [[operatr objectAtIndex:k] intValue];
            // distance within max limit and opeartr = 1
            if((index+1) <= distanceArrCount && operatorCurrentValue >= 0){
                index++;
                [lowerboundDistance replaceObjectAtIndex:k withObject:[higherboundDistance objectAtIndex:k]];
                [higherboundDistance replaceObjectAtIndex:k withObject:[distanceArr objectAtIndex:index]];
                [offset replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:0]];
                [self getDataForDefaultPage];
                 break;
            }
            // if distance reaches at max limit
            else{
                int operatorCurrentValue = [[operatr objectAtIndex:k] intValue];
                
                if(operatorCurrentValue == 1 ){
                    operatorCurrentValue-=1;
                    [lowerboundDistance replaceObjectAtIndex:k withObject:[NSNumber numberWithFloat:0.00]];
                    [higherboundDistance replaceObjectAtIndex:k withObject:[distanceArr objectAtIndex:0]];
                    [offset replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:0]];
                    [operatr replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:operatorCurrentValue]];
                    
                    [self getDataForDefaultPage];
                    break;
                }
                // changing Category and reseting parameter
                else if(operatorCurrentValue == 0){
                    NSUInteger categoryArrayCount = [categoryArr count];
                    if(categoryIndex <= categoryArrayCount - 2){
                        [lowerboundDistance replaceObjectAtIndex:k withObject:[NSNumber numberWithFloat:0.00]];
                        [higherboundDistance replaceObjectAtIndex:k withObject:[distanceArr objectAtIndex:0]];
                        [offset replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:0]];
                        [operatr replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:1]];
                        categoryIndex+=1;
                        int cat = [[categoryArr objectAtIndex:categoryIndex] intValue];
                        [categoryArr replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:cat]];
                        [self getDataForDefaultPage];
                        break;
                    }
                }
                else{
                    // **************************** Exhaust all category ************************
                    // in this case, i am just reseting the parameter for the missing category to initial like below
                    
                    
//                    [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"No more Data."];
//                    break;

                    [lowerboundDistance replaceObjectAtIndex:k withObject:[NSNumber numberWithFloat:0.00]];
                    [higherboundDistance replaceObjectAtIndex:k withObject:[distanceArr objectAtIndex:0]];
                    [offset replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:0]];
                    [operatr replaceObjectAtIndex:k withObject:[NSNumber numberWithInt:1]];
                  
                    [self getDataForDefaultPage];
                    break;
                    
                }
            }
        }
    }
//    if (say == 1) {
//        [self FilterData];
//    }
}

-(void)FilterData{
    
    if([[AppDelegate getAppDelegate] checkInternateConnection] ){
        
        int checkGenreId;
        if(DataArr.count != 0){
            NSUInteger count = [DataArr count] / 3;
            
            
            for(int i =0; i<count;i++){
                NSMutableArray*data = [[NSMutableArray alloc]init];
                NSMutableDictionary*dict = [[NSMutableDictionary alloc]init];
                
                int prevGenreId = 0;
                dict =  [DataArr objectAtIndex:3*i];
                [data addObject:dict];
                
                
                // increasing offset of each category by 1
                int value = [[offset objectAtIndex:i]intValue];
                value+=1;
                prevGenreId = [[dict valueForKey:@"genreid"]intValue];
                
                
                // comapring items genre id
                for(int j=1; j<3;j++){
                    dict = [DataArr objectAtIndex:3*i+j];
                    checkGenreId = [[dict valueForKey:@"genreid"]intValue];
                    
                    if(prevGenreId==checkGenreId){
                        value+=1;
                        [data addObject:dict];
                    }
                    else{
                        
                        break;
                    }
                    
                }
                [offset replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d",value]];
                [FinalArray addObject:data];
            }
            [DataTAble scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES]; // changed on 19 feb 2018
            [DataTAble reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }
    
    else{
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}

//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.0f;
//}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LogoutView.hidden = YES;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
//    if (section == 0){
//        footer.backgroundColor=[UIColor clearColor];
//        UIButton*AddMoreBTn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,140,34)];
//        AddMoreBTn.backgroundColor = [UIColor orangeColor];
//        [AddMoreBTn setTitle:@"Show More" forState:UIControlStateNormal];
//        [AddMoreBTn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        AddMoreBTn.titleLabel.textAlignment=NSTextAlignmentCenter;
//        AddMoreBTn.titleLabel.font = [UIFont systemFontOfSize:12];
//        AddMoreBTn.center=footer.center;
//        AddMoreBTn.layer.cornerRadius = 17;
//        AddMoreBTn.clipsToBounds = YES;
//        [AddMoreBTn addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
//
//        [footer addSubview:AddMoreBTn];
//
//
//    }
//    return footer;
//}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return FinalArray.count;
    return FinalArray.count;
}


// code for showing data on table 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return  255;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cell";
    
    HOMECELL *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[HOMECELL alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    // creating shadow in the bottom of the view
    
    cell.defaultView.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.defaultView.layer.shadowOffset = CGSizeMake(0,5);
    cell.defaultView.layer.shadowOpacity = 1;
    cell.defaultView.layer.shadowRadius = 1.0;
    
    // end of creating shadow
    
    cell.selectionStyle = UITableViewStylePlain;
    if (FinalArray.count!=0) {
        
        NSString *rupee=@"\u20B9";
        NSArray*finlDict=[FinalArray objectAtIndex:indexPath.row];
        NSDictionary*dict1=[finlDict objectAtIndex:0];
        NSString*name=[dict1 valueForKey:@"rmnu_std"];
        
        NSString*genreID = [dict1 valueForKey:@"genreid"];
        // setting Tag value on the button
        cell.tag = genreID.integerValue;
        
        NSUInteger arrayLength = [finlDict count];
        // Marque effect try
        
        // end of Marque effect
        
        // showing 3 outlet for a item
        if(arrayLength== 3){
            
            NSDictionary*dict2 = [finlDict objectAtIndex:1];
            NSDictionary*dict3 = [finlDict objectAtIndex:2];
            

            cell.FirstOutlet.text = [NSString stringWithFormat:@"%@%@",[dict1 valueForKey:@"outletname"],@"                  "];
            cell.FirstOutlet.textColor = [UIColor darkTextColor];
            cell.FirstOutlet.font = [UIFont boldSystemFontOfSize:16.0];
            cell.FirstOutlet.backgroundColor = [UIColor clearColor];
            

            cell.DishPriceFirstOutlet.text = [NSString stringWithFormat:@"%@%@",rupee,[dict1 valueForKey:@"rmnu_cost"]];
            // if rating value contains null
            if ([[dict1 valueForKey:@"avgrating"] isKindOfClass:[NSNull class]]) {
                cell.DishRatingFirstOulet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
            cell.DishRatingFirstOulet.text = [NSString stringWithFormat:@"%@",[dict1 valueForKey:@"avgrating"]];
            }
            
            // if review value contains null
            if ([[dict1 valueForKey:@"total_comments"] isKindOfClass:[NSNull class]]) {
                cell.DishReviewFirstOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishReviewFirstOutlet.text = [NSString stringWithFormat:@"%@",[dict1 valueForKey:@"total_comments"]];
            }

            
            
            cell.SecondOutlet.text= [NSString stringWithFormat:@"%@",[dict2 valueForKey:@"outletname"]];
            cell.DishPriceSecondOutlet.text = [NSString stringWithFormat:@"%@%@",rupee,[dict2 valueForKey:@"rmnu_cost"]];
            // if rating value contains null
            if ([[dict2 valueForKey:@"avgrating"] isKindOfClass:[NSNull class]]) {
                cell.DishRatingSecondOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishRatingSecondOutlet.text = [NSString stringWithFormat:@"%@",[dict2 valueForKey:@"avgrating"]];
            }
            // if review value contains null
            if ([[dict2 valueForKey:@"total_comments"] isKindOfClass:[NSNull class]]) {
                cell.DishReviewSecondOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishReviewSecondOutlet.text = [NSString stringWithFormat:@"%@",[dict2 valueForKey:@"total_comments"]];
            }
            
            
            
            cell.ThirdOutlet.text = [NSString stringWithFormat:@"%@",[dict3 valueForKey:@"outletname"]];
            cell.DishPriceThirdOutlet.text = [NSString stringWithFormat:@"%@%@",rupee,[dict3 valueForKey:@"rmnu_cost"]];
            // if rating value contains null
            if ([[dict3 valueForKey:@"avgrating"] isKindOfClass:[NSNull class]]) {
                cell.DishRatingThirdOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishRatingThirdOutlet.text = [NSString stringWithFormat:@"%@",[dict3 valueForKey:@"avgrating"]];
            }
            // if review value contains null
            if ([[dict3 valueForKey:@"total_comments"] isKindOfClass:[NSNull class]]) {
                cell.DishReviewThirdOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
               cell.DishReviewThirdOutlet.text = [NSString stringWithFormat:@"%@",[dict3 valueForKey:@"total_comments"]];
            }

            
            
            cell.secondView.hidden = NO;
            cell.thirdView.hidden = NO;
            
        }
        
        // showing 2 outlet for a item
        else if(arrayLength == 2){
            NSDictionary*dict2 = [finlDict objectAtIndex:1];
            
            // Marque type effect
            cell.FirstOutlet.text = [dict1 valueForKey:@"outletname"] ;
            cell.FirstOutlet.textColor = [UIColor blackColor];
            cell.FirstOutlet.backgroundColor = [UIColor clearColor];
            // end of Marque type effect
            
            cell.DishPriceFirstOutlet.text = [NSString stringWithFormat:@"%@%@",rupee,[dict1 valueForKey:@"rmnu_cost"]];
            
            // if rating value contains null
            if ([[dict1 valueForKey:@"avgrating"] isKindOfClass:[NSNull class]]) {
                cell.DishRatingFirstOulet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishRatingFirstOulet.text = [NSString stringWithFormat:@"%@",[dict1 valueForKey:@"avgrating"]];
            }
            // if review value contains null
            if ([[dict1 valueForKey:@"total_comments"] isKindOfClass:[NSNull class]]) {
                cell.DishReviewFirstOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
               cell.DishReviewFirstOutlet.text = [NSString stringWithFormat:@"%@",[dict1 valueForKey:@"total_comments"]];
            }

            
            
            
            
            cell.SecondOutlet.text= [NSString stringWithFormat:@"%@",[dict2 valueForKey:@"outletname"]];
            cell.DishPriceSecondOutlet.text = [NSString stringWithFormat:@"%@%@",rupee,[dict2 valueForKey:@"rmnu_cost"]];
            // if rating value contains null
            if ([[dict2 valueForKey:@"avgrating"] isKindOfClass:[NSNull class]]) {
                cell.DishRatingSecondOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishRatingSecondOutlet.text = [NSString stringWithFormat:@"%@",[dict2 valueForKey:@"avgrating"]];
            }
            // if review value contains null
            if ([[dict2 valueForKey:@"total_comments"] isKindOfClass:[NSNull class]]) {
                cell.DishReviewSecondOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishReviewSecondOutlet.text = [NSString stringWithFormat:@"%@",[dict2 valueForKey:@"total_comments"]];

            }

            
            
            // Hiding data on cell
            cell.secondView.hidden = NO;
            cell.thirdView.hidden = YES;
            
        }
        // showing 1 outlet for a item
        else{
            // Marque type effect
            cell.FirstOutlet.text = [dict1 valueForKey:@"outletname"] ;
            cell.FirstOutlet.textColor = [UIColor blackColor];
            cell.FirstOutlet.backgroundColor = [UIColor clearColor];
            
            // end of Marque type effect
            
            cell.DishPriceFirstOutlet.text = [NSString stringWithFormat:@"%@%@",rupee,[dict1 valueForKey:@"rmnu_cost"]];
            // if rating value contains null
            if ([[dict1 valueForKey:@"avgrating"] isKindOfClass:[NSNull class]]) {
                cell.DishRatingFirstOulet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishRatingFirstOulet.text = [NSString stringWithFormat:@"%@",[dict1 valueForKey:@"avgrating"]];
            }
            // if review value contains null
            if ([[dict1 valueForKey:@"total_comments"] isKindOfClass:[NSNull class]]) {
                cell.DishReviewFirstOutlet.text = [NSString stringWithFormat:@"%d",0];
            }
            else{
                cell.DishReviewFirstOutlet.text = [NSString stringWithFormat:@"%@",[dict1 valueForKey:@"total_comments"]];
            }

            
            
            // Hiding 2nd and 3rd outlet Details
            
            cell.secondView.hidden = YES;
            cell.thirdView.hidden = YES;
            
        }
        
        
        
        //
        //        int imgno=[[finlDict valueForKey:@"itemid"]intValue];
        
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        //        dispatch_async(queue, ^{
        //            NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.2.121/pg_rating/image/%d.jpg",imgno]]];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                UIImage *image = [UIImage imageWithData:imageData];
        //                cell.Profile_img.image=image;
        //            });
        //        });
        
        
        
        
        cell.NameDish.text=name;
        [cell.Profile_img_Button setBackgroundImage:[UIImage imageNamed:@"boy-image-2.png"] forState:UIControlStateNormal];
        [[cell.Profile_img_Button layer] setBorderWidth:2.0f];
        [[cell.Profile_img_Button layer] setBorderColor:RgbColor.CGColor];
        // star icon color change
        cell.firstStar.image = [cell.firstStar.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.firstStar setTintColor:GoldColor];
        
        cell.secondStar.image = [cell.secondStar.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.secondStar setTintColor:GoldColor];

        cell.thirdStar.image = [cell.thirdStar.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.thirdStar setTintColor:GoldColor];
        
        // review icon color change
        cell.firstReview.image = [cell.firstReview.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.firstReview setTintColor:RgbColor];
        
        cell.secondReview.image = [cell.secondReview.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.secondReview setTintColor:RgbColor];
        
        cell.thirdReview.image = [cell.thirdReview.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.thirdReview setTintColor:RgbColor];
        
        
        // ---------------- Load More
        
        // end of Load More
        
        [cell.Profile_img_Button addTarget:self action:@selector(selectDish:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.firstOutletPlusBtn addTarget:self action:@selector(popUpvieww:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.secondOutletPlusBtn addTarget:self action:@selector(popUpvieww:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.thirdOutletPlusBtn addTarget:self action:@selector(popUpvieww:event:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return cell;
}

-(IBAction)selectDish:(UIButton*)sender event:(id)event

{
    NSSet *touches = [event allTouches];
    
    UITouch *touch = [touches anyObject];
    
    LogoutView.hidden=YES;
    
    CGPoint currentTouchPosition;
    NSIndexPath *indexPath;
    currentTouchPosition = [touch locationInView:DataTAble];
    indexPath = [DataTAble indexPathForRowAtPoint: currentTouchPosition];
    
    currentTouchPosition = [touch locationInView: DataTAble];
    
    indexPath = [ DataTAble  indexPathForRowAtPoint: currentTouchPosition];
    
    SelectDishVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectDishVC"];
    
    
    if (indexPath != nil)
        
    {
        
        [super touchesBegan:touches withEvent:event];
        NSArray*finlDict=[FinalArray objectAtIndex:indexPath.row];
        NSDictionary*dict1=[finlDict objectAtIndex:0];
        NSString*genreID = [dict1 valueForKey:@"genreid"];
        [[NSUserDefaults standardUserDefaults] setInteger:genreID.integerValue forKey:@"selectedCellInDefaultPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


/*
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 HOMECELL *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
 NSInteger tag = selectedCell.tag;
 [[NSUserDefaults standardUserDefaults] setInteger:tag forKey:@"selectedCellInDefaultPage"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 
 SelectDishVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectDishVC"];
 [self.navigationController pushViewController:vc animated:YES];
 }
 */

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
            // calling methods after correctly getting location of latitude and longitude
            
            [self fetchDistanceDefault];
            
        }
        else {
            
            NSLog(@"%@", error.debugDescription);

        }
        
    } ];
    
    [ locationManager stopUpdatingLocation];
    
}


-(void)fetchCategoryDefault{
    if([[AppDelegate getAppDelegate] checkInternateConnection]){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *dict =[[NSDictionary alloc]init];
        [ServiceHIT sharedInstance].delegate=self;
        [[ServiceHIT sharedInstance]POSTService:fetchCategory Params:dict Occurance:@"1"];
    }
    else{
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}
-(void)ResponseData:(NSDictionary *)Response
{
    [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
    //NSError * err;
    NSString*str=[Response valueForKey:@"FetchCategoryResult"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (data!=nil) {
        NSMutableArray *categoryData = [[NSMutableArray alloc]init];
        
        categoryData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        categoryData = [categoryData valueForKey:@"cat_code"];
        categoryArr = [[NSMutableArray alloc]initWithCapacity:[categoryData count]];
        for(int i=0; i < [categoryData count]; i++){
            [categoryArr addObject:[categoryData objectAtIndex:i]];
        }
        [categoryArrayOriginal addObjectsFromArray:categoryArr];
        [self getDataForDefaultPage];
    }
    
}



-(void)fetchDistanceDefault{
    if ([[AppDelegate getAppDelegate] checkInternateConnection])
    {
        
        
        NSDictionary *dict =@{
                              @"abc":@"",
                              };
        
        // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        
        [manager POST:[NSString stringWithFormat:@"%@%@",MainUrll,fetchDistance] parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSError *error = nil;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (JSON==nil) {
                [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Server Error" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            }
            else{
                // [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Password has been sent" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                NSString *str = [JSON valueForKey:@"FetchDistanceResult"];
                NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                NSArray*array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(int i=0; i<array.count; i++){
                    
                    NSDictionary *data = [array objectAtIndex:i];
                    
                    [distanceArr addObject:[NSString stringWithFormat:@"%.2f",[[data valueForKey:@"default_distance"]floatValue]]];
                }
                
                [self fetchCategoryDefault];
                
            }
            
            NSLog(@"%@",JSON);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
        
    }
    else
    {
        
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    
}

// Load More when last cell comes
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        [self loadMore];
    }
}


-(void)loadMore{
    if([[AppDelegate getAppDelegate] checkInternateConnection]){
        
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
        
        [self getDataForDefaultPage];
    }
    else
    {
        
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}

// capturing every touch and hiding popup view
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == defaultPopUpView)    {
        defaultPopUpView.hidden=YES;
        LogoutView.hidden = YES;
    }
    LogoutView.hidden = YES;
}



-(IBAction)popUpvieww:(UIButton*)sender event:(id)event

{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition;
    NSIndexPath *indexPath;
    currentTouchPosition = [touch locationInView:defaultPopUpView];
    indexPath = [DataTAble indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        defaultPopUpView.hidden=NO;

        float datapopupHeight=defaultDataPopView.frame.size.height;
        float viewheight=self.view.frame.size.height;
        float datapopupWidth=171;
        if (currentTouchPosition.y+datapopupHeight > viewheight) {
            
            defaultDataPopView.frame=CGRectMake(currentTouchPosition.x-datapopupWidth, currentTouchPosition.y - datapopupHeight, datapopupWidth, datapopupHeight);
            
        }
        else{
            defaultDataPopView.frame=CGRectMake(currentTouchPosition.x-datapopupWidth, currentTouchPosition.y, datapopupWidth, datapopupHeight);
        }
    }
}


- (void)refreshTable {
    //TODO: refresh your data
        for(int i =0; i<5; i++){
        [lowerboundDistance replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.00]];
        [higherboundDistance replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:40.00]];
        [offset replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
        [operatr replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:1]];
        [categoryArr replaceObjectAtIndex:i withObject:[categoryArrayOriginal objectAtIndex:i]];
    }
    [FinalArray removeAllObjects];
    DataArr=[NSMutableArray array];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [refreshControl endRefreshing];
    categoryIndex = 4 ;
    [self getDataForDefaultPage];
    

    //    [SelectDishTable reloadData];
}



-(IBAction)tripleDot:(id)sender{
    
    if(LogoutView.isHidden==YES){
       LogoutView.hidden=NO;
    }
    else{
        LogoutView.hidden=YES;
    }
    
}

-(IBAction)LogoutBtn:(id)sender{
    // clear all the data saved in Sqlite and NSUserDefault
    
    alert=[[UIAlertView alloc]initWithTitle:@"Logout" message:@"Are You Sure to Logout ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0)//OK button pressed
    {
        //do something
    }
    else if(buttonIndex == 1)    //Annul button pressed.
    {
        NSString *blankString = @"";
        [[NSUserDefaults standardUserDefaults] setObject:blankString forKey:@"radioButtonOnFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:blankString forKey:@"cityOnFilter"];
        [[NSUserDefaults standardUserDefaults] setObject:blankString forKey:@"localityOnFilter"]; 

        
        NSString *query = [NSString stringWithFormat:@"UPDATE FilterDetails SET status = '0'"];
        // Execute the query.
        [self.dbManager executeQuery:query];
        //[AppHelper saveToUserDefaults:@"" withKey:@"login"];

        LoginVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
        }
    
}

#pragma Search Delegate

- (IBAction)SearchButton:(id)sender {
    
    _SearchBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.25 animations:^{
        _SearchBar.frame = CGRectMake(0, 22, 410, 33);
        [self.view addSubview:_SearchBar];
    }];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    _SearchBar.hidden = YES;
    isFiltered = false;
    [DataTAble reloadData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        isFiltered = false;
    }else{
        isFiltered = true;
        tableDataFilter = [[NSMutableArray alloc]init];
        
           // Handle as per requirement of search functionality.
    }
    
    [DataTAble reloadData];
}
                           
@end
