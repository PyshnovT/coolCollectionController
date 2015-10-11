//
//  CoolCollectionView.m
//  rocketbank
//
//  Created by Vitaly Berg on 29/09/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolCollectionView.h"


@implementation CoolCollectionView


- (void)awakeFromNib {
    [self commonInit];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
    
- (void)commonInit {
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    self.cardBehaviourEnabled = NO;
    self.showsVerticalScrollIndicator = NO;
}

@end
