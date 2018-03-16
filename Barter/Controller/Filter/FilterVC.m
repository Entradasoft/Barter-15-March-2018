//
//  FilterVC.m
//  Barter
//
//  Created by Gulshan Kumar on 11/26/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import "FilterVC.h"
#import "FilterCuisinesVC.h"
#import "AppHelper.h"
#import "FilterCuisinesVC.h"
#import "Define.h"
#import "ViewController.h"
#import "DBManager.h" // for using sqlite
#import "ServiceHIT.h"
#import "MBProgressHUD.h"
#import "LoginVC.h"

@interface FilterVC ()<UITextFieldDelegate,ServiceHitDrlegate,UITableViewDelegate,UITableViewDataSource>
// creating object of Dbmanger class to access all methods to do database operation
@property (nonatomic, strong) DBManager *dbManager;

@property (strong, nonatomic) IBOutlet UITextField *CityTextField;
@property (strong, nonatomic) IBOutlet UITextField *LocalityTextField;

- (IBAction)FilterArrow:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *FilterArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *RelevanceRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *RatingRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *TrendingRadioButton;

 

@end

NSMutableSet *cityData; // created set for collecting unique set of city
NSMutableSet *localityData; //  created set for collecting unique set of locality.
NSString *textFieldCheck;
NSMutableArray *filterData;
NSMutableArray *tableDataFilter;
UITableView *searchTableView;
UIAlertView *alert;
NSString *sortByButtonName;
BOOL isFiltered;

@implementation FilterVC
NSMutableArray *countOfEachCategoryArray;



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    
    // for using sqlite , we have write this line of code below
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"Barter.sql"];
    
    countOfEachCategoryArray = [NSMutableArray array];
    [self counterSelectedItems];
    
    [self getCityAndLocation];
    
    _CityTextField.delegate = self;
    _LocalityTextField.delegate = self;
    _CityTextField.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    cityData = [NSMutableSet set];
    localityData = [NSMutableSet set];
    
    // On click of textField
    [_CityTextField addTarget:self action:@selector(city) forControlEvents:UIControlEventEditingDidBegin];
    [_LocalityTextField addTarget:self action:@selector(locality) forControlEvents:UIControlEventEditingDidBegin];
    
    filterData = [[NSMutableArray alloc]init];
    searchTableView.hidden = YES;
    _LogoutView.hidden = YES;
    
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = YES;
    
    // checking whether sort by button selected or not
    
    NSUserDefaults *vk = [NSUserDefaults standardUserDefaults];
    sortByButtonName = [vk valueForKey:@"radioButtonOnFilter"];
    
    if ([sortByButtonName isEqualToString:@"Relevance"]) {
        _RelevanceRadioButton.selected = YES;
        _RatingRadioButton.selected = NO;
        _TrendingRadioButton.selected = NO;
    }else if([sortByButtonName isEqualToString:@"Rating"]){
        _RelevanceRadioButton.selected = NO;
        _RatingRadioButton.selected = YES;
        _TrendingRadioButton.selected = NO;
    }else if([sortByButtonName isEqualToString:@"Trending"]){
        _RelevanceRadioButton.selected = NO;
        _RatingRadioButton.selected = NO;
        _TrendingRadioButton.selected = YES;
    }else{
        _RelevanceRadioButton.selected = YES;
        _RatingRadioButton.selected = NO;
        _TrendingRadioButton.selected = NO;
    }
    
     searchTableView = [[UITableView alloc]init];
    
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


