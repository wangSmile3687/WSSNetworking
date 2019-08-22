# WSSNetworking

[![CI Status](https://img.shields.io/travis/18566663687@163.com/WSSNetworking.svg?style=flat)](https://travis-ci.org/18566663687@163.com/WSSNetworking)
[![Version](https://img.shields.io/cocoapods/v/WSSNetworking.svg?style=flat)](https://cocoapods.org/pods/WSSNetworking)
[![License](https://img.shields.io/cocoapods/l/WSSNetworking.svg?style=flat)](https://cocoapods.org/pods/WSSNetworking)
[![Platform](https://img.shields.io/cocoapods/p/WSSNetworking.svg?style=flat)](https://cocoapods.org/pods/WSSNetworking)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WSSNetworking is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WSSNetworking'
```


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// Override point for customization after application launch.

[WSSNetworkConfig sharedConfig].baseUrl = @"http://XXXX";

[WSSNetworkConfig sharedConfig].debugLogEnabled = YES;

[WSSNetworkConfig sharedConfig].networkProtocol = [TestNetworkHandle sharedProtocol];

return YES;
}

WSSRequest *request = [[WSSRequest alloc] initWithRequestMethod:WSSRequestMethodPOST fullUrl:nil requestUrl:@"XXX" requestArgument:@{@"page_num":@"1",@"page_size":@"20"}];

[request startRequestWithSuccess:^(WSSRequest * _Nullable request) {

NSLog(@"----------request   success------   %@",request.responseObject);

} failure:^(WSSRequest * _Nullable request) {

NSLog(@"----------request   failure------   %@",request.responseObject);

}];

//    request.delegate = self;

//    [request startRequest];

- (void)requestFailure:(WSSRequest *)request {
}

- (void)requestSuccess:(WSSRequest *)request {
}

## Author

wangsi,18566663687@163.com

## License

WSSNetworking is available under the MIT license. See the LICENSE file for more info.
