//
//  NSDictionary+RACSupport.h
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2012-10-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACCollection.h"

@class RACSignal;

@interface NSDictionary (RACSupport)

/// A signal that will send RACTuples of the key-value pairs in the dictionary.
///
/// Mutating the dictionary will not affect the signal after it's been created.
@property (nonatomic, strong, readonly) RACSignal *rac_signal;

/// A signal that will send all of the keys in the dictionary.
///
/// Mutating the dictionary will not affect the signal after it's been created.
@property (nonatomic, strong, readonly) RACSignal *rac_keySignal;

/// A signal that will send all of the values in the dictionary.
///
/// Mutating the dictionary will not affect the signal after it's been created.
@property (nonatomic, strong, readonly) RACSignal *rac_valueSignal;

@end
