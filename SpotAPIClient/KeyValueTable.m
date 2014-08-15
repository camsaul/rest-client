//
//  KeyValueTable.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "KeyValueTable.h"

@interface KeyValueTable () <NSTableViewDataSource>
@end

@implementation KeyValueTable

- (instancetype)init {
	if (self = [super init]) {
		self.valuePairs = [NSMutableArray array];
		self.arrayController = [[NSArrayController alloc] initWithContent:self.valuePairs];
	}
	return self;
}

- (void)awakeFromNib {
	NSParameterAssert(self.arrayController);
	NSParameterAssert(self.tableView);
	
	self.tableView.dataSource = self;

	[self.arrayController bind:@"contentArray" toObject:self withKeyPath:@"valuePairs" options:nil];
			
	// col:
	// <binding destination="HoO-Io-w5f" name="value" keyPath="arrangedObjects.key" id="xCt-Gk-h6Z"/>
	// cell:
	// 	<binding destination="HoO-Io-w5f" name="value" keyPath="arrangedObjects.description" id="CtJ-Fm-QCf"/>
	
	NSTableColumn *keyCol = self.tableView.tableColumns[0];
	[keyCol bind:NSValueBinding toObject:self.arrayController withKeyPath:@"arrangedObjects.key" options:nil];
	[[keyCol dataCell] bind:NSValueBinding toObject:self.arrayController withKeyPath:@"arrangedObjects.description" options:nil];
	
	NSTableColumn *valCol = self.tableView.tableColumns[1];
	[valCol bind:NSValueBinding toObject:self.arrayController withKeyPath:@"arrangedObjects.value" options:nil];
}


#pragma mark - Magic Getters

- (NSMutableDictionary *)values {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (NSDictionary *pair in self.valuePairs) {
		NSString *key = pair[@"key"];
		NSString *value = pair[@"value"];
		if (key.length && value.length) {
			dictionary[key] = value;
		}
	}
	return dictionary;
}


#pragma mark - NSMutableDictionary Behavior

- (void)setValuePairs:(NSMutableArray *)valuePairs {
	_valuePairs = valuePairs;
	self.arrayController.content = valuePairs;
	[self.tableView reloadData];
}

- (id)objectForKey:(id)aKey {
	return self.values[@"key"][@"value"];
}

- (void)setObject:(id)value forKey:(NSString *)key {
	for (NSMutableDictionary *pair in self.valuePairs) {
		if ([pair[@"key"] isEqualToString:key]) {
			pair[@"value"] = value;
			return;
		}
	}
	NSMutableDictionary *pair = [@{@"key": key, @"value": value} mutableCopy];
	[self.valuePairs addObject:pair];
}

- (void)removeObjectForKey:(NSString *)key {
	for (NSMutableDictionary *pair in self.valuePairs) {
		if ([pair.key isEqualToString:key]) {
			[self.valuePairs removeObject:pair];
			return;
		}
	}
}


- (id)objectForKeyedSubscript:(id)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
	[self setObject:obj forKey:key];
	self.arrayController.content = self.valuePairs;
	[self.tableView reloadData];
}

@end
