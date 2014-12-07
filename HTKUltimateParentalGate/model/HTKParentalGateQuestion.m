//
//  HTKParentalGateQuestion.m
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

#import "HTKParentalGateQuestion.h"

@interface HTKParentalGateQuestion ()

/**
 * Question shown to user
 */
@property (readwrite, nonatomic, strong) NSString *questionString;

/**
 * Answer to the question
 */
@property (readwrite, nonatomic, strong) NSNumber *answerNumber;

@end

@implementation HTKParentalGateQuestion

- (instancetype)initWithQuestion:(NSString *)question answerNumber:(NSNumber *)answerNumber {
    self = [super init];
    if (self) {
        _questionString = question;
        _answerNumber = answerNumber;
    }
    return self;
}

@end
