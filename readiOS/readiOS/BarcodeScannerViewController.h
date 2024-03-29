//
//  BarcodeScannerViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 24/06/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RetrieveBooks.h"
#import "MBProgressHUD.h"

@interface BarcodeScannerViewController : UIViewController<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}
@property (retain) RetrieveBooks *retrieveBooks;
@property (strong, nonatomic) NSArray *results;


@end
