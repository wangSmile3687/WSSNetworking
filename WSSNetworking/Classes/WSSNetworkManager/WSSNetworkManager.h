//
//  WSSNetworkManager.h
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//

#import <Foundation/Foundation.h>

@class WSSRequest;

@interface WSSNetworkManager : NSObject
/// shared manager
+ (WSSNetworkManager *)sharedManager;
/// add request and start request
- (void)addRequest:(WSSRequest *)request;
/// cancel request
- (void)cancelRequest:(WSSRequest *)request;
/// cancel all request
- (void)cancelAllRequest;

@end

