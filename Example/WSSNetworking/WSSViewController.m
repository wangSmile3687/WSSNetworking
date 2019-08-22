//
//  WSSViewController.m
//  WSSNetworking
//
//  Created by smile on 08/22/2019.
//  Copyright (c) 2019 smile. All rights reserved.
//

#import "WSSViewController.h"
#import "AViewController.h"
@interface WSSViewController ()

@end

@implementation WSSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor cyanColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 30);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick {
    AViewController *vc = [[AViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