- (IBAction)FilterArrow:(id)sender {
    // saving button id in userdefault
    NSUInteger buttonTagValue = [sender tag];
    [[NSUserDefaults standardUserDefaults] setInteger:buttonTagValue forKey:@"buttonTagValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    FilterCuisinesVC *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterCuisinesVC"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)BackButton:(id)sender {
    // [self.navigationController popViewControllerAnimated:YES];
    NSString *query = [NSString stringWithFormat:@"UPDATE FilterDetails SET status = '0'"];
    // Execute the query.
    [self.dbManager executeQuery:query];
    _CityTextField.text = @"";
    _LocalityTextField.text = @"";
    [self counterSelectedItems];
    
    NSString *blankString = @"";
    [[NSUserDefaults standardUserDefaults] setObject:blankString forKey:@"radioButtonOnFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:blankString forKey:@"cityOnFilter"];
    [[NSUserDefaults standardUserDefaults] setObject:blankString forKey:@"localityOnFilter"];

    
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)radioButton:(id)sender {
    NSInteger tagvalue = [sender tag];
    if(tagvalue == 1){
        _RelevanceRadioButton.selected=YES;
        _RatingRadioButton.selected=NO;
        _TrendingRadioButton.selected=NO;
        
        NSString *radioButtonOnFilter = @"Relevance";
        [[NSUserDefaults standardUserDefaults] setObject:radioButtonOnFilter forKey:@"radioButtonOnFilter"];
        
    }
    else if(tagvalue == 2){
        _RelevanceRadioButton.selected=NO;
        _RatingRadioButton.selected=YES;
        _TrendingRadioButton.selected=NO;
        
        NSString *radioButtonOnFilter = @"Rating";
        [[NSUserDefaults standardUserDefaults] setObject:radioButtonOnFilter forKey:@"radioButtonOnFilter"];

    }
    else {
        _RelevanceRadioButton.selected=NO;
        _RatingRadioButton.selected=NO;
        _TrendingRadioButton.selected=YES;
        
        NSString *radioButtonOnFilter = @"Trending";
        [[NSUserDefaults standardUserDefaults] setObject:radioButtonOnFilter forKey:@"radioButtonOnFilter"];

    }
}
-(void)getCityAndLocation{
    NSDictionary *loginDict =@{
                               // parameter depends upon the service
                               @"OutletID": @"",
                               };
    [ServiceHIT sharedInstance].delegate=self;
    [[ServiceHIT sharedInstance]POSTService:GetCityAndLocation Params:loginDict Occurance:@"1"];
    
}

-(void)ResponseData:(NSDictionary*)Response
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // response dictionary
    NSString*str=[Response valueForKey:@"ECABS_getLocationResult"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    if (data!=nil) {
        // creating a table in sqlite for storing city and locality
        NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS CityAndLocation (city TEXT,locality text)"];
        // Execute the query.
        [self.dbManager executeQuery:query];
        NSMutableArray *locationData = [[NSMutableArray alloc]init];
        locationData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for(int i =0 ; i< locationData.count ; i++){
            NSDictionary *dict = [locationData objectAtIndex:i];
            NSString *query1 = [NSString stringWithFormat:@"INSERT INTO CityAndLocation VALUES (UPPER('%@'),UPPER('%@'))", [dict valueForKey:@"city"],[dict valueForKey:@"location"]];
            // Execute the query.
            [self.dbManager executeQuery:query1];
            
            //  [cityData addObject:[[dict valueForKey:@"city"] uppercaseString]];
            //  [localityData addObject:[[dict valueForKey:@"location"] uppercaseString]];
        }
    }
}

-(void)counterSelectedItems{
    
    for(int i=1; i<=4 ; i++){
        
        NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM FilterDetails where subCategoryCoder= '%@' and status = 1", [NSString stringWithFormat:@"%d", i]];
        NSArray *countOfEachCategory = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]]; // fetching data from sqlite table
        int counter = [[[countOfEachCategory objectAtIndex:0] objectAtIndex:0] intValue] ;
        
        if(counter != 0){
            [countOfEachCategoryArray addObject:[NSNumber numberWithInt:counter]];
        }else{
            [countOfEachCategoryArray addObject:[NSNumber numberWithInt:0]];
        }
    }
    if(countOfEachCategoryArray.count==4){
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-5, 0, 22, 22)];
        CAShapeLayer *circleLayer = [[CAShapeLayer alloc]init];
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        circleLayer.strokeColor = RgbColor.CGColor;
        circleLayer.path = bezierPath.CGPath;
        circleLayer.lineWidth = 2;
        
        UIBezierPath *bezierPath1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-5, 0, 22, 22)];
        CAShapeLayer *circleLayer1 = [[CAShapeLayer alloc]init];
        circleLayer1.fillColor = [UIColor clearColor].CGColor;
        circleLayer1.strokeColor = RgbColor.CGColor;
        circleLayer1.path = bezierPath1.CGPath;
        circleLayer1.lineWidth = 2;
        
        UIBezierPath *bezierPath2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-5, 0, 22, 22)];
        CAShapeLayer *circleLayer2 = [[CAShapeLayer alloc]init];
        circleLayer2.fillColor = [UIColor clearColor].CGColor;
        circleLayer2.strokeColor = RgbColor.CGColor;
        circleLayer2.path = bezierPath2.CGPath;
        circleLayer2.lineWidth = 2;
        
        UIBezierPath *bezierPath3 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-5, 0, 22, 22)];
        CAShapeLayer *circleLayer3 = [[CAShapeLayer alloc]init];
        circleLayer3.fillColor = [UIColor clearColor].CGColor;
        circleLayer3.strokeColor = RgbColor.CGColor;
        circleLayer3.path = bezierPath3.CGPath;
        circleLayer3.lineWidth = 2;
        
        [_CuisneCountLabel.layer addSublayer:circleLayer];
        [_CollectionCountLabel.layer addSublayer:circleLayer1];
        [_HotnessCountLabel.layer addSublayer:circleLayer2];
        [_CuisneTypeCountLabel.layer addSublayer:circleLayer3];
        
        // if selected category count is zero than hide the label
        if([[countOfEachCategoryArray objectAtIndex:0] intValue] == 0){
            _CuisneCountLabel.hidden = YES;
        }else{
            _CuisneCountLabel.text=[NSString stringWithFormat:@"%@",[countOfEachCategoryArray objectAtIndex:0]];
        }
        
        if([[countOfEachCategoryArray objectAtIndex:1] intValue] == 0){
            _CollectionCountLabel.hidden = YES;
        }else{
            _CollectionCountLabel.text=[NSString stringWithFormat:@"%@",[countOfEachCategoryArray objectAtIndex:1]];
        }
        
        if([[countOfEachCategoryArray objectAtIndex:2] intValue] == 0){
            _HotnessCountLabel.hidden = YES;
        }else{
            _HotnessCountLabel.text=[NSString stringWithFormat:@"%@",[countOfEachCategoryArray objectAtIndex:2]];
        }
        
        if([[countOfEachCategoryArray objectAtIndex:3] intValue] == 0){
            _CuisneTypeCountLabel.hidden = YES;
        }else{
            _CuisneTypeCountLabel.text=[NSString stringWithFormat:@"%@",[countOfEachCategoryArray objectAtIndex:3]];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self counterSelectedItems];
}

