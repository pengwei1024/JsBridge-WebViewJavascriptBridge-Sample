function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        return callback(WebViewJavascriptBridge);
    }
    if (window.WVJBCallbacks) {
        return window.WVJBCallbacks.push(callback);
    }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function () {document.documentElement.removeChild(WVJBIframe)}, 0)
}

setupWebViewJavascriptBridge(function (bridge) {
    window.MyBridge = {
        native: {
            setMenu: function (button, clickEvent) {
                bridge.callHandler("MyBridge.native.setMenu", button, function (responseData) {
                    alert('click!');
                    clickEvent(button);
                });
            },
            alertDialog: function (title, desc, sureClick, cancelClick) {
                bridge.callHandler("MyBridge.native.alertDialog", {title: title, desc: desc}, function (responseData) {
                    if (responseData && responseData == "1") {
                        sureClick();
                    } else {
                        cancelClick();
                    }
                });
            },
            getLocation:function (result) {
                bridge.callHandler("MyBridge.native.getLocation", {}, function (responseData) {
                    if (responseData && result) {
                        var ret = responseData.split(',');
                        if (ret && ret.length === 2) {
                            result(ret[0], ret[1]);
                        }
                    }
                });
            },
            takePhoto:function () {
                alert('暂未实现');
            }
        },
        service: {
            ajax: function () {
                alert('暂未实现');
            },
            hiShare:function () {
                alert('暂未实现');
            }
        }
    };
    if (onMyBridgeReady) {
        onMyBridgeReady();
    }
});