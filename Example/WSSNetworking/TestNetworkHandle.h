//
//  TestNetworkHandle.h
//  WSNetworking_Example
//
//  Created by smile on 2019/8/21.
//  Copyright © 2019 wangSmile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WSSNetworkConfig.h>

@interface TestNetworkHandle : NSObject <WSSNetworkProtocol>

+ (instancetype)sharedProtocol;

@end

