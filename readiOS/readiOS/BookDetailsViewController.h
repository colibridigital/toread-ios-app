//
//  BookDetailsViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailsViewController : UIViewController

- (IBAction)dismissDetailsView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
//this will eventually load the cover
//from the url? 
@property (weak, nonatomic) IBOutlet UIImageView *bookCover;

@end
