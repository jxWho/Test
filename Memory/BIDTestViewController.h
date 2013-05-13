//
//  BIDTestViewController.h
//  Memory
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BIDViewController;
@class BIDNonMultiViewController;
@interface BIDTestViewController : UIViewController


@property (strong, nonatomic) BIDViewController *viewController;
@property (strong, nonatomic) BIDNonMultiViewController *NonViewController;

- (IBAction)NonMulti:(id)sender;
- (IBAction)Multi:(id)sender;

@end
