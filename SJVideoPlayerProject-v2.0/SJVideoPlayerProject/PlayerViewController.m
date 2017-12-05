//
//  PlayerViewController.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "PlayerViewController.h"
#import "SJVideoPlayerHeader.h"
#import <Masonry.h>


#define Player  [SJVideoPlayer sharedPlayer]

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:Player.view];
    [Player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.leading.trailing.offset(0);
        make.height.equalTo(Player.view.mas_width).multipliedBy(9.0f / 16);
    }];
    
    Player.placeholder = [UIImage imageNamed:@"test"];
    
    Player.assetURL = [[NSBundle mainBundle] URLForResource:@"sample.mp4" withExtension:nil];
    
    __weak typeof(self) _self = self;
    Player.clickedBackEvent = ^(SJVideoPlayer * _Nonnull player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [Player stop];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self _setPlayerMoreSettingItems];
    
    // Do any additional setup after loading the view.
}

- (void)_setPlayerMoreSettingItems {
    
    SJVideoPlayerMoreSettingSecondary *QQ = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"qq"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到QQ"];
    }];
    
    SJVideoPlayerMoreSettingSecondary *wechat = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"wechat"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到wechat"];
    }];
    
    SJVideoPlayerMoreSettingSecondary *weibo = [[SJVideoPlayerMoreSettingSecondary alloc] initWithTitle:@"" image:[UIImage imageNamed:@"weibo"] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"分享到weibo"];
    }];
    
    SJVideoPlayerMoreSetting *share = [[SJVideoPlayerMoreSetting alloc] initWithTitle:@"share" image:[UIImage imageNamed:@"share"] showTowSetting:YES twoSettingTopTitle:@"shareTitle" twoSettingItems:@[QQ, wechat, weibo] clickedExeBlock:^(SJVideoPlayerMoreSetting * _Nonnull model) {
        [Player showTitle:@"clicked Share"];
    }];
    
//    shareItem.twoSettingItems
    Player.moreSettings = @[share];
}

- (void)dealloc {
    [Player stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
