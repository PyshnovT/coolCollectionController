//
//  CoolWowCardCell.m
//  CoolCollectionView
//
//  Created by Timothy Pyshnov on 13/10/15.
//  Copyright © 2015 Pyshnov. All rights reserved.
//

#import "CoolWowCardCell.h"
#import "CoolCellItem.h"

@interface CoolWowCardCell ()


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CoolWowCardCell

- (void)awakeFromNib {
    // Initialization code
}

+ (BOOL)handleItem:(CoolCellItem *)item {
    return item.type == CardItemTypeWow;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
