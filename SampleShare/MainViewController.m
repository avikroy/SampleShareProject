//
//  MainViewController.m
//  SampleShare
//
//  Created by Debasish on 26/07/14.
//  Copyright (c) 2014 Debasish. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
@interface MainViewController ()
{
    AppDelegate *appDelegate;

}
@end

static NSString* kAppId = @"1428956924009830";
@implementation MainViewController
@synthesize HUD;
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self createHUD];
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];

	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)buttonSharePressed:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:@"ShareinFB App"];
//        [mySLComposerSheet addImage:[UIImage imageNamed:@"icon_114.png"]];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://youtu.be/sO0kBRu5c28"]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    [self createAlertView:@"" withAlertMessage:@"Your Facebook Sharing was Cancelled" withAlertTag:5];
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    [self createAlertView:@"" withAlertMessage:@"Your Facebook Sharing was Successfull" withAlertTag:5];
                    break;
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else{
        [self createAlertView:@"" withAlertMessage:@"Your Facebook Setting was unavailable" withAlertTag:5];
    }
  
}
-(void)createAlertView:(NSString *)alrtTitle withAlertMessage:(NSString *)alrtMsg withAlertTag:(int)alrtTag
{
    UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:alrtTitle
                                                     message:alrtMsg
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
    myAlert.tag=alrtTag;
    [myAlert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)FacebookLoginBtnPressed
{
    // self.view.userInteractionEnabled=NO;
    
    if (isNetworkAvailable())
    {
        FBSessionLoginBehavior behavior = FBSessionLoginBehaviorForcingWebView;
        FBSessionTokenCachingStrategy *tokenCachingStrategy  = [self createCachingStrategy];
        
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",@"user_photos",@"publish_stream",
                                nil];
        
        appDelegate._session = [[FBSession alloc] initWithAppID:kAppId
                                                    permissions:permissions
                                                urlSchemeSuffix:nil
                                             tokenCacheStrategy:tokenCachingStrategy];
        
        appDelegate.facebook.accessToken =  [FBSession activeSession].accessToken;
        appDelegate.facebook.expirationDate = [FBSession activeSession].expirationDate;
        [FBSession setActiveSession: appDelegate._session];
        
        [appDelegate._session openWithBehavior:behavior
                             completionHandler:^(FBSession *session,
                                                 FBSessionState status,
                                                 NSError *error) {
                                 
                                 if (error) {
                                     
                                 }
                                 
                                 [self updateForSessionChange];
                             }];
        
    }
    else
    {
        NSLog(@"problem");
    }
}
- (void)updateForSessionChange {
    
    self.strFaaceBookAcessToken=  [FBSession activeSession].accessToken;
    
    
    if (appDelegate._session.isOpen) {
        [self showHUD];

        
        FBRequest *me = [[FBRequest alloc] initWithSession:appDelegate._session
                                                 graphPath:@"me"];
        [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                         NSDictionary<FBGraphUser> *result,
                                         NSError *error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                return;
            }
            [self hideHUD];

            NSString *strProfilepic_url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[result objectForKey:@"id"]];
            NSString *strName;
            strName=[result objectForKey:@"name"];
            NSString *strEmail=[result objectForKey:@"email"];
            NSString *strGender=[result objectForKey:@"gender"];
            NSLog(@"name:%@ and emal addres:- %@ and the gender is %@ the link is %@",strName,strEmail,strGender,strProfilepic_url);
            
           /* NSUserDefaults *defaults=User_Defaults;
            [defaults setObject:strEmail forKey:@"UserID"];
            [defaults setObject:strName forKey:@"Passwd"];
            [defaults setBool:YES forKey:@"isFBLogin"];
            [defaults synchronize];
            
            conModel=[[ConnectionModel alloc] init];
            conModel.delegate=self;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"fblogin" forKey:@"action"];
            [dict setObject:strEmail forKey:@"user_email"];
            [dict setObject:strName forKey:@"name"];
            NSLog(@"%@",dict);
            [conModel startResquestForFBLogin:dict];*/
            
        }];
    }
    else {
        if (appDelegate._session.state == FBSessionStateCreatedTokenLoaded) {
            
            [appDelegate._session openWithCompletionHandler:^(FBSession *session,
                                                              FBSessionState status,
                                                              NSError *error) {
                
                [self updateForSessionChange];
            }];
        }
        else if (appDelegate._session.state == FBSessionStateClosedLoginFailed ||appDelegate._session.state == FBSessionStateClosed) {
            
            [appDelegate._session closeAndClearTokenInformation];
            appDelegate._session = nil;
            
        }
        
    }
    
    appDelegate.facebook.accessToken = [FBSession activeSession].accessToken;
    appDelegate.facebook.expirationDate = [FBSession activeSession].expirationDate;
    
}
- (FBSessionTokenCachingStrategy*)createCachingStrategy {
    
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [[FBSessionTokenCachingStrategy alloc]
                                                           initWithUserDefaultTokenInformationKeyName:[NSString stringWithFormat:@"FBAccessTokenInformationKey"]];
    return tokenCachingStrategy;
}
#pragma mark - Check network rechability
BOOL isNetworkAvailable ()
{
    BOOL isInternet=NO;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
        isInternet=NO;
    else
        isInternet=YES;
    
    return isInternet;
}

#pragma mark - Create HUD
-(void)createHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Please wait...";
    //HUD.detailsLabelText = @"Please wait...";
    HUD.square = YES;
}
-(void)showHUD
{
    [self.HUD show:YES];
}
-(void)hideHUD
{
    [self.HUD hide:YES];
}

@end
