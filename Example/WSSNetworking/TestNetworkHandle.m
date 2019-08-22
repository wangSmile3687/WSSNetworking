//
//  TestNetworkHandle.m
//  WSNetworking_Example
//
//  Created by smile on 2019/8/21.
//  Copyright © 2019 wangSmile. All rights reserved.
//

#import "TestNetworkHandle.h"


@implementation TestNetworkHandle
+ (instancetype)sharedProtocol {
    static TestNetworkHandle *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[self alloc] init];
    });
    return handle;
}


//- (id)requestParameters:(id)parameters {//例如 统一处理参数加密
//    return nil;
//}
//- (id)resultSuccessResponseWithResult:(id)result { //例如 统一处理返回值解密
//    return nil;
//}

@end
