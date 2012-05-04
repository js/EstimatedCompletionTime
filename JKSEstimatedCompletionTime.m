//
//  JKSEstimatedCompletionTime.m
//  EstimatedCompletionTime
//
//  Created by Johan Sørensen on 5/4/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSEstimatedCompletionTime.h"

@implementation JKSEstimatedCompletionTime
{
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
}
@synthesize updateInterval = _updateInterval;

- (instancetype)initWithUpdateInterval:(NSTimeInterval)updateInterval
{
    if ((self = [super init])) {
        _updateInterval = updateInterval;
        _queue = dispatch_queue_create("com.johansorensen.estimated-completion-time", NULL);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    }
    return self;
}


- (void)dealloc
{
    if (_timer)
        dispatch_source_cancel(_timer);
    if (_queue)
        dispatch_release(_queue);
}


- (void)startEstimatingForCompletedValue:(double)totalValue
                             updateBlock:(double (^)(void))updateBlock
                           progressBlock:(void (^)(NSTimeInterval))progressBlock
{
    NSParameterAssert(totalValue > 0);
    NSDate *startDate = [NSDate date];

    dispatch_source_set_timer(_timer,
                              dispatch_time(DISPATCH_TIME_NOW, 0),
                              self.updateInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            double progress = updateBlock();
            if (progress >= totalValue) {
                dispatch_source_cancel(_timer);
            }
            NSLog(@"completed: %.2f/%.2f", progress, totalValue);
            if (progress <= 0) {
                return;
            }

            // Extremely naive calculation here, it does get better the closer to completion it is though
            NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceReferenceDate] - [startDate timeIntervalSinceReferenceDate];
            NSTimeInterval estimatedRemaining = elapsedTime * (totalValue - progress) / progress;
            NSLog(@"estimate=%.2f elapsed=%.2f", estimatedRemaining, elapsedTime);
            if (estimatedRemaining < 0)
                estimatedRemaining = 0;
            progressBlock(estimatedRemaining);
        });
    });
    dispatch_resume(_timer);
}


- (void)invalidate
{
    dispatch_source_cancel(_timer);
}


@end
