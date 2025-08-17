#import "EmojiPhysicsPlayground.h"
#import <CoreMotion/CoreMotion.h>

@interface EmojiPhysicsPlayground () <UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) NSMutableArray<UIView *> *emojis;
@property (nonatomic, strong) NSMutableArray<UIView *> *bombs;
@property (nonatomic, strong) NSMutableArray<UIView *> *stars;

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSTimer *gameTimer;

@end

@implementation EmojiPhysicsPlayground

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gravityEnabled = YES;
        _shakeDetectionEnabled = YES;
        _emojis = [NSMutableArray array];
        _bombs = [NSMutableArray array];
        _stars = [NSMutableArray array];
        
        [self setupPhysics];
        [self setupMotionManager];
    }
    return self;
}

- (void)setupPhysics {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    
    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.collision.collisionDelegate = self;
    [self.animator addBehavior:self.collision];
    
    self.gravity = [[UIGravityBehavior alloc] init];
    [self.animator addBehavior:self.gravity];
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.itemBehavior.elasticity = 0.6;
    self.itemBehavior.friction = 0.3;
    self.itemBehavior.resistance = 0.2;
    [self.animator addBehavior:self.itemBehavior];
}

- (void)setupMotionManager {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 1.0 / 60.0;
}

- (void)startPhysics {
    if (self.gravityEnabled && self.motionManager.isAccelerometerAvailable) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (accelerometerData) {
                self.gravity.gravityDirection = CGVectorMake(accelerometerData.acceleration.x * 2, -accelerometerData.acceleration.y * 2);
            }
        }];
    }
    
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(spawnRandomEmoji) userInfo:nil repeats:YES];
}

- (void)stopPhysics {
    [self.motionManager stopAccelerometerUpdates];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
}

- (void)reset {
    [self stopPhysics];
    
    for (UIView *view in self.emojis) { [self removeView:view]; }
    for (UIView *view in self.bombs) { [self removeView:view]; }
    for (UIView *view in self.stars) { [self removeView:view]; }
    
    [self.emojis removeAllObjects];
    [self.bombs removeAllObjects];
    [self.stars removeAllObjects];
    
    self.score = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scoreDidChange:)]) {
        [self.delegate scoreDidChange:self.score];
    }
    
    [self startPhysics];
}

- (void)addEmoji:(EmojiType)type atPoint:(CGPoint)point {
    NSString *emojiString;
    CGFloat size = 40.0;
    
    switch (type) {
        case EmojiTypeRegular:
            emojiString = @"😀";
            break;
        case EmojiTypeBomb:
            emojiString = @"💣";
            size = 50.0;
            break;
        case EmojiTypeStar:
            emojiString = @"🌟";
            size = 30.0;
            break;
    }
    
    UILabel *emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    emojiLabel.text = emojiString;
    emojiLabel.font = [UIFont systemFontOfSize:size - 4];
    emojiLabel.textAlignment = NSTextAlignmentCenter;
    emojiLabel.center = point;
    
    [self addSubview:emojiLabel];
    
    if (type == EmojiTypeBomb) {
        [self.bombs addObject:emojiLabel];
    } else if (type == EmojiTypeStar) {
        [self.stars addObject:emojiLabel];
    } else {
        [self.emojis addObject:emojiLabel];
    }
    
    [self.collision addItem:emojiLabel];
    [self.gravity addItem:emojiLabel];
    [self.itemBehavior addItem:emojiLabel];
}

- (void)spawnRandomEmoji {
    int random = arc4random_uniform(10);
    EmojiType type;
    if (random < 2) {
        type = EmojiTypeBomb;
    } else if (random < 4) {
        type = EmojiTypeStar;
    } else {
        type = EmojiTypeRegular;
    }
    
    CGFloat x = arc4random_uniform(self.bounds.size.width);
    [self addEmoji:type atPoint:CGPointMake(x, -50)];
}

- (void)removeView:(UIView *)view {
    [self.collision removeItem:view];
    [self.gravity removeItem:view];
    [self.itemBehavior removeItem:view];
    [view removeFromSuperview];
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p {
    UIView *view1 = (UIView *)item1;
    UIView *view2 = (UIView *)item2;
    
    BOOL isView1Bomb = [self.bombs containsObject:view1];
    BOOL isView2Bomb = [self.bombs containsObject:view2];
    BOOL isView1Star = [self.stars containsObject:view1];
    BOOL isView2Star = [self.stars containsObject:view2];
    
    if (isView1Bomb) { [self handleBombCollision:view1]; }
    if (isView2Bomb) { [self handleBombCollision:view2]; }
    
    if (isView1Star && !isView2Bomb) { [self handleStarCollision:view1 withView:view2]; }
    if (isView2Star && !isView1Bomb) { [self handleStarCollision:view2 withView:view1]; }
}

- (void)handleBombCollision:(UIView *)bomb {
    [self removeView:bomb];
    [self.bombs removeObject:bomb];
    
    self.score -= 50;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scoreDidChange:)]) {
        [self.delegate scoreDidChange:self.score];
    }
    
    // Explosion effect
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [feedback impactOccurred];
}

- (void)handleStarCollision:(UIView *)star withView:(UIView *)otherView {
    if ([self.emojis containsObject:otherView]) {
        [self removeView:star];
        [self.stars removeObject:star];
        
        self.score += 100;
        if (self.delegate && [self.delegate respondsToSelector:@selector(scoreDidChange:)]) {
            [self.delegate scoreDidChange:self.score];
        }
        
        UINotificationFeedbackGenerator *feedback = [[UINotificationFeedbackGenerator alloc] init];
        [feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
}

@end