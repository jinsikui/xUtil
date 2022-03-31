

#import "xAVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "xTimer.h"

#define ERROR_DOMAIN @"xAVAudioPlayer"

@interface xAVAudioPlayer()<AVAudioPlayerDelegate>
@property(nonatomic) BOOL           hasPreparedForPlay;
@property(nonatomic) AVAudioPlayer  *player;
@property(nonatomic) xTimer         *playingTimeTimer;
@end

@implementation xAVAudioPlayer

- (instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        _url = url;
        NSError *error = nil;
        if (!_player) {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_url error:&error];
            _player.delegate = self;
            _player.numberOfLoops = 0;
            if (error) {
                [self postError:error];
                _player = nil;
                return self;
            }
            _player.volume = 1;
            BOOL preparedOK = [_player prepareToPlay];
            if (!preparedOK) {
                [self postError:[NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]];
                return self;
            }
        }
    }
    return self;
}

- (void)dealloc{
    [self dispose];
}

- (void)dispose{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForPlay{
    if (_hasPreparedForPlay) {
        return;
    }
    //监听输出设备变化（耳机插拔，蓝牙设备连接和断开等）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    //电话打断
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    _hasPreparedForPlay = YES;
}

#pragma mark - System Audio Process

- (void)sessionInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType) {
        //begin interruption
        //直接停止播放
        [self stop];
    }
    else if (AVAudioSessionInterruptionTypeEnded == interruptionType) {
        //end interruption
    }
}

- (void)sessionRouteChange:(NSNotification *)notification {
    AVAudioSessionRouteChangeReason routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (AVAudioSessionRouteChangeReasonNewDeviceAvailable == routeChangeReason) { //新设备插入
        if ([self isNotUseBuiltInPort]) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
    }
    else if (AVAudioSessionRouteChangeReasonOldDeviceUnavailable == routeChangeReason) { //新设备拔出
        if (![self isNotUseBuiltInPort]) {
            [self pause];
            //扬声器模式
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
    } else {
        //没有设备音频变化
    }
}

//检测是否有耳机，只需在route中是否有Headphone或Headset存在
- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
    // #warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    return [self isHeadsetPluggedIn];
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if ((route == NULL) || (CFStringGetLength(route) == 0)) {
        // Silent Mode
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        //    NSLog(@"AudioRoute: %@", routeStr);
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if (headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
    
#endif
}

//设备是否存在，耳麦，耳机等
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
        else  if ([[desc portType] isEqualToString:AVAudioSessionPortHeadsetMic]) {
            return YES;
        }else {
            continue;
        }
    }
    return NO;
}

- (BOOL)isNotUseBuiltInPort{
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    if (outputs.count <= 0) {
        return NO;
    }
    AVAudioSessionPortDescription *port = (AVAudioSessionPortDescription*)outputs[0];
    return ![port.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]&&![port.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker];
}

//AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.state = xAVAudioPlayerStateFinished;
    [self seek:0];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    [self postError:error];
}

#pragma mark - Interfaces

- (void)play{
    if (!_hasPreparedForPlay || _state == xAVAudioPlayerStatePlaying) {
        return;
    }
    NSError *error = nil;
    if (![[AVAudioSession sharedInstance] setActive:YES error:&error]) {
        [self postError:error];
        return;
    }
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error]) {
        [self postError:error];
        return;
    }
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_url error:&error];
        _player.delegate = self;
        _player.numberOfLoops = 0;
        if (error) {
            [self postError:error];
            _player = nil;
            return;
        }
        _player.volume = 1;
        BOOL preparedOK = [_player prepareToPlay];
        if (!preparedOK) {
            [self postError:[NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]];
            return;
        }
    }
    BOOL playOK = [_player play];
    if (!playOK) {
        [self postError:[NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]];
        return;
    }
    self.state = xAVAudioPlayerStatePlaying;
    
}

- (void)setState:(xAVAudioPlayerState)state{
    if (_state != state) {
        _state = state;
        [self postState];
        if (state == xAVAudioPlayerStatePlaying) {
            if (!_playingTimeTimer) {
                __weak typeof(self) weak = self;
                _playingTimeTimer = [xTimer timerOnMainWithIntervalSeconds:0 fireOnStart:YES action:^{
                    __strong typeof(weak) s = weak;
                    if (s.state == xAVAudioPlayerStatePlaying) {
                        [s postState];
                    }
                }];
            }
            [_playingTimeTimer start];
        }
        else{
            [_playingTimeTimer stop];
        }
    }
}

- (void)pause{
    if (_state != xAVAudioPlayerStatePlaying) {
        return;
    }
    [self postState];
    [_player pause];
    self.state = xAVAudioPlayerStatePaused;
}

- (void)stop{
    [_player stop];
    self.state = xAVAudioPlayerStateNone;
}

- (NSTimeInterval)curTime{
    if (!_player) {
        return 0;
    }
    return _player.currentTime;
}

- (void)seek:(NSTimeInterval)time{
    if (!_player) {
        return;
    }
    _player.currentTime = time;
    [self postState];
}

- (NSTimeInterval)duration{
    if (!_player) {
        return 0;
    }
    return _player.duration;
}

- (void)postState{
    NSObject<audioPlayerDelegate> *delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(playerOnStateChanged:curTime:duration:)]) {
        [delegate playerOnStateChanged:_state curTime:_player.currentTime duration:_player.duration];
    }
}

- (void)postError:(NSError*)error{
    NSObject<audioPlayerDelegate> *delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(playerOnError:)]) {
        [delegate playerOnError:error];
    }
}

@end
