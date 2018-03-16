//
//  UIMarqueeLabel.h
//  ATimeOnline 2.0
//
//  Created by MMD Programmer 6 on 6/27/56 BE.
//  Copyright (c) 2556 MMD Programmer 6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMarqueeLabel : UILabel
{


    UILabel *textLabel;
    UILabel *phantomLabel;
    NSString *Contenttext;
    int delay;
    int fontSize;
    

}

-(void)setText:(NSString *)Text withAnimate:(BOOL )animate;
@property int delay;

@property BOOL isTextRun;
@property int Size;
@property(retain)UIColor *themetextColor;
@property(nonatomic,retain)UIFont *LabelFont;
@property float LoopSpace;
@end
