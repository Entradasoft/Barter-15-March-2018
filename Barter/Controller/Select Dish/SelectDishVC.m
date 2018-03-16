//
//  SelectDishVC.m
//  Barter
//
//  Created by iOS on 10/12/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import "SelectDishVC.h"
#import "HOMECELL.h"
#import "AppDelegate.h"
#import "ServiceHIT.h"
#import "Define.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "CBAutoScrollLabel.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "LoginVC.h"
#import "DBManager.h"


@interface SelectDishVC ()<ServiceHitDrlegate,UISearchBarDelegate>{
    
    float cellTagValue;
    NSMutableArray*DataForSelectDish;
    NSMutableArray *tempData;
    IBOutlet UITableView*SelectDishTable;
    float latitude;
    float longitude;
    float Operatr;
    NSMutableArray *distance;
    NSMutableArray*INDEXCHECK; // more and less functionality
    NSMutableArray*votes;
    NSMutableArray *colors;
    NSMutableArray *tableDataFilter;
    IBOutlet UIView*popUpView;
    IBOutlet UIView*DataPopView;
    float lowerboundDistance;
    float higherboundDistance;
    int indexOfDistanceArray;
    BOOL isFiltered;
    UIAlertView *alert;
}
@property (nonatomic, strong) DBManager *dbManager;
@end


@implementation SelectDishVC
@synthesize logoutView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  Popup View when user clicks info button
    popUpView.hidden=YES;
    DataPopView.layer.cornerRadius=8;
    DataPopView.layer.masksToBounds=YES;
    // end of popup
    
    // logout view
    logoutView.hidden=YES;
    logoutView.layer.cornerRadius=8;
    logoutView.layer.masksToBounds=YES;
    
    //end of logout view

    // Navigation Bar------------
    self.navigationController.navigationBar.hidden = YES;
    
    // Navigation Bar
    // Do any additional setup after loading the view.
    Operatr = 1;
    DataForSelectDish=[NSMutableArray array];
    cellTagValue = [[[NSUserDefaults standardUserDefaults] valueForKey:@"selectedCellInDefaultPage"]floatValue];
    NSUserDefaults*prefs=[NSUserDefaults standardUserDefaults];
    latitude=[[prefs valueForKey:@"latitude"] floatValue];
    longitude=[[prefs valueForKey:@"longitude"] floatValue];
    
    colors = [[NSMutableArray alloc]initWithObjects:[UIColor redColor],[UIColor blackColor], [UIColor purpleColor],[UIColor brownColor],[UIColor darkGrayColor],[UIColor magentaColor],nil];
    // [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:cellTagValue];
    
    lowerboundDistance = 0.00f;
    higherboundDistance = 40.0f;
    
    [self fetchDistanceSelectDish];
    //longitude = 77.3894659
    //latitude = 28.6174944
    
    INDEXCHECK =  [[NSMutableArray alloc]init];
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = YES;
    
    
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Barter.sql"];
//    self.ScrollableOutletName = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 217 , 31)];
//    //some properties of scroll
//    self.ScrollableOutletName.userInteractionEnabled = YES;
//    self.ScrollableOutletName.showsHorizontalScrollIndicator = YES;
//    self.ScrollableOutletName.contentSize = CGSizeMake(217, 31);
}
-(void)getDataForSelectDish{
    NSDictionary *selectDishDict =@{
                                    @"longitude":[NSNumber numberWithDouble:77.3894659],
                                    @"latitude":[NSNumber numberWithDouble: 28.6174944],
//                                    @"longitude":longitude,
//                                    @"latitude":latitude,
                                    @"genreId":[NSNumber numberWithDouble: cellTagValue],
                                    @"lowerbound":[NSNumber numberWithDouble:lowerboundDistance],
                                    @"distance":[NSNumber numberWithDouble:higherboundDistance],
                                    @"operatr":[NSNumber numberWithDouble: Operatr]
                                    
                                    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ServiceHIT sharedInstance].delegate=self;
    [[ServiceHIT sharedInstance]POSTService:SelectDish Params:selectDishDict Occurance:@"1"];
}



