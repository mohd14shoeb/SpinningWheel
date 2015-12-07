//
//  Constants.h
//  DaisyWheel
//
//  Created by Phil Wright on 7/18/14.
//  Copyright (c) 2014 Touchopia, LLC. All rights reserved.
//

#define NSLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960),[[UIScreen mainScreen] currentMode].size) : NO)

#define kDaisyWheelPic @"daisywheel.jpeg"
#define kDaisyWheelInvitationText @"Check out daisy wheel"
#define kDaisyWheelItunesUrl @"https://itunes.apple.com/in/app/daisy-wheel/id443767214?mt=8"

// Permssions and Defaults
#define kFirstRun       @"firstRun"
#define kAlertsAllowed  @"AlertsAllowed"
#define kReminderMessage    @"ReminderMessage"
#define kTapSoundFile		@"click.mp3"
#define kDefaultFont        @"Lato-Reg"
#define kDefaultFontSize    16.0f

#define is_iPad     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)