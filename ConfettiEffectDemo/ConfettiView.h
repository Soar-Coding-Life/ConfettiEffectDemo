//
//  ConfettiView.h
//  ConfettiEffectDemo
//
//  Created by 王贵彬 on 2025/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfettiView : UIView

@property (nonatomic, assign) NSUInteger maxConfettiCount; // 超过此数自动清理
@property (nonatomic, assign) NSUInteger autoClearCount; // 每次自动清理多少个

@property (nonatomic, copy) NSArray<NSString *> *emojis;
@property (nonatomic, copy) NSArray<UIImage *> *confettiImages;

- (instancetype)initWithEmojis:(NSArray<NSString *> *)emojis;
- (instancetype)initWithImages:(NSArray<UIImage *> *)images;

- (void)shootConfettiFromPoint:(CGPoint)point;
- (void)clearAllConfetti;
- (void)clearSomeConfetti:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
