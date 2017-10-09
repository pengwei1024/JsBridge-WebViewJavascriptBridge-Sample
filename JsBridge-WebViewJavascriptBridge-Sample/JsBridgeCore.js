document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
    var bridge = event.bridge;
    window.MyBridge = {
        sdk: {
            version: function(){
                return 1;
            }
        },
        title: {
            setTitle: function(options) {
                if (options) {
                    bridge.callHandler('JsBridge.title.setTitle', options.data, function(responseObject) {
                        if (responseObject) {
                            options.onSuccess()
                        } else {
                            options.onFailure()
                        }
                    })
                }
            },
            setNavMenu: function(options) {
                if (options) {
                    bridge.callHandler('JsBridge.title.setNavMenu', options.data, function(responseObject) {
                        if (responseObject) {
                            options.onSuccess();
                            options.onListener(responseObject)
                        } else {
                            options.onFailure();
                        }
                    })
                }
            }
        }
    };
    if (onMyBridgeReady) {
        onMyBridgeReady();
    }
});


