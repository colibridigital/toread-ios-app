//
//  RetrieveBooks.m
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "RetrieveBooks.h"

@implementation RetrieveBooks

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *) getDataFromURL:(NSString*) url{
    NSLog(@"try requesting books");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];

}

- (NSData*)getDataFromURLAsData:(NSString*)url {
    
    NSLog(@"try requesting books");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    return oResponseData;
}

- (NSDictionary *)getJsonFromData:(NSData*) urlData{
    
    NSLog(@"get json from data");
    
    NSError *error;
    
    // Construct a Array around the Data from the response
    NSDictionary* object = [NSJSONSerialization
                       JSONObjectWithData:urlData
                       options:0
                       error:&error];
    
    return object;
}

- (NSArray*)parseJson:(NSDictionary*) json {
    // Iterate through the object and print desired results
    
    NSLog(@"parse json");
    
    NSArray *items = [json objectForKey:@"items"];
    
    for (int i=0; i < [items count]; i++) {
        NSLog(@"Item %.2i - Title  - %@", i+1, [[items[i] objectForKey:@"volumeInfo"] objectForKey:@"title"]);
        NSLog(@"Item %.2i - Authors  - %@", i+1, [[items[i] objectForKey:@"volumeInfo"] objectForKey:@"authors"]);
        NSLog(@"Item %.2i - Publisher  - %@", i+1, [[items[i] objectForKey:@"volumeInfo"] objectForKey:@"publisher"]);
        NSLog(@"Item %.2i - Image Link  - %@", i+1, [[[items[i] objectForKey:@"volumeInfo"] objectForKey:@"imageLinks"] objectForKey:@"thumbnail"]);
        
    }
    
    return items;
}

@end
