//
//  BIDView.m
//  MemoryHomework
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "BIDView.h"

@implementation BIDView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] ){
        self.currentColor = [UIColor greenColor];
        self.memory = [[NSMutableArray alloc]initWithCapacity:401];
        for( int i = 0; i < 401; i++ )
            [self.memory addObject:@0];
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width = 150;
    CGFloat height = 401;
    CGFloat WIDTH = [UIScreen mainScreen].bounds.size.width;
//    CGFloat HEIGHT = [UIScreen mainScreen].bounds.size.height;
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, self.currentColor.CGColor);

    CGRect currentRect = CGRectMake((WIDTH - width)/2, 10, width, height);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    int first = -1;
    int last = -1;
    for( int i = 0; i < [self.memory count]; i++ ){
        if( [self.memory[i] isEqual:@1] ){
            if (first == -1)
                first = i;
            else{
                if( i == ([self.memory count] - 1) || [self.memory[i + 1] isEqual: @0] )
                    last = i;
                if( last != -1 ){
                    //添加矩形
                    CGRect newRect = CGRectMake((WIDTH - width)/2, 10 + first , width, (last - first) );
                    CGContextAddRect(context, newRect);
                    CGContextDrawPath(context, kCGPathFillStroke);
                    
                    first = last = -1;
                }
            }
        }
    }
}

@end
