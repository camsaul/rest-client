//
//  Request.h
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

typedef enum : NSUInteger {
	APIBaseURLProduction,
	APIBaseURLStaging,
	APIBaseURLLocal
} APIBaseURL;

typedef enum : NSUInteger {
	RequestMethodGET,
	RequestMethodPOST,
	RequestMethodDELETE
} RequestMethod;

@interface Request : NSObject

/// Status of the request, updated as it
@property (nonatomic, copy, readonly) NSString *status;

- (instancetype)initWithRequestMethod:(RequestMethod)method headers:(NSDictionary *)headers baseURL:(APIBaseURL)baseURL endpoint:(NSString *)endpoint getParams:(NSDictionary *)getParams postParams:(NSDictionary *)postParams;

/// perform request. Completion will be called on non-main thread
- (void)perform:(void(^)(NSData *))completion;

@end
