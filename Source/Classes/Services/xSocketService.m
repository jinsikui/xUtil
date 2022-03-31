

#import "xSocketService.h"
#if __has_include(<SocketRocket/SocketRocket.h>)
#import <SocketRocket/SocketRocket.h>
#else
#import "SocketRocket.h"
#endif
#import "xTask.h"
#import "xTimer.h"
#import "xNetworkMonitor.h"
#import "xNotice.h"

@interface xSocketService()<SRWebSocketDelegate>
@property(nonatomic) SRWebSocket *socket;
@property(nonatomic) NSUInteger serverIndex;
@property(nonatomic) NSString *curServer;
@property(nonatomic) NSUInteger maxRetryPow;
@property(nonatomic) NSUInteger curRetryTimes;
@property(nonatomic) xTaskHandle *retryHandle;
@property(nonatomic) xTimer *heartTimer;
@end

@implementation xSocketService

- (instancetype)initWithServers:(NSArray<NSString*>*)servers userInfo:(NSDictionary* __nullable)userInfo{
    self = [super init];
    if (self) {
        _servers = servers;
        _userInfo = userInfo;
        _status = xSocketStatusClose;
        if (servers.count > 0) {
            _serverIndex = 0;
            _curServer = servers[_serverIndex];
            _maxRetryPow = 3;
            _curRetryTimes = 0;
        }
        __weak typeof(self) weak = self;
        _heartTimer = [xTimer timerOnGlobalWithIntervalSeconds:30 fireOnStart:NO action:^{
            [weak heartBeat];
        }];
        [[xNetworkMonitor shared] registerCallbackWithLife:self callback:^(AFNetworkReachabilityStatus status) {
            if (weak.status != xSocketStatusOpen && (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN)) {
                [weak _retry];
            }
        }];
        [[xNetworkMonitor shared] startMonitoring];
        [[xNotice shared] registerAppBecomeActive:self action:^(id _Nullable param) {
            if (weak.status != xSocketStatusOpen) {
                [weak _retry];
            }
        }];
    }
    return self;
}

- (void)open{
    NSLog(@"===== websocket opening =====");
    [self _close];
    _socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_curServer]];
    _socket.delegate = self;
    [_socket open];
}

- (void)retry{
    __weak typeof(self) weak = self;
    double interval = pow(2, _curRetryTimes < _maxRetryPow ? _curRetryTimes : _maxRetryPow);
    _retryHandle = [xTask asyncGlobalAfter:interval task:^{
        [weak _retry];
    }];
}

- (void)_retry{
    NSLog(@"===== websocket retry =====");
    _curRetryTimes ++;
    _serverIndex = (_serverIndex + 1) % _servers.count;
    _curServer = _servers[_serverIndex];
    [self open];
}

- (void)close{
    [self _close];
    id<xSocketServiceDelegate> delegate = self.delegate;
    if (delegate) {
        [delegate socketClosedWithInfo:@{@"code":@(0),@"reason":@"",@"server":_curServer?:@""}];
    }
}

- (void)_close{
    if (_retryHandle) {
        [_retryHandle cancel];
    }
    if (_socket) {
        [_socket close];
        _socket.delegate = nil;
        _socket = nil;
    }
    _status = xSocketStatusClose;
}

- (void)heartBeat{
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"ver":@(1), @"type":@(0)} options:0 error:nil];
    if (self.status == xSocketStatusOpen) {
        [_socket send:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
}

- (void)dealloc{
    [self _close];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    id<xSocketServiceDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(socketGotData:userInfo:)]) {
        [delegate socketGotData:message userInfo:self.userInfo];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"===== websocket connected to server:%@ =====", _curServer);
    _status = xSocketStatusOpen;
    _curRetryTimes = 0;
    id<xSocketServiceDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(socketConnectedWithUserInfo:)]) {
        [delegate socketConnectedWithUserInfo:self.userInfo];
    }
    [self heartBeat];
    [_heartTimer start];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"===== websocket fail: %@ =====", error);
    _status = xSocketStatusFail;
    [_heartTimer stop];
    id<xSocketServiceDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(socketErrorWithInfo:)]) {
        [delegate socketErrorWithInfo:@{@"code":@(error.code), @"msg":error.description?:@"", @"server":_curServer?:@""}];
    }
    [self retry];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"===== websocket close with code: %ld reason: %@ wasClean: %@ =====", (long)code, reason, (wasClean ? @"YES":@"NO"));
    _status = xSocketStatusClose;
    [_heartTimer stop];
    id<xSocketServiceDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(socketClosedWithInfo:)]) {
        [delegate socketClosedWithInfo:@{@"code":@(code), @"reason":reason?:@"", @"server":_curServer?:@""}];
    }
    [self retry];
}
@end
