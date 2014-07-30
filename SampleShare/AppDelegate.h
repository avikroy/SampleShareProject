//
//  AppDelegate.h
//  SampleShare
//
//  Created by Debasish on 26/07/14.
//  Copyright (c) 2014 Debasish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "Facebook.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    FBSession *_session;
    Facebook *facebook;

}
@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic)MainViewController *mainVC;
@property (nonatomic, strong)  FBSession *_session;
@property (nonatomic, strong)  Facebook *facebook;
@property(nonatomic,strong)UINavigationController *navigation;

@end