-(void)ResponseData:(NSDictionary *)Response
{
    
    NSString*str=[Response valueForKey:@"SelectDishResult"];
    
    //NSError * err;
    if(Response != nil && [str length] != 0){
      //  NSString*str=[Response valueForKey:@"SelectDishResult"];
        
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        tempData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(tempData!=nil && tempData.count >= 1){
            
            NSMutableArray* dataArray = [[NSMutableArray alloc]init];
            for(int i = 0; i<tempData.count;i++){
                dataArray = [tempData objectAtIndex:i];
                [DataForSelectDish addObject:dataArray];
            }
            
            // If Response contains less than 3 elements than save the previous data and hit the service again with
            // updated parameter
            if(DataForSelectDish.count < 4){
                int distanceArrCount = (int)[distance count];
                
                for (int  j =0; j < [distance count]; j++) {
                    float x = [[distance objectAtIndex:j] floatValue];
                    if(higherboundDistance == x ){
                        indexOfDistanceArray = j;
                    }
                }
                
                if(indexOfDistanceArray + 1 <= distanceArrCount - 2 && Operatr >= 0){
                    [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
                    lowerboundDistance = higherboundDistance;
                    higherboundDistance = [[distance objectAtIndex:indexOfDistanceArray+1] floatValue];
                    [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
                    [self getDataForSelectDish];
                   // return;
                }
                
                else if(Operatr >= 0){
                    [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
                    lowerboundDistance = 0.0f;
                    higherboundDistance = [[distance objectAtIndex:0] floatValue];
                    Operatr -= 1;
                    [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
                    [self getDataForSelectDish];
                   // return;
                }
            }
        }
        
        [SelectDishTable scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
        [SelectDishTable reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
    }
    else {
        int distanceArrCount = (int)[distance count];
        for (int  j =0; j < [distance count]; j++) {
            float x = [[distance objectAtIndex:j] floatValue];
            if(higherboundDistance == x ){
                indexOfDistanceArray = j;
            }
        }

        if(indexOfDistanceArray + 1 <= distanceArrCount - 2 && Operatr >= 0){
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
            lowerboundDistance = higherboundDistance;
            higherboundDistance = [[distance objectAtIndex:indexOfDistanceArray+1] floatValue];
            [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
            [self getDataForSelectDish];
        }
        else if(Operatr >= 0){
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
            lowerboundDistance = 0.0f;
            higherboundDistance = [[distance objectAtIndex:0] floatValue];
            Operatr -= 1;
            [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
            [self getDataForSelectDish];
        }
        
        
    }
    [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
    
        int distanceArrCount = (int)[distance count];
        for (int  j =0; j < [distance count]; j++) {
            float x = [[distance objectAtIndex:j] floatValue];
            if(higherboundDistance == x){
                indexOfDistanceArray = j;
            }
        }
        
        if(indexOfDistanceArray + 1 <= distanceArrCount - 2 && Operatr >= 0){
            //[[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
            lowerboundDistance = higherboundDistance;
            higherboundDistance = [[distance objectAtIndex:indexOfDistanceArray + 1] floatValue];
            [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
            [self getDataForSelectDish];
        }
        else if(Operatr >= 0){
           // [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Gathering dishes...Please wait..."];
            lowerboundDistance = 0.00;
            higherboundDistance = [[distance objectAtIndex:0] floatValue];
            Operatr -= 1;
            [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
            [self getDataForSelectDish];
        }
        else{
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"No More Dishes..."];
        }
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DataForSelectDish.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"cell";
    
    HOMECELL *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[HOMECELL alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.selectionStyle = UITableViewStylePlain;
    // creating shadow in the bottom of the view
    cell.myView.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.myView.layer.shadowOffset = CGSizeMake(0, 5);
    cell.myView.layer.shadowOpacity = 1;
    cell.myView.layer.shadowRadius = 1.0;
    // end of creating shadow
    
    
    NSDictionary*finlDict=[DataForSelectDish objectAtIndex:indexPath.row];
    //NSArray*KEys=[finlDict allKeys];
    //    NSArray*Data=[dict valueForKey:[KEys objectAtIndex:0]];
    if (finlDict.count!=0) {
        
        NSString *rupee=@"\u20B9";
        
        
        // Formating String
        NSString *DateNTime =[finlDict objectForKey:@"g_datetime"];
        DateNTime = [DateNTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        NSString *reviewerName =[finlDict objectForKey:@"g_name"];
        reviewerName = [[reviewerName substringToIndex:1] capitalizedString];
        NSString *avgRating =[NSString stringWithFormat:@"%@",[finlDict objectForKey:@"rating"]];
        NSString *numberOfPeopleRated = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"total_votes"]];
        NSString *outletAvgRatingNCountLabel =[NSString stringWithFormat:@"%@(%@)", avgRating,numberOfPeopleRated];
        
        // short and long description
        
        NSString *wholeText = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"rmnu_aboutitem"]];
        
        NSArray *words = [wholeText componentsSeparatedByString:@" "];
        NSUInteger wordCount = [words count];
        wordCount-=1;
        NSMutableArray *firstFiveWords = [[NSMutableArray alloc]init];
        for(int i = 0 ; i<6 ; i++){
            [firstFiveWords addObject: [words objectAtIndex:i]];
        }
        NSString  *firstFiveResult = [[firstFiveWords valueForKey:@"description"] componentsJoinedByString:@" "];
        
        NSMutableArray *sixToLastWords =[[NSMutableArray alloc]init];
        for(int i =6; i<=wordCount; i++){
            [sixToLastWords addObject:[words objectAtIndex:i]];
        }
        NSString *sixToLastResult = [[sixToLastWords valueForKey:@"description"] componentsJoinedByString:@" "];
        
        
        // end of short and long description
        // end of Formating
        
        cell.outletNameLabel.text = [finlDict objectForKey:@"outletname"];
        cell.DishName.text = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"rmnu_std"]];
        cell.DishName.textColor = [UIColor darkTextColor];
        cell.DishName.font=[UIFont boldSystemFontOfSize:16];
        cell.DishName.backgroundColor = [UIColor clearColor];

        
        
        cell.outletAvgRatingNCountLabel.text = outletAvgRatingNCountLabel;
        NSString*outletReviewCountString =[[NSString alloc]init];
        
        outletReviewCountString = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"total_comments"]];
        cell.outletReviewCountLabel.text = outletReviewCountString;
        if([outletReviewCountString isEqualToString:@"0"]){
            cell.outletShowAll.text = @"Show All(0)";
            cell.outletShowAll.textColor = [UIColor grayColor];
        }else{
            cell.outletShowAll.text = [NSString stringWithFormat:@"Show All(%@)",outletReviewCountString];

        }
        
        
        cell.outletDishPriceLabel.text = [NSString stringWithFormat:@"%@%@",rupee,[finlDict objectForKey:@"rmnu_cost"]];
        cell.outletShortDescriptionLabel.text = firstFiveResult;
        cell.outletLongDescriptionLabel.text = sixToLastResult;
        cell.outletAvgRating.text = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"rating"]];
        cell.outletNumberOfPeopleRatedLabel.text = [NSString stringWithFormat:@"%@ Votes",[finlDict objectForKey:@"total_votes"]];
        cell.outletFiveStarRatingCountLabel.text = [NSString stringWithFormat:@"%@ Votes",[finlDict objectForKey:@"votes_5"]];
        cell.outletFourStarRatingCountLabel.text = [NSString stringWithFormat:@"%@ Votes",[finlDict objectForKey:@"votes_4"]];
        
        cell.outletThreeStarRatingCountLabel.text = [NSString stringWithFormat:@"%@ Votes",[finlDict objectForKey:@"votes_3"]];
        cell.outletTwoStarRatingCountLabel.text = [NSString stringWithFormat:@"%@ Votes",[finlDict objectForKey:@"votes_2"]];
        cell.outletOneStarRatingCountLabel.text = [NSString stringWithFormat:@"%@ Votes",[finlDict objectForKey:@"votes_1"]];
        
        // Details of the pop view
        
//        _outletAddress.text = [NSString stringWithFormat:@"%@,%@",[finlDict objectForKey:@"location"],[finlDict valueForKey:@"city"]];
//        _outletMobileNumber.text = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"mcontact"]];
//        _outletEmailId.text = [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"econtact"]];
//        _OutletNameScrollLabel.text = [finlDict objectForKey:@"outletname"];

        
//        // Scrollable outlet name
//        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 210, 31)];
//        myLabel.numberOfLines = 0;
//        myLabel.text = [finlDict objectForKey:@"outletname"];
//        myLabel.textAlignment = NSTextAlignmentLeft;
//        myLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:30];
//        [self.ScrollableOutletName addSubview:myLabel];
        
        // end of popview details
        
        if([[finlDict objectForKey:@"comment"] isKindOfClass:[NSNull class]]){
            cell.outletTopReviewDescriptionLabel.text =  [NSString stringWithFormat:@"%@",@"No comment yet."];
        }
        else{
        cell.outletTopReviewDescriptionLabel.text =  [NSString stringWithFormat:@"%@",[finlDict objectForKey:@"comment"]];
        }
        cell.outletReviewerName.text = [finlDict objectForKey:@"g_name"];
        
        // updated at 17 dec 2017 for cicular label for top reviewer first character
        cell.outletReviewerFirstCharacter.backgroundColor =[UIColor redColor];
        
        cell.outletReviewerFirstCharacter.clipsToBounds = YES;
        [cell.outletReviewerFirstCharacter setTitle:reviewerName forState:UIControlStateNormal];
        
        cell.outletReviewerFirstCharacter.layer.cornerRadius = 25;
        
        // end of circular label

        
        // showing Avg Rating of outlet
        cell.staticStarRatingView.canEdit = NO;
        cell.staticStarRatingView.maxRating = 5;
        float rating = [[finlDict objectForKey:@"rating"] floatValue];
        
        cell.staticStarRatingView.rating = rating;
        
        cell.topReviewerStarRatingView.canEdit = NO;
        cell.topReviewerStarRatingView.maxRating = 5;
  // checking whether guest rating is null or not **************************************
            if([[finlDict objectForKey:@"g_rating"] isKindOfClass:[NSNull class]]){
                
                float guestRating = 0;
                cell.topReviewerStarRatingView.rating = guestRating;

        }
            else{
                
                float guestRating = [[finlDict objectForKey:@"g_rating"] floatValue];
                cell.topReviewerStarRatingView.rating = guestRating;

        }
        // end of avg Rating
        
        
        // creating border of image
        [[cell.Dish_img layer] setBorderWidth:2.0f];
        [[cell.Dish_img layer] setBorderColor:RgbColor.CGColor];
        // changing icons color
        cell.starRateNReview.image = [cell.starRateNReview.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.starRateNReview setTintColor:GoldColor];

        
        cell.reviewImg.image = [cell.reviewImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.reviewImg setTintColor:RgbColor];
        
        cell.reviewBigIconImg.image = [cell.reviewBigIconImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.reviewBigIconImg setTintColor:RgbColor];
        
        
        // code for progress bar
        votes = [[NSMutableArray alloc]init];
        
        [votes addObject:[finlDict objectForKey:@"votes_1"]];
        [votes addObject:[finlDict objectForKey:@"votes_2"]];
        [votes addObject:[finlDict objectForKey:@"votes_3"]];
        [votes addObject:[finlDict objectForKey:@"votes_4"]];
        [votes addObject:[finlDict objectForKey:@"votes_5"]];
        
        float max = [[votes valueForKeyPath:@"@max.intValue"] floatValue];
        max++;
        float vote_one = [[votes objectAtIndex:0] floatValue] / max;
        float vote_two = [[votes objectAtIndex:1] floatValue] /  max;
        float vote_three = [[votes objectAtIndex:2] floatValue] / max;
        float vote_four = [[votes objectAtIndex:3] floatValue] / max;
        float vote_five = [[votes objectAtIndex:4] floatValue] / max;
        
        [cell.FirstProgressView setProgress:vote_five animated:YES];
        [cell.SecondProgressView setProgress:vote_four animated:YES];
        [cell.ThirdProgressView setProgress:vote_three animated:YES];
        [cell.FourthProgressView setProgress:vote_two animated:YES];
        [cell.FifthProgressView setProgress:vote_one animated:YES];
        
        // More And Less Functionality
        [cell.moreButton addTarget:self action:@selector(morebtn:event:) forControlEvents:UIControlEventTouchUpInside];
        //
        [cell.lessButton addTarget:self action:@selector(less:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.infobtn addTarget:self action:@selector(popUpvieww:event:) forControlEvents:UIControlEventTouchUpInside];
        
        // ---------end of more/less ------
        
        // Different color for different Reviewer
        
        int random = arc4random() % [colors count];
        cell.outletReviewerFirstCharacter.backgroundColor = [colors objectAtIndex:random];
        // end of Different color for different Reviewer
        
        if ([INDEXCHECK containsObject:indexPath]) {
            
            cell.outletLongDescriptionLabel.hidden = NO;
            cell.moreButton.hidden = YES;
        }
        else{
            cell.outletLongDescriptionLabel.hidden = YES;
            cell.moreButton.hidden = NO;
        }

    }
    return cell;
    
}
// capturing every touch and hiding popup view
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == popUpView)    {
        popUpView.hidden=YES;
        
    }

    logoutView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    logoutView.hidden = YES;
}


-(IBAction)popUpvieww:(UIButton*)sender event:(id)event

{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition;
    NSIndexPath *indexPath;
    currentTouchPosition = [touch locationInView:popUpView];
    indexPath = [SelectDishTable indexPathForRowAtPoint: currentTouchPosition];

    if (indexPath != nil)
    {
        
        NSDictionary *array = [[NSDictionary alloc]init];
        array = [DataForSelectDish objectAtIndex:indexPath.row];
        
        _outletAddress.text = [NSString stringWithFormat:@"%@,%@",[array objectForKey:@"location"],[array valueForKey:@"city"]];
        _outletMobileNumber.text = [NSString stringWithFormat:@"%@",[array objectForKey:@"mcontact"]];
        _outletEmailId.text = [NSString stringWithFormat:@"%@",[array objectForKey:@"econtact"]];
        _OutletNameScrollLabel.text = [array objectForKey:@"outletname"];
        
        [UIView animateWithDuration:9.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                            popUpView.hidden=NO;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
        
        float datapopupHeight=DataPopView.frame.size.height;
                float viewheight=self.view.frame.size.height;
        
        if (currentTouchPosition.y+datapopupHeight>viewheight) {
            
            DataPopView.frame=CGRectMake(currentTouchPosition.x - 233, currentTouchPosition.y-datapopupHeight, DataPopView.frame.size.width, DataPopView.frame.size.height);
            
        }
        else{
        DataPopView.frame=CGRectMake(currentTouchPosition.x - 233, currentTouchPosition.y, DataPopView.frame.size.width, DataPopView.frame.size.height);
        }
    }
}
-(IBAction)morebtn:(UIButton*)sender event:(id)event

{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition;
    NSIndexPath *indexPath;
    currentTouchPosition = [touch locationInView:SelectDishTable];
    indexPath = [SelectDishTable indexPathForRowAtPoint: currentTouchPosition];

    
    if (indexPath != nil)
        
    {
        HOMECELL*cell=[SelectDishTable cellForRowAtIndexPath:indexPath];
        cell.moreButton.hidden=YES;
        cell.outletLongDescriptionLabel.hidden = NO;
        cell.outletLongDescriptionLabel.frame = CGRectMake(4, 185, 316, 70);
        
        if([INDEXCHECK containsObject:indexPath]){

            
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
//            [SelectDishTable scrollToRowAtIndexPath:indexPath
//                                   atScrollPosition:UITableViewScrollPositionNone
//                                           animated:YES];
//            [UIView animateWithDuration:1.0
//                                  delay:0.0
//                                options: UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                 [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//                             }
//                             completion:^(BOOL finished){
//                                 NSLog(@"Done!");
//                             }];
            
            
           
            [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else{
            [INDEXCHECK addObject:indexPath];
   

           // [SelectDishTable reloadData];
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
//            [SelectDishTable scrollToRowAtIndexPath:indexPath
//                                   atScrollPosition:UITableViewScrollPositionNone
//                                           animated:YES];
//            [UIView animateWithDuration:1.0
//                                  delay:0.0
//                                options: UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                 [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//                             }
//                             completion:^(BOOL finished){
//                                 NSLog(@"Done!");
//                             }];
            
                  [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [super touchesBegan:touches withEvent:event];
            
        }

    }
}


-(IBAction)less:(UIButton*)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition;
    NSIndexPath *indexPath;
    currentTouchPosition = [touch locationInView:SelectDishTable];
    indexPath = [SelectDishTable indexPathForRowAtPoint: currentTouchPosition];
    currentTouchPosition = [touch locationInView: SelectDishTable];
    indexPath = [ SelectDishTable  indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
        
    {
        HOMECELL*cell=[SelectDishTable cellForRowAtIndexPath:indexPath];
        cell.moreButton.hidden=NO;
        cell.outletLongDescriptionLabel.hidden = YES;
        if([INDEXCHECK containsObject:indexPath]){
            [INDEXCHECK removeObject:indexPath];
            
            [SelectDishTable reloadData];

            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            
            [SelectDishTable scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:YES];
//            [UIView animateWithDuration:1.0
//                                  delay:0.0
//                                options: UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//                             }
//                             completion:^(BOOL finished){
//                                 NSLog(@"Done!");
//                             }];
            
            [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationTop];
            
        }
        else{

            
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            
            [SelectDishTable scrollToRowAtIndexPath:indexPath
                                   atScrollPosition:UITableViewScrollPositionBottom
                                           animated:YES];
            
//            [UIView animateWithDuration:1.0
//                                  delay:0.0
//                                options: UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                 [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//                             }
//                             completion:^(BOOL finished){
//                                 NSLog(@"Done!");
//                             }];
            
            [SelectDishTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationTop];
        }

        [super touchesBegan:touches withEvent:event];
        
    }
}

-(void)SecondTimeResponseData:(NSDictionary*)Response
{
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if ([INDEXCHECK containsObject:indexPath]) {
        
        return 720;
    }
    else{
        return  250;
    }
}



- (IBAction)outletMenu:(id)sender {
}

- (IBAction)showAlloutletReview:(id)sender {
}

- (IBAction)BackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)TripleDot:(id)sender{
    if (logoutView.isHidden == YES) {
        logoutView.hidden = NO;
    }
    else{
        logoutView.hidden = YES;
    }
}

-(void)fetchDistanceSelectDish{
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
                distance = [NSMutableArray array];
                for(int i=0; i<array.count; i++){
                    
                    NSDictionary *data1 = [array objectAtIndex:i];
                                        [distance addObject:[NSString stringWithFormat:@"%.2f",[[data1 valueForKey:@"select_dish_distance"] floatValue]]];
                }
                [self getDataForSelectDish];
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
        LoginVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

#pragma Search Delegate

- (IBAction)SearchBarButton:(UIButton *)sender {
    _searchBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.25 animations:^{
        _searchBar.frame = CGRectMake(1, 22, 410, 33);
        [self.view addSubview:_searchBar];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    _searchBar.hidden = YES;
    isFiltered = false;
   // [DataTAble reloadData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        isFiltered = false;
    }else{
        isFiltered = true;
        tableDataFilter = [[NSMutableArray alloc]init];
        // Handle as per requirement of search functionality.
    }
    
    [SelectDishTable reloadData];
}

@end



