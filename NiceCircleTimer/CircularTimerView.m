//
//  CircularTimer.m
//
//  Copyright (c) 2013 Crowd Studio.
//  Copyright (c) 2013 Luke Scott.
//  All rights reserved.
//
//  Distributed under MIT license, see LICENSE file
//

#import "CircularTimerView.h"
#import <QuartzCore/QuartzCore.h>

@interface CircularTimerView ()
{
    CADisplayLink *timer;
}

@property (assign, nonatomic) BOOL running;
@property (assign, nonatomic) float radius;
@property (nonatomic) NSTimeInterval finSecs;
@property (nonatomic) NSTimeInterval initialSecs;
@property (nonatomic) NSTimeInterval now;

@end

@implementation CircularTimerView

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.direction = CircularTimerViewDirectionClockwise;
        self.startDegrees = 270.f;
        self.radius = self.frame.size.width / 2;
        self.internalRadius = 0.f;
        [super setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.direction = CircularTimerViewDirectionClockwise;
        self.startDegrees = 270.f;
        self.radius = frame.size.width / 2;
        self.internalRadius = 0.f;
        self.autostart = YES;
        [super setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithPosition:(CGPoint)position
                radius:(float)radius
        internalRadius:(float)internalRadius
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, radius * 2, radius * 2)];
    if (self) {
        self.direction = CircularTimerViewDirectionClockwise;
        self.startDegrees = 270.f;
        self.radius = radius;
        self.internalRadius = internalRadius;
        self.autostart = YES;
        [super setBackgroundColor:[UIColor clearColor]];
    }
    
    
    //receive start/stop notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopNotification)
                                                 name:@"stopNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startNotification) name:@"startNotification" object:nil];
    
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.radius = self.frame.size.width / 2;
}

- (void)startNotification
{
    [self start];
}
    
- (void)stopNotification
{
    if (self.running) {
        [self stop];
    }
}

- (double)calculateFrameInterval
{
    float total = [self.finalDate timeIntervalSince1970] - [self.initialDate timeIntervalSince1970];
    float circumference = 2.f * M_PI * self.radius;
    float pointsPerSecond = circumference * self.contentScaleFactor / total;
    float frameInterval = floorf(1.f / (pointsPerSecond * 10.f / 60.f));
    return frameInterval;
}

