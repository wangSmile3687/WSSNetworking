//
//  AViewController.m
//  WSNetworking_Example
//
//  Created by smile on 2019/8/6.
//  Copyright © 2019 wangSmile. All rights reserved.
//

#import "AViewController.h"

#import <WSSRequest.h>

@interface AViewController ()<WSSRequestDelegate>

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    
    WSSRequest *request = [[WSSRequest alloc] initWithRequestMethod:WSSRequestMethodPOST fullUrl:nil requestUrl:@"XXX" requestArgument:@{@"page_num":@"1",@"page_size":@"20"}];
    [request startRequestWithSuccess:^(WSSRequest * _Nullable request) {
        NSLog(@"----------request   success------   %@",request.responseObject);

    } failure:^(WSSRequest * _Nullable request) {
        NSLog(@"----------request   failure------   %@",request.responseObject);
    }];
//    request.delegate = self;
//    [request startRequest];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [request cancelRequest];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    });
    
    
   
    
}
#pragma mark - WSSRequestDelegate

- (void)requestFailure:(WSSRequest *)request {
    
}
- (void)requestSuccess:(WSSRequest *)request {
}

- (void)dealloc {
    NSLog(@"----dealloc---------AViewController-------");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
