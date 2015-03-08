//
//  UIButton+RACSupport.h
//  ReactiveCocoa
//
//  Created by Ash Furrow on 2013-06-06.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACAction;

@interface UIButton (RACSupport)

/// An action to execute whenever the button is tapped.
///
/// The receiver will be automatically enabled and disabled based on
/// `RACAction.enabled`.
@property (nonatomic, strong) RACAction *rac_action;

@end
