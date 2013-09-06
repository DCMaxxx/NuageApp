//
//  NSString+NPMimeType.m
//  Cloud
//
//  Created by np101137 on 9/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+NPMimeType.h"
#if TARGET_OS_IPHONE
#endif


@implementation NSString (NPMimeType)

- (NSString *)mimeType
{
    NSString *mimeType = @"application/octet-stream";
    
    
	CFStringRef pathExtension = CFBridgingRetain([self pathExtension]);
    
	if (pathExtension != NULL) {
		if (CFStringGetLength(pathExtension) > 0) {
			CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
			
			if (UTI != NULL) {
				CFStringRef registeredType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
				
				if (registeredType != nil) {
					mimeType = CFBridgingRelease(registeredType);
				}
				
				CFRelease(UTI);
			}
		}
		
		CFRelease(pathExtension);
    }
	
    
    return mimeType;
}

@end
