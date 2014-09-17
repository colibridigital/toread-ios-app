//
//  BarcodeScannerResultDetails.m
//  readiOS
//
//  Created by Ingrid Funie on 26/06/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BarcodeScannerResultDetails.h"

@interface BarcodeScannerResultDetails ()

@end

@implementation BarcodeScannerResultDetails


@synthesize starRating=_starRating;
@synthesize starRatingLabel = _starRatingLabel;
@synthesize scanResult;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"initialize");
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)showWithCustomView:(NSString*)message {
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
    //modify this according to the needs
	HUD.labelText = message;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1.5];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"show view");
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self initiatePickerViewWithTableNames];
    if([self.appDelegate connectedToInternet]) {
        [self initiateWithDetails];
    } else {
        [self showWithCustomView:@"No Internet Connection"];
    }
    
    
    _starRating.backgroundColor  = [UIColor blackColor];
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.maxRating = 5.0;
    _starRating.delegate = self;
    _starRating.horizontalMargin = 15.0;
    _starRating.editable=NO;
    
    _starRating.displayMode=EDStarRatingDisplayHalf;
    [_starRating  setNeedsDisplay];
    _starRating.tintColor = [UIColor yellowColor];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"show view2");
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self initiatePickerViewWithTableNames];
    [self initiateWithDetails];
    
    
    _starRating.backgroundColor  = [UIColor blackColor];
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.maxRating = 5.0;
    _starRating.delegate = self;
    _starRating.horizontalMargin = 15.0;
    _starRating.editable=NO;
    
    _starRating.displayMode=EDStarRatingDisplayHalf;
    [_starRating  setNeedsDisplay];
    _starRating.tintColor = [UIColor yellowColor];
    
}

-(void)initiateWithDetails {
    NSString *stringURL = [[[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"imageLinks"] objectForKey:@"thumbnail"];
    
    self.coverLink = stringURL;
    
    //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
    
    @try {
        NSURL *url = [NSURL URLWithString:stringURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        
        // dispatch_sync(dispatch_get_main_queue(), ^(void) {
        UIImage *bookImage;
        if (data != nil)
            bookImage = [[UIImage alloc] initWithData:data];
        
        self.bookCover.image = bookImage;
        //  });
        //});
        
    }
    @catch (NSException *e) {
        NSLog(@"exception thrown %@", e);
    }
    
    
    
    self.bookTitle.text = [[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"title"];
    NSString* bookAuthors = @"";
    
    if ([[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"authors"] != nil) {
        NSLog(@"not nil");
        NSArray *authors = [[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"authors"];
        
        NSLog(@" authors %@", authors);
        
        for (NSString* author in authors) {
            bookAuthors = [bookAuthors stringByAppendingString:[NSString stringWithFormat:@"%@; ",author]];
        }
        
        self.bookAuthors.text = [bookAuthors substringToIndex:[bookAuthors length] - 2]; //to remove the last ;
    } else {
        self.bookAuthors.text = @"";
    }
    
    self.editor = [[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"publisher"];
    
    if ([[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"averageRating"] != nil) {
        NSLog(@"not nil");
        NSDecimalNumber *ratings = [[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"averageRating"];
        
        self.starRating.rating = [ratings doubleValue];
        self.rating = [ratings doubleValue];
        
    } else {
        self.starRating.rating = 0.0;
    }
    
    self.starRatingLabel.text = [NSString stringWithFormat:@"%f", self.starRating.rating];
    
    self.isbn = [[[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"industryIdentifiers"][0] objectForKey:@"identifier"];
    
    NSLog(@"isbn %@", self.isbn);
    
    self.desc = [[[self.scanResult objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"description"];
    
    //cut it if too long? but not here where i get the text
    self.bookDesc.text = self.desc;
    
}


- (void) initiatePickerViewWithTableNames {
    [self.appDelegate getAllDatabaseTableNames];
    self.tableNames = [self.appDelegate.tableNames mutableCopy];
    
    [self.tableNames insertObject:@"Create New List" atIndex:1];
    
    NSMutableArray *newTable = [NSMutableArray array];
    
    for (NSString* name in self.tableNames) {
        if ([name rangeOfString:@"suggested"].location != NSNotFound || [name rangeOfString:@"read"].location != NSNotFound) {
            continue;
        } else{
            [newTable addObject:[[name stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString]];
        }
    }
    
    self.pickerViewData = [newTable mutableCopy];
    
}

- (void)showPickerView {
    //show picker view with the database to move the book to
    self.pickerView = [[UIPickerView alloc] init];
    
    // Calculate the screen's width.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float pickerWidth = screenWidth * 3 / 4;
    
    // Calculate the starting x coordinate.
    float xPoint = screenWidth / 2 - pickerWidth / 2;
    
    // Set the picker's frame. We set the y coordinate to 50px.
    [self.pickerView setFrame: CGRectMake(xPoint, 245.0f, pickerWidth, 130.0f)];
    
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    
    [self.view addSubview:self.pickerView];
}

- (IBAction)pickAction:(id)sender {
    
    
    NSInteger selectedSegment = self.segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        NSLog(@"first segment selected");
        
        [self showPickerView];
        
        // [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else {
        //toggle the correct view to be visible
        
        NSLog(@"second segment selected");
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.pickerView removeFromSuperview];
    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
}


// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerViewData count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerViewData objectAtIndex: row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New List"]) {
        
        NSLog(@"here");
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Create New List" message:@"Would you like to create a new list called?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        self.av.tag = 1;
        
        [self.av setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        [self.av show];
        
        
    } else {
        
        self.listToAdd = [self.pickerViewData objectAtIndex:row];
        
        NSString* message = [NSString stringWithFormat:@"Would you like to add a new book to the %@ list?", self.listToAdd];
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Add New Book" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        self.av.tag = 2;
        
        [self.av show];

        
    }
    
    [self.pickerView removeFromSuperview];
    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (self.av.tag == 1) {
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No");
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"You have clicked Yes with listName %@", [[self.av textFieldAtIndex:0] text]);
            self.customListTitle = [[self.av textFieldAtIndex:0] text];
            NSLog(@"%@", self.customListTitle);
            
            [self.appDelegate createNewCustomListInTheDatabase:[[self.av textFieldAtIndex:0] text]];
            [self.appDelegate addBookToTheDatabaseBookList:[self.customListTitle lowercaseString] bookTitle:self.bookTitle.text bookAuthors:self.bookAuthors.text publisher:self.editor coverLink:self.coverLink rating:self.rating isbn:self.isbn desc:self.desc];
            
            [self showWithCustomView:[NSString stringWithFormat:@"Added to : %@", self.customListTitle]];
            
        }
    } else if (self.av.tag == 2) {
        
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No");
        }
        else if(buttonIndex == 1)
        {
            
            [self.appDelegate addBookToTheDatabaseBookList:[self.listToAdd lowercaseString] bookTitle:self.bookTitle.text bookAuthors:self.bookAuthors.text publisher:self.editor coverLink:self.coverLink rating:self.rating isbn:self.isbn desc:self.desc];
            
            [self showWithCustomView:[NSString stringWithFormat:@"Added to: %@", self.listToAdd]];
        }
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
