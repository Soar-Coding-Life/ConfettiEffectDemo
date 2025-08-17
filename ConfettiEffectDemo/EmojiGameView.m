#import "EmojiGameView.h"

@interface EmojiGameView ()

@property (nonatomic, strong) GameConfiguration *configuration;
@property (nonatomic, strong, readwrite) GameState *gameState;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<id> *> *grid;
@property (nonatomic, strong) UIView *gridBackground;

@end

@implementation EmojiGameView

- (instancetype)initWithFrame:(CGRect)frame configuration:(GameConfiguration *)configuration {
    self = [super initWithFrame:frame];
    if (self) {
        _configuration = configuration;
        [self setupUI];
        [self resetGame];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.98 alpha:1.0];
    
    self.gridBackground = [[UIView alloc] init];
    self.gridBackground.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    self.gridBackground.layer.cornerRadius = 8.0;
    [self addSubview:self.gridBackground];
    
    // Layout grid background
    self.gridBackground.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.gridBackground.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.9],
        [self.gridBackground.heightAnchor constraintEqualToAnchor:self.gridBackground.widthAnchor],
        [self.gridBackground.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.gridBackground.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
    
    [self layoutIfNeeded]; // Ensure grid background has a frame
    
    CGFloat totalSpacing = 10.0 * (self.configuration.gridSize + 1);
    CGFloat cellDimension = (self.gridBackground.frame.size.width - totalSpacing) / self.configuration.gridSize;
    
    for (int i = 0; i < self.configuration.gridSize; i++) {
        for (int j = 0; j < self.configuration.gridSize; j++) {
            UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(10 + j * (cellDimension + 10), 10 + i * (cellDimension + 10), cellDimension, cellDimension)];
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            cell.layer.cornerRadius = 4.0;
            [self.gridBackground addSubview:cell];
        }
    }
}

- (void)resetGame {
    [self.gridBackground.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupUI];
    
    self.gameState = [[GameState alloc] init];
    if (self.delegate && [self.delegate respondsToSelector:@selector(scoreDidUpdate:)]) {
        [self.delegate scoreDidUpdate:self.gameState.score];
    }
    
    self.grid = [NSMutableArray arrayWithCapacity:self.configuration.gridSize];
    for (int i = 0; i < self.configuration.gridSize; i++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.configuration.gridSize];
        for (int j = 0; j < self.configuration.gridSize; j++) {
            [row addObject:[NSNull null]];
        }
        [self.grid addObject:row];
    }
    
    [self spawnNewTile];
    [self spawnNewTile];
}

