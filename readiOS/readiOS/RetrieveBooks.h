//
//  RetrieveBooks.h
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RetrieveBooks : NSObject

- (NSString *)getDataFromURL:(NSString*)url;
- (NSData*)getDataFromURLAsData:(NSString*)url;
- (NSDictionary *)getJsonFromData:(NSData*) urlData;
- (void)parseJson:(NSDictionary*) json;

@end
