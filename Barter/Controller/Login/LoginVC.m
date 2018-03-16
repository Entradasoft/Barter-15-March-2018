//
//  LoginVC.m
//  Barter
//
//  Created by iOS on 09/12/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import "LoginVC.h"
#import "ServiceHIT.h"
#import "AppHelper.h"
#import "AppDelegate.h"
#import "CSNotificationView.h"
#import "MBProgressHUD.h"
#import "ViewController.h"
#import "Define.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <Google/SignIn.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "DBManager.h"

@interface LoginVC ()<ServiceHitDrlegate>{
    
    IBOutlet UIButton*SignInBtn;
    IBOutlet UITextField*EmailTxt;
    IBOutlet UITextField*PwdTxt;
    
    IBOutlet UIButton *rememberMeButton;
    NSString*emailStr;
    NSString*nameStr;
    BOOL rememberState;
    
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = TRUE;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Barter.sql"];
    
    
    rememberState=YES;
    
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    UIImage *imageSelected = [[UIImage imageNamed:@"checked-button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    UIImage *imageNotSelected = [[UIImage imageNamed:@"check-box-empty.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //
    // //   [rememberMeButton setImage:imageSelected forState:UIControlStateNormal];
    // //   [rememberMeButton setImage:imageNotSelected forState:UIControlStateSelected];
    rememberMeButton.tintColor = RgbColor;
    rememberMeButton.selected=YES;
    
    
    //    ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    //    [self.navigationController pushViewController:vc animated:YES];
    // end of Date Picker
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];   //it hides
    
}



- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // it shows
    
}

