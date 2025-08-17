//
//  EmojiGameModels.h
//  ConfettiEffectDemo
//
//  Created by Claude on 2025/8/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmojiLevel : NSObject

@property (nonatomic, assign) NSInteger level; // Represents the number (2, 4, 8, ...)
@property (nonatomic, copy) NSString *emoji;
@property (nonatomic, assign) CGFloat size; // Size can still be used for visual representation
@property (nonatomic, assign) NSInteger score;

- (instancetype)initWithLevel:(NSInteger)level emoji:(NSString *)emoji size:(CGFloat)size score:(NSInteger)score;

@end

@interface GameTile : NSObject

@property (nonatomic, strong) EmojiLevel *level;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, strong) UIView *tileView; // A view to represent the tile on the grid

- (instancetype)initWithLevel:(EmojiLevel *)level row:(NSInteger)row column:(NSInteger)column;

@end

@interface GameConfiguration : NSObject

@property (nonatomic, strong) NSArray<EmojiLevel *> *emojiLevels;
@property (nonatomic, assign) NSInteger gridSize; // e.g., 4 for a 4x4 grid
@property (nonatomic, assign) NSInteger maxLevel;


+ (instancetype)defaultConfiguration;

@end

@interface GameState : NSObject

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) BOOL isGameOver;

- (void)addScore:(NSInteger)points;

@end

@interface LeaderboardEntry : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString *challengerID;
@property (nonatomic, assign) NSInteger score;

- (instancetype)initWithChallengerID:(NSString *)challengerID score:(NSInteger)score;

@end

NS_ASSUME_NONNULL_END


