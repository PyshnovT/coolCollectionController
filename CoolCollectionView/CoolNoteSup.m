//
//  CoolWowCardCell.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolNoteSup.h"
#import "CoolSupplementaryItem.h"
#import "CoolSupplementaryLayoutAttributes.h"

@interface CoolNoteSup ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, getter=isShadowVisible) BOOL shadowVisible;

@end

@implementation CoolNoteSup

- (void)awakeFromNib {
    [self commonInit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupDecorationView];
}

#pragma mark - Setups

- (void)commonInit {
    self.shadowVisible = YES;
}

- (void)setupDecorationView {
    self.decorationView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:14] CGPath]; //bezierPathWithRect:self.bounds] CGPath];
    // self.decorationView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    self.decorationView.layer.cornerRadius = 14;
    self.decorationView.layer.shadowOffset = CGSizeMake(0, 0);
    self.decorationView.layer.shadowOpacity = self.isShadowVisible ? 0.22 : 0.0;
    self.decorationView.layer.shadowColor = [UIColor blackColor].CGColor;
    
}

#pragma mark - Class

+ (BOOL)handleItem:(CoolSupplementaryItem *)item {
    return item.type == SupItemTypeNote;
}

#pragma mark - Setters

- (void)setShadowVisible:(BOOL)shadowVisible {
    _shadowVisible = shadowVisible;
    
    self.decorationView.layer.shadowOpacity = shadowVisible ? 0.22 : 0.0;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}


#pragma mark - Apply

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    CoolSupplementaryLayoutAttributes *supLayoutAttributes = (CoolSupplementaryLayoutAttributes *)layoutAttributes;
    
    self.shadowVisible = supLayoutAttributes.isShadowVisible;
}



@end
