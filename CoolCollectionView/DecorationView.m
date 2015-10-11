//
//  DecorationView.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 11/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "DecorationView.h"

@implementation DecorationView

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
}

@end
