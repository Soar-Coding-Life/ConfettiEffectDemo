//
//  EmojiPhysicsPlayground.h
//  ConfettiEffectDemo
//
//  Created by Claude on 2025/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EmojiType) {
    EmojiTypeRegular,
    EmojiTypeBomb,
    EmojiTypeStar
};

@class EmojiPhysicsPlayground;

@protocol EmojiPhysicsDelegate <NSObject>
- (void)scoreDidChange:(NSInteger)score;
- (void)gameOverWithScore:(NSInteger)score;
@end

@interface EmojiPhysicsPlayground : UIView

@property (nonatomic, weak) id<EmojiPhysicsDelegate> delegate;
@property (nonatomic, assign) BOOL gravityEnabled;
@property (nonatomic, assign) BOOL shakeDetectionEnabled;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startPhysics;
- (void)stopPhysics;
- (void)addEmoji:(EmojiType)type atPoint:(CGPoint)point;
- (void)reset;

@end

NS_ASSUME_NONNULL_END