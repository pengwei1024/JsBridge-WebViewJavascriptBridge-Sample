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
@end

@implementation ViewController {
    UIWebView *webView;
    NSString *bridgeCore;
    WVJBResponseCallback callback;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @" xxx";
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView setOpaque:NO];
    [webView setBackgroundColor:[UIColor clearColor]];
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
        NSString *button = data;
        NSLog(button);
        responseCallback(@"xxxxxxx");
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"UIAlertView click index => %d", buttonIndex);
    if (callback) {
        callback([NSString stringWithFormat: @"%d", buttonIndex]);
    }
}


@end