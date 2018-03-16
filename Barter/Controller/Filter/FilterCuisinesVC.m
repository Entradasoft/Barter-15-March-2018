//
//  FilterCuisinesVC.m
//  Barter
//
//  Created by Gulshan Kumar on 11/29/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import "FilterCuisinesVC.h"
#import "ServiceHIT.h"
#import "Define.h"
#import <sqlite3.h>
#import "AppDelegate.h"
#import "HOMECELL.h"
#import "ViewController.h"
#import "FilterVC.h"
#import "LoginVC.h"

@interface FilterCuisinesVC ()<ServiceHitDrlegate, UISearchBarDelegate, UISearchResultsUpdating>{
  
    NSInteger buttonTagValue;
    NSMutableArray *tableDataFilter;
    IBOutlet UITableView*DataTable;
    NSMutableArray*cuisineData;
    NSMutableArray*collectionData;
    NSMutableArray*hotnessData;
    NSMutableArray*cuisineTypeData;
    NSArray *tableData;
    NSMutableArray *checkedStatus;
    BOOL isFiltered;  // checking search is enable or not
    UIAlertView *alert;
}

@end

@implementation FilterCuisinesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Getting Selected button id of FilterVC class
    self.navigationItem.hidesBackButton=NO;
    self.navigationController.navigationBar.hidden = YES;
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Barter.sql"];
//    BOOL downloaded = [[NSUserDefaults standardUserDefaults] boolForKey: @"first"];
//    if (!downloaded) {
//        NSDictionary *dishsupertypeid=@{};
//        [ServiceHIT sharedInstance].delegate=self;
//        [[ServiceHIT sharedInstance]POSTService:Filter Params:dishsupertypeid Occurance:@"1"];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"first"];
//    }

    // variable initialization
    cuisineData = [[NSMutableArray alloc]init];
    collectionData = [[NSMutableArray alloc]init];
    hotnessData= [[NSMutableArray alloc]init];
    cuisineTypeData= [[NSMutableArray alloc]init];
    checkedStatus = [NSMutableArray array];

    //[self.SearchBar setBackgroundColor:[UIColor whiteColor]];
    //[self.SearchBar setBarTintColor:[UIColor clearColor]];
    
    buttonTagValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"buttonTagValue"];  // value of superCategoryCode
    [self getData];
    _LogoutView.hidden = YES;
    _SearchBar.delegate = self;
    _SearchBar.showsCancelButton = YES;
}


