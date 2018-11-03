//
//  CLHeaderView.h
//  CLVPN
//
//  Created by TTLGZMAC6 on 2018/9/11.
//  Copyright © 2018 LeeCen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLHeaderView : UIView

@property (nonatomic, strong) UIButton* button;
- (CGRect)GetCenter;
- (CGFloat)GetCornerRadius;
@end
