//
//  HTKParentalGateViewController.m
//  HTKUltimateParentalGate
//
//  Created by Henry T Kirk on 7/25/13.
//  Copyright (c) 2014 Henry T. Kirk (http://www.henrytkirk.info)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "HTKParentalGateViewController.h"
#import "HTKParentalGateManager.h"
#import "HTKParentalGateBallView.h"
#import "HTKParentalGateQuestion.h"
#import "HTKParentalGateConstants.h"

@interface HTKParentalGateViewController () <HTKParentalGateBallViewDelegate>

/**
 * Label that displays the title of the gate. Defaults to "Parental Gate"
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 * Label that displays the question the user has to answer.
 */
@property (nonatomic, strong) UILabel *questionLabel;

/**
 * Label that displays the time remaining to answer the question.
 * Formatted as "Time remaining: MM:SS"
 */
@property (nonatomic, strong) UILabel *timeRemainingLabel;

/**
 * The box that you need to drag the answer to.
 */
@property (nonatomic, strong) UIView *answerBoxView;

/**
 * Dimmed background view that when tapped will close the gate.
 */
@property (nonatomic, strong) UIView *dimmedView;

/**
 * Our manager for most logic with the gate
 */
@property (nonatomic, strong) HTKParentalGateManager *gateManager;

/**
 * Sets the height of the view
 */
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

/**
 * Sets the width of the view
 */
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

/**
 * Sets up the answer balls.
 */
- (void)setupBalls;

/**
 * Helper method that updates the timeRemainingLabel.
 */
- (void)updateTimeRemainingLabelWithMinutes:(NSInteger)minutes seconds:(NSInteger)seconds;

@end

@implementation HTKParentalGateViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _gateManager = [HTKParentalGateManager sharedInstance];
        
        // Listen to time remaining notification and state change
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTimeRemainingNotification:) name:HTKParentalGateTimeRemainingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleValidationStateChangedNotification:) name:HTKParentalGateValidationStateChangedNotification object:nil];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view.layer.cornerRadius = 6;
    self.view.layer.borderColor = [UIColor grayColor].CGColor;
    self.view.layer.borderWidth = 1;
    self.view.layer.masksToBounds = YES;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.titleLabel.text = @"Parental Gate";
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.titleLabel];

    self.questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.questionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.questionLabel.numberOfLines = 0;
    self.questionLabel.text = @"To continue, please answer the following question."; // Placeholder
    self.questionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    [self.view addSubview:self.questionLabel];
    
    self.timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeRemainingLabel.textAlignment = NSTextAlignmentCenter;
    [self.timeRemainingLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.timeRemainingLabel.text = @"Time remaining: 00:00"; // Placeholder
    self.timeRemainingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.timeRemainingLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.timeRemainingLabel];
    
    self.answerBoxView = [[UIView alloc] initWithFrame:CGRectZero];
    self.answerBoxView.translatesAutoresizingMaskIntoConstraints = NO;
    self.answerBoxView.backgroundColor = [UIColor darkGrayColor];
    self.answerBoxView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.answerBoxView.layer.borderWidth = 2.0;
    [self.view addSubview:self.answerBoxView];
    
    // constrain
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(_titleLabel, _questionLabel, _timeRemainingLabel, _answerBoxView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_titleLabel]-15-|" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_questionLabel]-20-|" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_titleLabel]-3-[_questionLabel]->=0-[_timeRemainingLabel]-20-|" options:0 metrics:nil views:viewDict]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timeRemainingLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    // Answer box constraints
    // set the size of the answer box
    NSDictionary *metricDict = @{@"answerBoxSize" : @50};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_answerBoxView(answerBoxSize)]-15-|" options:0 metrics:metricDict views:viewDict]];
    // Randomly place the answer box on
    // left or right side of the window
    if (arc4random_uniform(20) % 2) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_answerBoxView(answerBoxSize)]->=0-|" options:0 metrics:metricDict views:viewDict]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[_answerBoxView(answerBoxSize)]-15-|" options:0 metrics:metricDict views:viewDict]];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Generate a question and display it
    HTKParentalGateQuestion *question = self.gateManager.selectAQuestion;
    self.questionLabel.text = [NSString stringWithFormat:@"To continue, drag the answer for \"%@\" to the square in the corner.", question.questionString];
    
    // Setup countdown label
    NSInteger seconds = HTKParentalGateMaxAttemptSeconds % 60;
    NSInteger minutes = (HTKParentalGateMaxAttemptSeconds / 60) % 60;
    [self updateTimeRemainingLabelWithMinutes:minutes seconds:seconds];
    
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Start the attempt
    [self.gateManager performSelector:@selector(beginUserAttempt) withObject:nil afterDelay:0.25];
    // Setup balls on screen
    [self setupBalls];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Helpers

