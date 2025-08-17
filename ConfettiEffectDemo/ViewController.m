//
//  ViewController.m
//  ConfettiEffectDemo
//
//  Created by 王贵彬 on 2025/8/11.
//

#import "ViewController.h"
#import "ConfettiView.h"
#import "EmojiGameViewController.h"
#import "EmojiPhysicsViewController.h"

@interface ViewController ()

@property (nonatomic,strong) ConfettiView *confetti;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confetti & Games";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.98 alpha:1.0];
    
    UIButton *gameButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [gameButton setTitle:@"🎮 Play Emoji Merge Game" forState:UIControlStateNormal];
    gameButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [gameButton setBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0]];
    [gameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    gameButton.layer.cornerRadius = 25;
    gameButton.translatesAutoresizingMaskIntoConstraints = NO;
    [gameButton addTarget:self action:@selector(playGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gameButton];
    
    UIButton *physicsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [physicsButton setTitle:@"🎪 Physics Playground" forState:UIControlStateNormal];
    physicsButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [physicsButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.4 blue:1.0 alpha:1.0]];
    [physicsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    physicsButton.layer.cornerRadius = 25;
    physicsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [physicsButton addTarget:self action:@selector(physicsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:physicsButton];
    
    UIButton *confettiButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confettiButton setTitle:@"🎉 Confetti Demo" forState:UIControlStateNormal];
    confettiButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [confettiButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]];
    [confettiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confettiButton.layer.cornerRadius = 25;
    confettiButton.translatesAutoresizingMaskIntoConstraints = NO;
    [confettiButton addTarget:self action:@selector(confettiButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confettiButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [gameButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [gameButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-60],
        [gameButton.widthAnchor constraintEqualToConstant:280],
        [gameButton.heightAnchor constraintEqualToConstant:50],
        
        [physicsButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [physicsButton.topAnchor constraintEqualToAnchor:gameButton.bottomAnchor constant:20],
        [physicsButton.widthAnchor constraintEqualToConstant:280],
        [physicsButton.heightAnchor constraintEqualToConstant:50],
        
        [confettiButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [confettiButton.topAnchor constraintEqualToAnchor:physicsButton.bottomAnchor constant:20],
        [confettiButton.widthAnchor constraintEqualToConstant:280],
        [confettiButton.heightAnchor constraintEqualToConstant:50]
    ]];

    UIButton *imageConfettiButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [imageConfettiButton setTitle:@"🖼️ Image Confetti Demo" forState:UIControlStateNormal];
    imageConfettiButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [imageConfettiButton setBackgroundColor:[UIColor colorWithRed:0.1 green:0.7 blue:0.5 alpha:1.0]];
    [imageConfettiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    imageConfettiButton.layer.cornerRadius = 25;
    imageConfettiButton.translatesAutoresizingMaskIntoConstraints = NO;
    [imageConfettiButton addTarget:self action:@selector(imageConfettiButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageConfettiButton];

    [NSLayoutConstraint activateConstraints:@[
        [imageConfettiButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [imageConfettiButton.topAnchor constraintEqualToAnchor:confettiButton.bottomAnchor constant:20],
        [imageConfettiButton.widthAnchor constraintEqualToConstant:280],
        [imageConfettiButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)playGameButtonTapped:(UIButton *)sender {
    EmojiGameViewController *gameVC = [[EmojiGameViewController alloc] init];
    [self.navigationController pushViewController:gameVC animated:YES];
}

- (void)physicsButtonTapped:(UIButton *)sender {
    EmojiPhysicsViewController *physicsVC = [[EmojiPhysicsViewController alloc] init];
    [self.navigationController pushViewController:physicsVC animated:YES];
}

- (void)confettiButtonTapped:(UIButton *)sender {
    ConfettiView *confetti = [[ConfettiView alloc] initWithEmojis:@[@"🎉", @"🎊", @"🥳", @"🤡", @"💗"]];
    confetti.frame = self.view.bounds;
    confetti.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    confetti.maxConfettiCount = 150;
    confetti.autoClearCount = 10;
    [self.view addSubview:confetti];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [confetti removeFromSuperview];
    });
}

- (void)imageConfettiButtonTapped:(UIButton *)sender {
    // TODO: Add your own images named "confetti1", "confetti2", "confetti3" to your Assets.xcassets
    NSArray<UIImage *> *images = @[
        [UIImage systemImageNamed:@"person"],
        [UIImage systemImageNamed:@"book"],
        [UIImage systemImageNamed:@"command"]
    ];
    
    // Filter out nil images in case they weren't added to assets
    NSMutableArray<UIImage *> *validImages = [NSMutableArray array];
    for (UIImage *image in images) {
        if (image) {
            [validImages addObject:image];
        }
    }

    if (validImages.count == 0) {
        // If no valid images are found, fallback to emojis
        [self confettiButtonTapped:sender];
        return;
    }

    ConfettiView *confetti = [[ConfettiView alloc] initWithImages:validImages];
    confetti.frame = self.view.bounds;
    confetti.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    confetti.maxConfettiCount = 150;
    confetti.autoClearCount = 10;
    [self.view addSubview:confetti];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [confetti removeFromSuperview];
    });
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

@end
