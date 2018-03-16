//
//  FilterCuisinesVC.h
//  Barter
//
//  Created by Gulshan Kumar on 11/29/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

@interface FilterCuisinesVC : UIViewController<UITableViewDelegate,UITableViewDelegate>

@property(strong,nonatomic) DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *SearchBtnOutlet;
@property (weak, nonatomic) IBOutlet UIButton *TripleDotButtonOutlet;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (weak, nonatomic) IBOutlet UIView *LogoutView;

- (IBAction)SearchBtn:(UIButton *)sender;
- (IBAction)TripleDot:(UIButton *)sender;
- (IBAction)LogoutBtn:(UIButton *)sender;
- (IBAction)ResetBtn:(UIButton *)sender;
- (IBAction)BackButton:(id)sender;
@end
