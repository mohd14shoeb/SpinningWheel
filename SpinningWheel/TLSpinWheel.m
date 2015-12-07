//
//  TLSpinWheel.m
//
//
//  Created by Phil Wright on 7/17/14.
//  Copyright (c) 2014 Touchopia, LLC. All rights reserved.
//

#import "TLSpinWheel.h"

@implementation TLSpinWheel {
    NSDate			*_lastTimerDate;
    CADisplayLink	*_displayTimer;
    double			_initialAngle;
    NSDate			*_previousTouchDate;
    CGFloat			_angularVelocity;
    UITouch			*_currentTouch;
    BOOL			_animating;
}

@synthesize angle = _angle;

- (void)startAnimating
{
    if (!_displayTimer && _enableSpinning) {
        if ([_delegate respondsToSelector:@selector(spinWheelDidStartSpinningFromInertia:)]) {
            [_delegate spinWheelDidStartSpinningFromInertia:self];
        }
        
        _isSpinning		= YES;
        _lastTimerDate	= nil;
        _displayTimer	= [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTimer)];
        [_displayTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAnimating
{
    if (_displayTimer) {
        if ([_delegate respondsToSelector:@selector(spinWheelDidStartSpinningFromInertia:)]) {
            [_delegate spinWheelDidFinishSpinning:self];
        }
        
        _isSpinning = NO;
        [_displayTimer invalidate];
        _displayTimer = nil;
    }
}

- (void)animationTimer
{
    if (!_lastTimerDate) {
        _lastTimerDate = [NSDate date];
    }
    else if (_lastTimerDate && (_angularVelocity == 0)) {
        _lastTimerDate = [NSDate date];
        [self stopAnimating];
    }
    else {
        NSTimeInterval passed = [[NSDate date] timeIntervalSinceDate:_lastTimerDate];
        
        double angleReduction = _drag * passed * ABS(_angularVelocity);
        
        if (_angularVelocity < 0) {
            _angularVelocity += angleReduction;
            
            if (_angularVelocity > 0) {
                _angularVelocity = 0;
            }
        } else if (_angularVelocity > 0) {
            _angularVelocity -= angleReduction;
            
            if (_angularVelocity < 0) {
                _angularVelocity = 0;
            }
        }
        
        if (ABS(_angularVelocity) < 0.01) {
            _angularVelocity = 0;
        }
        
        double useAngle = _angle;
        useAngle += _angularVelocity * passed;
        
        // limit useAngle to +/- 2*PI
        if (useAngle < 0) {
            while (useAngle < -2 * M_PI) {
                useAngle += 2 * M_PI;
            }
        } else {
            while (useAngle > 2 * M_PI) {
                useAngle -= 2 * M_PI;
            }
        }
        
        self.angle		= useAngle;
        _lastTimerDate	= [NSDate date];
        [self setNeedsDisplay];
    }
}

#pragma mark - touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL shouldReact = YES;
    
    if ([_delegate respondsToSelector:@selector(spinWheelShouldBeginTouch:)]) {
        shouldReact = [_delegate spinWheelShouldBeginTouch:self];
    }
    
    if (shouldReact && (!_currentTouch || (_currentTouch.phase == UITouchPhaseCancelled) || (_currentTouch.phase == UITouchPhaseEnded))) {
        _currentTouch		= [touches anyObject];
        _angularVelocity	= 0;
        _initialAngle		= _angle;
        _previousTouchDate	= [NSDate date];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        CGPoint touchPoint	= [_currentTouch locationInView:self];
        CGPoint prevPoint	= [_currentTouch previousLocationInView:self];
        
        CGFloat	touchAngle	= [self angleForPoint:touchPoint];
        CGFloat	prevAngle	= [self angleForPoint:prevPoint];
        
        _previousTouchDate = [NSDate date];
        
        CGFloat change = touchAngle - prevAngle;
        
        if (change > M_PI) {
            change -= 2 * M_PI;
        } else if (change < -M_PI) {
            change += 2 * M_PI;
        }
        self.angle += change;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches containsObject:_currentTouch]) {
        _angularVelocity	= [self calculateFinalAngularVelocity:_currentTouch];
        _previousTouchDate	= nil;
        [self startAnimating];
        _currentTouch = NULL;
    }
}

#pragma mark - Calculation

- (CGFloat)calculateFinalAngularVelocity:(UITouch *)touch
{
    CGFloat finalVelocity = 0;
    
    if (_previousTouchDate) {
        NSTimeInterval	delay		= [[NSDate date] timeIntervalSinceDate:_previousTouchDate];
        CGFloat			prevAngle	= [self angleForPoint:[touch previousLocationInView:self]];
        CGFloat			endAngle	= [self angleForPoint:[touch locationInView:self]];
        finalVelocity = (endAngle - prevAngle) / delay;
    }
    return finalVelocity;
}

- (void)setAngle:(CGFloat)angle
{
    [UIView animateWithDuration:0.8
                     animations:^{
                         _angle = angle;
                     }
                     completion:^(BOOL finished){
                     }];
    
    if ([_delegate respondsToSelector:@selector(spinWheelAngleDidChange:)]) {
        [_delegate spinWheelAngleDidChange:self];
    }
}

- (void)moveFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle
{
    NSLog(@"\n\nFrom: %.2f, To: %0.2f\n\n",fromAngle,toAngle);
    
    if(fromAngle>toAngle) {
        NSLog(@"left");
    }
    
    float ang = (fromAngle<toAngle) ? fromAngle : toAngle;
    
    for(float newAngle = ang;newAngle < toAngle; newAngle += .01) {
        [self setAngle:newAngle];
        NSLog(@"newAngle==%0.2f",newAngle);
    }
    
    [self setAngle:toAngle];
    
    if ([_delegate respondsToSelector:@selector(spinWheelAngleDidChange:)]) {
        [_delegate spinWheelAngleDidChange:self];
    }
}

- (CGFloat)angle
{
    return _angle;
}

- (CGFloat)angleForPoint:(CGPoint)point
{
    CGFloat angle = atan2(point.y - self.frame.size.height / 2, point.x - self.frame.size.width / 2);
    if (angle < 0) {
        angle += M_PI * 2;
    }
    return angle;
}

- (void)dealloc
{
    [self stopAnimating];
}

@end
