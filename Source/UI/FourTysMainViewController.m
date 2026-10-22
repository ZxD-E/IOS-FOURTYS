#import "FourTysMainViewController.h"
#import "../Core/SAProtocolHandler.h"

@interface FourTysMainViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *glassContainerView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation FourTysMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLayoutConstraintsAndViews];
    [self initiateServerDataQuery];
}

- (void)setupLayoutConstraintsAndViews {
    self.view.backgroundColor = [UIColor colorWithRed:0.04 green:0.05 blue:0.07 alpha:1.0];
    
    // Background Container
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backgroundImageView];

    // Dark Gradient Overlay
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:0.03 green:0.04 blue:0.06 alpha:0.85].CGColor,
                        (id)[UIColor colorWithRed:0.08 green:0.10 blue:0.15 alpha:0.95].CGColor];
    [self.view.layer addSublayer:gradient];

    // Main Card
    CGFloat cardWidth = MIN(self.view.bounds.size.width - 40, 420);
    self.glassContainerView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - cardWidth)/2, 80, cardWidth, 260)];
    self.glassContainerView.backgroundColor = [UIColor colorWithRed:0.10 green:0.12 blue:0.18 alpha:0.6];
    self.glassContainerView.layer.cornerRadius = 16;
    self.glassContainerView.layer.borderWidth = 1.0;
    self.glassContainerView.layer.borderColor = [UIColor colorWithRed:0.20 green:0.25 blue:0.35 alpha:0.5].CGColor;
    [self.view addSubview:self.glassContainerView];

    // Header Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, cardWidth - 40, 30)];
    titleLabel.text = @"FOURTYS ROLEPLAY";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [self.glassContainerView addSubview:titleLabel];

    // Realtime Status
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, cardWidth - 40, 20)];
    self.statusLabel.text = @"Checking server state (fourtys.net:1234)...";
    self.statusLabel.textColor = [UIColor colorWithRed:0.30 green:0.75 blue:0.95 alpha:1.0];
    self.statusLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [self.glassContainerView addSubview:self.statusLabel];

    // Username Input
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, cardWidth - 40, 50)];
    self.usernameTextField.backgroundColor = [UIColor colorWithRed:0.05 green:0.06 blue:0.09 alpha:0.8];
    self.usernameTextField.textColor = [UIColor whiteColor];
    self.usernameTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.usernameTextField.layer.cornerRadius = 10;
    self.usernameTextField.layer.borderWidth = 1;
    self.usernameTextField.layer.borderColor = [UIColor colorWithRed:0.18 green:0.22 blue:0.30 alpha:1.0].CGColor;
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"UCP / Character Name..." attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    
    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 50)];
    self.usernameTextField.leftView = leftPaddingView;
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameTextField.delegate = self;
    [self.glassContainerView addSubview:self.usernameTextField];

    // Connect Button
    self.connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.connectButton.frame = CGRectMake(20, 170, cardWidth - 40, 52);
    self.connectButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.42 blue:0.95 alpha:1.0];
    [self.connectButton setTitle:@"CONNECT SERVER" forState:UIControlStateNormal];
    [self.connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.connectButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.connectButton.layer.cornerRadius = 10;
    [self.connectButton addTarget:self action:@selector(handleConnectPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.glassContainerView addSubview:self.connectButton];
}

- (void)initiateServerDataQuery {
    [[SAProtocolHandler sharedHandler] queryServerHost:@"fourtys.net" port:1234 completion:^(SAMPServerInfo info, NSError *error) {
        if (info.isOnline) {
            self.statusLabel.text = [NSString stringWithFormat:@"🟢 ONLINE | %d/%d Players", info.players, info.maxPlayers];
            self.statusLabel.textColor = [UIColor colorWithRed:0.20 green:0.85 blue:0.40 alpha:1.0];
        } else {
            self.statusLabel.text = @"🔴 OFFLINE | fourtys.net:1234";
            self.statusLabel.textColor = [UIColor colorWithRed:0.95 green:0.30 blue:0.30 alpha:1.0];
        }
    }];
}

- (void)handleConnectPressed {
    NSString *username = self.usernameTextField.text;
    if ([username length] == 0) {
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        [shake setDuration:0.08];
        [shake setRepeatCount:2];
        [shake setAutoreverses:YES];
        [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.glassContainerView.center.x - 6, self.glassContainerView.center.y)]];
        [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(self.glassContainerView.center.x + 6, self.glassContainerView.center.y)]];
        [self.glassContainerView.layer addAnimation:shake forKey:@"position"];
        return;
    }

    NSString *customURL = [NSString stringWithFormat:@"samp://fourtys.net:1234?name=%@", [username stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL] options:@{} completionHandler:nil];
}

@end