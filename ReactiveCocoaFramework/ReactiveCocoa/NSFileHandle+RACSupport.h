//
//  NSFileHandle+RACSupport.h
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 5/10/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface NSFileHandle (RACSupport)

/// Repeatedly reads any available data in the background.
///
/// Returns a signal that will send zero or more `NSData` objects, then complete
/// when no more data can be read.
- (RACSignal *)rac_readDataToEndOfFile;

@end
