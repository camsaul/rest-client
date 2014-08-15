//
//  Request.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "Request.h"

static const float kRequestTimeoutInterval = 20.0f;

static NSOperationQueue *sRequestOperationQueue;

@interface Request ()
@property (nonatomic, copy, readwrite) NSString *status; /// magic setter will always run on main thread
@property (nonatomic, retain) NSURLRequest *URLRequest;
@end

@implementation Request


#pragma mark - Class Methods

+ (void)initialize {
	// don't think dispatch_once is need but better safe than sorry
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sRequestOperationQueue = [[NSOperationQueue alloc] init];
		sRequestOperationQueue.maxConcurrentOperationCount = 1;
	});

}

+ (NSString *)URLStringForBaseURL:(APIBaseURL)baseURL {
	switch (baseURL) {
		case APIBaseURLProduction:	return @"https://api.spot.com/api/";
		case APIBaseURLStaging:		return @"https://api-staging.spot.com/api/";
		case APIBaseURLLocal:		return @"http://localhost:8000/api/";
	}
}

+ (NSString *)stringForRequestMethod:(RequestMethod)method {
	switch (method) {
		case RequestMethodGET:		return @"GET";
		case RequestMethodPOST:		return @"POST";
		case RequestMethodDELETE:	return @"DELETE";
	}
}

+ (NSString *)stringForStatusCode:(NSUInteger)statusCode {
	switch (statusCode) {
		case 200: return @"OK";
		case 201: return @"Created";
		case 202: return @"Accepted"; // e.g. processing not completed
		case 204: return @"No Content";
		case 400: return @"Bad Request";
		case 403: return @"Forbidden";
		case 404: return @"Not Found";
		case 405: return @"Method not Allowed";
		case 406: return @"Not Acceptable";
		case 408: return @"Client Request Timeout";
		case 409: return @"Conflict";
		case 410: return @"Gone";
		case 411: return @"Length Required";
		case 412: return @"Precondition Failed";
		case 413: return @"Request Entity Too Large";
		case 414: return @"Request-URI Too Long";
		case 420: return @"Enhance Your Calm";
		case 429: return @"Too Many Requests";
		case 431: return @"Request Header Fields Too Large";
		case 500: return @"Internal Server Error";
		case 501: return @"Not Implemented";
		case 502: return @"Bad Gateway";
		case 504: return @"Gateway Timeout";
		case 505: return @"HTTP Version Not Supported";
	}
	if (statusCode >= 200 && statusCode < 400) return @"Success";
	if (statusCode < 500) return @"Client Error";
	if (statusCode < 600) return @"Server Error";
	return @"Unknown";
}

+ (NSString *)encodeGETParams:(NSDictionary *)getParams {
	NSMutableString *paramsString = [[NSMutableString alloc] init];
	[getParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		if (paramsString.length) [paramsString appendFormat:@"&"];
		[paramsString appendFormat:@"%@=%@", key, value];
	}];
	return paramsString;
}

+ (NSURL *)URLForBaseURL:(APIBaseURL)baseURL endpoint:(NSString *)endpoint getParams:(NSDictionary *)getParams {
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", [self URLStringForBaseURL:baseURL], endpoint, [self encodeGETParams:getParams]]];
}


#pragma mark - Lifecycle

- (instancetype)initWithRequestMethod:(RequestMethod)method headers:(NSDictionary *)headers baseURL:(APIBaseURL)baseURL endpoint:(NSString *)endpoint getParams:(NSDictionary *)getParams postParams:(NSDictionary *)postParams {
	if (self = [super init]) {
		NSURL				*url		= [Request URLForBaseURL:baseURL endpoint:endpoint getParams:getParams];
		NSMutableURLRequest *request	= [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kRequestTimeoutInterval];
		request.HTTPMethod				= [Request stringForRequestMethod:method];
		
		// HTTP Headers
		[headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
			[request setValue:value forHTTPHeaderField:key];
		}];
		
		// TODO - Post Params
		
		self.URLRequest = request;
	}
	return self;
}

- (void)perform:(void(^)(NSData *))completion {
	// cancel previous request(s)
	[sRequestOperationQueue cancelAllOperations];
	
	self.status = [NSString stringWithFormat:@"Performing request: \"%@ %@\"", self.URLRequest.HTTPMethod, self.URLRequest.URL.absoluteString];
	NSLog(@"Headers: %@", self.URLRequest.allHTTPHeaderFields);
	NSLog(@"Body: %@", [[NSString alloc] initWithData:self.URLRequest.HTTPBody encoding:NSUTF8StringEncoding]);

	__weak Request *weakSelf = self;
	CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
	[NSURLConnection sendAsynchronousRequest:self.URLRequest queue:sRequestOperationQueue completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *connectionError) {
		CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
		int requestTime = (int)((end - start) * 1000);
		
		NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
		if (!weakSelf) return;
		Request *strongSelf = weakSelf;
		
		if (connectionError) {
			strongSelf.status = [NSString stringWithFormat:@"Connection error: %@", connectionError.localizedDescription];
			return;
		}
		strongSelf.status = [NSString stringWithFormat:@"%ld - %@ (%d ms)", response.statusCode, [Request stringForStatusCode:response.statusCode], requestTime];
				
		completion(data);
	}];
}


#pragma mark - Getters / Setters

- (void)setStatus:(NSString *)status {
	NSLog(@"SET STATUS -> %@", status);
	NSParameterAssert(!status || [status isKindOfClass:NSString.class]);
	
	if ([NSThread isMainThread]) {
		_status = status;
		return;
	}
	__weak Request *weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		weakSelf.status = status;
	});
}

@end
