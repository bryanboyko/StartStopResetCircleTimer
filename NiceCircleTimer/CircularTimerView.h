//
//  CircularTimer.h
//
//  Copyright (c) 2013 Crowd Studio.
//  Copyright (c) 2013 Luke Scott.
//  All rights reserved.
//
//  Distributed under MIT license, see LICENSE file
//

#import <UIKit/UIKit.h>

typedef enum {
    CircularTimerViewDirectionClockwise,
    CircularTimerViewDirectionCounterClockwise,
    CircularTimerViewDirectionBoth
} CircularTimerViewDirection;

@interface CircularTimerView : UIView

- (id)initWithPosition:(CGPoint)position
                radius:(float)radius
        internalRadius:(float)internalRadius;

- (void)start;
- (void)stop;
- (BOOL)isRunning;
- (BOOL)willRun;
- (void)setupCountdown:(NSTimeInterval)seconds;

- (NSTimeInterval)intervalLength;
- (NSTimeInterval)runningElapsedTime;

@property (readonly, nonatomic, getter = isRunning) BOOL running;
@property (readonly, nonatomic) float radius;
@property (assign, nonatomic) float internalRadius;
@property (assign, nonatomic) float startDegrees;
@property (assign, nonatomic) CircularTimerViewDirection direction;
@property (assign, nonatomic) BOOL invert;
@property (assign, nonatomic) BOOL autostart;
@property (assign, nonatomic) NSInteger framesPerSecond;
@property (strong, nonatomic) NSDate *initialDate;
@property (strong, nonatomic) NSDate *finalDate;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *backgroundFadeColor;
@property (strong, nonatomic) UIColor *foregroundColor;
@property (strong, nonatomic) UIColor *foregroundFadeColor;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *fontFadeColor;
@property (strong, nonatomic) NSString *text;
@property (copy, nonatomic) void(^startBlock)(CircularTimerView *circularTimerView);
@property (copy, nonatomic) void(^endBlock)(CircularTimerView *circularTimerView);
@property (copy, nonatomic) void(^frameBlock)(CircularTimerView *circularTimerView);
@end