//
//  MainViewController.h
//  SampleShare
//
//  Created by Debasish on 26/07/14.
//  Copyright (c) 2014 Debasish. All rights reserved.
//

#import <Social/Social.h>
#import "Facebook.h"
#import "MBProgressHUD.h"
@interface MainViewController : UIViewController<MBProgressHUDDelegate>

@property (retain,nonatomic) MBProgressHUD *HUD;
@property(nonatomic,strong)NSString *strFaaceBookAcessToken;
- (IBAction)buttonSharePressed:(id)sender;
@end
