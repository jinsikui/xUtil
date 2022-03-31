

#import "xAVPlayerAgent.h"

@interface xAVPlayerAgent()<xAVPlayerDelegate>
@property(nonatomic) xAVPlayer      *player;
@property(nonatomic) NSPointerArray *listenerList;
@property(nonatomic) int            cleanThreshold;
@end

@implementation xAVPlayerAgent

+ (instancetype)shared {
    static xAVPlayerAgent *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xAVPlayerAgent alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _listenerList = [NSPointerArray weakObjectsPointerArray];
        _cleanThreshold = 500;
    }
    return self;
}

- (xAVPlayerState)state{
    return _player.state;
}

- (NSTimeInterval)curTime{
    return _player.curTime;
}

- (NSTimeInterval)duration{
    return _player.duration;
}

- (void)play:(NSURL *)url{
    if ([url.absoluteString isEqualToString:_url.absoluteString] && _player) {
        if (_player.state == xAVPlayerStatePlaying) {
            return;
        }
        else if (_player.state == xAVPlayerStatePaused) {
            [_player play];
            return;
        }
    }
    _url = url;
    _player = [[xAVPlayer alloc] initWithUrl:url];
    _player.delegate = self;
    [_player prepareForPlay];
    [_player play];
}

- (void)pause{
    if (_player && _player.state == xAVPlayerStatePlaying) {
        [_player pause];
    }
    else{
        [_player stop];
    }
}

- (void)stop{
    [_player stop];
}

- (void)seek:(NSTimeInterval)time{
    if (_player && (_player.state == xAVPlayerStatePlaying || _player.state == xAVPlayerStatePaused)) {
        if (time < _player.duration) {
            [_player seek:time];
        }
    }
}

//不需要remove，不会强引用
- (void)registerListener:(NSObject<xAVPlayerDelegate>*)listener{
    @synchronized(self) {
        if ([[_listenerList allObjects] containsObject:listener]) {
            return;
        }
        [_listenerList addPointer:(__bridge void * _Nullable)(listener)];
        if (_listenerList.count >= _cleanThreshold) {
            NSPointerArray *list = [NSPointerArray weakObjectsPointerArray];
            for(id<xAVPlayerDelegate> obj in _listenerList.allObjects) {
                if (obj != NULL) {
                    [list addPointer:(__bridge void * _Nullable)(obj)];
                }
            }
            _listenerList = list;
        }
    }
}

#pragma mark - xAVPlayerDelegate

- (void)xAVPlayerOnStateChanged:(xAVPlayerState)state curTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration{
    @synchronized(self) {
        for(id obj in _listenerList) {
            if (obj != NULL) {
                NSObject<xAVPlayerDelegate> *listener = (NSObject<xAVPlayerDelegate>*)obj;
                if ([listener respondsToSelector:@selector(xAVPlayerOnStateChanged:curTime:duration:)]) {
                    [listener xAVPlayerOnStateChanged:state curTime:curTime duration:duration];
                }
            }
        }
    }
}

- (void)xAVPlayerOnError:(NSError*)error{
    @synchronized(self) {
        for(id obj in _listenerList) {
            if (obj != NULL) {
                NSObject<xAVPlayerDelegate> *listener = (NSObject<xAVPlayerDelegate>*)obj;
                if ([listener respondsToSelector:@selector(xAVPlayerOnError:)]) {
                    [listener xAVPlayerOnError:error];
                }
            }
        }
    }
}

@end
