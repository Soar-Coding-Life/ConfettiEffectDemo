#import "EmojiPhysicsViewController.h"
#import "EmojiPhysicsPlayground.h"

@interface EmojiPhysicsViewController () <EmojiPhysicsDelegate>

@property (nonatomic, strong) EmojiPhysicsPlayground *playground;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *instructionsLabel;

@end

@implementation EmojiPhysicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Emoji Physics Game";
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0];
    
    [self setupUI];
    [self setupPlayground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.playground startPhysics];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playground stopPhysics];
}

- (void)setupUI {
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.text = @"Score: 0";
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.font = [UIFont boldSystemFontOfSize:24];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scoreLabel];
    
    self.instructionsLabel = [[UILabel alloc] init];
    self.instructionsLabel.text = @"Tap to add emojis. Avoid the bombs and collect the stars!";
    self.instructionsLabel.textColor = [UIColor whiteColor];
    self.instructionsLabel.font = [UIFont systemFontOfSize:14];
    self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.instructionsLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scoreLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.scoreLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        
        [self.instructionsLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.instructionsLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
}

- (void)setupPlayground {
    self.playground = [[EmojiPhysicsPlayground alloc] initWithFrame:CGRectZero];
    self.playground.delegate = self;
    self.playground.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.playground];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.playground.topAnchor constraintEqualToAnchor:self.scoreLabel.bottomAnchor constant:20],
        [self.playground.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playground.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playground.bottomAnchor constraintEqualToAnchor:self.instructionsLabel.topAnchor constant:-20]
    ]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.playground addGestureRecognizer:tapRecognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    CGPoint tapLocation = [sender locationInView:self.playground];
    [self.playground addEmoji:EmojiTypeRegular atPoint:tapLocation];
}

#pragma mark - EmojiPhysicsDelegate

- (void)scoreDidChange:(NSInteger)score {
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)score];
}

- (void)gameOverWithScore:(NSInteger)score {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over"
                                                                   message:[NSString stringWithFormat:@"Final Score: %ld", (long)score]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Play Again"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.playground reset];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Quit"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end