//
//  SelectDishVC.h
//  Barter
//
//  Created by iOS on 10/12/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectDishVC : UIViewController

@property(nonatomic, retain) UILabel *rateLabel;

// popup View
@property (weak, nonatomic) IBOutlet UILabel *outletAddress;
@property (weak, nonatomic) IBOutlet UILabel *outletMobileNumber;
@property (weak, nonatomic) IBOutlet UILabel *outletEmailId;
@property (weak ,nonatomic) IBOutlet UIView *logoutView;
//@property (strong, nonatomic) IBOutlet UIScrollView *ScrollableOutletName;
@property (weak, nonatomic) IBOutlet UILabel *OutletNameScrollLabel;


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)SearchBarButton:(UIButton *)sender;

-(IBAction)LogoutBtn:(id)sender;
-(IBAction)TripleDot: (id)sender;
- (IBAction)BackButton:(id)sender;
@end
