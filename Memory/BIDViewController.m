//
//  BIDViewController.m
//  Memory
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//
#import "BIDViewController.h"
#import "BIDView.h"
@interface BIDViewController ()
{
    NSLock *addProcessLock;
    BOOL flag;
}
@end

@implementation BIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES];
    flag = YES;
    addProcessLock = [[NSLock alloc]init];
    self.process = [[NSMutableArray alloc]init];
    NSTimer *timer;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timeHandle) userInfo:nil repeats:YES];
    
    self.checkProcessThread = [[NSThread alloc]initWithTarget:self selector:@selector(checkProcess) object:nil];
    self.addProcessThread = [[NSThread alloc]initWithTarget:self selector:@selector(addProcess) object:nil];
    
    [self.checkProcessThread start];
    [self.addProcessThread start];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    flag = NO;
}

- (void)checkProcess
{
    while (flag){
        if( [addProcessLock tryLock] ){
            NSLog(@"check") ;
            for( int i = 0; i < [self.process count]; i++ ){
                int tt = [[self.process[i] objectForKey:@"time"] intValue];
                tt --;
                NSNumber *newTime = [NSNumber numberWithInt:tt];
                NSMutableDictionary *dic = (NSMutableDictionary *)self.process[i];
                [dic setObject:newTime forKey:@"time"];
                
                //判断、移除线程
                if( tt == 0 ){
                    NSLog(@"remove");
                    int startIndex = [[self.process[i] objectForKey:@"startIndex"] intValue];
                    int lastIndex = [[self.process[i] objectForKey:@"lastIndex"] intValue];
                    
                    BIDView *bidView = (BIDView *)self.view;
                    for( int ii = startIndex; ii <= lastIndex; ii++ )
                        bidView.memory[ii] = @0;
                    
                }
            }
            //移除线程
            int CNT = [self.process count];
            for( int i = 0; i < CNT; i++ )
                for( int j = 0;j < [self.process count]; j++ ){
                    int tt = [[self.process[j] objectForKey:@"time"] intValue];
                    if( tt == 0 )
                        [self.process removeObjectAtIndex:j];
                }
            [addProcessLock unlock];
            sleep(1); //等待1秒
        }
    }
}

- (void)addProcess
{
    while (flag){
        if( [addProcessLock tryLock] ){
            NSLog(@"add");
            NSMutableDictionary *newProcess = [self createAProcess];
            int length = [[newProcess objectForKey:@"length"] intValue];
            
            BIDView *bidView = (BIDView *)self.view;
            int currentIndex = bidView.currentType.selectedSegmentIndex;
            
            int first = -1;
            int last = -1;
            NSDictionary *tempDic = nil;
            switch(currentIndex){
                case kFirst:
                    tempDic = [self firstMemoryWithLength:length];
                    if( tempDic != nil ){
                        first = [[tempDic objectForKey:@"firstIndex"] intValue];
                        last = [[tempDic objectForKey:@"lastIndex"] intValue];
                    }
                    break;
                case kWorst:
                    tempDic = [self WorstMemoryWithLength:length];
                    if( tempDic != nil ){
                        first = [[tempDic objectForKey:@"firstIndex"] intValue];
                        last = [[tempDic objectForKey:@"lastIndex"] intValue];
                    }
                    break;
                case kBest:
                    tempDic = [self BestMemoryWithLength:length];
                    if( tempDic != nil ){
                        first = [[tempDic objectForKey:@"firstIndex"] intValue];
                        last = [[tempDic objectForKey:@"lastIndex"] intValue];
                    }
                    break;
                default:
                    break;
            }
            if( first != -1 && last != -1 ){
                for( int i = first; i <= last; i++  )
                    bidView.memory[i] = @1;
                [newProcess setObject:[NSNumber numberWithInt:first] forKey:@"firstIndex"];
                [newProcess setObject:[NSNumber numberWithInt:last] forKey:@"lastIndex"];
                [self.process addObject:newProcess];
            }
            [addProcessLock unlock];
                
            sleep(1);
        }
    }
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

- (void)timeHandle
{
    BIDView *bidView =  (BIDView *)self.view;
    [bidView setNeedsDisplay];
    //    NSLog(@"reflesh");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)createAProcess
{
    static BOOL seeded = NO;
    if( !seeded ){
        seeded = YES;
        srandom(time(NULL));
    }
    NSNumber *length = [NSNumber numberWithInt:random() % 300 + 10];
    NSNumber *time = [NSNumber numberWithInt:random() % 10 + 5];
    
    NSLog(@"%@",length);
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:length,@"length",time,@"time", nil];
}

- (IBAction)Back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
