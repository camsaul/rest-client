//
//  Document.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "Document.h"
#import "Request.h"

@interface Document ()
@property (nonatomic, strong) Request *request;

@property (copy) NSMutableDictionary *headers;
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
		self.headers = [@{@"Content-Type": @"application/json",
						  @"Auth-Token": @"",
						  @"API-Key": @""} mutableCopy];
		self.getParams = [NSMutableDictionary dictionary];
		self.postParams = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
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

BOOL isKey = NO;
BOOL canBeKey = YES;
NSUInteger keyStart = 0;

void appendChar(__unsafe_unretained NSTextStorage *output, unichar ch) {
	NSString *str = [NSString stringWithCharacters:&ch length:1];
	NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:str];
	[output appendAttributedString:attributedStr];
}

void appendStr(__unsafe_unretained NSTextStorage *output, std::string str) {
	NSString *nsStr = [[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding];
	NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:nsStr];
	[output appendAttributedString:attributedStr];
}

void outputNewLine(__unsafe_unretained NSTextStorage *output, unsigned indentationLevel) {
	std::string str { '\n' };
	while (indentationLevel > 0) {
		str += "      ";
		indentationLevel--;
	}
	appendStr(output, str);
}

- (NSTextStorage *)formatResponse:(NSData *)data {
	typedef enum : unsigned {
		FieldTypeString,
		FieldTypeDictionary,
		FieldTypeArray,
		FieldTypeNumber
	} FieldType;
	
	NSTextStorage *output = [[NSTextStorage alloc] init];
	unsigned indentationLevel = 0;
	BOOL isEscaped = NO;
	isKey = NO;
	canBeKey = YES;
	std::stack<FieldType> context;
	
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	for (int i = 0; i < string.length; i++) {
		bool outputNewLineAtEnd = false;
		
		unichar ch = [string characterAtIndex:i];
		
		switch (ch) {
			case '\\': {
				if (isEscaped) {
					isEscaped = false;
				} else {
					isEscaped = true;
				}
			} break;
			if (isEscaped) {
				isEscaped = false;
				break;
			}
			case '"': {
				if (context.top() == FieldTypeString) {
					context.pop();
				} else if (context.top() == FieldTypeDictionary) {
					if (!isKey && canBeKey) {
						isKey = YES;
						canBeKey = NO;
						keyStart = output.length + 1;
					}
					context.push(FieldTypeString);
				}
			} break;
			if (context.top() == FieldTypeString) break;
			case ':': {
				if (isKey) {
					unsigned keyLen = output.length - keyStart - 1;
					NSLog(@"keystart = %d, keyLen = %d", keyStart, keyLen);
					NSRange range = NSMakeRange(keyStart, keyLen);
					NSLog(@"Key = %d - %d --->'%@'", keyStart, keyStart + keyLen, [output attributedSubstringFromRange:range].string);
					isKey = NO;
					[output addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
				}
			} break;
			case ',': {
				outputNewLineAtEnd = true;
				canBeKey = YES;
			} break;
			case '{': {
				context.push(FieldTypeDictionary);
				indentationLevel++;
				outputNewLineAtEnd = true;
				canBeKey = YES;
			} break;
			case '}': {
				NSParameterAssert(context.top() == FieldTypeDictionary);
				context.pop();
				--indentationLevel;
				outputNewLine(output, indentationLevel);
//				outputNewLine(output, --indentationLevel);
			} break;
		}
		
		appendChar(output, ch);
		if (outputNewLineAtEnd) {
			outputNewLine(output, indentationLevel);
		}
	}
//	
//	NSTextStorage *output = [[NSTextStorage alloc] initWithString:];
//	NSMutableArray *chars = [NSMutableArray array];
		
//	char *cStr = (char *)data.bytes;
//	char *ch = cStr;
//	while(ch[0]) {
//		[output appendCharacter:ch];
//		ch++;
//	}
	
	return output;
}


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
	self.request = [[Request alloc] initWithRequestMethod:(RequestMethod)self.requestMethodIndex headers:self.headers baseURL:(APIBaseURL)self.apiBaseURLIndex endpoint:self.endpoint getParams:self.getParams postParams:self.postParams];
	[self.request perform:^(NSData *responseData) {
		NSParameterAssert(![NSThread isMainThread]);
		
		// TODO Convert to AttributedString + format
		NSTextStorage *responseStr = [self formatResponse:responseData];
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
