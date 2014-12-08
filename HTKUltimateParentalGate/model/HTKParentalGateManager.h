//
//  HTKParentalGateManager.h
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

#import <UIKit/UIKit.h>
@class HTKParentalGateQuestion;

/**
 * The manager that handles parental gate
 */
@interface HTKParentalGateManager : NSObject

/**
 * The current selected question.
 */
@property (readonly, nonatomic, strong) HTKParentalGateQuestion *currentQuestion;

/**
 * Shared instance. I sure hope you know how this is used.
 */
+ (instancetype)sharedInstance;

/**
 * Returns if the user is locked out for too many repeated failed attempts.
 */
- (BOOL)userIsLockedOut;

/**
 * Randomly selects a question from the HTKParentalGateQuestions.plist
 * and returns it. Will save to currentQuestion.
 */
- (HTKParentalGateQuestion *)selectAQuestion;

/**
 * Returns and array of NSNumbers that contain the answer and "fill" answers
 * based on a range around the actual answer. Returns as many answers as
 * HTKParentalGateMaxNumberOfBalls has set.
 */
- (NSArray *)answersForCurrentQuestion;

/**
 * Starts the attempt timer and performs reset of incorrect counter. Call this to
 * start firing off the elapsed time notifications.
 */
- (void)beginUserAttempt;

/**
 * Ends user attempt early. Call this when dismissing the view to disable any
 * timer.
 */
- (void)endUserAttempt;

/**
 * Determines if the user selected the correct answer based on number supplied
 * If so, it will fire off notifications and reset. If incorrect, it will
 * increment the failed attempt counter.
 */
- (BOOL)didUserSelectCorrectAnswerWithNumber:(NSNumber *)number;

@end
