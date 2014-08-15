//
//  JSONFormatter.m
//  SpotAPIClient
//
//  Created by Cam Saul on 8/14/14.
//  Copyright (c) 2014 Spot. All rights reserved.
//

#import "JSONFormatter.h"

bool isKey = false;
bool canBeKey = true;
int keyStart = 0;

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

NSTextStorage *FormatResponse(NSData *data) {
	typedef enum : unsigned {
		FieldTypeString,
		FieldTypeDictionary,
		FieldTypeArray,
		FieldTypeNumber
	} FieldType;
	
	NSTextStorage *output = [[NSTextStorage alloc] init];
	unsigned indentationLevel = 0;
	bool isEscaped = false;
	isKey = false;
	canBeKey = true;
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
						isKey = true;
						canBeKey = false;
						keyStart = (int)output.length + 1;
					}
					context.push(FieldTypeString);
				}
			} break;
				if (context.top() == FieldTypeString) break;
			case ':': {
				if (isKey) {
					int keyLen = (int)output.length - keyStart - 1;
					NSRange range = NSMakeRange(keyStart, keyLen);
					isKey = false;
					[output addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
				}
			} break;
			case ',': {
				outputNewLineAtEnd = true;
				canBeKey = true;
			} break;
			case '{': {
				context.push(FieldTypeDictionary);
				indentationLevel++;
				outputNewLineAtEnd = true;
				canBeKey = true;
			} break;
			case '}': {
				NSCParameterAssert(context.top() == FieldTypeDictionary);
				context.pop();
				--indentationLevel;
				outputNewLine(output, indentationLevel);
			} break;
		}
		
		appendChar(output, ch);
		if (outputNewLineAtEnd) {
			outputNewLine(output, indentationLevel);
		}
	}
	
	return output;
}