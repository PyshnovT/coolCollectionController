//
//  CoolCollectionViewLayout.h
//  rocketbank
//
//  Created by Тимофей Пышнов on 02/10/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CardColletionViewLayoutDelegate <NSObject>

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CoolCardCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<CardColletionViewLayoutDelegate> delegate;

@property (nonatomic) CGFloat interSectionSpaceY;
@property (nonatomic) CGFloat interItemSpaceY;
//@property (nonatomic) CGFloat cellHeight;

@end
