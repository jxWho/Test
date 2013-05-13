//
//  BIDNonMultiViewController.m
//  Memory
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "BIDNonMultiViewController.h"
#import "BIDView.h"

@interface BIDNonMultiViewController ()

@end

@implementation BIDNonMultiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    
    [self resetView];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"说明" message:@"为了能够检验算法的正确性，预先非配好了一些内存，然后使用不同的分配算法(toolbar中可以选择)来放进同一个大小为30的线程(按start开始)" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    
}

- (void)resetView
{
    BIDView *bidView = (BIDView *)self.view;
    // 0 - 50空闲
    // 51 - 110 占有
    // 111 - 300 空闲
    // 300 - 359 占有
    //360 - 401 空闲
    for( int i = 0; i < [bidView.memory count]; i++ ){
        if( i >= 0 && i <= 50 )
            bidView.memory[i] = @0;
        else if( i > 50 && i <= 110 )
            bidView.memory[i] = @1;
        else if( i > 110 && i <= 300 )
            bidView.memory[i] = @0;
        else if( i > 300 && i <= 359 )
            bidView.memory[i] = @1;
        else
            bidView.memory[i] = @0;
    }
    [bidView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSDictionary *)firstMemoryWithLength:(int)length
{
    BIDView *bidView = (BIDView *)self.view;
    
    //First Fit
    int first = -1;
    int last = -1;
    for( int i = 0; i < [bidView.memory count]; i++ ){
        if( [bidView.memory[i] isEqual:@0] ){
            if( first == -1 ){
                first = i;
            }else{
                //到达内存末尾了
                if( i == ([bidView.memory count] - 1) ){
                    if( first + length > i )
                        first = last = -1;
                    else{
                        last = i;
                        break;
                    }
                }
                //得到了一个hole
                else if( [bidView.memory[i + 1] isEqual:@1] ){
                    if( (first + length) > i ){
                        //这一块内存太小了
                        first = last = -1;
                    }else{
                        last = i;
                        break;
                    }
                }else{
                    //在连续free内存中已经找到了足够大的
                    if( (first + length) <= i ){
                        last = i;
                        break;
                    }
                }
            }
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:first],@"firstIndex",[NSNumber numberWithInt:last],@"lastIndex", nil];
    
}

- (NSDictionary *)WorstMemoryWithLength:(int)length
{
    BIDView *bidView = (BIDView *)self.view;
    int first = -1;
    int last = -1;
    NSMutableArray *avalibleMemory = [[NSMutableArray alloc]init];
    for( int i = 0; i < [bidView.memory count]; i++ ){
        if( [bidView.memory[i] isEqual:@0] ){
            if( first == -1 )
                first = i;
            else{
                //走到了内存的尽头或者这是一个hole
                if( i == ([bidView.memory count] - 1) || [bidView.memory[i + 1] isEqual:@1] ){
                    //内存不够大
                    if( first + length > i )
                        last = first = -1;
                    else{
                        last = i;
                        NSDictionary *newMemory = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:first],@"firstIndex",[NSNumber numberWithInt:last],@"lastIndex", nil];
                        [avalibleMemory addObject:newMemory];
                        //继续寻找下一个hole
                        first = last = -1;
                    }
                }
            }
        }
    }
    NSDictionary *maxMemory = nil;
    int maxLength = 0;
    for( int i = 0; i < [avalibleMemory count]; i++ ){
        int tempFirst = [[avalibleMemory[i] objectForKey:@"firstIndex"] intValue];
        int tempLast = [[avalibleMemory[i] objectForKey:@"lastIndex"] intValue];
        int newLength = tempLast - tempFirst;
        if( newLength > maxLength ){
            maxLength = newLength;
            maxMemory = avalibleMemory[i];
        }
    }
    int tempFirst =  - 1;
    int tempLast = -1;
    if( [avalibleMemory count] >0 ){
        tempFirst = [[maxMemory objectForKey:@"firstIndex"] intValue];
        tempLast = tempFirst + length;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tempFirst],@"firstIndex",[NSNumber numberWithInt:tempLast],@"lastIndex", nil];
}

- (NSDictionary *)BestMemoryWithLength:(int)length
{
    BIDView *bidView = (BIDView *)self.view;
    int first = -1;
    int last = -1;
    NSMutableArray *avalibleMemory = [[NSMutableArray alloc]init];
    for( int i = 0; i < [bidView.memory count]; i++ ){
        if( [bidView.memory[i] isEqual:@0] ){
            if( first == -1 )
                first = i;
            else{
                //走到了内存的尽头或者这是一个hole
                if( i == ([bidView.memory count] - 1) || [bidView.memory[i + 1] isEqual:@1] ){
                    //内存不够大
                    if( first + length > i )
                        last = first = -1;
                    else{
                        last = i;
                        NSDictionary *newMemory = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:first],@"firstIndex",[NSNumber numberWithInt:last],@"lastIndex", nil];
                        [avalibleMemory addObject:newMemory];
                        //继续寻找下一个hole
                        first = last = -1;
                    }
                }
            }
        }
    }
    NSDictionary *minMemory = nil;
    int minLength = 5000;
    for( int i = 0; i < [avalibleMemory count]; i++ ){
        int tempFirst = [[avalibleMemory[i] objectForKey:@"firstIndex"] intValue];
        int tempLast = [[avalibleMemory[i] objectForKey:@"lastIndex"] intValue];
        int newLength = tempLast - tempFirst;
        if( newLength < minLength ){
            minLength = newLength;
            minMemory = avalibleMemory[i];
        }
    }

    int tempFirst =  - 1;
    int tempLast = -1;
    if( [avalibleMemory count] >0 ){
        tempFirst = [[minMemory objectForKey:@"firstIndex"] intValue];
        tempLast = tempFirst + length;
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tempFirst],@"firstIndex",[NSNumber numberWithInt:tempLast],@"lastIndex", nil];
}

#pragma mark - Button Methods
- (IBAction)startMemory:(id)sender {
    NSLog(@"start");
    BIDView *bidView = (BIDView *)self.view;
    int currentInde = [bidView.currentType selectedSegmentIndex];
    NSLog(@"%d",currentInde);
    
    int length = 30;
    int first = -1;
    int last = -1;
    NSDictionary *tempDic = nil;
    switch (currentInde) {
        case kFirst:
            tempDic = [self firstMemoryWithLength:length];
            if( tempDic ){
                first = [[tempDic objectForKey:@"firstIndex"] intValue];
                last = [[tempDic objectForKey:@"lastIndex"] intValue];
            }
            break;
        case kWorst:
            tempDic = [self WorstMemoryWithLength:length];
            if( tempDic ){
                first = [[tempDic objectForKey:@"firstIndex"] intValue];
                last = [[tempDic objectForKey:@"lastIndex"] intValue];
            }
            break;
        case kBest:
            tempDic = [self BestMemoryWithLength:length];
            if( tempDic ){
                first = [[tempDic objectForKey:@"firstIndex"] intValue];
                last = [[tempDic objectForKey:@"lastIndex"] intValue];
            }
            break;
        default:
            break;
    }
    if( last != -1 && first != -1 ){
        NSLog(@"%d %d",last, first);
        NSLog(@"%@",bidView.memory[first]);
        for( int i = first; i <= last; i++ )
            bidView.memory[i] = @1;
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"失败" message:@"内存不足" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    [bidView setNeedsDisplay];
}

- (IBAction)Back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeModel:(id)sender {
    [self resetView];
}
@end
