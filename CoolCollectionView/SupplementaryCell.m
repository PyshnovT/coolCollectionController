//
//  SupCell.m
//  CoolCollectionView
//
//  Created by Тимофей Пышнов on 06/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "SupplementaryCell.h"
#import "CardLayoutAttributes.h"

@interface SupplementaryCell ()



@end

@implementation SupplementaryCell

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"%@", NSStringFromCGRect(self.bounds));

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupDecorationView];

}

- (void)setupDecorationView {
    self.decorationView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    ;
    self.decorationView.layer.cornerRadius = 10;
    self.decorationView.layer.shadowOffset = CGSizeMake(0, -2);
    self.decorationView.layer.shadowOpacity = 0.2;
    self.decorationView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
  //  NSLog(@"BOUNDS::::::::::::: %@", NSStringFromCGRect(self.bounds));
    
}

@end
