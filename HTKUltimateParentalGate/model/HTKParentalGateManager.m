//
//  HTKParentalGateManager.m
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

#import "HTKParentalGateManager.h"
#import "HTKParentalGateQuestion.h"
#import "HTKParentalGateConstants.h"

@interface HTKParentalGateManager () <UIAlertViewDelegate>

/**
 * Our array of questions we will present to user.
 */
@property (nonatomic, strong) NSMutableArray *questionsArray;

/**
 * Currently selected question
 */
@property (readwrite, nonatomic, strong) HTKParentalGateQuestion *currentQuestion;

/**
 * Timer that tracks how much time user has to complete answer
 */
@property (nonatomic, strong) NSTimer *attemptTimer;

/**
 * Timer that tracks how long is left if we've triggered too many failed
 * attempts in a row.
 */
@property (nonatomic, strong) NSTimer *unlockTimer;

/**
 * The date when we will unlock the gate for another attempt if it
 * was triggered.
 */
@property (nonatomic, strong) NSDate *unlockDate;

/**
 * The alert view that displays messages to user. We hold onto a 
 * reference so we can update the message string with unlock time
 * remaining.
 */
@property (nonatomic, strong) UIAlertView *alertView;

/**
 * The answer the user last tried. We use this to track incorrect answers.
 */
@property (nonatomic, strong) NSNumber *answerLastTried;

/**
 * How many seconds are left for the attempt.
 */
@property (nonatomic) NSInteger attemptSecondsRemaining;

/**
 * How many times has the user attempted to get past the gate. If 
 * it gets above HTKParentalGateMaxAttemptsBeforeWait, then it will
 * lock the user for HTKParentalGateLockoutNumberOfMinutes until they
 * can try again.
 */
@property (nonatomic) NSInteger attemptCounter;

/**
 * Counts how many times the user got an incorrect answer for the attempt.
 * If exceeds HTKParentalGateMaxAttemptsBeforeClose, then will close the
 * attempt and alert user.
 */
@property (nonatomic) NSInteger incorrectAnswerCounter;

/**
 * Called when timer fires for attempt counter
 */
- (void)attemptTimerDidProgress:(NSTimer *)timer;

/**
 * Sets up the unlock timer
 */
- (void)setupUnlockTimer;

/**
 * Called when unlock timer fires. Will update time remaining
 * if the alert view is presented.
 */
- (void)unlockTimerFired:(NSTimer *)timer;

/**
 * Resets the attempt timer
 */
- (void)resetAttemptTimer;

/**
 * Resets the unlock timer
 */
- (void)resetUnlockTimer;

/**
 * Shows an alert view with title and message provided.
 */
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

/**
 * Dismisses the visible alert view
 */
- (void)dismissAlertView;

/**
 * Returns a formatted string used for displaying how much time remains
 * until the user is permitted to try again. Format: HH:MM. (i.e. 04:55)
 */
- (NSString *)formattedUnlockTimeRemainingString;

/**
 * Loads questions from the HTKParentalGateQuestions.plist and processes into
 * memory.
 */
- (void)loadQuestions;

@end

@implementation HTKParentalGateManager

+ (instancetype)sharedInstance {
    static HTKParentalGateManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _questionsArray = [NSMutableArray array];
        // Populate our questions array from plist
        [self loadQuestions];
    }
    return self;
}

- (void)dealloc {
    // reset timers
    [self resetAttemptTimer];
    [self resetUnlockTimer];
}

#pragma mark - Timer Methods

- (void)attemptTimerDidProgress:(NSTimer *)timer {
    self.attemptSecondsRemaining--;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HTKParentalGateTimeRemainingNotification object:nil userInfo:@{HTKParentalGateTimeRemainingSecondsKey : @(self.attemptSecondsRemaining)}];
    
    if (self.attemptSecondsRemaining <= 0) {
        [self resetAttemptTimer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HTKParentalGateValidationStateChangedNotification object:nil userInfo:@{HTKParentalGateValidationStateChangedKey : @(HTKParentalGateValidationStateTimesUp)}];
        
        // Alert user time's up
        [self showAlertViewWithTitle:@"Out of Time!" message:HTKParentalGateAlertTimesUpMessage];
    }
}

- (void)setupUnlockTimer {
    // Determine the date in future when we can unlock.
    self.unlockDate = [NSDate dateWithTimeIntervalSinceNow:(HTKParentalGateLockoutNumberOfMinutes * 60)];
    // Create our unlock timer.
    self.unlockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(unlockTimerFired:) userInfo:nil repeats:YES];
}

- (void)unlockTimerFired:(NSTimer *)timer {
    if ([self userIsLockedOut]) {
        // If our alert view is present, update the message with
        // remaining time left
        if (self.alertView) {
            self.alertView.message = [NSString stringWithFormat:HTKParentalGateAlertLockOutMessage, [self formattedUnlockTimeRemainingString]];
        }
    }
}

- (void)resetAttemptTimer {
    [self.attemptTimer invalidate];
    self.attemptTimer = nil;
}

- (void)resetUnlockTimer {
    [self.unlockTimer invalidate];
    self.unlockTimer = nil;
}

#pragma mark - Question/Answers

- (BOOL)userIsLockedOut {
    // Determine how many seconds left until we reach unlock date
    NSTimeInterval secondsBetween = [self.unlockDate timeIntervalSinceDate:[NSDate date]];
    if (secondsBetween <= 0) {
        // reset everything
        [self resetUnlockTimer];
        self.attemptCounter = 0;
        self.unlockDate = nil;
        [self dismissAlertView];
    }
    return (self.attemptCounter > HTKParentalGateMaxAttemptsBeforeWait);
}

