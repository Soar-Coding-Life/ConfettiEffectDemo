//
//  EmojiGameViewController.m
//  ConfettiEffectDemo
//
//  Created by Claude on 2025/8/11.
//

#import "EmojiGameViewController.h"
#import "EmojiGameView.h"
#import "EmojiGameModels.h"

@interface EmojiGameViewController () <EmojiGameViewDelegate>

@property (nonatomic, strong) EmojiGameView *gameView;
@property (nonatomic, strong) UIView *topPanel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *bestScoreLabel;
@property (nonatomic, strong) UIButton *resetButton;

@property (nonatomic, assign) NSInteger bestScore;
@property (nonatomic, assign) NSInteger lastMilestone;

@end

@implementation EmojiGameViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupSwipeGestures];
    [self.gameView resetGame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTopPanel];
    [self setupGameView];
}

- (void)setupTopPanel {
    self.topPanel = [[UIView alloc] init];
    self.topPanel.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    self.topPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topPanel];

    // Score Label
    UIView *scoreContainer = [self createInfoContainer];
    [self.topPanel addSubview:scoreContainer];
    
    UILabel *scoreTitle = [self createTitleLabel:@"SCORE"];
    [scoreContainer addSubview:scoreTitle];
    
    self.scoreLabel = [self createValueLabel:@"0"];
    [scoreContainer addSubview:self.scoreLabel];

    // Best Score Label
    UIView *bestContainer = [self createInfoContainer];
    [self.topPanel addSubview:bestContainer];
    
    UILabel *bestTitle = [self createTitleLabel:@"BEST"];
    [bestContainer addSubview:bestTitle];
    
    self.bestScoreLabel = [self createValueLabel:@"0"]; // You would load the saved best score here
    [bestContainer addSubview:self.bestScoreLabel];

    // Reset Button
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resetButton setTitle:@"🔄" forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [self.resetButton setTintColor:[UIColor whiteColor]];
    self.resetButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.72 blue:0.65 alpha:1.0];
    self.resetButton.layer.cornerRadius = 8;
    [self.resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topPanel addSubview:self.resetButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.topPanel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.topPanel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.topPanel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.topPanel.heightAnchor constraintEqualToConstant:100],

        [scoreContainer.leadingAnchor constraintEqualToAnchor:self.topPanel.leadingAnchor constant:20],
        [scoreContainer.centerYAnchor constraintEqualToAnchor:self.topPanel.centerYAnchor],
        [scoreTitle.centerXAnchor constraintEqualToAnchor:scoreContainer.centerXAnchor],
        [scoreTitle.topAnchor constraintEqualToAnchor:scoreContainer.topAnchor constant:8],
        [self.scoreLabel.centerXAnchor constraintEqualToAnchor:scoreContainer.centerXAnchor],
        [self.scoreLabel.bottomAnchor constraintEqualToAnchor:scoreContainer.bottomAnchor constant:-8],

        [bestContainer.leadingAnchor constraintEqualToAnchor:scoreContainer.trailingAnchor constant:10],
        [bestContainer.centerYAnchor constraintEqualToAnchor:self.topPanel.centerYAnchor],
        [bestTitle.centerXAnchor constraintEqualToAnchor:bestContainer.centerXAnchor],
        [bestTitle.topAnchor constraintEqualToAnchor:bestContainer.topAnchor constant:8],
        [self.bestScoreLabel.centerXAnchor constraintEqualToAnchor:bestContainer.centerXAnchor],
        [self.bestScoreLabel.bottomAnchor constraintEqualToAnchor:bestContainer.bottomAnchor constant:-8],

        [self.resetButton.trailingAnchor constraintEqualToAnchor:self.topPanel.trailingAnchor constant:-20],
        [self.resetButton.centerYAnchor constraintEqualToAnchor:self.topPanel.centerYAnchor],
        [self.resetButton.widthAnchor constraintEqualToConstant:60],
        [self.resetButton.heightAnchor constraintEqualToConstant:60],
    ]];
}

- (UIView *)createInfoContainer {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor colorWithRed:0.78 green:0.72 blue:0.65 alpha:1.0];
    container.layer.cornerRadius = 8;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [container.widthAnchor constraintEqualToConstant:100].active = YES;
    [container.heightAnchor constraintEqualToConstant:60].active = YES;
    return container;
}

- (UILabel *)createTitleLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UILabel *)createValueLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:24];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (void)setupGameView {
    GameConfiguration *config = [GameConfiguration defaultConfiguration];
    self.gameView = [[EmojiGameView alloc] initWithFrame:CGRectZero configuration:config];
    self.gameView.delegate = self;
    self.gameView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.gameView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.gameView.topAnchor constraintEqualToAnchor:self.topPanel.bottomAnchor],
        [self.gameView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.gameView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.gameView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupSwipeGestures {
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

#pragma mark - Button Actions

- (void)resetButtonTapped:(UIButton *)sender {
    [self.gameView resetGame];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender {
    [self.gameView move:sender.direction];
}

#pragma mark - EmojiGameViewDelegate

- (void)gameDidEnd:(NSInteger)finalScore {
    NSString *message = [NSString stringWithFormat:@"Final Score: %ld", (long)finalScore];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Play Again"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.gameView resetGame];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Quit"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)scoreDidUpdate:(NSInteger)newScore {
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)newScore];
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
