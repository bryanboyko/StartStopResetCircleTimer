//
//  BBTimer2ViewController.m
//  NiceCircleTimer
//
//  Created by Bryan Boyko on 8/21/14.
//  Copyright (c) 2014 Bryan Boyko. All rights reserved.
//

#import "BBTimer2ViewController.h"
#import "CircularTimerView.h"
#import "QBFlatButton.h"
#import "BBPopupViewController.h"
#import "UIViewController+CWPopup.h"

@interface BBTimer2ViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) CircularTimerView *circularTimer;
@property (nonatomic, assign) NSTimeInterval *selectedCountdownTime;
@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic) UIView *hidePickerView;
@property (nonatomic) NSTimeInterval seconds;

@property (nonatomic) QBFlatButton *startButton;
@property (nonatomic) QBFlatButton *stopButton;
@property (nonatomic) QBFlatButton *resetButton;
@property (nonatomic) QBFlatButton *timePickerButton;

@property (nonatomic) BOOL firstStartPush;
@property (nonatomic) BOOL keepStopped;

@property (nonatomic) UIView *topView;

@property (nonatomic) NSTimeInterval timerLength;

@end

@implementation BBTimer2ViewController
@synthesize datePicker, hidePickerView, stopButton, resetButton, startButton, timePickerButton;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.keepStopped = NO;
        self.firstStartPush = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // activate popover blur view
    self.useBlurForPopup = YES;
    
    //add top view to recess timer animation 'below' gray circles
    self.topView = [[UIView alloc] initWithFrame:self.view.frame];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topView];
    
    //add buttons
    [self createStartButton];
    
    // Stop Button
    [self createStopButton];
    
    // Set Time button
    [self createTimePickerButton];
    
    [self drawOuterCircle];
    [self drawInnerCircle];
}

-(void)toggleStopReset:(id)sender
{

    
    if (sender == stopButton) {
            
            //stop animation
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopNotification" object:nil];
            
            // remove stop button when stop button is pushed
            [stopButton removeFromSuperview];
            
            //add reset button in place of stop button
            [self createResetButton];
        
            self.keepStopped = YES;
            
    } else if (sender == startButton) {
        
        if (self.keepStopped == NO) {
            
            if (self.firstStartPush == NO) {
                
                [self.circularTimer setupCountdown:self.timerLength];
                
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"startNotification" object:nil];
                    
                    self.keepStopped = YES;
            
                
            } else if (self.firstStartPush == YES) {
                [self createCircle];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"startNotification" object:nil];
                
                self.firstStartPush = NO;
            }
            
        }
    } else if (sender == resetButton) {
        
        // replace reset button with stop button
        [resetButton removeFromSuperview];
        [self.view addSubview:stopButton];
        
        self.keepStopped = NO;
        
        // reset circle animation and keep stopped at zero secs
        [self.circularTimer setupCountdown:self.timerLength];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startNotification" object:nil];
        [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:0.03];
    }
}

- (void)stopAnimation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopNotification" object:nil];
}


#pragma Circle Code



- (void)createCircle
{
    self.circularTimer = [[CircularTimerView alloc] initWithPosition:CGPointMake(CGRectGetMidX(self.view.frame)-105.0f,
                                                                                 CGRectGetMidY(self.view.frame)-145.0f)
                                                              radius:105.0f
                                                      internalRadius:90.0f];
    
    self.circularTimer.backgroundColor = [UIColor clearColor];
    self.circularTimer.backgroundFadeColor = [UIColor clearColor];
    self.circularTimer.foregroundColor = [UIColor yellowColor];
    self.circularTimer.foregroundFadeColor = [UIColor redColor];
    self.circularTimer.direction = CircularTimerViewDirectionClockwise;
    self.circularTimer.fontColor = [UIColor whiteColor];
    self.circularTimer.fontFadeColor = [UIColor whiteColor];
    
    [self.circularTimer setupCountdown:self.timerLength];
    
    self.circularTimer.frameBlock = ^(CircularTimerView *circularTimerView){
        circularTimerView.text = [NSString stringWithFormat:@"%f", [circularTimerView intervalLength]];
    };
    
    [self.view insertSubview:self.circularTimer aboveSubview:self.topView];
}

- (void)drawOuterCircle
{
    // Set up the shape of the circle
    int radius = 120;
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius,
                                  CGRectGetMidY(self.view.frame)-radius-40);
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor lightGrayColor].CGColor;
    circle.lineWidth = 30;
    
    // add shadow
    circle.shadowColor = [[UIColor blackColor] CGColor];
    circle.shadowOffset = CGSizeMake(0.0f, 1.0f);
    circle.shadowRadius = 1.0f;
    circle.shadowOpacity = 0.8f;
    
    // Add to parent layer
    [self.topView.layer addSublayer:circle];
}


- (void)drawInnerCircle
{
    
    // Set up the shape of the circle
    int radius = 45;
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(CGRectGetMidX(self.view.frame)-radius,
                                  CGRectGetMidY(self.view.frame)-radius-40);
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor lightGrayColor].CGColor;
    circle.lineWidth = 90;
    
    // add shadow
    circle.shadowColor = [[UIColor blackColor] CGColor];
    circle.shadowOffset = CGSizeMake(0.0f, 1.0f);
    circle.shadowRadius = 1.0f;
    circle.shadowOpacity = 0.8f;
    
    // Add to parent layer
    [self.topView.layer addSublayer:circle];
}

