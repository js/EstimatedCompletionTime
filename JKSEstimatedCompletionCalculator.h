//
//  JKSEstimatedCompletionCalculator.h
//  EstimatedCompletionTime
//
//  Created by Johan Sørensen on 5/4/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import <Foundation/Foundation.h>

/** An "Estimated Time Remaining" calculator that uses a rolling average to estimate
 */
@interface JKSEstimatedCompletionCalculator : NSObject
@property (readonly) double completedValue;

/** Designated initializer
 *
 * @param completedValue The value the task should reach in order to be considered complete
 */
- (instancetype)initWithCompletedValue:(double)completedValue;

/** Starts the estimated completion calculation from the current time */
- (void)start;

/** Updates the completion estimation with a new progress
 * 
 * @param progress the current progress of the task
 */
- (void)updateWithProgress:(double)progress;

/** Returns the time remaining */
- (NSTimeInterval)estimatedTimeRemaining;

/** Resets the calculation and makes the receiver ready to start over */
- (void)reset;

@end
