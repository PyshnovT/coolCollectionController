//
//  CoolCollectionView.h
//  rocketbank
//
//  Created by Vitaly Berg on 29/09/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolCardCollectionView : UICollectionView

@property (nonatomic) BOOL cardBehaviourEnabled;
@property (nonatomic) BOOL cardMagicEnabled;

@property (nonatomic, strong) NSArray *clingingCellClasses; // классы-ячейки, которые прикрепляются наверх

@end
