//
//  CLHeaderView.m
//  CLVPN
//
//  Created by TTLGZMAC6 on 2018/9/11.
//  Copyright © 2018 LeeCen. All rights reserved.
//

#import "CLHeaderView.h"

@interface CLHeaderView()



@end

@implementation CLHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
    }
    return self;
}

- (CGRect)GetCenter {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat x = CGRectGetMidX(self.frame);
    CGFloat y = CGRectGetMidY(self.frame);
    CGFloat len = fminf(width, height)*0.5;
    return CGRectMake(x-len/2, y-len/2, len, len);
}

- (CGFloat)GetCornerRadius {
   return [self GetCenter].size.width / 2;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = [self GetCenter];
        _button.backgroundColor = [UIColor colorWithRed:54/255.0 green:153/255.0 blue:236/255.0 alpha:1];
        _button.layer.cornerRadius = [self GetCornerRadius];
        _button.layer.masksToBounds = YES;
        _button.titleLabel.font = [UIFont systemFontOfSize:22];
    }
    return _button;
}

@end
