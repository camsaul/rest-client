//
//  KeyValueTable.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "KeyValueTable.h"
#import "KeyValuePair.h"

@interface KeyValueTable () <KeyValuePairDelegate>
@end

@implementation KeyValueTable

- (instancetype)init {
	if (self = [super init]) {
		self.valuePairs = [NSMutableArray array];
		self.arrayController = [[NSArrayController alloc] initWithContent:self.valuePairs];
		self.arrayController.objectClass = KeyValuePair.class;
	}
	return self;
}

- (void)awakeFromNib {
	NSParameterAssert(self.arrayController);
	NSParameterAssert(self.tableView);

	[self.arrayController bind:@"contentArray" toObject:self withKeyPath:@"valuePairs" options:nil];
			
	NSTableColumn *keyCol = self.tableView.tableColumns[0];
	[keyCol bind:NSValueBinding toObject:self.arrayController withKeyPath:@"arrangedObjects.key" options:nil];
	[[keyCol dataCell] bind:NSValueBinding toObject:self.arrayController withKeyPath:@"arrangedObjects.description" options:nil];
	
	NSTableColumn *valCol = self.tableView.tableColumns[1];
	[valCol bind:NSValueBinding toObject:self.arrayController withKeyPath:@"arrangedObjects.value" options:nil];
}


#pragma mark - Magic Getters

- (NSMutableDictionary *)values {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (KeyValuePair *pair in self.valuePairs) {
		if (pair.key.length && pair.value.length) {
			dictionary[pair.key] = pair.value;
		}
	}
	return dictionary;
}


#pragma mark - Actions

- (IBAction)insert:(id)sender {
	[self.arrayController addObject:[KeyValuePair pairWithKey:nil value:nil delegate:self]];
	NSLog(@"SENDER -> %@", sender);
//	[self.arrayController insert:[KeyValuePair pairWithKey:nil value:nil delegate:self]];
}

- (IBAction)remove:(id)sender {
	[self.arrayController remove:sender];
}


#pragma mark - NSMutableDictionary Behavior

- (void)setValuePairs:(NSMutableArray *)valuePairs {
	if (_valuePairs == valuePairs) return;
	
	if (!_valuePairs) {
		_valuePairs = valuePairs;
		return;
	}
	
	_valuePairs = valuePairs;
	self.arrayController.content = valuePairs;
	[self.tableView reloadData];
}

- (id)objectForKey:(id)aKey {
	return self.values[aKey][@"value"];
}

- (void)setObject:(id)value forKey:(NSString *)key {
	for (NSMutableDictionary *pair in self.valuePairs) {
		if ([pair.key isEqualToString:key]) {
			pair.value = value;
			return;
		}
	}
	KeyValuePair *pair = [KeyValuePair pairWithKey:key value:value delegate:self];
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


#pragma mark - KeyValuePairDelegate

- (void)keyValuePairUpdated:(KeyValuePair *)pair {
	NSLog(@"GET Param updated: %@", pair);
	[self.delegate keyValueTableValuesUpdated:self];
}

@end
