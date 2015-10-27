//
//  DecorationView.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 11/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolCardDecorationView.h"

@implementation CoolCardDecorationView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - Setups

- (void)setupView {
    self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.16;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

@end
