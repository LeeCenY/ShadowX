//
//  CLVPNManager.m
//  CLVPN
//
//  Created by TTLGZMAC6 on 2018/9/7.
//  Copyright © 2018 LeeCen. All rights reserved.
//

#import "CLVPNManager.h"
#import <NetworkExtension/NetworkExtension.h>

@interface CLVPNManager()

@property (nonatomic, assign) BOOL observerAdded;

@end

@implementation CLVPNManager

#pragma mark - set/get
- (void)setVPNStatus:(VPNStatus)VPNStatus{
    _VPNStatus = VPNStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kProxyServiceVPNStatusNotification" object:nil];
}

+ (instancetype)sharedInstance{
    static CLVPNManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CLVPNManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.observerAdded = NO;
        __weak typeof(self) weakself = self;
        [self loadProviderManager:^(NETunnelProviderManager *manager) {
            
            [weakself updateVPNStatus:manager];
        }];
    }
    return self;
}

#pragma mark - exposed method
- (void)connect:(void (^)(NSError *error))complete {
    
    [self loadProviderManager:^(NETunnelProviderManager *manager) {
        NSError* error;
        [manager.connection startVPNTunnelWithOptions:nil andReturnError:&error];
        
        if (complete) {
            complete(error);
        }
    }];
    
}

- (void)disconnect{
    [self loadProviderManager:^(NETunnelProviderManager *manager) {
        [manager.connection stopVPNTunnel];
    }];
}

#pragma mark - private method

- (NETunnelProviderManager *)createProviderManager{
    
    NETunnelProviderManager *manager = [[NETunnelProviderManager alloc] init];
    NETunnelProviderProtocol *conf = [[NETunnelProviderProtocol alloc] init];
    conf.serverAddress = @"ShadowX";
    manager.protocolConfiguration = conf;
    manager.localizedDescription = @"ShadowX";
    return manager;
}

- (void)loadProviderManager:(void(^)(NETunnelProviderManager *manager))compelte {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        
        NETunnelProviderManager *manager = [[NETunnelProviderManager alloc] init];
        
        if (nil == error && managers.count > 0) {
            manager = managers.firstObject;

        }else{
            manager = [self createProviderManager];
        }
        manager.enabled = YES;
        
        //set rule config
        NSMutableDictionary *conf = @{}.mutableCopy;
        conf[@"ss_address"] = @"IP服务器";
        conf[@"ss_port"] = @8888;
        conf[@"ss_method"] = @"CHACHA20";// 大写 没有横杠 看Extension中的枚举类设定 否则引发fatal error
        conf[@"ss_password"] = @"密码";
        conf[@"ymal_conf"] = [self getRuleConf];
        
        [self saveProviderManager:manager configuration:conf complete:^(NSError* error) {
            if (error) {
                if (compelte) {
                    compelte(nil);
                }
                return;
            }
            // add observer
            if (!self.observerAdded) {
                self.observerAdded = YES;
                [NSNotificationCenter.defaultCenter addObserverForName:NEVPNStatusDidChangeNotification object:manager.connection queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                    [self updateVPNStatus:manager];
                }];
            }
            if (compelte) {
                compelte(manager);
            }
        }];
    }];
}

- (void)saveProviderManager:(NETunnelProviderManager *)manager configuration:(NSDictionary<NSString *,id>*)config complete:(nullable void (^)(NSError *))complete {
    NETunnelProviderProtocol* protocol = (NETunnelProviderProtocol*)manager.protocolConfiguration;
    protocol.providerConfiguration = config;
    manager.protocolConfiguration = protocol;
    [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            complete(error);
            return;
        }
        [manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            complete(error);
        }];
    }];
}


- (NSString *)getRuleConf{
    NSString * Path = [[NSBundle mainBundle] pathForResource:@"NEKitRule" ofType:@"conf"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:Path]];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


#pragma mark - tool

- (void)updateVPNStatus:(NEVPNManager *)manager{
    switch (manager.connection.status) {
        case NEVPNStatusConnected: //VPN已连接
            self.VPNStatus = VPNStatusOn;
            break;
        case NEVPNStatusConnecting: // VPN正在连接
            self.VPNStatus = VPNStatusConnecting;
            break;
        case NEVPNStatusReasserting: // VPN在失去底层网络连接后重新连接
            self.VPNStatus = VPNStatusConnecting;
            break;
        case NEVPNStatusDisconnecting: // VPN正在断开连接
            self.VPNStatus = VPNStatusDisconnecting;
            break;
        case NEVPNStatusDisconnected: //VPN已断开连接
            self.VPNStatus = VPNStatusOff;
            break;
        case NEVPNStatusInvalid: //未配置VPN
            self.VPNStatus = VPNStatusOff;
            break;
        default:
            break;
    }
}

@end
