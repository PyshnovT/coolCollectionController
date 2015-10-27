//
//  DecorationView.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 11/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolCardDecorationView.h"

@interface CoolCardDecorationView ()

@property (weak, nonatomic) IBOutlet UIView *shadowView;


@end

@implementation CoolCardDecorationView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupView];
}

#pragma mark - Setups

- (void)setupView {
    /*
    self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:0.5];
    
    NSLog(@"%@", NSStringFromCGRect(self.bounds));
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.16;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
     */
}

@end
