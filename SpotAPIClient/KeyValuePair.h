//
//  KeyValuePair.h
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

@class KeyValuePair;

@protocol KeyValuePairDelegate <NSObject>

- (void)keyValuePairUpdated:(KeyValuePair *)pair;

@end


@interface KeyValuePair : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (weak) id<KeyValuePairDelegate> delegate;

+ (KeyValuePair *)pairWithKey:(NSString *)key value:(NSString *)value delegate:(id<KeyValuePairDelegate>)delegate;

@end