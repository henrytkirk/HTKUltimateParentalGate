//
//  HTKParentalGateConstants.h
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

/**
 * Enum for the state of the validation of the gate attempt.
 * This will be included inside userInfo (HTKParentalGateValidationStateChangedKey)
 * with the HTKParentalGateValidationStateChangedNotification notification.
 */
typedef NS_ENUM(NSUInteger, HTKParentalGateValidationState) {
    /**
     * State invalid. Shouldn't get here.
     */
    HTKParentalGateValidationStateInvalid,
    
    /**
     * Times up state, when user runs out of time to answer the
     * question.
     */
    HTKParentalGateValidationStateTimesUp,
    
    /**
     * State when user gets too many incorrect answers and
     * and the gate closed.
     */
    HTKParentalGateValidationStateTooManyIncorrectAnswers,
    
    /**
     * State when user makes to many attempts overall to
     * get past the gate. When this state is hit the
     * user is locked out for x minutes before they can try again.
     */
    HTKParentalGateValidationStateTooManyAttempts,
    
    /**
     * State when user has answered the question correctly
     */
    HTKParentalGateValidationStateIsValidated
};

/**
 * Key that aligns with the plist values for questions
 */
static const NSString *HTKParentalGateQuestionKey = @"question";
static const NSString *HTKParentalGateAnswerKey = @"answer_number";

/**
 * Notification name and userInfo key for state change. See
 * HTKParentalGateValidationState enum for possible state values.
 */
static NSString *HTKParentalGateValidationStateChangedNotification = @"HTKParentalGateValidationStateChangedNotification";
static NSString *HTKParentalGateValidationStateChangedKey = @"HTKParentalGateValidationStateChangedKey";

/**
 * Notification name and userInfo key for time remaining.
 */
static NSString *HTKParentalGateTimeRemainingNotification = @"HTKParentalGateTimeRemainingNotification";
static NSString *HTKParentalGateTimeRemainingSecondsKey = @"HTKParentalGateTimeRemainingSecondsKey";

#pragma mark - Customizable Settings

/**
 * Size of the balls. 44 should be smallest for best usability.
 */
static const CGFloat HTKParentalGateBallSize = 44;

/**
 * Strings that represent the messages displayed to user when alerts
 * are displayed.
 */
static NSString *HTKParentalGateAlertLockOutMessage = @"The Parental Gate has closed because you made too many attempts in a row. You can try again in %@.";
static NSString *HTKParentalGateAlertTooManyIncorrectAnswersMessage = @"The Parental Gate has closed because you had too many incorrect answers for the question.";
static NSString *HTKParentalGateAlertTimesUpMessage = @"The Parental Gate has closed because you ran out of time to answer the question.";

/**
 * How many balls to display on the screen at once.
 */
static const NSInteger HTKParentalGateMaxNumberOfBalls = 8;

/**
 * Minimum velocity in points per second.
 */
static const NSInteger HTKParentalGateMinVelocityPerSecond = 75;

/**
 * Maximum velocity in points per second.
 */
static const NSInteger HTKParentalGateMaxVelocityPerSecond = 125;

/**
 * How many seconds the user should be allowed to attempt answering the
 * question. Will close after time runs out.
 */
static const NSInteger HTKParentalGateMaxAttemptSeconds = 15;

/**
 * How many attempts before it will lock the user out for HTKParentalGateLockoutNumberOfMinutes
 * minutes.
 */
static const NSInteger HTKParentalGateMaxAttemptsBeforeWait = 5;

/**
 * How many incorrect answers the user can get before it will close.
 */
static const NSInteger HTKParentalGateMaxAttemptsBeforeClose = 3;

/**
 * How many minutes should the user be locked out if HTKParentalGateMaxAttemptsBeforeWait
 * is triggered.
 */
static const NSInteger HTKParentalGateLockoutNumberOfMinutes = 5;

/**
 * How long the alert view is displayed to user before automatically closing
 * if the user does not dismiss on their own.
 */
static const NSInteger HTKParentalGateDismissAlertSeconds = 5;

