# JsBridge-WebViewJavascriptBridge
iOS JsBridge Solution by WebViewJavascriptBridge

为 [JsBridge](https://github.com/pengwei1024/JsBridge) 开发的 iOS 解决方案

![](./screenshot.gif)

## Sample
**Native register**

```
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
```
**Js Call**

```
MyBridge.native.alertDialog(
     'Title',
      'it\'s a native dialog',
      function(){
            alert('sure button click');
       },
      function(){
         alert('cancel button click');
       }
       );
```

## License
<pre>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>

