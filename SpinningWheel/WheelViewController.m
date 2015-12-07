//
//  ViewController.m
//  DaisyWheel
//
//  Created by Phil Wright on 7/17/14.
//  Copyright (c) 2014 Touchopia, LLC. All rights reserved.
//

#import "WheelViewController.h"
#import "TLImageView.h"
#import "SoundManager.h"
#import "Constants.h"
#import "Math.h"
#import "AppDelegate.h"

@interface WheelViewController () <TLSpinWheelDelegate>

- (void)playClick;

@property (strong, nonatomic) UIImageView *tipImage;
@end

@implementation WheelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    [self.view setFrame:screenBounds];
    self.tipImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 86, 320, 196)];
    
    [self.tipImage setUserInteractionEnabled: false];
    
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    CGRect wheelFrame = CGRectMake(10, 230, 300, 300);
    self.tipImage.frame = CGRectMake(0, 86, 320, 196);
    

    if (is_iPad) {
        wheelFrame = CGRectMake(200,100, 600,600);
        self.tipImage.frame = CGRectMake(650, 160, 354, 490);
    }
    
    self.tipImage.center = CGPointMake(self.view.frame.size.width/2, 180);

    
    UIImage *wheelCover = [UIImage imageNamed:@"wheelCover"];
    UIImage *wheelTips	= [UIImage imageNamed:@"wheelTips" ];
    
    
    [self showTipNumber:1];
    
    
    // Wheel tips
    TLImageView *imageWheel = [[TLImageView alloc] initWithFrame:wheelFrame image:wheelTips];
    
    imageWheel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    imageWheel.delegate			= self;
    imageWheel.enableSpinning	= YES;
    
    // Set drag of the spinning wheel
    imageWheel.drag = 2;
    
    [self.view addSubview:imageWheel];
    
    
    // Wheel Cover
    TLImageView *wheelImgView = [[TLImageView alloc] initWithFrame:wheelFrame image:wheelCover];
    wheelImgView.userInteractionEnabled = NO;
    if (is_iPad) {
        wheelImgView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    
    wheelImgView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    
    [self.view addSubview:wheelImgView];
    [self.view addSubview:self.tipImage];
}

-(void)showReminderMessage
{
}


-(void)playClick
{
    [[SoundManager sharedManager] playSound:@"click" looping:NO];
}

#pragma mark - Wheel Delegate Methods

- (BOOL)spinWheelShouldBeginTouch:(TLSpinWheel *)spinWheel
{
    [self.tipImage setHidden:YES];
    [self playClick];
    return YES;
}

- (void)spinWheelDidStartSpinningFromInertia:(TLSpinWheel *)spinWheel
{
    [self playClick];
}

- (void)spinWheelDidFinishSpinning:(TLSpinWheel *)spinWheel
{
    float ceilValue = ceil(fabs(spinWheel.angle));
    float floorValue = floor(fabs(spinWheel.angle));
   
    // stop clicks
    //[self playClick];

    [[SoundManager sharedManager] stopAllSounds];
    
    int rounded = 0;
    float calculatedFloorValue;
    float calculatedCeilValue;
    
    calculatedFloorValue =  (fabs(floorValue))*0.78 + 0.39;
    calculatedCeilValue  =  (fabs(ceilValue))*0.78 + 0.39;
    
    NSLog(@"Calculated Floor Value : %0.02f",calculatedFloorValue);
    NSLog(@"Calculated ceil Value : %0.02f",calculatedCeilValue);

    if (fabs(spinWheel.angle)> calculatedFloorValue && fabs(spinWheel.angle) > calculatedCeilValue) {
        rounded = ceilValue + 1;
       // NSLog(@"Both Greater");
    }
    else if (fabs(spinWheel.angle ) > calculatedFloorValue && fabs(spinWheel.angle ) < calculatedCeilValue) {
        if ((fabs(spinWheel.angle) - calculatedFloorValue) > (calculatedCeilValue - (fabs(spinWheel.angle)))) {
            rounded = ceilValue;
        } else {
            rounded = floorValue;
        }
        //NSLog(@"Greater than Floor and Less than Ceil");
    }
    else if (fabs(spinWheel.angle )< calculatedFloorValue) {
        rounded = floorValue;
        NSLog(@"Less than Ceil");
    }
    
    if (spinWheel.angle < 0) {
        rounded = -rounded;
    }
    
    CGFloat newAngle = rounded * 0.78;
    
    [spinWheel moveFromAngle:spinWheel.angle toAngle:newAngle];

    if (rounded >= 0) {
        NSLog(@"Use Tip postive: %d", rounded + 1);
        [self showTipNumber:rounded + 1];
    } else if (rounded < 0) {
        NSLog(@"Use Tip negative: %d", 9 + rounded);
        [self showTipNumber:rounded + 9];
    }
}

- (void)spinWheelAngleDidChange:(TLSpinWheel *)spinWheel
{
    NSLog(@"Moving Angle : %0.02f",spinWheel.angle);
}

- (void)showTipNumber:(int)number
{
    [self.tipImage setHidden:NO];
    
    NSString	*tipImageString = [NSString stringWithFormat:@"i_tip-%d.png", number];
    if (is_iPad) {
        tipImageString = [NSString stringWithFormat:@"tip-%d-ipadhd.png", number];
    }
    UIImage		*tip = [UIImage imageNamed:tipImageString];
    [self.tipImage setImage:tip];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
