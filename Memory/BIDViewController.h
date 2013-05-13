//
//  BIDViewController.h
//  Memory
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BIDViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *process;
@property (strong, nonatomic) NSThread *checkProcessThread;
@property (strong, nonatomic) NSThread *addProcessThread;

- (IBAction)Back:(id)sender;
@end
