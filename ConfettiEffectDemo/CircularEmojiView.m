//
//  CircularEmojiView.m
//  ConfettiEffectDemo
//
//  Created by Claude on 2025/8/11.
//

#import "CircularEmojiView.h"

@interface CircularEmojiView ()

@property (nonatomic, strong) UILabel *emojiLabel;

@end

@implementation CircularEmojiView

- (instancetype)initWithEmoji:(NSString *)emoji diameter:(CGFloat)diameter {
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    if (self) {
        _emoji = emoji;
        _diameter = diameter;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // 设置圆形背景
    self.layer.cornerRadius = self.diameter / 2;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    // 添加边框
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
    
    // 添加阴影
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2, 2);
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 3;
    self.layer.masksToBounds = NO;
    
    // 创建emoji标签
    self.emojiLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.emojiLabel.text = self.emoji;
    self.emojiLabel.font = [UIFont systemFontOfSize:self.diameter * 0.7];
    self.emojiLabel.textAlignment = NSTextAlignmentCenter;
    self.emojiLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.emojiLabel];
}

- (void)setEmoji:(NSString *)emoji {
    _emoji = emoji;
    self.emojiLabel.text = emoji;
}

// 重写这个方法，让UIDynamicAnimator正确识别为圆形
- (UIDynamicItemCollisionBoundsType)collisionBoundsType {
    return UIDynamicItemCollisionBoundsTypeEllipse;
}

// 确保碰撞边界是圆形
- (UIBezierPath *)collisionBoundingPath {
    return [UIBezierPath bezierPathWithOvalInRect:self.bounds];
}

@end