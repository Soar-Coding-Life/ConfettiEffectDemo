#import <UIKit/UIKit.h>
#import "EmojiGameModels.h"

NS_ASSUME_NONNULL_BEGIN

@class EmojiGameView;

@protocol EmojiGameViewDelegate <NSObject>

- (void)gameDidEnd:(NSInteger)finalScore;
- (void)scoreDidUpdate:(NSInteger)newScore;

@end

@interface EmojiGameView : UIView

@property (nonatomic, weak) id<EmojiGameViewDelegate> delegate;
@property (nonatomic, strong, readonly) GameState *gameState;

- (instancetype)initWithFrame:(CGRect)frame configuration:(GameConfiguration *)configuration;
- (void)resetGame;
- (void)move:(UISwipeGestureRecognizerDirection)direction;

@end

NS_ASSUME_NONNULL_END