- (IBAction)rememberMe:(id)sender {
    if(rememberMeButton.selected==YES){
        rememberMeButton.selected=NO;
        rememberState = NO;
    }
    else{
        rememberMeButton.selected=YES;
        rememberState = YES;
    }
}
- (IBAction)forgotPassword:(id)sender {
    
    
    // Hitting Service
    if ([[AppDelegate getAppDelegate] checkInternateConnection])
    {
        BOOL emailCheck =[self validEmail:EmailTxt.text];
        
        if (EmailTxt.text.length==0)
        {
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Email Address"];
        }
        else if (emailCheck==NO)
        {
            [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Correct Email Address"];
        }
        else
        {
            NSString*urlString=[NSString stringWithFormat:@"%@%@",MainUrll,Login];
            NSDictionary *forgotPasswordDict =@{
                                                // parameter depends upon the service
                                                @"OutletID": @"",
                                                @"email": EmailTxt.text,
                                                @"pass":@"",
                                                @"deviceid": @""
                                                };
            
            
            // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
            [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
            
            [manager POST:urlString parameters:forgotPasswordDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
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
                    NSDictionary *data = [JSON objectForKey:@"ECABS_GuestSignInResult"];
                    NSDictionary *dict = [data objectForKey:@"GstSearch"];
                    NSString *error = [dict objectForKey:@"Error"];
                    if([error isEqualToString:@"invalid_email"]){
                        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Email Id not registered with us"];
                    }
                    else{
                        [self sendMailForFrgotPassword:error andEmail:EmailTxt.text];
                    }
                    
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
        }
    }
    else
    {
        
        [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    
    
}

-(void)sendMailForFrgotPassword:(NSString *)Error andEmail:(NSString*)Email{
    
    //NSLog(Error);
    if ([[AppDelegate getAppDelegate] checkInternateConnection])
    {
        NSArray *fullString = [Error componentsSeparatedByString:@"#"];
        NSString*name = [fullString objectAtIndex:1];
        NSString *pwd = [fullString objectAtIndex:2];
        
        NSString *body = [NSString stringWithFormat:@"Hi %@,\nLooks like you forget your password.\nNothing to worry.\nEmail:%@\n Password:%@ \nTeam:Barter", name,Email,pwd];
        NSString*urlString=[NSString stringWithFormat:@"%@%@",MainUrll,ForgotPassword];
        NSDictionary *forgotPasswordDict =@{
                                            // parameter depends upon the service
                                            @"to": Email,
                                            @"subject":@"Password For Login",
                                            @"body":body,
                                            };
        
        
        // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        
        [manager POST:urlString parameters:forgotPasswordDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSError *error = nil;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            
            //        [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (JSON==nil) {
                [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Server Error" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            }
            else{
                [[AppDelegate getAppDelegate]alert:APP_NAME message:@"Password will be send to Your Email id,Soon" cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                //[self sendMailForFrgotPassword];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) validEmail:(NSString*) emailString {
    if([emailString length]==0){
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)signIn:(id)sender {
    
    BOOL emailCheck =[self validEmail:EmailTxt.text];
    
    if (EmailTxt.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Email Address"];
    }
    else if (emailCheck==NO)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Correct Email Address"];
    }
    else if (PwdTxt.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Password"];
    }
    else{
        NSDictionary *loginDict =@{
                                   // parameter depends upon the service
                                   @"OutletID": @"",
                                   @"email": EmailTxt.text,
                                   @"pass": PwdTxt.text,
                                   @"deviceid": @""
                                   };
        
        
        
        [ServiceHIT sharedInstance].delegate=self;
        [[ServiceHIT sharedInstance]POSTService:Login Params:loginDict Occurance:@"1"];
        //        ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        //        [self.navigationController pushViewController:vc animated:YES];
    }
}


// this method will be changed as per Login Api (Not True Rihj Now)
-(void)ResponseData:(NSDictionary*)Response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //NSLog(@"%@",Response);
    // response dictionary
    NSDictionary*dict=[Response valueForKey:@"ECABS_GuestSignInResult"];
    NSArray*arr=[dict valueForKey:@"GstSearch"];
    NSString*dt=[arr valueForKey:@"Error"];
    
    if([dt isEqualToString:@""]){
        // [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:dt];
        if(rememberMeButton.selected==YES){
            [AppHelper saveToUserDefaults:@"login" withKey:@"login"];
        }
        // first clear the old data stored in sqlite
        [self clearDataFromSaveCategoryData];
        // every things fine so i am storing category in sqlite here
        
        [self saveCategoryData];
        
        
        
        ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        vc.pageCheck = @"Login";
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if([dt isEqualToString:@"invalid_email"]){
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Email Id not registered with us"];
    }
    else{
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Password is incorrect"];
    }
    
}

//- (IBAction)fbSignIn:(id)sender {
//    [self.view endEditing:YES];
//    [AppHelper saveToUserDefaults:@"facebook" withKey:@"signwith"];
//
//    if([[AppDelegate getAppDelegate]checkInternateConnection])
//    {
//
//        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
//        [manager logOut];
//        [FBSDKAccessToken setCurrentAccessToken:nil];
//
//        [AppHelper saveToUserDefaults:@"fb" withKey:@"signWith"];
//
//        //  [AppHelper getfb:_accountStore];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getFacebookData:) name:FbDataNotification object:nil];
//
//    }
//    else
//    {
//        [[AppDelegate getAppDelegate] alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again." cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    }
//}

//-(void)getFacebookData:(NSNotification *)fbData
//
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:FbDataNotification object:nil];
//    NSDictionary *dataDict= [[fbData userInfo]mutableCopy];
//    //    loginType=@"1";
//    //    NSArray* foo = [[dataDict valueForKey:@"name" ] componentsSeparatedByString: @" "];
//    //    NSString *firstname = [dataDict valueForKey:@"first_name"];
//    //    NSString *lastname = [dataDict valueForKey:@"last_name"];
//    emailStr=[dataDict valueForKey:@"email"];
//    //NSString *genderStr=[dataDict valueForKey:@"gender"];
//    NSString *socialId=[dataDict valueForKey:@"id"];
//    nameStr=[[[dataDict valueForKey:@"first_name"]stringByAppendingString:@" " ]stringByAppendingString:[dataDict valueForKey:@"last_name"]];
//    NSString*img=[dataDict valueForKey:@"profileImage"];
//    if (img==nil||[img isKindOfClass:[NSNull class]]) {
//        img=@"";
//    }
//    [AppHelper saveToUserDefaults:img withKey:@"ProfileImg"];
//    NSLog(@"login");
//    if (nameStr!=nil) {
//
//
//        [self Fb_gmailLogin];
//    }
//}
//- (IBAction)googleSignIN:(id)sender {
//}
//
//
//
//
//-(void)Fb_gmailLogin
//{
//
//    NSString*devicetoken=[AppHelper userDefaultsForKey:@"devicetoken"];
//    if (devicetoken==nil||[devicetoken isKindOfClass:[NSNull class]]) {
//        devicetoken=@"";
//    }
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy/MM/dd";
//    NSString *string = [formatter stringFromDate:[NSDate date]];
//    NSDictionary *dict =@{
//                          @"OutletID": OutLetID,
//                          @"Email": emailStr,
//                          };
//
//    [ServiceHIT sharedInstance].delegate=self;;
//    [[ServiceHIT sharedInstance]POSTService:SignUp Params:dict Occurance:@"2"];
//}
//
////  this method will be changed as per login api
//-(void)SecondTimeResponseData:(NSDictionary*)Response
//{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    // NSLog(@"%@",Response);
//    NSDictionary*dict=[Response valueForKey:@"ECABS_GuestSignUpResult"];
//    NSDictionary*dt=[dict valueForKey:@"GstSearch"];
//    NSString*error=[dt valueForKey:@"Error"];
//    if ([error isEqualToString:@""]) {
//        [AppHelper saveToUserDefaults:@"LOGIN" withKey:@"LOGIN"];
//        [AppHelper saveToUserDefaults:@"" withKey:@"user_type"];
//
//        NSArray*MyorderArray=[dict valueForKey:@"ListGuestOrders"];
//        [AppHelper saveToUserDefaults:MyorderArray withKey:@"MyorderArray"];
//        [AppHelper saveToUserDefaults:emailStr withKey:@"email"];
//        [AppHelper saveToUserDefaults:nameStr withKey:@"name"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:
//         @"TestNotification" object:nil userInfo:nil];
//        ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
//
//
//    }
//    else if([error isEqualToString:@"This email Id is already in use. Please go back & try signing up with different one."]){
//
//        ViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    // CGPoint touchLocation = [touch locationInView:touch.view];
    self.editing=NO;
}


-(void) clearDataFromSaveCategoryData {
    
    // Prepare the query string.
    NSString *query = [NSString stringWithFormat:@"delete from SubCategory"];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
}



// inserting category data into sqlite
-(void)saveCategoryData{
    NSDictionary *Dict =@{
                          // parameter depends upon the service
                          @"OutletID": @"",
                          };
    
    
    [ServiceHIT sharedInstance].delegate=self;
    [[ServiceHIT sharedInstance]POSTService:Filter Params:Dict Occurance:@"2"];
}
-(void)SecondTimeResponseData:(NSDictionary*)Response
{
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS FilterDetails (subCategoryDescription TEXT,subCategoryCoder TEXT, subCategoryID TEXT, status TEXT)"];
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    NSString *query1 = [NSString stringWithFormat:@"DELETE FROM FilterDetails"];
    // Execute the query.
    [self.dbManager executeQuery:query1];
    
    // NSLog(@"%@" , Response);
    NSMutableArray *tableDataFilter = [NSMutableArray array];
    NSString *filterServiceData=[Response valueForKey:@"FCABS_categoryResult"];
    NSData *data = [filterServiceData dataUsingEncoding:NSUTF8StringEncoding];
    tableDataFilter = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // Filtering Data
    for(int i =0 ; i < tableDataFilter.count ; i++){
        
        NSDictionary *dict = [NSDictionary dictionary];
        dict = [tableDataFilter objectAtIndex:i];
        if([[dict valueForKey:@"dishsupertypeid"] intValue] < 5){
            // Prepare the query string.
            NSString *query2 = [NSString stringWithFormat:@"insert into FilterDetails values('%@', '%@', '%@','%@')", [NSString stringWithFormat:@"%@",[dict valueForKey:@"dishsubtypedescription"]], [NSString stringWithFormat:@"%@",[dict valueForKey:@"dishsupertypeid"]],[NSString stringWithFormat:@"%@",[dict valueForKey:@"dishsubtypeid"]], [NSString stringWithFormat:@"0"]];
            
            // Execute the query.
            [self.dbManager executeQuery:query2];
            
        }
    }
    //    // If the query was successfully executed then pop the view controller.
    //    if (self.dbManager.affectedRows != 0) {
    //        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    //
    //    }
    //    else{
    //        NSLog(@"Could not execute the query.");
    //    }
}



@end
