//
//  WSSRequest.m
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//

#import "WSSRequest.h"
#import "WSSNetworkManager.h"
#import "WSSNetworkConfig.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@interface WSSRequest ()
@property (nonatomic, copy, readwrite)     NSString                    *requestUrl;
@property (nonatomic, copy, readwrite)     NSString                    *fullUrl;
@property (nonatomic, assign, readwrite)   NSTimeInterval              requestTimeoutInterval;
@property (nonatomic, assign, readwrite)   WSSRequestMethod            requestMethod;
@property (nonatomic, strong, readwrite)   id                          requestArgument;
@end
@implementation WSSRequest
- (void)dealloc {
    WSSLog(@"--dealloc---WSSRequest--------");
}
- (instancetype)initWithRequestMethod:(WSSRequestMethod)requestMethod fullUrl:(NSString *)fullUrlStr requestUrl:(NSString *)requestUrl requestArgument:(id)requestArgument {
    if (self = [super init]) {
        self.requestMethod = requestMethod;
        self.fullUrl = fullUrlStr;
        self.requestUrl = requestUrl;
        self.requestArgument = requestArgument;
        _requestSerializerType = WSSRequestSerializerTypeHTTP;
    }
    return self;
}
- (void)startRequestWithSuccess:(WSSRequestSuccessBlock)success failure:(WSSRequestFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    [self startRequest];
}
- (void)startRequest {
    [[WSSNetworkManager sharedManager] addRequest:self];
}
- (void)cancelRequest {
    self.delegate = nil;
    [[WSSNetworkManager sharedManager] cancelRequest:self];
}

#pragma mark - getter
- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}
- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}
- (NSURLRequest *)currentRequest {
    return self.requestTask.currentRequest;
}
- (NSURLRequest *)originalRequest {
    return self.requestTask.originalRequest;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } { method: %@ } { arguments: %@ }", NSStringFromClass([self class]), self, self.currentRequest.URL, self.currentRequest.HTTPMethod, self.requestArgument];
}
@end
