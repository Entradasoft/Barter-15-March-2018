//
//  HOMECELL.h
//  Barter
//
//  Created by iOS on 24/11/17.
//  Copyright © 2017 Nikhil Capsitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBAutoScrollLabel.h"
#import "ASStarRatingView.h"
@class ASStarRatingView;
@interface HOMECELL : UITableViewCell

// First Outlet
@property(nonatomic,strong)IBOutlet UIButton*Profile_img_Button;

@property(nonatomic,strong)IBOutlet UILabel*NameDish;
@property (weak, nonatomic) IBOutlet UILabel *FirstOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishPriceFirstOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishRatingFirstOulet;
@property (strong, nonatomic) IBOutlet UILabel *DishReviewFirstOutlet;
@property(nonatomic,strong)IBOutlet UIImageView*firstStar;
@property(nonatomic,strong)IBOutlet UIImageView*firstReview;
@property(nonatomic,strong)IBOutlet UIView *defaultView;
@property(nonatomic,strong)IBOutlet UIButton*firstOutletPlusBtn;


// Second Outlet

@property (weak, nonatomic) IBOutlet UILabel *SecondOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishPriceSecondOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishRatingSecondOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishReviewSecondOutlet;
@property(nonatomic,strong)IBOutlet UIImageView*secondStar;
@property(nonatomic,strong)IBOutlet UIImageView*secondReview;
@property (strong, nonatomic) IBOutlet UIView *secondView;
@property(nonatomic,strong)IBOutlet UIButton*secondOutletPlusBtn;

// Third outlet

@property (weak, nonatomic) IBOutlet UILabel *ThirdOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishPriceThirdOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishRatingThirdOutlet;
@property (strong, nonatomic) IBOutlet UILabel *DishReviewThirdOutlet;
@property (strong,nonatomic) IBOutlet UILabel  *FilterData;
@property(nonatomic,strong)IBOutlet UIImageView*thirdStar;
@property(nonatomic,strong)IBOutlet UIImageView*thirdReview;
@property (strong, nonatomic) IBOutlet UIView *thirdView;
@property(nonatomic,strong)IBOutlet UIButton*thirdOutletPlusBtn;

// Filter Page
@property (weak, nonatomic) IBOutlet UIButton *selectBoxButton;


// Select Dish
@property(nonatomic,strong)IBOutlet UIButton*infobtn;
@property (weak, nonatomic) IBOutlet UILabel *DishName;
@property (weak, nonatomic) IBOutlet UILabel *outletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletAvgRatingNCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletReviewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletDishPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletShortDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletLongDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletAvgRating;
@property (weak, nonatomic) IBOutlet UILabel *outletNumberOfPeopleRatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletFiveStarRatingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletFourStarRatingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletThreeStarRatingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletTwoStarRatingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletOneStarRatingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletShowAll;
@property (weak, nonatomic) IBOutlet UILabel *outletReviewDateAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *outletTopReviewDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *outletReviewerFirstCharacter;
@property (weak, nonatomic) IBOutlet UILabel *outletReviewerName;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *lessButton;

@property(nonatomic,strong)IBOutlet UIImageView*Dish_img;
@property(nonatomic,strong)IBOutlet UIImageView*starRateNReview;

@property(nonatomic,strong)IBOutlet UIImageView*reviewImg;
@property(nonatomic,strong)IBOutlet UIImageView*reviewBigIconImg;

@property (weak, nonatomic) IBOutlet UIProgressView *FirstProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *SecondProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *ThirdProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *FourthProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *FifthProgressView;
// ui View
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet ASStarRatingView *staticStarRatingView;
@property (retain, nonatomic) IBOutlet ASStarRatingView *topReviewerStarRatingView;

//// DataPopUp View
//@property (weak, nonatomic)IBOutlet UIView*popUpView;
//@property (weak, nonatomic)IBOutlet UIView*DataPopView;
//@property (weak, nonatomic) IBOutlet UILabel *outletAddress;
//@property (weak, nonatomic) IBOutlet UILabel *outletMobileNumber;
//@property (weak, nonatomic) IBOutlet UILabel *outletEmailId;
////@property (strong, nonatomic) IBOutlet UIScrollView *ScrollableOutletName;
//@property (weak, nonatomic) IBOutlet UILabel *OutletNameScrollLabel;

@end
