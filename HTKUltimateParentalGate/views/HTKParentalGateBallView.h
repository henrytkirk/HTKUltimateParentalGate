//
//  HTKParentalGateBallView.h
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
@class HTKParentalGateBallView;

/**
 * Delegate for the ball view. Handles positioning.
 */
@protocol HTKParentalGateBallViewDelegate <NSObject>

/**
 * Called when ball needs it's position updated when being dragged. Provides the timeDelta
 * and currentDirection for calculation of position. The new position will be the
 * calculated by currentDirection(x,y) * timeDelta. 
 */
- (void)setPositionForBall:(HTKParentalGateBallView *)ballView timeDelta:(CFTimeInterval)timeDelta currentVelocity:(CGPoint)currentVelocity;

/**
 * Called when user drags the ball view.
 */
- (void)userDidDragBall:(HTKParentalGateBallView *)ballView withPanGesture:(UIPanGestureRecognizer *)panGesture;

@end

/**
 * A round ball that displays a number inside it to represent
 * the answer to one of the questions posed. Will typically be
 * randomly colored with a outline.
 */
@interface HTKParentalGateBallView : UIView

/**
 * Delegate
 */
@property (nonatomic, weak) id<HTKParentalGateBallViewDelegate> delegate;

/**
 * The total amount of points the ball will move each second, i.e. velocity.
 * Use this value with the timeDelta to calculate the position of the
 * ball between cadisplaylink firings.
 * When the ball hits the edges we "bounce" off by taking the opposite
 * of the x,y value that hit the edge to change direction. 
 * i.e. a y value of 25 would become -25 sending it the other direction,
 * but preserving the actual rate.
 */
@property (nonatomic) CGPoint currentVelocity;

/**
 * The value that the ball represents.
 */
@property (readonly, nonatomic, strong) NSNumber *answerValue;

/**
 * Designated initalizer. Used to setup the initial position, velocity, value, and delegate.
 */
- (instancetype)initWithFrame:(CGRect)frame answerValue:(NSNumber *)answerValue initialVelocity:(CGPoint)initialVelocity delegate:(id<HTKParentalGateBallViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end
