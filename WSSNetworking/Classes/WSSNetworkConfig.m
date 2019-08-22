//
//  WSSNetworkConfig.m
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//

#import "WSSNetworkConfig.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

void WSSLog(NSString *format, ...) {
#ifdef DEBUG
    if (![WSSNetworkConfig sharedConfig].debugLogEnabled) {
        return;
    }
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}
@implementation WSSNetworkConfig
+ (WSSNetworkConfig *)sharedConfig {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    if (self = [super init]) {
        _baseUrl = @"";
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _debugLogEnabled = NO;
        _timeoutInterval = 15;
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ baseURL: %@ }", NSStringFromClass([self class]), self, self.baseUrl];
}
@end
