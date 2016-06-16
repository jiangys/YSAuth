//
//  YSShareView.m
//  YSAuth
//
//  Created by jiangys on 16/6/16.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import "YSShareView.h"

@implementation YSShareView

- (void)showShareView
{
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 200);
    bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self addSubview:bgView];
    [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setGestureHidden)]];
    
    UIView *shareView = [[UIView alloc] init];
    shareView.frame = CGRectMake(0, self.frame.size.height - 200, self.frame.size.width, 200);
    shareView.backgroundColor = [UIColor whiteColor];
    [self addSubview:shareView];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)setGestureHidden
{
    [self hideShareView];
}

- (void)hideShareView
{
    [self removeFromSuperview];
}

- (void)setShareItemArray:(NSArray *)shareItemArray
{
    _shareItemArray = shareItemArray;
    
    NSUInteger count = shareItemArray.count;
    for (int i = 0; i< count; i++) {
        UIButton *shareButton = [[UIButton alloc] init];
        shareButton.adjustsImageWhenHighlighted = NO;
        shareButton.tag = i;
        [shareButton setTitle:shareItemArray[i] forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [shareButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [shareButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        // 监听按钮点击
        [shareButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 内边距(四周)
    CGFloat inset = 10;
    NSUInteger count = _shareItemArray.count;
    CGFloat btnW = (self.frame.size.width - 2 * inset) / ShareMaxCols;
    CGFloat btnH = (self.frame.size.height - inset) / ShareMaxRows;
    for (int i = 0; i<count; i++) {
        UIButton *btn = self.subviews[i];
        
        CGRect frame = self.frame;
        frame.size.width = btnW;
        frame.size.height = btnH;
        frame.origin.x = inset + (i%ShareMaxCols) * btnW;
        frame.origin.y = inset + (i/ShareMaxCols) * btnH;
        
        btn.frame = frame;
    }
}

/**
 *  监听表情按钮点击
 *
 *  @param btn 被点击的表情按钮
 */
- (void)btnClick:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(shareViewDidSelectTag:)]) {
        [_delegate shareViewDidSelectTag:btn.tag];
    }
}
@end
