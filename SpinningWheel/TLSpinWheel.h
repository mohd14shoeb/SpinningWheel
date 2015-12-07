//
//  TLSpinWheel.h
//
//
//  Created by Phil Wright on 7/17/14.
//  Copyright (c) 2014 Touchopia, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TLSpinWheel;

@protocol TLSpinWheelDelegate <NSObject>
@optional
- (void)spinWheelDidStartSpinningFromInertia:(TLSpinWheel *)spinWheel;
- (void)spinWheelDidFinishSpinning:(TLSpinWheel *)spinWheel;
- (void)spinWheelAngleDidChange:(TLSpinWheel *)spinWheel;
- (BOOL)spinWheelShouldBeginTouch:(TLSpinWheel *)spinWheel;
@end

@interface TLSpinWheel : UIView
@property BOOL enableSpinning;

- (void)moveFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle;

@property (nonatomic, assign, readonly) BOOL isSpinning;
@property (nonatomic, weak) id <TLSpinWheelDelegate> delegate;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat drag;

@end
