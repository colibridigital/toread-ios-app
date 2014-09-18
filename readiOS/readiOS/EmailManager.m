//
//  EmailManager.m
//  readiOS
//
//  Created by Ingrid Funie on 27/06/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "EmailManager.h"


@implementation EmailManager

@synthesize listResult;

-(id)init {
    if (self = [super init]) {
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.filePath = @"";
    }
    return self;
}

-(void)saveDetailsFromDatabaseList:(NSString*)list {
    
    self.listName = list;
    
    NSLog(@"%@", self.listName);
    
    if ([list isEqualToString:@"favouriteBooks"]) {
        
        [self.appDelegate loadFavouriteDatabaseAllDetails];
        
        self.listResult = [self.appDelegate.favouriteBooks mutableCopy];
        
    } else {
    
        [self.appDelegate initiateCustomBooksListFromTheDatabaseWithAllDetails:list];
        
        self.listResult = [self.appDelegate.customListBooks mutableCopy];
    }
    
    [self saveTextFile];
    
}

-(void) saveTextFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.listName]];
    
    NSLog(@"filePath written to :%@ result count %lu", self.filePath, (unsigned long)self.listResult.count);
    
    NSString *str = @"";
    
    for (int i=0; i<self.listResult.count; i++) {
        
        BooksDatabase *bDB = [self.listResult objectAtIndex:i];

        NSLog(@"%@", bDB.title);
        
        int j = i+1;
        
        NSString *item = [NSString stringWithFormat:@"Book %i:\n\nTitle: %@\nAuthors: %@\nEditor: %@\nCover Link from Google: %@\nRating from Google: %f\n\n", j, bDB.title, bDB.authors, bDB.editor, bDB.coverLink, bDB.rating];
        str = [str stringByAppendingString:item];
    }
    
    NSLog(@"string :%@", str);
    
    [str writeToFile:self.filePath atomically:TRUE encoding:NSUnicodeStringEncoding error:NULL];
    
    //need to delete the file once is sent
}

-(MFMailComposeViewController*)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:[NSString stringWithFormat:@"Your list %@ is attached", self.listName]];
    
    NSData *fileData = [NSData dataWithContentsOfFile:self.filePath];
    
    NSLog(@"file path: %@", self.filePath);

    [picker addAttachmentData:fileData
                       mimeType:@"text/plain"
                       fileName:[NSString stringWithFormat:@"%@.txt", self.listName]];
    NSString *emailBody = @"Here you go!";
    [picker setMessageBody:emailBody isHTML:NO];
    
    NSLog(@"return picker");
    
    return picker;

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSLog(@"what is the result");
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}


@end
