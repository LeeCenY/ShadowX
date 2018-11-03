//
//  CLVPNManager.h
//  CLVPN
//
//  Created by TTLGZMAC6 on 2018/9/7.
//  Copyright © 2018 LeeCen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPNStatus){
    VPNStatusOff,
    VPNStatusConnecting,
    VPNStatusOn,
    VPNStatusDisconnecting,
};

@interface CLVPNManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) VPNStatus VPNStatus;

- (void)connect:(void (^)(NSError *error))complete;
- (void)disconnect;

@end