- (void)spawnNewTile {
    NSMutableArray<NSValue *> *emptyCells = [NSMutableArray array];
    for (int i = 0; i < self.configuration.gridSize; i++) {
        for (int j = 0; j < self.configuration.gridSize; j++) {
            if (self.grid[i][j] == [NSNull null]) {
                [emptyCells addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            }
        }
    }
    
    if (emptyCells.count > 0) {
        NSInteger index = arc4random_uniform((uint32_t)emptyCells.count);
        CGPoint point = [emptyCells[index] CGPointValue];
        
        NSInteger levelValue = (arc4random_uniform(10) < 9) ? 2 : 4; // 90% chance of 2, 10% of 4
        EmojiLevel *level = [self levelForValue:levelValue];
        
        GameTile *tile = [[GameTile alloc] initWithLevel:level row:point.x column:point.y];
        [self addTile:tile];
    }
}

- (void)addTile:(GameTile *)tile {
    self.grid[tile.row][tile.column] = tile;
    
    CGFloat totalSpacing = 10.0 * (self.configuration.gridSize + 1);
    CGFloat cellDimension = (self.gridBackground.frame.size.width - totalSpacing) / self.configuration.gridSize;
    
    UILabel *tileView = [[UILabel alloc] initWithFrame:CGRectMake(10 + tile.column * (cellDimension + 10), 10 + tile.row * (cellDimension + 10), cellDimension, cellDimension)];
    tileView.text = tile.level.emoji;
    tileView.font = [UIFont boldSystemFontOfSize:40];
    tileView.textAlignment = NSTextAlignmentCenter;
    tileView.backgroundColor = [self colorForLevel:tile.level.level];
    tileView.layer.cornerRadius = 4.0;
    tileView.clipsToBounds = YES;
    
    tile.tileView = tileView;
    [self.gridBackground addSubview:tileView];
}

- (void)move:(UISwipeGestureRecognizerDirection)direction {
    if (self.gameState.isGameOver) return;

    BOOL moved = NO;
    NSMutableArray<dispatch_block_t> *animations = [NSMutableArray array];

    for (int i = 0; i < self.configuration.gridSize; i++) {
        // 1. Extract the line of tiles
        NSMutableArray *line = [NSMutableArray array];
        for (int j = 0; j < self.configuration.gridSize; j++) {
            NSInteger r = (direction == UISwipeGestureRecognizerDirectionUp || direction == UISwipeGestureRecognizerDirectionDown) ? j : i;
            NSInteger c = (direction == UISwipeGestureRecognizerDirectionUp || direction == UISwipeGestureRecognizerDirectionDown) ? i : j;
            if (self.grid[r][c] != [NSNull null]) {
                [line addObject:self.grid[r][c]];
            }
        }

        // 2. Reverse if necessary (for down/right moves)
        BOOL reverse = direction == UISwipeGestureRecognizerDirectionRight || direction == UISwipeGestureRecognizerDirectionDown;
        if (reverse) {
            line = [[[line reverseObjectEnumerator] allObjects] mutableCopy];
        }

        // 3. Merge the line
        NSMutableArray *newLine = [NSMutableArray array];
        NSMutableArray<GameTile *> *mergedTiles = [NSMutableArray array];
        for (int j = 0; j < line.count; j++) {
            GameTile *tile = line[j];
            if (newLine.count > 0 && ! [mergedTiles containsObject:[newLine lastObject]] && ((GameTile *)[newLine lastObject]).level.level == tile.level.level) {
                GameTile *lastTile = [newLine lastObject];
                
                EmojiLevel *newLevel = [self levelForValue:lastTile.level.level * 2];
                lastTile.level = newLevel;
                [mergedTiles addObject:lastTile];
                
                [self.gameState addScore:newLevel.score];
                if (self.delegate && [self.delegate respondsToSelector:@selector(scoreDidUpdate:)]) {
                    [self.delegate scoreDidUpdate:self.gameState.score];
                }
                
                // Animation for merge
                [animations addObject:^{
                    [tile.tileView removeFromSuperview];
                    UILabel *label = (UILabel *)lastTile.tileView;
                    label.text = newLevel.emoji;
                    lastTile.tileView.backgroundColor = [self colorForLevel:newLevel.level];
                    lastTile.tileView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }];
                
            } else {
                [newLine addObject:tile];
            }
        }
        
        // 4. Reverse back
        if (reverse) {
            newLine = [[[newLine reverseObjectEnumerator] allObjects] mutableCopy];
        }

        // 5. Update grid and create move animations
        for (int j = 0; j < self.configuration.gridSize; j++) {
            NSInteger r = (direction == UISwipeGestureRecognizerDirectionUp || direction == UISwipeGestureRecognizerDirectionDown) ? j : i;
            NSInteger c = (direction == UISwipeGestureRecognizerDirectionUp || direction == UISwipeGestureRecognizerDirectionDown) ? i : j;
            
            GameTile *oldTile = self.grid[r][c];
            GameTile *newTile = nil;
            
            if (reverse) {
                if (j >= self.configuration.gridSize - newLine.count) {
                    newTile = newLine[j - (self.configuration.gridSize - newLine.count)];
                }
            } else {
                if (j < newLine.count) {
                    newTile = newLine[j];
                }
            }

            if (oldTile != [NSNull null] && oldTile != newTile) {
                 self.grid[r][c] = [NSNull null];
            }
            
            if (newTile && (newTile.row != r || newTile.column != c)) {
                moved = YES;
                self.grid[r][c] = newTile;
                newTile.row = r;
                newTile.column = c;
                
                [animations addObject:^{
                    CGFloat totalSpacing = 10.0 * (self.configuration.gridSize + 1);
                    CGFloat cellDimension = (self.gridBackground.frame.size.width - totalSpacing) / self.configuration.gridSize;
                    newTile.tileView.frame = CGRectMake(10 + c * (cellDimension + 10), 10 + r * (cellDimension + 10), cellDimension, cellDimension);
                }];
            }
        }
    }

    // Execute animations
    [UIView animateWithDuration:0.15 animations:^{
        for (dispatch_block_t animation in animations) {
            animation();
        }
    } completion:^(BOOL finished) {
        for (UIView *view in self.gridBackground.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                view.transform = CGAffineTransformIdentity;
            }
        }
        if (moved) {
            [self spawnNewTile];
            [self checkForGameOver];
        }
    }];
}

