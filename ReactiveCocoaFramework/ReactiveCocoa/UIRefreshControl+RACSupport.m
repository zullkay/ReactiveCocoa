//
//  UIRefreshControl+RACSupport.m
//  ReactiveCocoa
//
//  Created by Dave Lee on 2013-10-17.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UIRefreshControl+RACSupport.h"
#import "EXTKeyPathCoding.h"
#import "NSObject+RACSelectorSignal.h"
#import "RACAction.h"
#import "RACDisposable.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACSignal.h"
#import "RACSignal+Operations.h"
#import "UIControl+RACSupport.h"
#import <objc/runtime.h>

static void *UIRefreshControlActionKey = &UIRefreshControlActionKey;
static void *UIRefreshControlActionDisposableKey = &UIRefreshControlActionDisposableKey;

@implementation UIRefreshControl (RACSupport)

- (RACAction *)rac_action {
	return objc_getAssociatedObject(self, UIRefreshControlActionKey);
}

- (void)setRac_action:(RACAction *)action {
	RACAction *previousAction = self.rac_action;
	if (action == previousAction) return;

	objc_setAssociatedObject(self, UIRefreshControlActionKey, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[objc_getAssociatedObject(self, UIRefreshControlActionDisposableKey) dispose];

	if (action == nil) return;

	RACDisposable *enabledDisposable = [action.enabled setKeyPath:@keypath(self.enabled) onObject:self];
	RACDisposable *actionDisposable = [[[[[self
		rac_signalForControlEvents:UIControlEventValueChanged]
		doDisposed:^{
			[enabledDisposable dispose];
		}]
		map:^(UIRefreshControl *control) {
			return [[[[action
				signalWithValue:control]
				catchTo:[RACSignal empty]]
				ignoreValues]
				concat:[RACSignal return:control]];
		}]
		concat]
		subscribeNext:^(UIRefreshControl *control) {
			[control endRefreshing];
		}];

	objc_setAssociatedObject(self, UIRefreshControlActionDisposableKey, actionDisposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
