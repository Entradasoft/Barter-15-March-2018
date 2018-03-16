//
//  UIMarqueeLabel.m
//  ATimeOnline 2.0
//
//  Created by MMD Programmer 6 on 6/27/56 BE.
//  Copyright (c) 2556 MMD Programmer 6. All rights reserved.
//

#import "UIMarqueeLabel.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIMarqueeLabel
@synthesize LabelFont = _LabelFont;
@synthesize delay;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     _isTextRun = YES;
        Contenttext = self.text;
        self.delay = 3;
        self.text = @"";
    } 
    return self;
}

-(void)awakeFromNib{
    
    _isTextRun = YES;
    Contenttext = self.text;
    self.delay = 3;
    [self setNeedsDisplay];
}
-(void)setText:(NSString *)Text withAnimate:(BOOL )animate{
    self.text = Text;
    [textLabel removeFromSuperview];
    [phantomLabel removeFromSuperview];
    textLabel = nil;
    phantomLabel = nil;
    [self setNeedsDisplay];
}
-(void)setFontSize:(int)Size{
    self.fontSize = 12;
    [self setNeedsDisplay];
}
-(void)setFont:(UIFont *)font{

    _LabelFont = [UIFont systemFontOfSize:12];
    [self setNeedsDisplay];    
}
- (void)drawRect:(CGRect)rect
{
    self.clipsToBounds = YES;
    Contenttext = self.text;
    self.backgroundColor = [UIColor clearColor];
    if(!textLabel){
    textLabel = [[UILabel alloc]initWithFrame:rect];
    phantomLabel = [[UILabel alloc]initWithFrame:rect];
    }else{
        
        textLabel.frame = rect;
        phantomLabel.frame = rect;
    }
    _themetextColor = self.textColor;
    textLabel.backgroundColor = [UIColor clearColor];
     phantomLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = _themetextColor;
    phantomLabel.textColor = _themetextColor;
    textLabel.numberOfLines = 1;
    phantomLabel.numberOfLines =1;

    [textLabel setText:Contenttext];
    [phantomLabel setText:Contenttext];
    textLabel.font=[UIFont systemFontOfSize:12];
    [phantomLabel setFont:_LabelFont];
    [phantomLabel sizeToFit];    
    [textLabel sizeToFit];
    float textmargin = 0;
    if(_LoopSpace == 0.0)
      _LoopSpace = 30.0;
    
    if(textLabel.frame.size.width < self.frame.size.width){
        _LoopSpace = 0;
        textmargin = self.frame.size.width - textLabel.frame.size.width;//NSLog(@"%f",textmargin);
    }
    CGRect frame = textLabel.frame;
    frame.origin.y = rect.size.height/2 - textLabel.frame.size.height/2;
    textLabel.frame = frame;
    CGRect phantomframe = frame;
    phantomframe.origin.x = textLabel.frame.origin.x + textLabel.frame.size.width + (_LoopSpace+textmargin);
    phantomLabel.frame = phantomframe;
    [self addSubview:textLabel];
    [self addSubview:phantomLabel];
   if(textLabel.frame.size.width > self.frame.size.width)
        [self startAnimate:25];
 
}

-(void)startAnimate:(float)velocity{

    float textmargin = 0;
    if(textLabel.frame.size.width < self.frame.size.width){
        textmargin = self.frame.size.width - textLabel.frame.size.width;
    }
    CGRect textFrame = textLabel.frame;
        textFrame.origin.x = -textFrame.size.width - _LoopSpace - textmargin;
    CGRect phantomtextFrame = textFrame;
    phantomtextFrame.origin.x = textFrame.size.width + textFrame.origin.x + (_LoopSpace+textmargin); 
    float time = ((textFrame.size.width + textmargin )) / velocity;
     [UIView animateWithDuration:time delay:delay options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear) animations:^(){
        textLabel.frame = textFrame;
        phantomLabel.frame = phantomtextFrame;
    } completion:^(BOOL fin){}];

}
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    [super drawLayer:layer inContext:ctx];
}
-(void)startAnimateParallax{
    int time = ( (arc4random() % (300-100+1)) + 100 );
    [self startAnimate:time];
}

@end
