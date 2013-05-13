//
//  BIDView.h
//  MemoryHomework
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    kFirst = 0,
    kWorst,
    kBest,
}MemoryType;
@interface BIDView : UIView
@property (strong, nonatomic) UIColor *currentColor;
@property (strong, atomic)  NSMutableArray *memory;
@property (weak, nonatomic) IBOutlet UISegmentedControl *currentType;
@end
