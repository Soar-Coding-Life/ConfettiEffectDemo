//
//  ConfettiView.m
//  ConfettiEffectDemo
//
//  Created by 王贵彬 on 2025/8/11.
//

#import "ConfettiView.h"


typedef NS_ENUM(NSUInteger, ConfettiType) {
    ConfettiTypeEmoji,
    ConfettiTypeImage
};

@interface ConfettiView ()

@property (nonatomic, assign) ConfettiType confettiType;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) NSMutableArray<UIView *> *confettiViews;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

@end

@implementation ConfettiView

- (instancetype)initWithEmojis:(NSArray<NSString *> *)emojis {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.emojis = emojis;
        self.confettiType = ConfettiTypeEmoji;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImages:(NSArray<UIImage *> *)images {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.confettiImages = images;
        self.confettiType = ConfettiTypeImage;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.confettiViews = [NSMutableArray array];
    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collision];
    self.gravity = [[UIGravityBehavior alloc] init];
    [self.animator addBehavior:self.gravity];
    self.itemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.itemBehavior.elasticity = 0.5;
    self.itemBehavior.friction = 0.5;
    self.itemBehavior.resistance = 0.8;
    self.itemBehavior.allowsRotation = YES;
    [self.animator addBehavior:self.itemBehavior];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    [self shootConfettiFromPoint:point];
}

- (void)shootConfettiFromPoint:(CGPoint)point {
    NSUInteger count = 8 + arc4random_uniform(5);
    for (NSUInteger i = 0; i < count; i++) {
        UIView *confetti;
        if (self.confettiType == ConfettiTypeEmoji) {
            NSString *emoji = self.emojis[arc4random_uniform((uint32_t)self.emojis.count)];
            UILabel *label = [[UILabel alloc] init];
            label.text = emoji;
            label.font = [UIFont systemFontOfSize:36];
            label.frame = CGRectMake(0, 0, 44, 44);
            confetti = label;
        } else {
            UIImage *image = self.confettiImages[arc4random_uniform((uint32_t)self.confettiImages.count)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(0, 0, 44, 44);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            confetti = imageView;
        }
        
        confetti.center = point;
        [self addSubview:confetti];
        [self.confettiViews addObject:confetti];

        // 初始缩放动画
        confetti.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:0.2 animations:^{
            confetti.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                confetti.transform = CGAffineTransformIdentity;
            }];
        }];

        // 物理仿真
        [self.collision addItem:confetti];
        [self.gravity addItem:confetti];
        [self.itemBehavior addItem:confetti];

        CGFloat angle = ((CGFloat)arc4random() / UINT32_MAX) * M_PI * 2;
        CGFloat speed = 400 + arc4random_uniform(200);
        [self.itemBehavior addLinearVelocity:CGPointMake(cos(angle)*speed, sin(angle)*speed) forItem:confetti];
    }
    
    // 自动清理逻辑
    if (self.maxConfettiCount > 0 && self.confettiViews.count > self.maxConfettiCount) {
        NSUInteger removeCount = self.autoClearCount > 0 ? self.autoClearCount : (self.confettiViews.count - self.maxConfettiCount);
        [self clearSomeConfetti:removeCount];
    }
}

- (void)clearAllConfetti {
    for (UIView *confetti in self.confettiViews) {
        [self.collision removeItem:confetti];
        [self.gravity removeItem:confetti];
        [self.itemBehavior removeItem:confetti];
        [confetti removeFromSuperview];
    }
    [self.confettiViews removeAllObjects];
}

- (void)clearSomeConfetti:(NSUInteger)count {
    if (count == 0 || self.confettiViews.count == 0) return;
    NSUInteger removeCount = MIN(count, self.confettiViews.count);
    for (NSUInteger i = 0; i < removeCount; i++) {
        UIView *confetti = self.confettiViews.firstObject;
        [self.collision removeItem:confetti];
        [self.gravity removeItem:confetti];
        [self.itemBehavior removeItem:confetti];
        [confetti removeFromSuperview];
        [self.confettiViews removeObjectAtIndex:0];
    }
}

@end
