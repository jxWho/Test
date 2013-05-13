//
//  BIDTestViewController.m
//  Memory
//
//  Created by god on 13-5-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "BIDTestViewController.h"
#import "BIDViewController.h"
#import "BIDNonMultiViewController.h"

@interface BIDTestViewController ()

@end

@implementation BIDTestViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)NonMulti:(id)sender {
    self.NonViewController = [[BIDNonMultiViewController alloc]init];
    [self.navigationController pushViewController:self.NonViewController animated:YES];
}

- (IBAction)Multi:(id)sender {
    NSLog(@"111");
    self.viewController = [[BIDViewController alloc]init];
    [self.navigationController pushViewController:self.viewController animated:YES];
}
@end
