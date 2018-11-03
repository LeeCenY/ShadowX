//
//  ViewController.m
//  CLVPN
//
//  Created by TTLGZMAC6 on 2018/9/7.
//  Copyright © 2018 LeeCen. All rights reserved.
//

#import "ViewController.h"
#import "CLVPNManager.h"
#import <NetworkExtension/NetworkExtension.h>
#import "CLHeaderView.h"
#import "CLAboutViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) VPNStatus status;
@property (nonatomic, assign) NSTimeInterval dration;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CLHeaderView *headerView;
@property (nonatomic, assign) CGFloat headerViewHeight;

@end

@implementation ViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dration = 0.75;
    self.headerViewHeight = 300;
//    [self setup];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview: self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setNavigationBarTranslucent:self.navigationController.navigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setNavigationBarOpacity:self.navigationController.navigationBar];
}

- (void)setup {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

// 设置成 透明
- (void)setNavigationBarTranslucent:(UINavigationBar *)navigationBar {
    UIImage *translucentImage = [[UIImage alloc] init];
    [navigationBar setBackgroundImage:translucentImage forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = translucentImage;
}

// 恢复成默认状态
- (void)setNavigationBarOpacity:(UINavigationBar *)navigationBar {
    [navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"🇭🇰 香港 HK（默认选中）";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"将推出更多的地区服务。";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"如果不稳定或连接不上，请更新版本。";
    } else {
        cell.textLabel.text = @"关于";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    self.headerView = [[CLHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.headerViewHeight)];
    self.headerView.backgroundColor = [UIColor whiteColor];

    [self.headerView.button setTitle:@"连接" forState:UIControlStateNormal];
    [self.headerView.button addTarget:self action:@selector(touchBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.headerView addSubview: self.headerView.button];
    
    [self updateBtnStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVPNStatusChanged)
                                                 name:@"kProxyServiceVPNStatusNotification"
                                               object:nil];
    
    return self.headerView;
}

#pragma mark - eeeeeeee

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        
    }
    
    if (indexPath.row == 3) {
        CLAboutViewController *about = [[CLAboutViewController alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    }
}

#pragma mark - eeeeeeee
- (void)updateBtnStatus{
    switch ([CLVPNManager sharedInstance].VPNStatus) {
        case VPNStatusConnecting:
            [self.headerView.button setTitle:@"连接中" forState:UIControlStateNormal];
            break;
            
        case VPNStatusDisconnecting:
            [self.headerView.button setTitle:@"断开中" forState:UIControlStateNormal];
            break;
            
        case VPNStatusOn:
            [self.headerView.button setTitle:@"断开" forState:UIControlStateNormal];
            break;
            
        case VPNStatusOff:
            [self.headerView.button setTitle:@"连接" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    self.headerView.button.enabled = [CLVPNManager sharedInstance].VPNStatus == VPNStatusOn||[CLVPNManager sharedInstance].VPNStatus == VPNStatusOff;
}

- (void)touchBtn:(UIButton *)sender {

    if([CLVPNManager sharedInstance].VPNStatus == VPNStatusOff){
        [[CLVPNManager sharedInstance] connect:^(NSError * error) {
            if (error) {
                NSLog(@"%@",error);
                return;
            }
            
            UIViewPropertyAnimator *propertyAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:self.dration curve:(UIViewAnimationCurveEaseIn) animations:^{
                self.headerView.button.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.headerViewHeight);
                self.headerView.button.layer.cornerRadius = 0;
                self.headerView.button.layer.masksToBounds = NO;
            }];
            [propertyAnimator startAnimation];
        }];
    }else if ([CLVPNManager sharedInstance].VPNStatus == VPNStatusOn){
        [[CLVPNManager sharedInstance] disconnect];
        UIViewPropertyAnimator *propertyAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:self.dration curve:(UIViewAnimationCurveEaseIn) animations:^{
            self.headerView.button.frame = self.headerView.GetCenter;
            self.headerView.button.layer.cornerRadius = self.headerView.GetCornerRadius;
            self.headerView.button.layer.masksToBounds = YES;
        }];
        [propertyAnimator startAnimation];
    }
}

#pragma mark - 收到监听通知处理
- (void)onVPNStatusChanged{
    [self updateBtnStatus];
    
    if ([CLVPNManager sharedInstance].VPNStatus == VPNStatusOn) {
        
        self.headerView.button.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.headerViewHeight);
        self.headerView.button.layer.cornerRadius = 0;
        self.headerView.button.layer.masksToBounds = NO;
    }
    if ([CLVPNManager sharedInstance].VPNStatus == VPNStatusDisconnecting) {
        
        UIViewPropertyAnimator *propertyAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:self.dration curve:(UIViewAnimationCurveEaseIn) animations:^{
            self.headerView.button.frame = self.headerView.GetCenter;
            self.headerView.button.layer.cornerRadius = self.headerView.GetCornerRadius;
            self.headerView.button.layer.masksToBounds = YES;
        }];
        [propertyAnimator startAnimation];
    }
}


@end

