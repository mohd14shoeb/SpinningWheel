//
//  TLImageView.h
//
//
//  Created by Phil Wright on 7/17/14.
//  Copyright (c) 2014 Touchopia, LLC. All rights reserved.
//

#import "TLSpinWheel.h"

@interface TLImageView : TLSpinWheel

@property UIImage *image;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)anImage;
@end
