//
//  TutorialOptionViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 28/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface TutorialOptionViewController : UIViewController<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) AppDelegate *appDelegate;

- (void)showWithCustomView:(NSString*)message;

- (IBAction)authenticate:(id)sender;
- (IBAction)registerUser:(id)sender;
@end
