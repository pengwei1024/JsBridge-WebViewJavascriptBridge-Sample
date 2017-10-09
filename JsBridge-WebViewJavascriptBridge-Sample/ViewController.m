//
//  ViewController.m
//  JsBridge-WebViewJavascriptBridge-Sample
//
//  Created by pengwei on 2017/10/9.
//  Copyright © 2017 apkfuns. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController {
    UIWebView *webView;
    NSString *bridgeCore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds = self.view.bounds;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width,
            bounds.size.height)];
    webView.delegate = self;
    [self.view addSubview:webView];
    NSString *url = @"http://www.baidu.com";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:request];
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


@end