- (void)updateTimeRemainingLabelWithMinutes:(NSInteger)minutes seconds:(NSInteger)seconds {
    self.timeRemainingLabel.text = [NSString stringWithFormat:@"Time remaining: %02ld:%02ld", (long)minutes, (long)seconds];
    // Adjust color if we're less than 10 seconds
    if (minutes == 0 && seconds < 10) {
        self.timeRemainingLabel.textColor = [UIColor redColor];
    }
}

#pragma mark - Ball Setup

- (void)setupBalls {
    
    // Get an array of NSNumbers that contain the answer and
    // a bunch of fill answers, all of which are incorrect.
    NSArray *answersArray = [self.gateManager answersForCurrentQuestion];
    
    __weak __typeof(self) weakSelf = self;
    [answersArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSNumber *answerValue = (NSNumber *)obj;
        
        // set a random starting position
        NSInteger xRandom = arc4random_uniform(CGRectGetMaxX(strongSelf.view.frame) - HTKParentalGateBallSize);
        NSInteger yRandom = arc4random_uniform(CGRectGetMaxY(strongSelf.view.frame) - HTKParentalGateBallSize);
        CGRect ballFrame = CGRectMake(xRandom, yRandom, HTKParentalGateBallSize, HTKParentalGateBallSize);
        
        // Create a random velocity based on our min/max constants
        NSInteger pointsPerSecond = arc4random_uniform(HTKParentalGateMaxVelocityPerSecond) + HTKParentalGateMinVelocityPerSecond;
        CGPoint initialVelocity;
        if (pointsPerSecond % 2) {
            initialVelocity = CGPointMake(pointsPerSecond, -pointsPerSecond);
        } else {
            initialVelocity = CGPointMake(-pointsPerSecond, pointsPerSecond);
        }
        
        // Create the ball and animate on screen
        HTKParentalGateBallView *ballView = [[HTKParentalGateBallView alloc] initWithFrame:ballFrame answerValue:answerValue initialVelocity:initialVelocity delegate:self];
        ballView.transform = CGAffineTransformMakeScale(0, 0);
        [strongSelf.view addSubview:ballView];
        
        [UIView animateWithDuration:0.4f delay:(idx * 0.1) usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
            ballView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];
}

#pragma mark - Rotation / Constraints

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // iOS 7 only uses this
    [self updateConstraintsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self updateConstraintsForInterfaceOrientation:deviceOrientation];
}

- (void)updateConstraintsForInterfaceOrientation:(UIInterfaceOrientation)deviceOrientation {
    
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        self.widthConstraint.constant = 300;
        self.heightConstraint.constant = 420;
    } else {
        self.widthConstraint.constant = 430;
        self.heightConstraint.constant = [[UIApplication sharedApplication] isStatusBarHidden] ? 300 : 280;
    }
}

#pragma mark - Presentation / Dismissal 

- (void)showInParentViewController:(UIViewController *)parentViewController {
    
    self.view.alpha = 0;

    [self willMoveToParentViewController:parentViewController];
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];

    // Dimmed view
    self.dimmedView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dimmedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dimmedView.alpha = 0;
    [self.dimmedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapDimmedBackground:)]];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [parentViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:parentViewController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [parentViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:parentViewController.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    // Apply height/width constraints
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [parentViewController.view addConstraints:@[self.widthConstraint, self.heightConstraint]];
    
    // Determine if we're in landscape or portrait
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self updateConstraintsForInterfaceOrientation:deviceOrientation];
    
    // Dimmed view
    [parentViewController.view insertSubview:self.dimmedView belowSubview:self.view];
    [parentViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dimmedView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dimmedView)]];
    [parentViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dimmedView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dimmedView)]];

    // Animate in
    self.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:15 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [self didMoveToParentViewController:parentViewController];
        [UIView animateWithDuration:0.4 animations:^{
            self.dimmedView.alpha = 1;
        }];
    }];
}

