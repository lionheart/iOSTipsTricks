#import "HeightAdjustingViewController.h"

@interface HeightAdjustingViewController ()

@property (nonatomic, strong) UIView *adjustingView;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

- (void)keyboardDidHide:(NSNotification *)sender;
- (void)keyboardDidShow:(NSNotification *)sender;

@end

@implementation HeightAdjustingViewController

- (void)viewDidLoad {
    [super viewDidLoad]

    self.adjustingView = [[UIView alloc] init];
    self.adjustingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.adjustingView];

    NSDictionary *views = @{@"view": self.adjustingView,
                            @"top": self.topLayoutGuide };

    [self.view addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][view]" options:0 metrics:nil views:views]];

    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.adjustingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:self.bottomConstraint];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];;
}


#pragma mark - Notification Handlers

- (void)keyboardDidShow:(NSNotification *)sender {
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
    [self.view layoutIfNeeded];
}

- (void)keyboardDidHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

@end