- (IBAction)ResetBtn:(UIButton *)sender {
    
    NSString *query = [NSString stringWithFormat:@"UPDATE FilterDetails SET status = '0'"];
    // Execute the query.
    [self.dbManager executeQuery:query];
    _CityTextField.text = @"";
    _LocalityTextField.text = @"";
    [self counterSelectedItems];
    
    FilterVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Filter"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)ApplyFilterBtn:(UIButton *)sender {
    
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.pageCheck = @"Apply Filter";
    [self.navigationController pushViewController:vc animated:YES];
    
}



#pragma mark - Auto Complete search
-(void)city
{
    textFieldCheck=@"city";
}

-(void)locality
{
    textFieldCheck=@"locality";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * proposedNewString;
    
    [self.view addSubview:searchTableView];
    searchTableView.hidden =NO;
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.scrollEnabled = YES;
    
    if(textField.tag == 1){
        _LocalityTextField.enabled = true;
        _LocalityTextField.backgroundColor = [UIColor whiteColor];
        searchTableView.frame = CGRectMake(_CityTextField.frame.origin.x, _CityTextField.frame.origin.y + 30, _CityTextField.bounds.size.width,_CityTextField.bounds.size.height + 100);
        
        proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    }
    
    if(textField.tag == 2){
        
        searchTableView.frame = CGRectMake(_LocalityTextField.frame.origin.x, _LocalityTextField.frame.origin.y + 30, _LocalityTextField.bounds.size.width,_LocalityTextField.bounds.size.height + 100);
        
        proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    }
    
    [self searchAutocompleteEntriesWithSubstring:proposedNewString];
    return true;
}

/// You make Text Field work as Search Bar here
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    NSArray *data;
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [filterData removeAllObjects];
    if (substring.length!=0) {
        if([textFieldCheck isEqualToString:@"city"]){
            
            // Storing all objects from sqlite database ******************** <--
            NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT UPPER(city) FROM CityAndLocation"];
            data = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
        }else{
            
            NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT UPPER(locality) FROM CityAndLocation where UPPER(city) = '%@'",[NSString stringWithFormat:@"%@",_CityTextField.text]];
            data = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
        }
        
        if(data.count !=0){
            for(int i =0 ; i < data.count ; i++) {
                
                NSString *str = [NSString stringWithFormat:@"%@",[[data objectAtIndex:i] objectAtIndex:0]];
                if( [[str lowercaseString] hasPrefix:[substring lowercaseString]]) {
                    [filterData addObject:str];
                }
            }
        }
        
        [searchTableView reloadData];
    }else{ // in case of blank text box, i am hiding table view. e.g zero character in city and locality text field.
        
        if([textFieldCheck isEqualToString:@"city"]){
            _LocalityTextField.enabled = NO; // disabling locality text field
            _LocalityTextField.backgroundColor = [UIColor lightGrayColor];
            _LocalityTextField.text = @"";
        }
        
        searchTableView.hidden = YES;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([textFieldCheck isEqualToString:@"city"]){
        _CityTextField.text = @"";
        _CityTextField.text = [filterData objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:_CityTextField.text forKey:@"cityOnFilter"];
        
    }else{
        _LocalityTextField.text = @"";
        _LocalityTextField.text = [filterData objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:_LocalityTextField.text forKey:@"localityOnFilter"];
    }
        //[searchTableView reloadData];
    searchTableView.hidden = YES;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(filterData.count != 0){
        return filterData.count;
    }
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    if (filterData.count!=0) {
        cell.textLabel.text = [filterData objectAtIndex:indexPath.row];
        
    }
    
    return cell;
}



// if return key pressed keyboard will automatically hide.
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    searchTableView.hidden = YES;
    return YES;
}


-(IBAction)tripleDot:(id)sender{
    
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


#pragma mark - search Methods


- (IBAction)searchAction:(UIButton *)sender {
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
    //[DataTAble reloadData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        isFiltered = false;
    }else{
        isFiltered = true;
        tableDataFilter = [[NSMutableArray alloc]init];
        
        // Handle as per requirement of search functionality.

    }
    
   // [DataTAble reloadData];
}

@end
