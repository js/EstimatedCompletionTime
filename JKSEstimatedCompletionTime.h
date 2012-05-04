//
//  JKSEstimatedCompletionTime.h
//  EstimatedCompletionTime
//
//  Created by Johan Sørensen on 5/4/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKSEstimatedCompletionTime : NSObject

/** The interval at which we should calculate the remaining time */
@property (readonly) NSTimeInterval updateInterval;

/** Designated initializer
 *
 * @param updateInterval The interval at which we should calculate the remaining time
 */
- (instancetype)initWithUpdateInterval:(NSTimeInterval)updateInterval;

/** Start estimating when the task is complete
 *
 * @param totalValue The value to be reached in order for the task to be considered complete
 * @param updateBlock Called at every updateInterval and must return current progress out of totalValue
 * @param progressBlock A callback block which receives the estimated time remining as an argument
 */
- (void)startEstimatingForCompletedValue:(double)totalValue
                             updateBlock:(double (^)(void))updateBlock
                           progressBlock:(void (^)(NSTimeInterval estimatedTimeRemaining))progressBlock;

@end
