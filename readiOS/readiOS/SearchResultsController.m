//
//  SearchResultsController.m
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "SearchResultsController.h"
#import "SearchResultsCell.h"

@interface SearchResultsController ()

@end

@implementation SearchResultsController

@synthesize tableData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (void)setTableDataArray:(NSArray *)table {
    self.tableData = [[NSArray alloc] initWithArray:table];
}

- (IBAction)dismissView:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 30;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"initiating cell");
    
    static NSString *simpleTableIdentifier = @"SearchResultsCell";
    
    SearchResultsCell *cell = (SearchResultsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchResultsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.bookTitle.text = [[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"title"];
    
    cell.title = cell.bookTitle.text;
    
    
    NSString *stringURL = [[[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"imageLinks"] objectForKey:@"thumbnail"];
    
    cell.coverLink = stringURL;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        NSURL *url = [NSURL URLWithString:stringURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            UIImage *bookImage;
            if (data != nil)
                bookImage = [[UIImage alloc] initWithData:data];
            
            cell.bookCover.image = bookImage;
        });
    });
    
    NSString* bookAuthors = @"";
    
    if ([[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"authors"] != nil) {
        NSLog(@"not nil");
        NSArray *authors = [[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"authors"];
        
        NSLog(@" authors %@", authors);
        
        for (NSString* author in authors) {
            bookAuthors = [bookAuthors stringByAppendingString:[NSString stringWithFormat:@"%@; ",author]];
        }
        
        cell.bookAuthor.text = [bookAuthors substringToIndex:[bookAuthors length] - 2]; //to remove the last ;
    } else {
        cell.bookAuthor.text = @"";
    }
    
    cell.authors = cell.bookAuthor.text;
    
    cell.editor = [[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"publisher"];
    
    if ([[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"averageRating"] != nil) {
        NSLog(@"not nil");
        NSDecimalNumber *ratings = [[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"volumeInfo"] objectForKey:@"averageRating"];
        
        cell.rating = [ratings doubleValue];
        
    } else {
        cell.rating = 0.0;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

@end
