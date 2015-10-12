//
//  CoolCardTopDecorationView.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 12/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolCardTopDecorationView.h"

@implementation CoolCardTopDecorationView

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
    self.backgroundColor = [UIColor whiteColor];
}


@end
