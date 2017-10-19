//
//  ViewController.m
//  JsBridge-WebViewJavascriptBridge-Sample
//
//  Created by pengwei on 2017/10/9.
//  Copyright © 2017 apkfuns. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ViewController ()
@property WebViewJavascriptBridge *bridge;
@property(nonatomic, strong) CLLocationManager *locationManager; //定位服务
@end

@implementation ViewController {
    UIWebView *webView;
    NSString *bridgeCore;
    WVJBResponseCallback callback;
    WVJBResponseCallback menuClick;
    WVJBResponseCallback locationCallback;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @"JsBridge";
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    // load Url
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];

    // init WebViewJavascriptBridge
    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [self.bridge setWebViewDelegate:self];
    [self registerJsBridge];
}

/**
 * 注册 JsBridge
 */
- (void)registerJsBridge {
    [self.bridge registerHandler:@"MyBridge.native.setMenu" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data) {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:data
                                                                           style:UIBarButtonItemStylePlain target:self action:@selector(menuClick)];
            self.navigationItem.rightBarButtonItem = buttonItem;
            menuClick = responseCallback;
        }
    }];
    [self.bridge registerHandler:@"MyBridge.native.alertDialog" handler:^(id data, WVJBResponseCallback responseCallback) {

        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSLog(@"title = %@, desc=%@", [data objectForKey:@"title"], [data objectForKey:@"desc"]);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[data objectForKey:@"title"]
                                                                message:[data objectForKey:@"desc"]
                                                               delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"sure", nil];
            [alertView show];
            callback = responseCallback;
        }
    }];
    [self.bridge registerHandler:@"MyBridge.native.getLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self startLocation];
        locationCallback = responseCallback;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView1 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1 {
    // inject JS
    if (![[webView stringByEvaluatingJavaScriptFromString:@"typeof MyBridge == 'object'"] isEqualToString:@"true"]) {
        if (!bridgeCore) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JsBridgeCore" ofType:@"js"];
            bridgeCore = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        if (bridgeCore.length > 0) {
            [webView stringByEvaluatingJavaScriptFromString:bridgeCore];
            NSLog(@"inject js bridge from file.");
        }
    }
}

- (void)menuClick {
    NSLog(@"menuClick click");
    if (menuClick) {
        menuClick(@"data");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"UIAlertView click index => %d", buttonIndex);
    if (callback) {
        callback([NSString stringWithFormat:@"%d", buttonIndex]);
    }
}

// 开始定位
- (void)startLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 5.0;
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [_locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    //当前的经纬度
    NSLog(@"当前的经纬度 %f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    if (locationCallback) {
        locationCallback([NSString stringWithFormat:@"%f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}


@end