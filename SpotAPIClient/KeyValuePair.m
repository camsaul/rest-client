//
//  KeyValuePair.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "KeyValuePair.h"

@implementation KeyValuePair

+ (KeyValuePair *)pairWithKey:(NSString *)key value:(NSString *)value delegate:(id<KeyValuePairDelegate>)delegate {
	KeyValuePair *pair = [[KeyValuePair alloc] init];
	pair.key = key;
	pair.value = value;
	pair.delegate = delegate;
	return pair;
}

- (void)setKey:(NSString *)key {
	_key = key;
	[self.delegate keyValuePairUpdated:self];
}

- (void)setValue:(NSString *)value {
	_value = [value description];
	[self.delegate keyValuePairUpdated:self];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ -> %@", self.key, self.value];
}

- (id)objectForKey:(id)aKey {
	return [self valueForKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
	[self setValue:anObject forKey:aKey];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
	[self setObject:obj forKey:key];
}

@end
