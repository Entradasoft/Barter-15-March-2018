//
//  SignUP.m
//  Cheeky Monkey
//
//  Created by Gulshan Kumar on 10/10/17.
//  Copyright © 2017 Entrdasoft. All rights reserved.
//

#import "SignUP.h"
#import "Define.h"
#import "AppHelper.h"
#import "ServiceHIT.h"
#import "CSNotificationView.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <Google/SignIn.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "OTPMachismViewController.h"
@import Firebase;
#import <FirebaseAuth/FirebaseAuth.h>
#import <Firebase.h>
#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>
@interface SignUP ()<ServiceHitDrlegate>
{
    UIDatePicker*datePicker;
    IBOutlet UIButton*SignupBtn;
    IBOutlet UITextField*NameTxt;
    IBOutlet UITextField*EmailText;
    IBOutlet UITextField*pwd;
    IBOutlet UITextField*confirmPwd;
    IBOutlet UITextField*dob;
    
    
    
    NSString*namestr;
    //NSString*mobilestr;
    NSString*emailstr;
    
    NSString*password;
    NSString*confirmPassword;
    
}
// This property is used for storing Facebook Information
@property (nonatomic, strong) ACAccountStore *accountStore;

@end

@implementation SignUP

- (void)viewDidLoad {
    
    
    //    ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    //   [self.navigationController pushViewController:vc animated:YES];
    // ----------Hide Back  Button from screen------
    
    
    //-----------------------------------------------
    
    [super viewDidLoad];
    SignupBtn.layer.cornerRadius=5;
    //    SignupBtn.layer.borderColor = RgbColor.CGColor;
    //    SignupBtn.layer.borderWidth = 1.0;
    
    /*      // Google sign in process
     GIDSignIn *signIn = [GIDSignIn sharedInstance];
     signIn.shouldFetchBasicProfile = YES;
     signIn.delegate = self;
     signIn.uiDelegate = self;
     // Do any additional setup after loading the view.
     */
    
    // Date Picker View
    datePicker = [[UIDatePicker alloc] init];
    datePicker.backgroundColor = [UIColor whiteColor];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIToolbar *toolBar2= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolBar2 setBarStyle:UIBarStyleBlackTranslucent];
    
    [toolBar2 sizeToFit];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 200)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *barButtonDone2 = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(doneClicked)];
    toolBar2.items = @[ flex, barButtonDone2];
    barButtonDone2.tintColor = [UIColor blackColor];
    
    UIView *inputView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, screenWidth,  datePicker.frame.size.height)];
    inputView2.backgroundColor = [UIColor clearColor];
    [inputView2 addSubview:datePicker];
    
    //  [inputView2 addSubview:toolBar2];
    //[datePicker setMinimumDate: [NSDate date]];
    [datePicker setMaximumDate: [NSDate date]];
    dob.inputView = inputView2;
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];   //it hides
    
    _dobImg.image = [_dobImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [_dobImg setTintColor:[UIColor whiteColor]];
    
}



- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // it shows
    
}

- (void)datePickerValueChanged:(id)sender{
    
    NSDate*  date = datePicker.date;
    // NSDate*currdate=[NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/YYYY"];
    
    
    dob.text=[df stringFromDate:date];

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


-(IBAction)signMethod:(id)sender
{
    
    
    
    //   [self.navigationController pushViewController:vc animated:YES];
    
    
    //    NSString *stringToBeTested = MobileText.text;
    //
    //    NSString *mobileNumberPattern = @"[789][0-9]{9}";
    //    NSPredicate *mobileNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumberPattern];
    //
    //    BOOL Mobilematched = [mobileNumberPred evaluateWithObject:stringToBeTested];
    BOOL emailCheck =[self validEmail:EmailText.text];
    if (NameTxt.text.length==0) {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type a Name"];
    }
    
    else if (EmailText.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Email Address"];
    }
    else if (emailCheck==NO)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Correct Email Address"];
    }
    
    else if (pwd.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Password"];
    }
    else if (confirmPwd.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Confirm Password"];
    }
    else if (![pwd.text isEqualToString:confirmPwd.text])
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Passwords Don't Match "];
    }
    else if (dob.text.length == 0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Date Of Birth"];
    }
    else
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
        NSString *string = [formatter stringFromDate:[NSDate date]];
        NSDictionary *dict =@{
                              // parameter depends upon the service
                              @"OutletID": OutLetID,
                              @"validdate": string,
                              @"Name": NameTxt.text,
                              @"Phone":@"",
                              @"Email": EmailText.text,
                              @"dob": dob.text, // Did at last 17 nov 2017 6:20 pm
                              @"m_day": @"",
                              @"Sex": @"",
                              @"Address": @"",
                              @"Address1": @"",
                              @"Spl_remark":pwd.text,
                              @"discount": @"0",
                              @"updateGuest": [NSNumber numberWithBool:false],
                              @"apikey": @"",
                              @"deviceid": @""
                              };
        
        [AppHelper saveToUserDefaults:dict withKey:@"signupdict"];
        
        OTPMachismViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"OTPMachismViewController"];
        //                ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}
