//
//  HTKRootViewController.m
//  HTKUltimateParentalGateDemo
//
//  Created by Henry T Kirk on 12/6/14.
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

#import "HTKRootViewController.h"
#import "HTKParentalGateViewController.h"

@interface HTKRootViewController ()

/**
 * "Buy" button that we'll use to display the parental gate
 */
@property (nonatomic, strong) UIButton *buyNowButton;

/**
 * Called when user taps on button
 */
- (void)userDidTapOnBuyNowButton:(id)sender;

@end

@implementation HTKRootViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add observer so we get notifiy of state change of the gate
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleValidationStateChangedNotification:) name:HTKParentalGateValidationStateChangedNotification object:nil];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.buyNowButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.buyNowButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buyNowButton setTitle:@"Buy Now!" forState:UIControlStateNormal];
    self.buyNowButton.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 15);
    [self.buyNowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.buyNowButton.backgroundColor = [UIColor whiteColor];
    [self.buyNowButton addTarget:self action:@selector(userDidTapOnBuyNowButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buyNowButton];
    
    // Constrain
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buyNowButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buyNowButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userDidTapOnBuyNowButton:(id)sender {
    // Show our parental gate
    HTKParentalGateViewController *parentalGateController = [[HTKParentalGateViewController alloc] init];
    [parentalGateController showInParentViewController:self fullScreen:NO];
}

#pragma mark - Notification Handlers

- (void)handleValidationStateChangedNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        NSUInteger state = [notification.userInfo[HTKParentalGateValidationStateChangedKey] integerValue];
        switch (state) {
            case HTKParentalGateValidationStateIsValidated: {
                // Validated! Launch something here!
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Begin Purchase" message:@"Great! You've successfully validated the Parental Gate. Now you can continue your in app purchase!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                break;
            }
            // Handle other states
            case HTKParentalGateValidationStateInvalid:
            case HTKParentalGateValidationStateTimesUp:
            case HTKParentalGateValidationStateTooManyAttempts:
            case HTKParentalGateValidationStateTooManyIncorrectAnswers:
            default:
                break;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleValidationStateChangedNotification:notification];
        });
    }
}

@end
