//
//  OTPMachismViewController.m
//  Cheeky Monkey
//
//  Created by Gulshan Kumar on 11/16/17.
//  Copyright © 2017 Entrdasoft. All rights reserved.
//

#import "OTPMachismViewController.h"
#import "Define.h"
#import "AppHelper.h"
#import "ServiceHIT.h"
#import "CSNotificationView.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "OTPMachismViewController.h"
#import "ViewController.h"
@import Firebase;
#import <FirebaseAuth/FirebaseAuth.h>
#import <Firebase.h>
#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>

@interface OTPMachismViewController()<UITextFieldDelegate>
{
    IBOutlet UITextField *FirstChar;
    IBOutlet UITextField *SecondChar;
    IBOutlet UITextField *ThirdChar;
    IBOutlet UITextField *FourthChar;
    IBOutlet UITextField *FiveChar;
    IBOutlet UITextField *sixChar;
    // Updated by Gulshan 28 Nov 2017
    IBOutlet UIButton * GenerateOTP;
    IBOutlet UIButton * OTPSignUp;
    IBOutlet UIButton * ResendOTP;
    IBOutlet UITextField*MobileText;
    NSString*mobilestr;
}

@end

@implementation OTPMachismViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Disable buttons and textField
    OTPSignUp.enabled = NO;
    ResendOTP.enabled = NO;
    FirstChar.enabled = NO;
    SecondChar.enabled = NO;
    ThirdChar.enabled = NO;
    FourthChar.enabled = NO;
    FiveChar.enabled = NO;
    sixChar.enabled = NO;
    
    FirstChar.backgroundColor = [UIColor lightGrayColor];
    SecondChar.backgroundColor = [UIColor lightGrayColor];
    ThirdChar.backgroundColor = [UIColor lightGrayColor];
    FourthChar.backgroundColor = [UIColor lightGrayColor];
    FiveChar.backgroundColor = [UIColor lightGrayColor];
    sixChar.backgroundColor = [UIColor lightGrayColor];
    OTPSignUp.backgroundColor = [UIColor lightGrayColor];
    GenerateOTP.backgroundColor  = GreenColor;
    MobileText.delegate=self;
    // changing text font and size of the text

    
    // end of changing
    // end
    self.navigationItem.hidesBackButton=YES;
    FirstChar.keyboardType=UIKeyboardTypeNumberPad;
    SecondChar.keyboardType=UIKeyboardTypeNumberPad;
    ThirdChar.keyboardType=UIKeyboardTypeNumberPad;
    FourthChar.keyboardType=UIKeyboardTypeNumberPad;
    FiveChar.keyboardType=UIKeyboardTypeNumberPad;
    sixChar.keyboardType=UIKeyboardTypeNumberPad;
    
    FirstChar.tag=1;
    SecondChar.tag=2;
    ThirdChar.tag=3;
    FourthChar.tag=4;
    FiveChar.tag=5;
    sixChar.tag=6;
    
    FirstChar.delegate=self;
    SecondChar.delegate=self;
    ThirdChar.delegate=self;
    FourthChar.delegate=self;
    FiveChar.delegate=self;
    sixChar.delegate=self;
    
    [FirstChar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [SecondChar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [ThirdChar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [FourthChar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [FiveChar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [sixChar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // Do any additional setup after loading the view.
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(textField==MobileText)
    {
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
                                                                       withString:string];
        return resultText.length <= 10;
    }
    else{
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
                                                                       withString:string];
        return resultText.length <= 1;
    }
}


-(void)textFieldDidChange :(UITextField *) textField{
    //your code
    // resignFirstResponder means hide keeyboard
    //resignFirstResponder means to show keyboard
    
    if (textField == FirstChar) {
        if (textField.text.length==0) {
            [textField becomeFirstResponder];
            [FirstChar becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            [SecondChar becomeFirstResponder];
        }
    }
    else if (textField == SecondChar) {
        if (textField.text.length==0) {
            [textField resignFirstResponder];
            
            [SecondChar becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            [ThirdChar becomeFirstResponder];
        }
    }
    else if (textField == ThirdChar) {
        if (textField.text.length==0) {
            [textField resignFirstResponder];
            
            [ThirdChar becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            [FourthChar becomeFirstResponder];
        }
        
    }
    else if (textField==FourthChar)
    {
        if (textField.text.length==0) {
            [textField resignFirstResponder];
            
            [FourthChar becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            [FiveChar becomeFirstResponder];
        }
    }
    else if (textField==FiveChar)
    {
        if (textField.text.length==0) {
            [textField resignFirstResponder];
            
            [FiveChar becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            [sixChar becomeFirstResponder];
        }
    }
    else if (textField==sixChar)
    {
        if (textField.text.length==0) {
            [textField resignFirstResponder];
            
            [sixChar becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            
        }
    }
    
}
-(IBAction)generateotp:(id)sender
{
    
    // Alert for wrong input
    if (MobileText.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Mobile Number"];
    }
    
    else if (MobileText.text.length!=10)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Correct Mobile Number"];
    }
    
    else{
        
       
        OTPSignUp.enabled = YES;
        ResendOTP.enabled = YES;
        FirstChar.enabled = YES;
        SecondChar.enabled = YES;
        ThirdChar.enabled = YES;
        FourthChar.enabled = YES;
        FiveChar.enabled = YES;
        sixChar.enabled = YES;
        
        FirstChar.backgroundColor = [UIColor whiteColor];
        SecondChar.backgroundColor = [UIColor whiteColor];
        ThirdChar.backgroundColor = [UIColor whiteColor];
        FourthChar.backgroundColor = [UIColor whiteColor];
        FiveChar.backgroundColor = [UIColor whiteColor];
        sixChar.backgroundColor = [UIColor whiteColor];
        OTPSignUp.backgroundColor = GreenColor;
        
        
        
        NSString *strphone=[NSString stringWithFormat:@"%@%@",@"+91",MobileText.text];                            [[FIRPhoneAuthProvider provider] verifyPhoneNumber:strphone                                                UIDelegate:nil                                                completion:^(NSString * _Nullable verificationID, NSError * _Nullable error)         {
            if (error)
            {                 ;
                return;
                
            }
            else
            {
                [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Sending OTP..."];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:verificationID forKey:@"authVerificationID"];
                //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                OTPMachismViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"OTPMachismViewController"];
                //[self.navigationController pushViewController:vc animated:YES];
                
            }                      }];
    }
}
- (IBAction)ResendOTP:(id)sender {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    FirstChar.text = @"";
    SecondChar.text = @"";
    ThirdChar.text = @"";
    FourthChar.text = @"";
    FiveChar.text = @"";
    sixChar.text = @"";
    
    [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"OTP Resending..."];
    [self generateotp:nil];
}



-(IBAction) OTPSignUp:(id)sender{
    
    // update by gulshan
    NSString *stringToBeTested = MobileText.text;
    
    NSString *mobileNumberPattern = @"[789][0-9]{9}";
    NSPredicate *mobileNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumberPattern];
    
    BOOL Mobilematched = [mobileNumberPred evaluateWithObject:stringToBeTested];
    
    // Alert for wrong input
    if (MobileText.text.length==0)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Mobile Number"];
    }
    
    else if (MobileText.text.length!=10)
    {
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Type Correct Mobile Number"];
    }
    else{
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //===============
        
        
        //    [AppHelper saveToUserDefaults:@"LOGIN" withKey:@"LOGIN"];
        //    [AppHelper saveToUserDefaults:@"" withKey:@"user_type"];
        //    [[NSNotificationCenter defaultCenter] postNotificationName:
        //     @"TestNotification" object:nil userInfo:nil];
        //
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //
        NSString *verificationID = [defaults stringForKey:@"authVerificationID"];
        
        // what user enters in the text fields
        NSString*userip=[NSString stringWithFormat:@"%@%@%@%@%@%@",FirstChar.text,SecondChar.text,ThirdChar.text,FourthChar.text,FiveChar.text,sixChar.text];
        
        if(userip.length!=6){
             [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"Please Enter Correct 6 Digit OTP"];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else{
        
        // Checking OTP genearared by Firebase and entered by user
        FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
                                         credentialWithVerificationID:verificationID
                                         verificationCode:userip];
        // CHECKING STATUS OF OTP PROCESS, IF ERROR THEN RETURN
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          // ...
                                          [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:@"OTP Dosen't Match"];
                                          
                                          return;
                                      }
                                      
                                      
                                      
                                      NSMutableDictionary *signUpDict = [[defaults valueForKey:@"signupdict"] mutableCopy];
                                      
                                      [signUpDict setObject:MobileText.text forKey:@"Phone"];
                                      [ServiceHIT sharedInstance].delegate=self;
                                      [[ServiceHIT sharedInstance]POSTService:SignUp Params:signUpDict Occurance:@"1"];
                                  }
         ] ;
        
    }
}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ResponseData:(NSDictionary*)Response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"%@",Response);
    NSDictionary*dict=[Response valueForKey:@"ECABS_GuestSignUpResult"];
    NSArray*arr=[dict valueForKey:@"ListSaveGuest"];
    NSDictionary*dt=[arr objectAtIndex:0];
    if ([[dt valueForKey:@"Code"]intValue]==0) {
        NSLog(@"it is a string");
        [[AppDelegate getAppDelegate]NotificationAlert:self.navigationController message:[dt valueForKey:@"Code"]];
        
        
    }
    else {
        [AppHelper saveToUserDefaults:@"login" withKey:@"login"];
        
        ViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        vc.pageCheck = @"SignUp";
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

- (IBAction)OTPBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    //CGPoint touchLocation = [touch locationInView:touch.view];
    self.editing=NO;
}
@end
