# WSSNetworking

[![CI Status](https://img.shields.io/travis/18566663687@163.com/WSSNetworking.svg?style=flat)](https://travis-ci.org/18566663687@163.com/WSSNetworking)
[![Version](https://img.shields.io/cocoapods/v/WSSNetworking.svg?style=flat)](https://cocoapods.org/pods/WSSNetworking)
[![License](https://img.shields.io/cocoapods/l/WSSNetworking.svg?style=flat)](https://cocoapods.org/pods/WSSNetworking)
[![Platform](https://img.shields.io/cocoapods/p/WSSNetworking.svg?style=flat)](https://cocoapods.org/pods/WSSNetworking)

## Installation

WSSNetworking is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WSSNetworking'
pod 'WSSNetworking/WSSNetworkManager'
pod 'WSSNetworking/WSSReachabilityManager'
```
## Example

### WSSNetworking
```
pod 'WSSNetworking/WSSNetworkManager'


```
#### WSSNetworkConfig
```
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

```
#### WSSNetworkProtocol
```
/**
 入参的统一处理
 @param parameters parameters description
 @return return value description
 */
- (id)requestParameters:(id)parameters;
/**
 成功的统一处理
 
 @param result result description
 @return return value description
 */
- (id)resultSuccessResponseWithResult:(id)result;
/**
 失败的统一处理
 
 @param result result description
 @return return value description
 */
- (id)resultFailureResponseWithResult:(id)result;

```
#### WSSRequest
```
WSSRequest *request = [[WSSRequest alloc] initWithRequestMethod:WSSRequestMethodPOST fullUrl:nil requestUrl:@"XXX" requestArgument:@{@"page_num":@"1",@"page_size":@"20"}];

[request startRequestWithSuccess:^(WSSRequest * _Nullable request) {
    NSLog(@"----------request   success------   %@",request.responseObject);
} failure:^(WSSRequest * _Nullable request) {
    NSLog(@"----------request   failure------   %@",request.responseObject);
}];

或者
 
 request.tag = 100;
 request.delegate = self;
 [request startRequest];
 
 #pragma mark - WSSRequestDelegate
 - (void)requestFailure:(WSSRequest *)request {
 }
 - (void)requestSuccess:(WSSRequest *)request {
 }

可以在WSSNetworkConfig写上请求的baseUrl、timeoutInterval、sessionConfiguration、networkProtocol等 也可以直接设置

   request.baseUrl   //url
   request.requestSerializerType //序列化
   request.requestHeaderFieldValueDictionary //header信息

```

### WSSReachabilityManager
```
pod 'WSSNetworking/WSSReachabilityManager'

```

```
@property (nonatomic, strong) WSSNetworkReachabilityManager *networkReachabilityManager;

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kWSSNetworkReachabilityChangedNotification object:nil];
   self.networkReachabilityManager = [WSSNetworkReachabilityManager reachability];
   [self.networkReachabilityManager startMonitoring];
   WSSNetworkReachabilityStatus networkStatus = [self.networkReachabilityManager currentReachabilityStatus];

- (void)networkChanged:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    WSSNetworkReachabilityStatus networkStatus = [userInfo[kWSSNetworkingReachabilityNotificationStatusItem] integerValue];
}

```

## Author

wangsi,17601013687@163.com

## License

WSSNetworking is available under the MIT license. See the LICENSE file for more info.
