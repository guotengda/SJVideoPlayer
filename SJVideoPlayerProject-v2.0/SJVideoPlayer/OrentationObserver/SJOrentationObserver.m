//
//  SJOrentationObserver.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/5.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJOrentationObserver.h"
#import <Masonry/Masonry.h>

@interface SJOrentationObserver ()

@property (nonatomic, assign, readwrite, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, weak, readwrite) UIView *view;
@property (nonatomic, weak, readwrite) UIView *targetSuperview;

@end

@implementation SJOrentationObserver

- (instancetype)initWithTarget:(__weak UIView *)view container:(__weak UIView *)targetSuperview {
    self = [super init];
    if ( !self ) return nil;
    [self _observerDeviceOrientation];
    _view = view;
    _targetSuperview = targetSuperview;
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_observerDeviceOrientation {
    if ( ![UIDevice currentDevice].generatesDeviceOrientationNotifications ) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_handleDeviceOrientationChange {
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            self.fullScreen = NO;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            self.fullScreen = YES;
        }
            break;
        default: break;
    }
}

- (void)setFullScreen:(BOOL)fullScreen {
    if ( self.rotationCondition ) {
        if ( !self.rotationCondition(self) ) return;
    }
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( (UIDeviceOrientation)statusBarOrientation == deviceOrientation ) return;
    
    _fullScreen = fullScreen;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIView *superview = nil;
    UIInterfaceOrientation ori = UIInterfaceOrientationUnknown;
    switch ( [UIDevice currentDevice].orientation ) {
        case UIDeviceOrientationPortrait: {
            ori = UIInterfaceOrientationPortrait;
            transform = CGAffineTransformIdentity;
            superview = self.targetSuperview;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            ori = UIInterfaceOrientationLandscapeRight;
            transform = CGAffineTransformMakeRotation(M_PI_2);
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            ori = UIInterfaceOrientationLandscapeLeft;
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            superview = [UIApplication sharedApplication].keyWindow;
        }
            break;
        default: break;
    }

    if ( !superview ) return;
    if ( UIInterfaceOrientationUnknown == ori ) return;
    
    [superview addSubview:_view];
    [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ( UIInterfaceOrientationPortrait == ori ) {
            make.edges.offset(0);
        }
        else {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            make.size.mas_offset(CGSizeMake(MAX(width, height), MIN(width, height)));
            make.center.mas_offset(CGPointMake(0, 0));
        }
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        _view.transform = transform;
    }];
    [UIApplication sharedApplication].statusBarOrientation = ori;
    if ( self.orientationChanged ) self.orientationChanged(self);
}

- (BOOL)_changeOrientation {
    
    if ( self.fullScreen ) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
    else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    return YES;
}

@end
