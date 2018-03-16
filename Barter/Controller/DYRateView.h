#import <UIKit/UIKit.h>
@protocol DYRateViewDelegate;
typedef enum {
    RateViewAlignmentLeft,
    RateViewAlignmentCenter,
    RateViewAlignmentRight
} RateViewAlignment;


@interface DYRateView : UIView {
    UIImage *_fullStarImage;
    UIImage *_emptyStarImage;
    CGPoint _origin;
    NSInteger _numOfStars;
}

@property(nonatomic, assign) RateViewAlignment alignment;
@property(nonatomic, assign) CGFloat rate;
@property(nonatomic, assign) CGFloat padding;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, retain) UIImage *fullStarImage;
@property(nonatomic, retain) UIImage *emptyStarImage;
@property(nonatomic, assign) NSObject<DYRateViewDelegate> *delegate;

- (DYRateView *)initWithFrame:(CGRect)frame;
- (DYRateView *)initWithFrame:(CGRect)rect fullStar:(UIImage *)fullStarImage emptyStar:(UIImage *)emptyStarImage;

@end

@protocol DYRateViewDelegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate;

@end
