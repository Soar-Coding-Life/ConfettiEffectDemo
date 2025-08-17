//
//  EmojiGameModels.m
//  ConfettiEffectDemo
//
//  Created by Claude on 2025/8/11.
//

#import "EmojiGameModels.h"

@implementation EmojiLevel

- (instancetype)initWithLevel:(NSInteger)level emoji:(NSString *)emoji size:(CGFloat)size score:(NSInteger)score {
    self = [super init];
    if (self) {
        _level = level;
        _emoji = emoji;
        _size = size;
        _score = score;
    }
    return self;
}

@end

@implementation GameTile

- (instancetype)initWithLevel:(EmojiLevel *)level row:(NSInteger)row column:(NSInteger)column {
    self = [super init];
    if (self) {
        _level = level;
        _row = row;
        _column = column;
    }
    return self;
}

@end

@implementation GameConfiguration

+ (instancetype)defaultConfiguration {
    GameConfiguration *config = [[GameConfiguration alloc] init];
    
    // 2048-style levels: 2, 4, 8, 16, ...
    config.emojiLevels = @[
        [[EmojiLevel alloc] initWithLevel:2    emoji:@"😀" size:60 score:2],
        [[EmojiLevel alloc] initWithLevel:4    emoji:@"😎" size:60 score:4],
        [[EmojiLevel alloc] initWithLevel:8    emoji:@"😂" size:60 score:8],
        [[EmojiLevel alloc] initWithLevel:16   emoji:@"😍" size:60 score:16],
        [[EmojiLevel alloc] initWithLevel:32   emoji:@"🥳" size:60 score:32],
        [[EmojiLevel alloc] initWithLevel:64   emoji:@"🤩" size:60 score:64],
        [[EmojiLevel alloc] initWithLevel:128  emoji:@"🤯" size:60 score:128],
        [[EmojiLevel alloc] initWithLevel:256  emoji:@"👑" size:60 score:256],
        [[EmojiLevel alloc] initWithLevel:512  emoji:@"💎" size:60 score:512],
        [[EmojiLevel alloc] initWithLevel:1024 emoji:@"🦄" size:60 score:1024],
        [[EmojiLevel alloc] initWithLevel:2048 emoji:@"🌟" size:60 score:2048]
    ];
    
    config.gridSize = 3;
    config.maxLevel = 2048;
    
    return config;
}

@end

@implementation GameState

- (instancetype)init {
    self = [super init];
    if (self) {
        _score = 0;
        _isGameOver = NO;
    }
    return self;
}

- (void)addScore:(NSInteger)points {
    _score += points;
}

@end

@implementation LeaderboardEntry

- (instancetype)initWithChallengerID:(NSString *)challengerID score:(NSInteger)score {
    self = [super init];
    if (self) {
        _challengerID = [challengerID copy];
        _score = score;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.challengerID forKey:@"challengerID"];
    [coder encodeInteger:self.score forKey:@"score"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _challengerID = [coder decodeObjectOfClass:[NSString class] forKey:@"challengerID"];
        _score = [coder decodeIntegerForKey:@"score"];
    }
    return self;
}

@end

