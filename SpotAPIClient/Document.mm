//
//  Document.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "Document.h"
#import "Request.h"
#import "JSONFormatter.h"

@interface Document ()
@property (nonatomic, strong) Request *request;

@property (copy) NSMutableDictionary *getParams;
@property (copy) NSMutableDictionary *postParams;

@property (readonly) NSString *endpoint; /// the part of the URL that doesn't include base URL or GET params.
@end

@implementation Document


#pragma mark - Window Property Getters

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"Document";
}

+ (BOOL)autosavesInPlace
{
    return YES;
}


#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
		self.urlFieldText = @"users/1";
  
		self.getParams = [NSMutableDictionary dictionary];
		self.postParams = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)windowControllerWillLoadNib:(NSWindowController *)windowController {
	[super windowControllerWillLoadNib:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];

	NSParameterAssert(self.HTTPHeadersTable);
	self.HTTPHeadersTable[@"Content-Type"] = @"application/json";
	self.HTTPHeadersTable[@"Auth-Token"] = @"";
	self.HTTPHeadersTable[@"API-Key"] = @"";

}


#pragma mark - Load/Save Data

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
	@throw exception;
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
	// You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
	// If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
	@throw exception;
	return YES;
}


#pragma mark - Local Methods




#pragma mark - Getters / Setters

- (NSString *)endpoint {
	NSArray *components = [self.urlFieldText componentsSeparatedByString:@"?"];
	if (!components.count) return self.urlFieldText;
	return components[0];
}

- (void)setRequest:(Request *)request {
	if (_request == request) return;
	[_request removeObserver:self forKeyPath:@"status"];
	[request addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:NULL];
	_request = request;
}


#pragma mark - Actions

- (IBAction)goButtonPressed:(id)sender {
	self.request = [[Request alloc] initWithRequestMethod:(RequestMethod)self.requestMethodIndex headers:self.HTTPHeadersTable.values baseURL:(APIBaseURL)self.apiBaseURLIndex endpoint:self.endpoint getParams:self.getParams postParams:self.postParams];
	[self.request perform:^(NSData *responseData) {
		NSParameterAssert(![NSThread isMainThread]);
		
		// TODO Convert to AttributedString + format
		NSTextStorage *responseStr = FormatResponse(responseData);
		dispatch_async(dispatch_get_main_queue(), ^{
			self.responseText = responseStr;
		});
	}];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:Request.class] && [keyPath isEqualToString:@"status"]) {
		Request *request = (Request *)object;
		NSLog(@"Observe: request.status -> (%@) %@", request.status.class, request.status);
		self.requestStatusText = request.status;
		
	}
}


@end