- (void)checkForGameOver {
    BOOL hasEmptyCells = NO;
    for (int i = 0; i < self.configuration.gridSize; i++) {
        for (int j = 0; j < self.configuration.gridSize; j++) {
            if (self.grid[i][j] == [NSNull null]) {
                hasEmptyCells = YES;
                break;
            }
        }
        if (hasEmptyCells) break;
    }
    
    if (hasEmptyCells) return;
    
    BOOL canMerge = NO;
    for (int i = 0; i < self.configuration.gridSize; i++) {
        for (int j = 0; j < self.configuration.gridSize; j++) {
            GameTile *tile = self.grid[i][j];
            // Check right
            if (j + 1 < self.configuration.gridSize) {
                GameTile *rightTile = self.grid[i][j+1];
                if (tile.level.level == rightTile.level.level) {
                    canMerge = YES;
                    break;
                }
            }
            // Check down
            if (i + 1 < self.configuration.gridSize) {
                GameTile *downTile = self.grid[i+1][j];
                if (tile.level.level == downTile.level.level) {
                    canMerge = YES;
                    break;
                }
            }
        }
        if (canMerge) break;
    }
    
    if (!canMerge) {
        self.gameState.isGameOver = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameDidEnd:)]) {
            [self.delegate gameDidEnd:self.gameState.score];
        }
    }
}

- (EmojiLevel *)levelForValue:(NSInteger)value {
    for (EmojiLevel *level in self.configuration.emojiLevels) {
        if (level.level == value) {
            return level;
        }
    }
    return nil;
}

- (UIColor *)colorForLevel:(NSInteger)level {
    switch (level) {
        case 2:    return [UIColor colorWithRed:0.93 green:0.89 blue:0.85 alpha:1.0];
        case 4:    return [UIColor colorWithRed:0.93 green:0.88 blue:0.78 alpha:1.0];
        case 8:    return [UIColor colorWithRed:0.95 green:0.69 blue:0.47 alpha:1.0];
        case 16:   return [UIColor colorWithRed:0.96 green:0.58 blue:0.39 alpha:1.0];
        case 32:   return [UIColor colorWithRed:0.96 green:0.48 blue:0.37 alpha:1.0];
        case 64:   return [UIColor colorWithRed:0.96 green:0.37 blue:0.23 alpha:1.0];
        case 128:  return [UIColor colorWithRed:0.93 green:0.81 blue:0.45 alpha:1.0];
        case 256:  return [UIColor colorWithRed:0.93 green:0.80 blue:0.38 alpha:1.0];
        case 512:  return [UIColor colorWithRed:0.93 green:0.78 blue:0.30 alpha:1.0];
        case 1024: return [UIColor colorWithRed:0.93 green:0.77 blue:0.23 alpha:1.0];
        case 2048: return [UIColor colorWithRed:0.93 green:0.76 blue:0.15 alpha:1.0];
        default:   return [UIColor colorWithRed:0.80 green:0.76 blue:0.72 alpha:1.0];
    }
}

@end