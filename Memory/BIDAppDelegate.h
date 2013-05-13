//
//  BIDAppDelegate.h
//  Memory
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDViewController;
@class BIDTestViewController;

@interface BIDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BIDTestViewController *viewController;

@end