- (void)getData{
    
    if(buttonTagValue==1){
        self.titleLabel.text=@"Cuisine";
        NSString *query = @"select * from FilterDetails where subCategoryCoder = '1'";
        // Get the results.
        if (tableData != nil) {
            tableData = nil;
        }
        tableData = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
        [DataTable reloadData];
    }
    else if(buttonTagValue==2){
        self.titleLabel.text=@"Collection";
        NSString *query = @"select * from FilterDetails where subCategoryCoder = '2'";
        // Get the results.
        if (tableData != nil) {
            tableData = nil;
        }
        tableData = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
        [DataTable reloadData];
    }
    else if(buttonTagValue==3){
        self.titleLabel.text=@"Hotness";
        NSString *query = @"select * from FilterDetails where subCategoryCoder = '3'";
        // Get the results.
        if (tableData != nil) {
            tableData = nil;
        }
        tableData = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
        [DataTable reloadData];
    }
    else if(buttonTagValue==4){
        self.titleLabel.text=@"Cuisine Type";
        NSString *query = @"select * from FilterDetails where subCategoryCoder = '4'";
        // Get the results.
        if (tableData != nil) {
            tableData = nil;
        }
        tableData = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
        [DataTable reloadData];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isFiltered) {
        return tableDataFilter.count;
    }
    
    return [tableData count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cell";
    
    HOMECELL *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[HOMECELL alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if (isFiltered) {
        cell.FilterData.text =[NSString stringWithFormat:@"%@",[[tableDataFilter objectAtIndex:indexPath.row] objectAtIndex:0]];
        cell.FilterData.textColor=[UIColor blackColor];
        
        NSString *status = [NSString stringWithFormat:@"%@",[[tableDataFilter objectAtIndex:indexPath.row] objectAtIndex:3] ];
        if([status isEqualToString:@"1"]){
            cell.selectBoxButton.selected = YES;
        }
        else{
            cell.selectBoxButton.selected = NO;
        }

    }else{
        cell.FilterData.text =[NSString stringWithFormat:@"%@",[[tableData objectAtIndex:indexPath.row] objectAtIndex:0]];
        cell.FilterData.textColor=[UIColor blackColor];
        
        NSString *status = [NSString stringWithFormat:@"%@",[[tableData objectAtIndex:indexPath.row] objectAtIndex:3] ];
        if([status isEqualToString:@"1"]){
            cell.selectBoxButton.selected = YES;
        }
        else{
            cell.selectBoxButton.selected = NO;
        }

    }

 
    return cell;
}


 //check mark enable
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *categoryname;
    
    if (isFiltered) {
            categoryname = [[tableDataFilter objectAtIndex:indexPath.row] objectAtIndex:0];
    }else{
            categoryname = [[tableData objectAtIndex:indexPath.row] objectAtIndex:0];
    }

    
    // fetching previous status and if status  = 1 change it to 0 and vice-versa
    NSString *query = [NSString stringWithFormat:@"select Status from FilterDetails where subCategoryDescription = '%@'" , categoryname];
    NSArray *statusData = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
    NSString *status = [NSString stringWithFormat:@"%@",[[statusData objectAtIndex:0] objectAtIndex:0]];
    if([status isEqualToString:@"0"]){
            NSString *query1 = [NSString stringWithFormat:@"UPDATE FilterDetails SET status = '1' WHERE subCategoryDescription = '%@' ", categoryname];
            // Execute the query.
            [self.dbManager executeQuery:query1];
    }else{
            NSString *query1 = [NSString stringWithFormat:@"UPDATE FilterDetails SET status = '0' WHERE subCategoryDescription = '%@' ", categoryname];
            // Execute the query.
            [self.dbManager executeQuery:query1];
    }
    
    [self getData];
}


- (IBAction)BackButton:(id)sender {
    
    FilterVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Filter"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)TripleDot:(UIButton *)sender {
    if(_LogoutView.isHidden==YES){
        _LogoutView.hidden=NO;
    }
    else{
        _LogoutView.hidden=YES;
    }
}

-(IBAction)LogoutBtn:(UIButton *)sender{
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


// capturing every touch and hiding popup view
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == self.view)    {
        _LogoutView.hidden = YES;
    }
    _LogoutView.hidden = YES;
}

- (IBAction)ResetBtn:(UIButton *)sender {

    int superCategoryCode =  (int)buttonTagValue;
    NSString *query = [NSString stringWithFormat:@"UPDATE FilterDetails SET Status = '0' WHERE subCategoryCoder = '%d'", superCategoryCode];
    // Execute the query.
    [self.dbManager executeQuery:query];

    FilterCuisinesVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterCuisinesVC"];
    [self.navigationController pushViewController:vc animated:NO];
    
}

#pragma mark - Search Methods
- (IBAction)SearchBtn:(UIButton *)sender {
    
    _SearchBtnOutlet.hidden = YES;
    // _TripleDotButtonOutlet.hidden = YES;
    
    _SearchBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.25 animations:^{
        _SearchBar.frame = CGRectMake(1, 22, 410, 33);
        [self.view addSubview:_SearchBar];
    }];
    
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    _SearchBar.hidden = YES;
    isFiltered = false;
    _SearchBtnOutlet.hidden = NO;
   // [DataTable reloadData];
    
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
 
    if (searchText.length == 0) {
        isFiltered = false;
    }else{
       // isFiltered = true;
      //  tableDataFilter = [[NSMutableArray alloc]init];
        
//        for(NSArray *categoryName in tableData){
//            NSString *name = [NSString stringWithFormat:@"%@",[categoryName objectAtIndex:0]];
//            NSRange nameRange = [name rangeOfString:searchText options:NSAnchoredSearch];
//            if (nameRange.location != NSNotFound) {
//                [tableDataFilter addObject:categoryName];
//            }
//        }
    }
    
  //  [DataTable reloadData];
}

@end
