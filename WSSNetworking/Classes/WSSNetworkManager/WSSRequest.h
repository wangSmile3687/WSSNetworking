//
//  WSSRequest.h
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//

#import <Foundation/Foundation.h>

#import "WSSNetworkProtocol.h"

/// HTTP Request method
typedef NS_ENUM(NSInteger, WSSRequestMethod) {
    WSSRequestMethodGET = 0,
    WSSRequestMethodPOST,
    WSSRequestMethodPUT,
    WSSRequestMethodDELETE,
};
/// request Serializer Type
typedef NS_ENUM(NSInteger, WSSRequestSerializerType) {
    WSSRequestSerializerTypeHTTP = 0,
    WSSRequestSerializerTypeJSON,
};
/// response Serializer Type
typedef NS_ENUM(NSInteger, WSSResponseSerializerType) {
    WSSResponseSerializerTypeHTTP,
    WSSResponseSerializerTypeJSON,
    WSSResponseSerializerTypeXML,
};
/// request Priority
typedef NS_ENUM(NSInteger, WSSRequestPriority) {
    WSSRequestPriorityLow = -4L,
    WSSRequestPriorityDefault = 0,
    WSSRequestPriorityHigh = 4,
};
@class WSSRequest;
@protocol WSSRequestDelegate <NSObject>
@optional
/// the delegate request success
- (void)requestSuccess:(WSSRequest *_Nullable)request;
/// the delegate request failure
- (void)requestFailure:(WSSRequest *_Nullable)request;
@end
typedef void(^WSSRequestSuccessBlock)(WSSRequest * _Nullable request);
typedef void(^WSSRequestFailureBlock)(WSSRequest * _Nullable request);
@interface WSSRequest : NSObject
/// init reques
/// @param requestMethod request method
/// @param fullUrlStr full url
/// @param requestUrl path url
/// @param requestArgument  Argument
- (instancetype _Nullable )initWithRequestMethod:(WSSRequestMethod)requestMethod
                                         fullUrl:(NSString *_Nullable)fullUrlStr
                                      requestUrl:(NSString *_Nullable)requestUrl
                                 requestArgument:(id _Nullable )requestArgument;
/// start request and block callback
- (void)startRequestWithSuccess:(WSSRequestSuccessBlock _Nullable )success
                        failure:(WSSRequestFailureBlock _Nullable )failure;
/// start request and  delegate callback
- (void)startRequest;
/// cancel request
- (void)cancelRequest;
/// the delegate of the result
@property (nonatomic, weak, nullable)     id <WSSRequestDelegate>      delegate;
@property (nonatomic, weak, nullable)     id <WSSNetworkProtocol>      networkProtocol;
/// success callback
@property (nonatomic, copy, nullable)     WSSRequestSuccessBlock       successBlock;
/// failure callback
@property (nonatomic, copy, nullable)     WSSRequestFailureBlock       failureBlock;
/// request Serializer Type
@property (nonatomic, assign)             WSSRequestSerializerType     requestSerializerType;
/// response Serializer Type
@property (nonatomic, assign)             WSSResponseSerializerType    responseSerializerType;
/// request method
@property (nonatomic, assign)             WSSRequestPriority           requestPriority;
/// identify request.
@property (nonatomic, assign)             NSInteger                    tag;
/// baseURL ,http://www.example.com
@property (nonatomic, copy, nullable)     NSString                    *baseUrl;
/// Additional HTTP request header field
@property (nonatomic, strong, nullable)   NSDictionary                *requestHeaderFieldValueDictionary;
/// The underlying NSURLSessionTask.
@property (nonatomic, strong, nullable)   NSURLSessionTask            *requestTask;
/// This serialized response object.
@property (nonatomic, strong, nullable)   id                          responseObject;
/// This error can be either serialization error or network error
@property (nonatomic, strong, nullable)   NSError                     *error;
#pragma mark - readonly
/// timeout
@property (nonatomic, assign, readonly)   NSTimeInterval              requestTimeoutInterval;
/// request method
@property (nonatomic, assign, readonly)   WSSRequestMethod             requestMethod;
/// path url  ,  /v1/example
@property (nonatomic, copy, readonly, nullable)     NSString          *requestUrl;
/// Complete url ,http://www.example.com/v1/exmaple
@property (nonatomic, copy, readonly, nullable)     NSString          *fullUrl;
/// Additional request argument
@property (nonatomic, strong, readonly, nullable)   id                requestArgument;
/// Shortcut for `requestTask.currentRequest`.
@property (nonatomic, strong, readonly, nullable)   NSURLRequest      *currentRequest;
/// Shortcut for `requestTask.originalRequest`.
@property (nonatomic, strong, readonly, nullable)   NSURLRequest      *originalRequest;
/// Shortcut for `requestTask.response`
@property (nonatomic, strong, readonly, nullable)   NSHTTPURLResponse *response;
/// The response header fields.
@property (nonatomic, strong, readonly, nullable)   NSDictionary      *responseHeaders;
@end

