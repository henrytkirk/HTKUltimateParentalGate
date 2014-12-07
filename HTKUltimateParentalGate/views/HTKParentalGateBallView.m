//
//  HTKParentalGateBallView.m
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

#import "HTKParentalGateBallView.h"
#import "UIColor+HTKColorUtilities.h"
#import "HTKParentalGateConstants.h"

@interface HTKParentalGateBallView () <UIGestureRecognizerDelegate>

/**
 * The value that this ball represents
 */
@property (readwrite, nonatomic, strong) NSNumber *answerValue;

/**
 * Timestamp when CADisplayLink last fired
 */
@property (nonatomic) CFTimeInterval lastTimeStamp;

/**
 * Delta for time between lastTime and current time stamp
 */
@property (nonatomic) CFTimeInterval timeDelta;

/**
 * Our timer used to update the position of the ball smoothly.
 */
@property (nonatomic, strong) CADisplayLink *ballTimer;

/**
 * If we're dragging the ball or not
 */
@property (nonatomic, getter = isDragging) BOOL dragging;

/**
 * Handles the pan gesture
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;

/**
 * Handles the inital press on the ball. Begins the panning action.
 */
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer;

/**
 * Called when CADisplayLink timer fires.
 */
- (void)updateDisplay:(CADisplayLink *)sender;

@end

@implementation HTKParentalGateBallView

- (instancetype)initWithFrame:(CGRect)frame answerValue:(NSNumber *)answerValue initialVelocity:(CGPoint)initialVelocity delegate:(id<HTKParentalGateBallViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        _answerValue = answerValue;
        _currentVelocity = initialVelocity;
        _delegate = delegate;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIColor *randomColor = [UIColor htk_randomColor];
    UIColor *reversedColor = [UIColor htk_reversedColorFromOriginal:randomColor];
    
    self.backgroundColor = randomColor;
    self.layer.borderColor = reversedColor.CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = HTKParentalGateBallSize/2;
    
    // Create ball timer
    self.ballTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
    [self.ballTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.delegate = self;
    [self addGestureRecognizer:panRecognizer];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.allowableMovement = 15;
    longPress.minimumPressDuration = 0.01;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    
    UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    answerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    answerLabel.text = [NSString stringWithFormat:@"%li", (long)_answerValue.integerValue];
    answerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    answerLabel.adjustsFontSizeToFitWidth = YES;
    answerLabel.textAlignment = NSTextAlignmentCenter;
    answerLabel.textColor = reversedColor;
    answerLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:answerLabel];
    
    // Constrain
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[answerLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(answerLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[answerLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(answerLabel)]];
}

- (void)dealloc {
    [self.ballTimer invalidate];
    self.ballTimer = nil;
}

#pragma mark - Position

- (void)updateDisplay:(CADisplayLink *)sender {
    if (self.lastTimeStamp == 0.0) {
        // First time fired, just save current timestamp
        self.lastTimeStamp = sender.timestamp;
    } else {
        // determine time delta
        self.timeDelta = sender.timestamp - self.lastTimeStamp;
        self.lastTimeStamp = sender.timestamp;
    }
    if (self.ballTimer && !self.ballTimer.isPaused && !self.isDragging) {
        if ([self.delegate respondsToSelector:@selector(setPositionForBall:timeDelta:currentVelocity:)]) {
            [self.delegate setPositionForBall:self timeDelta:self.timeDelta currentVelocity:self.currentVelocity];
        }
    }
}

#pragma mark - Gesture Recognizers

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.dragging = YES;
            self.ballTimer.paused = YES;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            self.dragging = YES;
            if ([self.delegate respondsToSelector:@selector(userDidDragBall:withPanGesture:)]) {
                [self.delegate userDidDragBall:self withPanGesture:recognizer];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.dragging = NO;
            self.ballTimer.paused = NO;
            self.lastTimeStamp = 0.0;
            break;
        }
        default:
            return;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            self.ballTimer.paused = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (!self.isDragging) {
                self.lastTimeStamp = 0.0;
                self.ballTimer.paused = NO;
            }
            break;
        }
        default:
            return;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
