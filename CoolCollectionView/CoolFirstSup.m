//
//  CoolWowCardCell.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolFirstSup.h"
#import "CoolSupplementaryItem.h"

@interface CoolFirstSup ()


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CoolFirstSup

- (void)awakeFromNib {
    // Initialization code
}

+ (BOOL)handleItem:(CoolSupplementaryItem *)item {
    return item.type == SupItemTypeFirst;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
