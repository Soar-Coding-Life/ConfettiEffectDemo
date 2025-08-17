//
//  CircularEmojiView.h
//  ConfettiEffectDemo
//
//  Created by Claude on 2025/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircularEmojiView : UIView

@property (nonatomic, copy) NSString *emoji;
@property (nonatomic, assign) CGFloat diameter;

- (instancetype)initWithEmoji:(NSString *)emoji diameter:(CGFloat)diameter;

@end

NS_ASSUME_NONNULL_END