- (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(float)percent
{
    float dec = percent / 100.f;
    CGFloat fRed, fBlue, fGreen, fAlpha;
    CGFloat tRed, tBlue, tGreen, tAlpha;
    CGFloat red, green, blue, alpha;
    
    if (CGColorGetNumberOfComponents(fromColor.CGColor) == 2) {
        [fromColor getWhite:&fRed alpha:&fAlpha];
        fGreen = fRed;
        fBlue = fRed;
    }
    else {
        [fromColor getRed:&fRed green:&fGreen blue:&fBlue alpha:&fAlpha];
    }
    if (CGColorGetNumberOfComponents(toColor.CGColor) == 2) {
        [toColor getWhite:&tRed alpha:&tAlpha];
        tGreen = tRed;
        tBlue = tRed;
    }
    else {
        [toColor getRed:&tRed green:&tGreen blue:&tBlue alpha:&tAlpha];
    }
    
    red = (dec * (tRed - fRed)) + fRed;
    green = (dec * (tGreen - fGreen)) + fGreen;
    blue = (dec * (tBlue - fBlue)) + fBlue;
    alpha = (dec * (tAlpha - fAlpha)) + fAlpha;
             
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)drawRect:(CGRect)rect
{
    if (self.running == NO) {
        return;
    }
    
    self.now = [[NSDate date] timeIntervalSince1970];
    self.finSecs = [self.finalDate timeIntervalSince1970];
    self.initialSecs = [self.initialDate timeIntervalSince1970];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    float strokeWidth = self.radius - self.internalRadius;
    float radius = self.internalRadius + strokeWidth / 2;
    float percent = MIN(100.f, (self.now - self.initialSecs) / (self.finSecs - self.initialSecs) * 100);
    
    if (self.frameBlock) {
        self.frameBlock(self);
    }
    
    // Background circle
    UIBezierPath *backgroundCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                    radius:radius
                                                                startAngle:DEGREES_TO_RADIANS(0.0f)
                                                                  endAngle:DEGREES_TO_RADIANS(360.0f)
                                                                 clockwise:YES];
    if (self.backgroundFadeColor) {
        [[self colorFromColor:self.backgroundColor toColor:self.backgroundFadeColor percent:percent] setStroke];
    }
    else {
        [self.backgroundColor setStroke];
    }
    backgroundCircle.lineWidth = strokeWidth;
    [backgroundCircle stroke];
    
    float startDeg;
    float endDeg;
    float oppDeg;
    
    endDeg = percent / 100.f * 360.f;
    
    switch (self.direction) {
        case CircularTimerViewDirectionClockwise:
        default:
            startDeg = self.startDegrees;
            break;
        case CircularTimerViewDirectionCounterClockwise:
            startDeg = self.startDegrees - endDeg;
            break;
        case CircularTimerViewDirectionBoth:
            startDeg = self.startDegrees - (endDeg / 2);
            break;
    }

    oppDeg = 360.f - startDeg;
    endDeg = (endDeg < oppDeg) ? startDeg + endDeg : endDeg - oppDeg;
    
    if (endDeg == startDeg) {
        if (self.invert) {
            startDeg = 0.f;
            endDeg = 0.f;
        }
        else {
            startDeg = 0.f;
            endDeg = 360.f;
        }
    }
 
    // Moving circle
    UIBezierPath *foregroundCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                    radius:radius
                                                                startAngle:DEGREES_TO_RADIANS(startDeg)
                                                                  endAngle:DEGREES_TO_RADIANS(endDeg)
                                                                 clockwise:!self.invert];
    if (self.foregroundFadeColor) {
        [[self colorFromColor:self.foregroundColor toColor:self.foregroundFadeColor percent:percent] setStroke];
    }
    else {
        [self.foregroundColor setStroke];
    }
    foregroundCircle.lineWidth = strokeWidth;
    [foregroundCircle stroke];
    
    
    
    // update text in timer and constrain to one decimal place
    NSNumberFormatter * formatter =  [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    NSNumber *countTime = [NSNumber numberWithDouble:self.now - self.initialSecs];
    self.text = [formatter stringFromNumber:countTime];
    
    // setup and add text
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:
                                @[[UIFont fontWithName:@"HiraKakuProN-W6" size:35], [UIColor whiteColor]]
                                                           forKeys:
                                @[NSFontAttributeName, NSForegroundColorAttributeName]];
    
    CGSize textSize = [self.text sizeWithAttributes:attributes];
    CGPoint textCenter = CGPointMake(center.x - textSize.width / 2, center.y - textSize.height / 2);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(0.0f, 2.0f), 1.0f);
    
    
    [self.text drawAtPoint:textCenter withAttributes:attributes];
    
}


- (void)updateCircle
{
    if ([self willRun]) {
        if (!self.running) {
            self.running = YES;
            if (self.startBlock != nil) {
                self.startBlock(self);
            }
        }
        [self setNeedsDisplay];
    } else {
        [timer invalidate], timer = nil;
        //self.running = NO;
        [self setNeedsDisplay];
        
        if (self.endBlock != nil) {
            self.endBlock(self);
        }
        return;
    }
}


#pragma mark
#pragma mark Public
#pragma mark

- (BOOL)willRun
{
    NSDate *now = [NSDate date];

    return [self.initialDate compare:now] == NSOrderedAscending
        && [self.finalDate compare:now] == NSOrderedDescending;
}

- (void)start
{
    float frameInterval;
    if (self.running == NO) {
        self.running = NO;
        if ([self willRun]) {
            if (self.framesPerSecond < 1) {
                frameInterval = [self calculateFrameInterval];
            }
            else {
                frameInterval = 1.f / (self.framesPerSecond / 60.f);
            }
            timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCircle)];
            timer.frameInterval = MIN(60, MAX(1, frameInterval));
            [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)stop
{
    [timer invalidate], timer = nil;
    self.running = NO;
}

- (void)setupCountdown:(NSTimeInterval)seconds
{
    self.initialDate = [NSDate date];
    self.finalDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
}

- (NSTimeInterval)intervalLength
{
    return [self.finalDate timeIntervalSinceDate:self.initialDate];
}

- (NSTimeInterval)runningElapsedTime
{
    
    NSLog(@"running");
    NSTimeInterval interval = 0;
    if (self.running) {
        interval = [[NSDate date] timeIntervalSinceDate:self.initialDate];
    }
    return interval;
}

@end
