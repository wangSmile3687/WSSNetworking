//
//  WSSNetworkConfig.h
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//

#import <Foundation/Foundation.h>
#import "WSSNetworkProtocol.h"

FOUNDATION_EXPORT void WSSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@class AFSecurityPolicy;

@interface WSSNetworkConfig : NSObject
/// shared config
+ (WSSNetworkConfig *)sharedConfig;
/// baseURL ,http://www.example.com
@property (nonatomic, copy)     NSString                    *baseUrl;
/// timeout , defult    15s
@property (nonatomic, assign)   NSTimeInterval              timeoutInterval;
/// debug  log  ,defult NO
@property (nonatomic, assign)   BOOL                        debugLogEnabled;
/// securityPolicy
@property (nonatomic, strong)   AFSecurityPolicy            *securityPolicy;
/// sessionConfiguration
@property (nonatomic, strong)   NSURLSessionConfiguration   *sessionConfiguration;
/// unify handle
@property (nonatomic, weak)     id <WSSNetworkProtocol>      networkProtocol;
@end

