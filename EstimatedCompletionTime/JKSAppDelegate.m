//
//  JKSAppDelegate.m
//  EstimatedCompletionTime
//
//  Created by Johan Sørensen on 5/4/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSAppDelegate.h"
#import "JKSEstimatedCompletionTime.h"
#import "JKSEstimatedCompletionCalculator.h"

@implementation JKSAppDelegate
{
    JKSEstimatedCompletionTime *_completionEstimator;
    JKSEstimatedCompletionCalculator *_completionCalculator; // Rolling average calculator
}
@synthesize window = _window;
@synthesize progressBar = _progressBar;
@synthesize progressLabel = _progressLabel;

- (id)init
{
    if ((self = [super init])) {
        _completionEstimator = [[JKSEstimatedCompletionTime alloc] initWithUpdateInterval:1];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}


- (IBAction)startPressed:(id)sender 
{
    double totalValue = 100.0f;
    [self.progressBar setMaxValue:totalValue];
    
    // Yes, the demo leaks the dispatch queue and source…
    dispatch_queue_t queue = dispatch_queue_create("com.johansorensen.faketask", NULL);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), 0.5*NSEC_PER_SEC, 0);
    __block double completed = 0.0f;
    dispatch_source_set_event_handler(timer, ^{
        completed += arc4random_uniform(10);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressBar setDoubleValue:completed];
        });
        if (completed >= totalValue) {
            NSLog(@"total value reached");
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
    
    [_completionEstimator
     startEstimatingForCompletedValue:totalValue
     updateBlock:^double{
         return completed;
     }
     progressBlock:^(NSTimeInterval estimatedTimeRemaining) {
         [self.progressLabel setStringValue:
          [NSString stringWithFormat:@"%.2f seconds remaining", estimatedTimeRemaining]];
      }];
}


- (IBAction)startPressed2:(id)sender 
{
    const double totalValue = 100.0f;
    _completionCalculator = [[JKSEstimatedCompletionCalculator alloc] initWithCompletedValue:totalValue];
    [self.progressBar setMaxValue:totalValue];

    // Yes, the demo leaks the dispatch queue and source…
    dispatch_queue_t queue = dispatch_queue_create("com.johansorensen.faketask", NULL);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), 0.5*NSEC_PER_SEC, 0);
    __block double completed = 0.0f;
    dispatch_source_set_event_handler(timer, ^{
        completed += arc4random_uniform(10);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressBar setDoubleValue:completed];
            [_completionCalculator updateWithProgress:completed];
            NSTimeInterval estimatedTimeRemaining = [_completionCalculator estimatedTimeRemaining];
            NSLog(@"completed %.2f/%.2f estimate=%.2f", completed, totalValue, estimatedTimeRemaining);
            [self.progressLabel setStringValue:
             [NSString stringWithFormat:@"%.2f seconds remaining", estimatedTimeRemaining]];
        });
        if (completed >= totalValue) {
            NSLog(@"total value reached");
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
    [_completionCalculator start];
}

@end



