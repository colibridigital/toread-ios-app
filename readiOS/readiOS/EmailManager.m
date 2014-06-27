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
    }
    return self;
}

-(void)saveDetailsFromDatabaseList:(NSString*)list {
    
    //list has to have appended Books at the end
    
    if ([list isEqualToString:@"favouriteBooks"]) {
        
        [self.appDelegate loadFavouriteDatabaseAllDetails];
        
        self.listResult = [self.appDelegate.favouriteBooks mutableCopy];
        
    } else {
    
       // [self.appDelegate initiateCustomBooksListFromTheDatabaseAllDetails:list];
        
        self.listResult = [self.appDelegate.customListBooks mutableCopy];
    }
    
    [self saveTextFile];
    
}

-(void) saveTextFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"file.txt"];
    
    NSLog(@"filePath written to :%@ result count %lu", filePath, (unsigned long)self.listResult.count);
    
    NSString *str = @"";
    
    for (int i=0; i<self.listResult.count; i++) {
        
        BooksDatabase *bDB = [self.listResult objectAtIndex:i];

        NSLog(@"%@", bDB.title);
        
        NSString *item = [NSString stringWithFormat:@"Item %i:\n%@\n%@\n%@\n%@\n%f\n", i, bDB.title, bDB.authors, bDB.editor, bDB.coverLink, bDB.rating];
        str = [str stringByAppendingString:item];
    }
    
    NSLog(@"string :%@", str);
    
    [str writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
}

-(MFMailComposeViewController*)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Your list is attached"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"file.txt"];
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSLog(@"file path: %@", filePath);

    [picker addAttachmentData:fileData
                       mimeType:@"text/plain"
                       fileName:@"file.txt"];
    NSString *emailBody = @"Here you go!";
    [picker setMessageBody:emailBody isHTML:NO];
    
    NSLog(@"return picker");
    
    return picker;
    //[self presentViewController:picker animated:YES completion:nil];

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
