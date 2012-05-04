//
//  JKSEstimatedCompletionCalculator.m
//  EstimatedCompletionTime
//
//  Created by Johan Sørensen on 5/4/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSEstimatedCompletionCalculator.h"
#import "JKSQueue.h"

@interface JKSProgressSample : NSObject
@property (assign) NSTimeInterval timeSinceStart;
@property (assign) double progressValue;
@end

@implementation JKSProgressSample
@synthesize timeSinceStart = _timeSinceStart;
@synthesize progressValue = _progressValue;
@end


@interface JKSEstimatedCompletionCalculator ()
@property (strong) JKSQueue *queue;
@property (strong) NSDate *startDate;
@property (strong) JKSProgressSample *currentSample;
@property (strong) JKSProgressSample *oldestSample;
@end

static const NSUInteger kRollingAverageMaxWindowSize = 256;

@implementation JKSEstimatedCompletionCalculator
@synthesize completedValue = _completedValue;
@synthesize startDate = _startDate;
@synthesize queue = _queue;
@synthesize currentSample = _currentSample;
@synthesize oldestSample = _oldestSample;


- (instancetype)initWithCompletedValue:(double)completedValue
{
    if ((self = [super init])) {
        _completedValue = completedValue;
        _queue = [[JKSQueue alloc] init];
    }
    return self;
}


- (void)start
{
    self.startDate = [NSDate date]; // TODO: use mach_absolute_time() instead?
}


- (void)updateWithProgress:(double)progress
{
    // Expire some old entries
    // TODO: make the expiration limit configurable
    while ([self.queue count] > kRollingAverageMaxWindowSize) {
        self.oldestSample = [self.queue dequeue];
    }

    self.currentSample = [[JKSProgressSample alloc] init];
    self.currentSample.timeSinceStart = [self.startDate timeIntervalSinceDate:[NSDate date]];
    //self.currentSample.progressValue = progress;
    self.currentSample.progressValue = progress / self.completedValue;
    [self.queue enqueue:self.currentSample];
    
    if ([self.queue count] == 1)
        self.oldestSample = self.currentSample;
}


- (NSTimeInterval)estimatedTimeRemaining
{
    // TODO: maybe check if we're above a certain number of samples before we calc ETR?
    NSTimeInterval remaining = -((1.0f - self.currentSample.progressValue) * 
                                 (self.currentSample.timeSinceStart - self.oldestSample.timeSinceStart) / 
                                 (self.currentSample.progressValue - self.oldestSample.progressValue));

    if (isnan(remaining) || isinf(remaining))
        return NSTimeIntervalSince1970;

    if (remaining <= 0)
        remaining = 0.0f;

    return remaining;

}


- (void)reset
{
    [self.queue removeAllEnquedObjects];
    self.currentSample = nil;
    self.oldestSample = nil;
    self.startDate = nil;
}

@end
