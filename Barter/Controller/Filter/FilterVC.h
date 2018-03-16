//
//  FilterVC.h
//  Barter
//
//  Created by Gulshan Kumar on 11/26/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface FilterVC : UIViewController<UITextFieldDelegate>



@property (weak, nonatomic) IBOutlet UILabel *CuisneCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *CollectionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *HotnessCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *CuisneTypeCountLabel;
@property (weak, nonatomic) IBOutlet UIView *LogoutView;
@property (weak, nonatomic) IBOutlet UIButton *SearchBtn;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



- (IBAction)radioButton:(id)sender;
- (IBAction)ResetBtn:(UIButton *)sender;
- (IBAction)BackButton:(id)sender;
- (IBAction)ApplyFilterBtn:(UIButton *)sender;
- (IBAction)searchAction:(UIButton *)sender;
- (IBAction)LogoutBtn:(UIButton *)sender;

@end