- (HTKParentalGateQuestion *)selectAQuestion {
    // Randomly pick a index of question to display
    NSUInteger indexToSelect = arc4random_uniform((int)self.questionsArray.count);
    // Set question
    _currentQuestion = [self.questionsArray objectAtIndex:indexToSelect];
    return _currentQuestion;
}

- (void)beginUserAttempt {
    // Set seconds for this attempt
    self.attemptSecondsRemaining = HTKParentalGateMaxAttemptSeconds;

    // Reset some counters
    self.answerLastTried = nil;
    self.incorrectAnswerCounter = 0;
    
    // Create the attempt timer
    [self resetAttemptTimer];
    self.attemptTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(attemptTimerDidProgress:) userInfo:nil repeats:YES];
    
    // Increment the attempt
    self.attemptCounter++;
}

- (BOOL)didUserSelectCorrectAnswerWithNumber:(NSNumber *)number {
    if ([number isEqualToNumber:self.currentQuestion.answerNumber]) {
        // Reset timer and post notification, we've got the right answer!
        [self resetAttemptTimer];
        
        // Reset our attempt counters
        self.incorrectAnswerCounter = 0;
        self.attemptCounter = 0;
        self.answerLastTried = nil;
        
        // Post notification we're validated!
        [[NSNotificationCenter defaultCenter] postNotificationName:HTKParentalGateValidationStateChangedNotification object:nil userInfo:@{HTKParentalGateValidationStateChangedKey : @(HTKParentalGateValidationStateIsValidated)}];

        return YES;
    } else {
        // Determine if we've tried this number before
        if (![self.answerLastTried isEqualToNumber:number]) {
            // Save to test with next time
            self.answerLastTried = number;
            // Increment incorrect answer counter
            self.incorrectAnswerCounter++;
        }
        return NO;
    }
}

#pragma mark - Attempt Counter Setters

- (void)setIncorrectAnswerCounter:(NSInteger)incorrectAnswerCounter {
    _incorrectAnswerCounter = incorrectAnswerCounter;
    if (_incorrectAnswerCounter > HTKParentalGateMaxAttemptsBeforeClose) {
        // Too many incorrect answers, close
        [self resetAttemptTimer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HTKParentalGateValidationStateChangedNotification object:nil userInfo:@{HTKParentalGateValidationStateChangedKey : @(HTKParentalGateValidationStateTooManyIncorrectAnswers)}];
        // Show alert to user
        [self showAlertViewWithTitle:@"Too Many Attempts!" message:HTKParentalGateAlertTooManyIncorrectAnswersMessage];
    }
}

- (void)setAttemptCounter:(NSInteger)attemptCounter {
    _attemptCounter = attemptCounter;
    if (_attemptCounter > HTKParentalGateMaxAttemptsBeforeWait) {
        // Too many attempts, let's lock out user for a bit
        [self resetAttemptTimer];
        // If we don't have a unlock timer, create it
        if (!self.unlockTimer) {
            [self setupUnlockTimer];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HTKParentalGateValidationStateChangedNotification object:nil userInfo:@{HTKParentalGateValidationStateChangedKey : @(HTKParentalGateValidationStateTooManyAttempts)}];
        
        // Alert user that we've made too many failed attempts and
        // display how much time is left until it unlocks.
        NSString *lockedOutMessage = [NSString stringWithFormat:HTKParentalGateAlertLockOutMessage, [self formattedUnlockTimeRemainingString]];
        [self showAlertViewWithTitle:@"Locked Out!" message:lockedOutMessage];
    }
}

#pragma mark - Alert Presentation

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [self.alertView show];
    [self performSelector:@selector(dismissAlertView) withObject:nil afterDelay:HTKParentalGateDismissAlertSeconds];
}

- (void)dismissAlertView {
    if (self.alertView) {
        [self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.alertView) {
        // Cancel selector to dismiss if user tapped it first
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAlertView) object:nil];
    }
}

#pragma mark - Helpers

- (NSString *)formattedUnlockTimeRemainingString {
    NSTimeInterval secondsBetween = [self.unlockDate timeIntervalSinceDate:[NSDate date]];
    NSInteger seconds = (int)secondsBetween % 60;
    NSInteger minutes = ((int)secondsBetween / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (void)loadQuestions {
    // Get path of our plist with questions
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"HTKParentalGateQuestions" ofType:@"plist"];
    NSArray *questionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    [self.questionsArray removeAllObjects];
    
    // Create our question objects and add to the array
    __weak __typeof(self) weakSelf = self;
    [questionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSDictionary *questionDict = (NSDictionary *)obj;
        HTKParentalGateQuestion *question = [[HTKParentalGateQuestion alloc] initWithQuestion:questionDict[HTKParentalGateQuestionKey] answerNumber:questionDict[HTKParentalGateAnswerKey]];
        [strongSelf.questionsArray addObject:question];
    }];
}

- (NSArray *)answersForCurrentQuestion {
    NSMutableArray *answersArray = [NSMutableArray array];
    
    NSInteger actualAnswer = self.currentQuestion.answerNumber.integerValue;
    NSInteger lowValue = 1;
    NSInteger highValue = actualAnswer * 3;

    // Add answer
    [answersArray addObject:@(actualAnswer)];

    // Now add fill answers
    for (NSUInteger i = 0; i < HTKParentalGateMaxNumberOfBalls - 1; i++) {
        NSInteger answerValue = 0;
        // make sure we don't duplicate answer
        answerValue = actualAnswer;
        while (answerValue == actualAnswer) {
            answerValue = arc4random_uniform((int)highValue) + lowValue;
        }
        [answersArray addObject:@(answerValue)];
    }
    
    return [NSArray arrayWithArray:answersArray];
}

@end