- (void)dismissParentalGateViewController {
    
    [self willMoveToParentViewController:nil];

    // Animate out
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:15 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.alpha = 0;
        self.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
        self.dimmedView.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.transform = CGAffineTransformMakeScale(1, 1);
        [self.view removeFromSuperview];
        [self.dimmedView removeFromSuperview];
        self.dimmedView = nil;
        [self removeFromParentViewController];
    }];
}

#pragma mark - Dimmed Background

- (void)userDidTapDimmedBackground:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self dismissParentalGateViewController];
    }
}

#pragma mark - Notification Handlers

- (void)handleValidationStateChangedNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        // Get state
        NSUInteger state = [notification.userInfo[HTKParentalGateValidationStateChangedKey] integerValue];
        switch (state) {
            case HTKParentalGateValidationStateIsValidated:
            case HTKParentalGateValidationStateInvalid:
            case HTKParentalGateValidationStateTimesUp:
            case HTKParentalGateValidationStateTooManyAttempts:
            case HTKParentalGateValidationStateTooManyIncorrectAnswers:
            default:
                // Close parental gate for all cases above.
                // The parent who presented us should respond to the
                // states and determine which controller to show next.
                [self dismissParentalGateViewController];
                break;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleValidationStateChangedNotification:notification];
        });
    }
}

- (void)handleTimeRemainingNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        // update our time remaining
        NSInteger secondsRemaining = [notification.userInfo[HTKParentalGateTimeRemainingSecondsKey] integerValue];
        NSInteger seconds = secondsRemaining % 60;
        NSInteger minutes = (secondsRemaining / 60) % 60;
        [self updateTimeRemainingLabelWithMinutes:minutes seconds:seconds];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleTimeRemainingNotification:notification];
        });
    }
}

#pragma mark - HTKParentalGateBallViewDelegate

- (void)setPositionForBall:(HTKParentalGateBallView *)ballView timeDelta:(CFTimeInterval)timeDelta currentVelocity:(CGPoint)currentVelocity {
    
    // Adjust velocity if needed
    CGPoint adjustedVelocity = currentVelocity;
    // Check if crossed left edge
    if (CGRectGetMinX(ballView.frame) <= 0) {
        // Send right
        adjustedVelocity.x = abs(currentVelocity.x);
    }
    // Check if crossed right edge
    if (CGRectGetMaxX(ballView.frame) >= CGRectGetWidth(self.view.frame)) {
        // Send left
        adjustedVelocity.x = -1 * abs(currentVelocity.x);
    }
    // Check if crossed top edge
    if (CGRectGetMinY(ballView.frame) <= 0) {
        // Send down
        adjustedVelocity.y = abs(currentVelocity.y);
    }
    // Check if crossed bottom edge
    if (CGRectGetMaxY(ballView.frame) >= CGRectGetHeight(self.view.frame)) {
        // Send up
        adjustedVelocity.y = -1 * abs(currentVelocity.y);
    }
    ballView.currentVelocity = adjustedVelocity;
    
    // Update position
    CGRect ballFrame = ballView.frame;
    // Adjust the origin by applying it's velocity.
    ballFrame.origin.x += adjustedVelocity.x * timeDelta;
    ballFrame.origin.y += adjustedVelocity.y * timeDelta;
    // Set frame
    ballView.frame = ballFrame;
}

- (void)userDidDragBall:(HTKParentalGateBallView *)ballView withPanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    // Determine our new center
    CGPoint newCenter = CGPointMake(panGesture.view.center.x + translation.x,
                                    panGesture.view.center.y + translation.y);
    
    if (CGRectContainsPoint(self.view.bounds, newCenter)) {
        // Set center, we're within our draggable area
        ballView.center = newCenter;
        [panGesture setTranslation:CGPointZero inView:self.view];
    } else {
        // Cancel the recognizer so the ball continues
        for (UIGestureRecognizer *recognizer in ballView.gestureRecognizers) {
            recognizer.enabled = NO;
            recognizer.enabled = YES;
        }
    }
    
    if (CGRectContainsPoint(self.answerBoxView.frame, newCenter)) {
        // Check for answer
        [self.gateManager didUserSelectCorrectAnswerWithNumber:ballView.answerValue];
    }
}

@end
