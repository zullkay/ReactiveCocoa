//
//  UIButton+RACSupport.m
//  ReactiveCocoa
//
//  Created by Ash Furrow on 2013-06-06.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UIButton+RACSupport.h"

#import "EXTKeyPathCoding.h"
#import "NSObject+RACPropertySubscribing.h"
#import "RACAction.h"
#import "RACDisposable.h"
#import "RACSignal+Operations.h"
#import "UIControl+RACSupport.h"

#import <objc/runtime.h>

static void *UIButtonActionKey = &UIButtonActionKey;
static void *UIButtonActionDisposableKey = &UIButtonActionDisposableKey;

@implementation UIButton (RACSupport)

- (RACAction *)rac_action {
	return objc_getAssociatedObject(self, UIButtonActionKey);
}

- (void)setRac_action:(RACAction *)action {
	RACAction *previousAction = self.rac_action;
	if (action == previousAction) return;

	objc_setAssociatedObject(self, UIButtonActionKey, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[objc_getAssociatedObject(self, UIButtonActionDisposableKey) dispose];

	if (action == nil) return;

	RACDisposable *enabledDisposable = [action.enabled setKeyPath:@keypath(self.enabled) onObject:self];
	RACDisposable *actionDisposable = [[[self
		rac_signalForControlEvents:UIControlEventTouchUpInside]
		doDisposed:^{
			[enabledDisposable dispose];
		}]
		subscribeNext:^(UIButton *control) {
			[action execute:control];
		}];

	objc_setAssociatedObject(self, UIButtonActionDisposableKey, actionDisposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