//-(IBAction)skip:(id)sender
//{
//    [AppHelper saveToUserDefaults:@"" withKey:@"user_type"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:
//     @"TestNotification" object:nil userInfo:nil];
//    HomeScreenVC*vc=[self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenVC"];
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickFacebookLoginBtn:(id)sender {
    [self.view endEditing:YES];
    [AppHelper saveToUserDefaults:@"facebook" withKey:@"signwith"];
    
    if([[AppDelegate getAppDelegate]checkInternateConnection])
    {
        
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        
        [AppHelper saveToUserDefaults:@"fb" withKey:@"signWith"];
        
        [AppHelper getfb:_accountStore];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getFacebookData:) name:FbDataNotification object:nil];
        
    }
    else
    {
        [[AppDelegate getAppDelegate] alert:APP_NAME message:@"Connection Error. Please check your internet connection and try again." cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}
-(void)getFacebookData:(NSNotification *)fbData

{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FbDataNotification object:nil];
    NSDictionary *dataDict= [[fbData userInfo]mutableCopy];
    // loginType=@"1";
    //NSArray* foo = [[dataDict valueForKey:@"name" ] componentsSeparatedByString: @" "];
    //NSString *firstname = [dataDict valueForKey:@"first_name"];
    // NSString *lastname = [dataDict valueForKey:@"last_name"];
    emailstr=[dataDict valueForKey:@"email"];
    //NSString *genderStr=[dataDict valueForKey:@"gender"];
    NSString *socialId=[dataDict valueForKey:@"id"];
    namestr=[[[dataDict valueForKey:@"first_name"]stringByAppendingString:@" " ]stringByAppendingString:[dataDict valueForKey:@"last_name"]];
    NSString*img=[dataDict valueForKey:@"profileImage"];
    if (img==nil||[img isKindOfClass:[NSNull class]]) {
        img=@"";
    }
    [AppHelper saveToUserDefaults:img withKey:@"ProfileImg"];
    NSLog(@"login");
    if (namestr!=nil) {
        
        
        [self Fb_gmailLogin];
    }
}

/*
 -(IBAction)googlelogin:(id)sender
 {
 [[GIDSignIn sharedInstance] signIn];
 }
 
 - (void)signIn:(GIDSignIn *)signIn
 didSignInForUser:(GIDGoogleUser *)user
 withError:(NSError *)error {
 // Perform any operations on signed in user here.
 NSString*IMG;
 if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
 {
 NSUInteger dimension = round(CGSizeMake(500, 500).width * [[UIScreen mainScreen] scale]);
 NSURL *imageURL = [user.profile imageURLWithDimension:dimension];
 NSLog(@"url %@",imageURL);
 IMG=imageURL.absoluteString;
 if (IMG==nil||[IMG isKindOfClass:[NSNull class]]) {
 IMG=@"";
 }
 [AppHelper saveToUserDefaults:IMG withKey:@"ProfileImg"];
 
 }
 NSString *userId = user.userID;
 
 NSString *idToken = user.authentication.idToken; // Safe to send to the server
 namestr = user.profile.name;
 emailstr = user.profile.email;
 
 if (namestr!=nil) {
 
 [MBProgressHUD showHUDAddedTo:self.view animated:YES];
 [self Fb_gmailLogin];
 }
 
 
 }
 - (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
 //  [myActivityIndicator stopAnimating];
 }
 
 // Present a view that prompts the user to sign in with Google
 - (void)signIn:(GIDSignIn *)signIn
 presentViewController:(UIViewController *)viewController {
 [self presentViewController:viewController animated:YES completion:nil];
 }
 
 // Dismiss the "Sign in with Google" view
 - (void)signIn:(GIDSignIn *)signIn
 dismissViewController:(UIViewController *)viewController {
 [self dismissViewControllerAnimated:YES completion:nil];
 }
 */
-(void)Fb_gmailLogin
{
    
    NSString*devicetoken=[AppHelper userDefaultsForKey:@"devicetoken"];
    if (devicetoken==nil||[devicetoken isKindOfClass:[NSNull class]]) {
        devicetoken=@"";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd";
    NSString *string = [formatter stringFromDate:[NSDate date]];
    NSDictionary *dict =@{
                          @"OutletID": OutLetID,
                          @"validdate": string,
                          @"Name": namestr,
                          @"Phone": @"",
                          @"Email": emailstr,
                          @"dob": @"",
                          @"m_day": @"",
                          @"Sex": @"",
                          @"Address": @"",
                          @"Address1": @"",
                          @"Spl_remark": @"",
                          @"discount": @"0",
                          @"updateGuest": [NSNumber numberWithBool:true],
                          @"apikey": @"",
                          @"deviceid": devicetoken
                          };
    
    [ServiceHIT sharedInstance].delegate=self;;
    [[ServiceHIT sharedInstance]POSTService:SignUp Params:dict Occurance:@"2"];
}
-(void)SecondTimeResponseData:(NSDictionary*)Response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"%@",Response);
    NSDictionary*dict=[Response valueForKey:@"ECABS_GuestSignUpResult"];
    NSDictionary*dt=[dict valueForKey:@"GstSearch"];
    NSString*error=[dt valueForKey:@"Error"];
    if ([error isEqualToString:@""]) {
        [AppHelper saveToUserDefaults:@"LOGIN" withKey:@"LOGIN"];
        [AppHelper saveToUserDefaults:@"" withKey:@"user_type"];
        
        NSArray*MyorderArray=[dict valueForKey:@"ListGuestOrders"];
        [AppHelper saveToUserDefaults:MyorderArray withKey:@"MyorderArray"];
        [AppHelper saveToUserDefaults:emailstr withKey:@"email"];
        [AppHelper saveToUserDefaults:namestr withKey:@"name"];
        [[NSNotificationCenter defaultCenter] postNotificationName:
         @"TestNotification" object:nil userInfo:nil];
        OTPMachismViewController*vc=[self.storyboard instantiateViewControllerWithIdentifier:@"OTPMachismViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }
    else if([error isEqualToString:@"This email Id is already in use. Please go back & try signing up with different one."]){
        
        ViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
   // CGPoint touchLocation = [touch locationInView:touch.view];
    self.editing=NO;
}

@end
