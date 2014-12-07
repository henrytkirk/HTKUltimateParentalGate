//
//  UIColor+HTKColorUtilities.h
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

/**
 * Color utility methods for generating a random color
 * and reversing the color. i.e. Black = White.
 */
@interface UIColor (HTKColorUtilities)

/**
 * Generates an solid, opaque random color.
 */
+ (UIColor *)htk_randomColor;

/**
 * Reverses the color provided, such as Black = White, Orange = Blue,
 * Red = Green, etc.
 */
+ (UIColor *)htk_reversedColorFromOriginal:(UIColor *)originalColor;

@end
