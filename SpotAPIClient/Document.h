//
//  Document.h
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument

@property (copy) NSString *urlFieldText;
@property (copy) NSString *requestStatusText;
@property (copy) NSTextStorage *responseText;

@property () NSUInteger requestMethodIndex;
@property () NSUInteger apiBaseURLIndex;

@property (strong) IBOutlet NSArrayController *headersArrayController;
@property (strong) IBOutlet NSTableView *headersTableView;

@end
