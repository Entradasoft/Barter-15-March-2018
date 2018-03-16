//
//  ViewController.h
//  Barter
//
//  Created by iOS on 22/11/17.
//  Copyright © 2017 Entradasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UISearchBarDelegate>
- (IBAction)SearchButton:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;

-(IBAction)tripleDot:(id)sender;
-(IBAction)LogoutBtn:(id)sender;

@property(nonatomic,strong)NSString*pageCheck;
@end

