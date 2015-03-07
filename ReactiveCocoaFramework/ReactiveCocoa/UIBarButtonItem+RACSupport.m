//
//  UIBarButtonItem+RACSupport.m
//  ReactiveCocoa
//
//  Created by Kyle LeNeau on 3/27/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UIBarButtonItem+RACSupport.h"
#import "EXTKeyPathCoding.h"
#import "EXTScope.h"
#import "NSObject+RACDeallocating.h"
#import "NSObject+RACDescription.h"
#import "NSObject+RACPropertySubscribing.h"
#import "RACAction.h"
#import "RACDisposable.h"
#import "RACSignal+Operations.h"
#import "RACSubject.h"
#import <objc/runtime.h>

static void *UIBarButtonItemActionKey = &UIBarButtonItemActionKey;
static void *UIBarButtonItemActionDisposableKey = &UIBarButtonItemActionDisposableKey;

@implementation UIBarButtonItem (RACSupport)

- (void)rac_actionReceived:(id)sender {
	RACSubject *subject = objc_getAssociatedObject(self, @selector(rac_actionSignal));
	[subject sendNext:self];
}

- (RACSignal *)rac_actionSignal {
	@weakify(self);
	return [[[RACSignal
		defer:^{
			@strongify(self);

			RACSubject *subject = objc_getAssociatedObject(self, @selector(rac_actionSignal));
			if (subject == nil) {
				subject = [RACSubject subject];
				objc_setAssociatedObject(self, @selector(rac_actionSignal), subject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

				if (self.target != nil) NSLog(@"WARNING: UIBarButtonItem.rac_actionSignal hijacks the item's existing target and action");

				self.target = self;
				self.action = @selector(rac_actionReceived:);
			}

			return subject;
		}]
		takeUntil:self.rac_willDeallocSignal]
		setNameWithFormat:@"%@ -rac_actionSignal", [self rac_description]];
}

- (RACAction *)rac_action {
	return objc_getAssociatedObject(self, UIBarButtonItemActionKey);
}

- (void)setRac_action:(RACAction *)action {
	RACAction *previousAction = self.rac_action;
	if (action == previousAction) return;

	objc_setAssociatedObject(self, UIBarButtonItemActionKey, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[objc_getAssociatedObject(self, UIBarButtonItemActionDisposableKey) dispose];

	if (action == nil) return;

	RACDisposable *enabledDisposable = [action.enabled setKeyPath:@keypath(self.enabled) onObject:self];
	RACDisposable *actionDisposable = [[self.rac_actionSignal
		doDisposed:^{
			[enabledDisposable dispose];
		}]
		subscribeNext:^(UIBarButtonItem *control) {
			[action execute:control];
		}];

	objc_setAssociatedObject(self, UIBarButtonItemActionDisposableKey, actionDisposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