- (NSDate *)dateWithZeroSeconds:(NSDate *)date
{
    NSTimeInterval time = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

#pragma create buttons

- (void)createStartButton
{
    startButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(30, 500, 115, 50);
    startButton.surfaceColor = [UIColor colorWithRed:86.0/255.0 green:217.0/255.0 blue:80.0/255.0 alpha:1.0];
    startButton.sideColor = [UIColor colorWithRed:80.0/255.0 green:160.0/255.0 blue:100.0/255.0 alpha:1.0];
    startButton.cornerRadius = 8.0;
    startButton.height = 2.0;
    startButton.depth = 1.0;
    
    [startButton addTarget:self action:@selector(toggleStopReset:) forControlEvents:UIControlEventTouchUpInside];
    
    startButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.view addSubview:startButton];
}

- (void)createStopButton
{
    stopButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    stopButton.frame = CGRectMake(175, 500, 115, 50);
    stopButton.surfaceColor = [UIColor colorWithRed:243.0/255.0 green:70.0/255.0 blue:0 alpha:1.0];
    stopButton.sideColor = [UIColor colorWithRed:160.0/255.0 green:80.0/255.0 blue:100.0/255.0 alpha:1.0];
    stopButton.cornerRadius = 8.0;
    stopButton.height = 2.0;
    stopButton.depth = 1.0;
    
    [stopButton addTarget:self action:@selector(toggleStopReset:) forControlEvents:UIControlEventTouchUpInside];
    
    stopButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    [self.view addSubview:stopButton];
}

- (void)createResetButton
{
    resetButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    resetButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = CGRectMake(190, 500, 100, 50);
    resetButton.surfaceColor = [UIColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:20.0/255.0 alpha:1.0];
    resetButton.sideColor = [UIColor colorWithRed:160.0/255.0 green:80.0/255.0 blue:100.0/255.0 alpha:1.0];
    resetButton.cornerRadius = 8.0;
    resetButton.height = 2.0;
    resetButton.depth = 1.0;
    
    [resetButton addTarget:self action:@selector(toggleStopReset:) forControlEvents:UIControlEventTouchUpInside];
    
    resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    
    [self.view addSubview:resetButton];
}

- (void)createTimePickerButton
{
    timePickerButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    timePickerButton = [QBFlatButton buttonWithType:UIButtonTypeCustom];
    timePickerButton.frame = CGRectMake(70, 440, 180, 50);
    timePickerButton.surfaceColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:255.0/255.0 alpha:1.0];
    timePickerButton.sideColor = [UIColor colorWithRed:100.0/255.0 green:80.0/255.0 blue:200.0/255.0 alpha:1.0];
    timePickerButton.cornerRadius = 8.0;
    timePickerButton.height = 2.0;
    timePickerButton.depth = 1.0;
    
    [timePickerButton addTarget:self action:@selector(btnPresentPopup:) forControlEvents:UIControlEventTouchUpInside];
    
    timePickerButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [timePickerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [timePickerButton setTitle:@"Set Timer" forState:UIControlStateNormal];
    
    [self.view addSubview:timePickerButton];
}

- (IBAction)showPicker:(UIButton *)sender
{
    // date picker setup
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + 250, 325, 250)];
    datePicker.countDownDuration = 30;
    datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    datePicker.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self.view addSubview:datePicker];
    
    // show picker in view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.3 animations:^{
        datePicker.frame = CGRectMake(0, screenRect.size.height - 230, 320, 250);
    }];
    [self performSelector:@selector(addCancelView) withObject:self afterDelay:0.3f];
}

- (void)addCancelView
{
    NSLog(@"added cancel view");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    hidePickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0, 320, screenRect.size.height - 230)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker:)];
    [hidePickerView addGestureRecognizer:tap];
    hidePickerView.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:hidePickerView];
}

- (void)hidePicker:(UITapGestureRecognizer *)sender
{
    [hidePickerView removeFromSuperview];
    datePicker.tag = 0;
    
    self.timerLength = datePicker.countDownDuration;
    NSLog(@"self.timerLength %f", self.timerLength);
    
    [UIView animateWithDuration:0.3 animations:^{
        datePicker.frame = CGRectMake(0, self.view.frame.size.height + 250, 325, 250);
    }];
    [self performSelector:@selector(dismissPopup) withObject:nil afterDelay:0.0f];
}


#pragma popup functions

- (IBAction)btnPresentPopup:(UIButton *)sender {
    BBPopupViewController *popupViewController = [[BBPopupViewController alloc] initWithNibName:@"BBPopupViewController" bundle:nil];
    [self presentPopupViewController:popupViewController animated:YES completion:nil];
    [self performSelector:@selector(showPicker:) withObject:nil afterDelay:0.3f];
}

- (void)dismissPopup {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}

//// so that tapping popup view doesnt dismiss it
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    return touch.view == self.view;
//}



@end
