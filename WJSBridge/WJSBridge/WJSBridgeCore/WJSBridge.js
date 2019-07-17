
function bcbwallet (method, params, callBack) {
    var message;
    var arr = method.split(".");
    method = arr[arr.length-1];
    WJSBridge.walletCall(method, params, callBack);
};

var WJSBridge = {
    walletCall: function(method, params, callBack) {
        var message;
        if (!callBack) {
            message = {'method': method, 'params': params};
            window.webkit.messageHandlers.WJSBridge.postMessage(message);
        }else {
            var callBackId = method+'callBack';
            message = {'method': method, 'params': params, 'callBack': callBackId};
            if (!WJSBridgeEvent._listeners[callBackId]) {
                WJSBridgeEvent.addEvent(callBackId, function (data){
                    callBack(data);
                })
            }
            window.webkit.messageHandlers.WJSBridge.postMessage(message);
        }
    },
    
    walletCallBack: function (callBackId, data) {
        WJSBridgeEvent.fireEvent(callBackId, data);
    },
    
    removeAllCallBacks: function(data){
        WJSBridgeEvent._listeners ={};
    }
};

var WJSBridgeEvent = {
    _listeners:{},

    addEvent: function(type, fn) {
        if (typeof this._listeners[type] === "undefined") {
            this._listeners[type] = [];
        }
        if (typeof fn === "function") {
            this._listeners[type].push(fn);
        }
        return this;
    },

    fireEvent: function (type, params) {
        var arrayEvent = this._listeners[type];
        if (arrayEvent instanceof Array) {
            for (var i = 0, len = arrayEvent.length; i<len; i+=1) {
                if (typeof arrayEvent[i] === "function") {
                    arrayEvent[i](params);
                }
            }
        }
        return this;
    },

    removeEvent: function (type, fn) {
        var arrayEvent = this._listeners[type];
        if (typeof type === "string" && arrayEvent instanceof Array) {
            if (typeof fn === "function") {
                for (var i=0, length=arrayEvent.length; i<length; i+=1){
                    if (arrayEvent[i] === fn){
                        this._listeners[type].splice(i, 1);
                        break;
                    }
                }
            } else {
                delete this._listeners[type];
            }
        }
        
        return this;
    }

};
