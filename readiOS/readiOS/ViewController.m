//
//  ViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "ViewController.h"
#import "BookCollectionViewCell.h"
#import "BookDetailsViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)initializeCollectionViewData
{
    self.bookFavoriteImages = @[@"one.jpg",@"two.jpg",@"three.jpg",@"four.jpg"];
    self.bookSuggestedImages = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"];
    self.bookUniversityImages = @[@"math.jpg", @"design.jpg", @"java.jpg", @"ai.jpg", @"logic.jpg"];
    self.bookMathsImages = @[@"maths1.jpg", @"maths2.jpg"];
    self.bookRandomImages = @[@"4.jpg", @"four.jpg", @"ai.jpg"];
    
    self.pickerViewData = @[@"University", @"Mathematics", @"Random"];
    
    self.customCollectionImages = self.bookUniversityImages;
    [self.customListButton setTitle:@"University" forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNibAndCell];
    [self.customCollectionView registerNibAndCell];
    [self.suggestedBooksView registerNibAndCell];
    
    [self initializeCollectionViewData];
    
    [self addGestureRecognizer:self.suggestedBooksView];
    [self addGestureRecognizer:self.collectionView];
    [self addGestureRecognizer:self.customCollectionView];
}

- (void)addGestureRecognizer:(BookCollectionView*)collView
{
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [collView addGestureRecognizer:lpgr];
  }

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    NSLog(@"in here");
   // CGPoint p = [gestureRecognizer locationInView:self.suggestedBooksView];
    
   // NSIndexPath *indexPath = [self.suggestedBooksView indexPathForItemAtPoint:p];
  //  if (indexPath == nil){
 //       NSLog(@"couldn't find index path");
 //   } else {
        // get the cell at indexPath (the one you long pressed)
        // BookCollectionViewCell* cell =[self cellForItemAtIndexPath:indexPath];
        // do stuff with the cell
        BookDetailsViewController *bookDetails = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        
        [self presentViewController:bookDetails animated:YES completion:nil];
        
      //  NSLog(@"getting cell %@", indexPath);
  //  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.suggestedBooksView) {
        return self.bookFavoriteImages.count;
    } else if (collectionView == self.collectionView) {
        return self.bookSuggestedImages.count;
    } else if (collectionView == self.customCollectionView) {
        return self.customCollectionImages.count;
    }
    
    else return 0;
}

- (void)saveBookToCell:(NSIndexPath *)indexPath cell:(BookCollectionViewCell *)cell booksImages:(NSArray *)booksImages
{
    UIImage *bookImage = [[UIImage alloc] init];
    bookImage = [UIImage imageNamed:[booksImages objectAtIndex:indexPath.row]];
    cell.bookLabel.text = [NSString stringWithFormat:@"Book %li", (long)indexPath.row ];
    [cell.bookLabel sizeToFit];
    cell.bookImage.image = bookImage;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    if (collectionView == self.suggestedBooksView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookSuggestedImages];
    } else if (collectionView == self.collectionView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookFavoriteImages];
    } else if (collectionView == self.customCollectionView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.customCollectionImages];
    }
    
    return cell;
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

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    //here we need to get the specific list from the cache-database...
    //atm we keep it dummy:
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Mathematics"]) {
        self.customCollectionImages = self.bookMathsImages;
        [self.customListButton setTitle:@"Mathematics" forState:UIControlStateNormal];
        NSLog(@"changed to maths");
    } else if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"University"]) {
        self.customCollectionImages = self.bookUniversityImages;
        [self.customListButton setTitle:@"University" forState:UIControlStateNormal];
        NSLog(@"changed to uni");
    } else {
        self.customCollectionImages = self.bookRandomImages;
        [self.customListButton setTitle:@"Random" forState:UIControlStateNormal];
        NSLog(@"changed to random");
    }
    
    //we can create a new custom list as well
    
    [self.customCollectionView reloadData];
    
    [self.pickerView removeFromSuperview];

}

- (IBAction)customListSelector:(id)sender {
    
    
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
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    
    [self.view addSubview:self.pickerView];
    
    }
@end
