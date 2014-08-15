//
//  KeyValueTable.h
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyValueTable : NSObject

@property (strong) IBOutlet NSArrayController *arrayController;
@property (strong) IBOutlet NSTableView *tableView;

@property (nonatomic, copy) NSMutableArray *valuePairs; // bind this
@property (nonatomic, readonly) NSMutableDictionary *values;

#pragma mark - Dictionary Behavior

- (id)objectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)removeObjectForKey:(id)aKey;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
