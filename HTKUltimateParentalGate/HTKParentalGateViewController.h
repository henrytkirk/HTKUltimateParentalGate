//
//  HTKParentalGateViewController.h
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
#import "HTKparentalGateConstants.h"

/**
 * Ultimate Parental Gate that displays a title, question, 
 * and time remaining with moving balls that contain the answer.
 * The user then attempts to drag the answer into a square on
 * the screen to attempt to validate the gate and move on.
 */
@interface HTKParentalGateViewController : UIViewController

/**
 * Shows the parental gate in the parent controller passed. Currently the
 * size is 300pt x 420pt (portrait) and is centered on the screen. (Animated)
 */
- (void)showInParentViewController:(UIViewController *)parentViewController;

/**
 * Dismisses the parental gate animated.
 */
- (void)dismissParentalGateViewController;

@end
