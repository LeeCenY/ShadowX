//
//  CLAboutViewController.m
//  CLVPN
//
//  Created by TTLGZMAC6 on 2018/9/11.
//  Copyright © 2018 LeeCen. All rights reserved.
//

#import "CLAboutViewController.h"
#import "APPInfo.h"

@interface CLAboutViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@end

@implementation CLAboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoImageView.layer.cornerRadius = 10;
    self.logoImageView.clipsToBounds = YES;
    
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.text = [self info];
    
    self.copyrightLabel.textAlignment = NSTextAlignmentCenter;
    self.copyrightLabel.text = [self copyright];
}

- (NSString *)info {
    
    NSString* appName = [APPInfo name];
    NSString* appVersion = [APPInfo version];
    NSString* appBuild = [APPInfo build];
    
    return [NSString stringWithFormat:@"%@ V%@(%@)", appName, appVersion, appBuild];
}

- (NSString *)copyright {
    return @"Copyright © 2018 ShadowX. All rights reserved.";
}

@end
