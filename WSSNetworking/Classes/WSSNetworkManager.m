//
//  WSSNetworkManager.m
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//

#import "WSSNetworkManager.h"
#import "WSSRequest.h"
#import "WSSNetworkConfig.h"
#import <pthread/pthread.h>
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)
@implementation WSSNetworkManager{
    AFHTTPSessionManager *_manager;
    WSSNetworkConfig *_config;
    AFJSONResponseSerializer *_jsonResponseSerializer;
    AFXMLParserResponseSerializer *_xmlParserResponseSerialzier;
    dispatch_queue_t _processingQueue;
    pthread_mutex_t _lock;
    WSSRequestMethod _requestMethod;
    NSString *_fullUrlStr;
    NSString *_pathStr;
    NSDictionary *_params;
    NSMutableDictionary<NSNumber *, WSSRequest *> *_requestsRecord;
}
+ (WSSNetworkManager *)sharedManager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    if (self = [super init]) {
        _config = [WSSNetworkConfig sharedConfig];
        _requestsRecord = [NSMutableDictionary new];
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_config.sessionConfiguration];
        _processingQueue = dispatch_queue_create("com.smile.networkManager.processing", DISPATCH_QUEUE_CONCURRENT);
        pthread_mutex_init(&_lock, NULL);
        _manager.securityPolicy = _config.securityPolicy;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.completionQueue = _processingQueue;
    }
    return self;
}
- (void)cancelRequest:(WSSRequest *)request {
    NSParameterAssert(request != nil);
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    [self clearCompletionBlock:request];
}
- (void)cancelAllRequest {
    Lock();
    NSArray *allKeys = [_requestsRecord allKeys];
    Unlock();
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            Lock();
            WSSRequest *request = _requestsRecord[key];
            Unlock();
            [request cancelRequest];
        }
    }
}
- (void)addRequest:(WSSRequest *)request {
    NSParameterAssert(request != nil);
    NSError * __autoreleasing requestSerializationError = nil;
    if (!request.networkProtocol) {
        request.networkProtocol = _config.networkProtocol;
    }
    request.requestTask = [self sessionTaskForRequest:request error:&requestSerializationError];
    if (requestSerializationError) {
        [self requestDidFailWithRequest:request error:requestSerializationError];
        return;
    }
    NSAssert(request.requestTask != nil, @"requestTask should not be nil");
    if ([request.requestTask respondsToSelector:@selector(priority)]) {
        switch (request.requestPriority) {
            case WSSRequestPriorityHigh:
                request.requestTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            case WSSRequestPriorityLow:
                request.requestTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case WSSRequestPriorityDefault:
                /*!!fall through*/
            default:
                request.requestTask.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    [self addRequestToRecord:request];
    [request.requestTask resume];
}
- (NSURLSessionTask *)sessionTaskForRequest:(WSSRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    WSSRequestMethod method = request.requestMethod;
    id params = request.requestArgument;
    if ([request.networkProtocol respondsToSelector:@selector(requestParameters:)]) {
        params = [request.networkProtocol requestParameters:params];
    }
    NSString *urlStr = [self buildRequestUrl:request];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    switch (method) {
        case WSSRequestMethodGET:
            return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:urlStr parameters:params error:error];
        case WSSRequestMethodPOST:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:urlStr parameters:params error:error];
        case WSSRequestMethodPUT:
            return [self dataTaskWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:urlStr parameters:params error:error];
        case WSSRequestMethodDELETE:
            return [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:urlStr parameters:params error:error];
    }
}
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleRequestResult:dataTask responseObject:responseObject error:error];
    }];
    return dataTask;
}
- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    Lock();
    WSSRequest *request = _requestsRecord[@(task.taskIdentifier)];
    Unlock();
    if (!request) {
        return;
    }
    NSError * __autoreleasing serializationError = nil;
    NSError *requestError = nil;
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        request.responseObject = [[NSString alloc] initWithData:responseObject encoding:[self stringEncodingWithRequest:request]];
        switch (request.responseSerializerType) {
            case WSSResponseSerializerTypeHTTP:
                break;
            case WSSResponseSerializerTypeJSON:
                request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response data:responseObject error:&serializationError];
                break;
            case WSSResponseSerializerTypeXML:
                request.responseObject = [self.xmlParserResponseSerialzier responseObjectForResponse:task.response data:responseObject error:&serializationError];
                break;
        }
    }
    if (serializationError) {
        requestError = serializationError;
    } else if (error) {
        requestError = error;
    }
    if (requestError) {
        if ([request.networkProtocol respondsToSelector:@selector(resultFailureResponseWithResult:)]) {
            request.responseObject = [request.networkProtocol resultFailureResponseWithResult:request.responseObject];
        }
        [self requestDidFailWithRequest:request error:requestError];
    } else {
        if ([request.networkProtocol respondsToSelector:@selector(resultSuccessResponseWithResult:)]) {
            request.responseObject = [request.networkProtocol resultSuccessResponseWithResult:request.responseObject];
        }
        [self requestDidSucceedWithRequest:request];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
        [self clearCompletionBlock:request];
    });
}
- (void)requestDidSucceedWithRequest:(WSSRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.delegate != nil) {
            [request.delegate requestSuccess:request];
        }
        if (request.successBlock) {
            request.successBlock(request);
        }
    });
}

- (void)requestDidFailWithRequest:(WSSRequest *)request error:(NSError *)error {
    request.error = error;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.delegate != nil) {
            [request.delegate requestFailure:request];
        }
        if (request.failureBlock) {
            request.failureBlock(request);
        }
    });
}
- (NSStringEncoding)stringEncodingWithRequest:(WSSRequest *)request {
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (request.response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)request.response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}
- (void)addRequestToRecord:(WSSRequest *)request {
    Lock();
    _requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    Unlock();
}
- (void)removeRequestFromRecord:(WSSRequest *)request {
    Lock();
    [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    WSSLog(@"Request queue size = %zd", [_requestsRecord count]);
    Unlock();
}
- (void)clearCompletionBlock:(WSSRequest *)request {
    request.successBlock = nil;
    request.failureBlock = nil;
}
- (NSString *)buildRequestUrl:(WSSRequest *)request {
    NSParameterAssert(request != nil);
    NSString *fullUrlStr = request.fullUrl;
    NSURL *fullUrl = [NSURL URLWithString:fullUrlStr];
    if (fullUrl && fullUrl.host && fullUrl.scheme) {
        WSSLog(@"full url: %@",fullUrlStr);
        return fullUrlStr;
    }
    NSString *baseUrl;
    if (request.baseUrl.length > 0) {
        baseUrl = request.baseUrl;
    } else {
        baseUrl = _config.baseUrl;
    }
    NSURL *url = [NSURL URLWithString:baseUrl];
    if (baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    NSString *requestUrlStr = request.requestUrl;
    NSString *absoluteStr = [NSURL URLWithString:requestUrlStr relativeToURL:url].absoluteString;
    WSSLog(@"url absolutestring : %@",absoluteStr);
    return absoluteStr;
}
- (AFHTTPRequestSerializer *)requestSerializerForRequest:(WSSRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == WSSRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == WSSRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    if (request.requestTimeoutInterval > 0) {
        requestSerializer.timeoutInterval = request.requestTimeoutInterval;
    } else {
        requestSerializer.timeoutInterval = _config.timeoutInterval;
    }
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = request.requestHeaderFieldValueDictionary;
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}
#pragma mark - getter
- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _jsonResponseSerializer;
}
- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlParserResponseSerialzier) {
        _xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
    }
    return _xmlParserResponseSerialzier;
}
@end
