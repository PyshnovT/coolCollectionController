//
//  CoolCollectionViewLayout.m
//  rocketbank
//
//  Created by Тимофей Пышнов on 02/10/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolCardCollectionViewLayout.h"
#import "CoolCardCollectionView.h"
#import "CoolCardDecorationView.h"

#import "CoolCardTopDecorationView.h"

#import "CoolSupplementaryLayoutAttributes.h"

@interface CoolCardCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo; 
@property (nonatomic, strong) NSMutableDictionary *cellBottomY;

@property (nonatomic) NSInteger numberOfClingedCards;
@property (nonatomic) CGFloat clingYOffset;

@property (nonatomic) BOOL cardBehaviourEnabled;
@property (nonatomic) BOOL cardMagicEnabled;

@property (nonatomic) NSInteger topMostSupIndex;

@end

@implementation CoolCardCollectionViewLayout

#warning Simplier!

#pragma mark - Setup

- (void)awakeFromNib {
    [self setupLayout];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout {
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    self.cardBehaviourEnabled = ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled;
    self.cardMagicEnabled = ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
    
    self.numberOfClingedCards = 3;
    self.clingYOffset = 8;
    
    self.interItemSpaceY = 0;
    self.interSectionSpaceY = 0;
    
    self.cellBottomY = [NSMutableDictionary dictionary];
    
    [self registerClass:[CoolCardDecorationView class] forDecorationViewOfKind:@"bottomLine"];
    [self registerClass:[CoolCardTopDecorationView class] forDecorationViewOfKind:@"topLine"];
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    NSInteger lastItemIndex = MAX(0, [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:numberOfSections - 1] - 1);
    
    NSIndexPath *indexPathForLastCard = [NSIndexPath indexPathForItem:lastItemIndex inSection:numberOfSections-1];
    
    NSNumber *tag = [self tagForIndexPath:indexPathForLastCard];
    CGFloat height = self.collectionView.contentInset.top + [self.cellBottomY[tag] floatValue] + self.collectionView.contentInset.bottom;
    
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, height);
    
    return size;
}

- (void)prepareLayout {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplementaryInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            
            
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSNumber *tag = [self tagForIndexPath:indexPath];
            
            NSDictionary *cellLayout = [self cellLayoutInfoForIndexPath:indexPath];
            self.cellBottomY[tag] = [cellLayout objectForKey:@"currentBottomY"];
            
            CGSize cellSize = [[cellLayout objectForKey:@"cellSize"] CGSizeValue];
            CGSize supplementaryViewSize = [[cellLayout objectForKey:@"supplementaryViewSize"] CGSizeValue];
            CGFloat previousBottomY = [[cellLayout objectForKey:@"previousBottomY"] floatValue];
        
            CGFloat cellCenterY = previousBottomY + (cellSize.height) / 2.0 + supplementaryViewSize.height;
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.size = cellSize;
            itemAttributes.center = CGPointMake(cellSize.width / 2.0, cellCenterY);
            
            cellLayoutInfo[indexPath] = itemAttributes;
            

            CellItemType itemType = [self.delegate cellItemTypeForCellAtIndexPath:indexPath];
            
            
            
            if (!indexPath.item) { // тут создаётся supplementary
                CoolSupplementaryLayoutAttributes *supAttributes = [CoolSupplementaryLayoutAttributes layoutAttributesForSupplementaryViewOfKind:supplementaryKind withIndexPath:indexPath];
                supAttributes.size = supplementaryViewSize;
                
                CGFloat supplementaryY = previousBottomY;
                CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
                CGFloat clingYOfsset = MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingedCards - 1));
                
                supAttributes.shadowVisible = YES;
                
                if (self.cardBehaviourEnabled) {
                    
                    if (self.cardMagicEnabled && indexPath.section > self.numberOfClingedCards - 1) { //
                        CGFloat d = previousBottomY - collectionViewYOffset - clingYOfsset;
                        
                        NSInteger magicN = 40;
                        
                        if (d <= magicN && magicN >= 0) {
                            
                            self.topMostSupIndex = indexPath.section;

                        
                            CGFloat delta = MIN((magicN - (d / magicN * magicN)) / 4, self.clingYOffset);
                            NSInteger rDelta = round(delta);
                        
                            
                            for (int i = 1; i <= 3; i++) {
                                
                                if (i == 3) {
                                    rDelta = -rDelta;
                                }

                                
                                NSIndexPath *previousSupplementaryIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section - i];
                                CoolSupplementaryLayoutAttributes *prevAttributes = supplementaryInfo[previousSupplementaryIndexPath];
                                
                                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - rDelta);

                                
                                supplementaryInfo[previousSupplementaryIndexPath] = prevAttributes;
                            }

                        }
                
                    }
                    
                    if ((supplementaryY < collectionViewYOffset + clingYOfsset)) { // всё, прицепился
                        supplementaryY = collectionViewYOffset + clingYOfsset;
                        
                        if (indexPath.section > self.numberOfClingedCards - 1) {
                            supAttributes.shadowVisible = self.cardMagicEnabled;
                        }
                        
                        
                    }
                    
                }
                
                
                supAttributes.center = CGPointMake(supplementaryViewSize.width / 2.0, supplementaryY + supplementaryViewSize.height / 2.0);
                supplementaryInfo[indexPath] = supAttributes;
                
            }
            
            
            
        }
    }
    
    newLayoutInfo[cellReuseIdentifier] = cellLayoutInfo;
    newLayoutInfo[supplementaryKind] = supplementaryInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    for (NSString *key in self.layoutInfo) {
        NSDictionary *attributesDict = [self.layoutInfo objectForKey:key];
        
        for (NSIndexPath *indexKey in attributesDict) {
            
            UICollectionViewLayoutAttributes *attributes = [attributesDict objectForKey:indexKey];
            
            if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) { // тут добавляем decoration
                
                if (self.cardBehaviourEnabled) {
                    
                    UICollectionViewLayoutAttributes *topDecorationViewAttributes = [self decorationAttributesForTopView];
                    [allAttributes addObject:topDecorationViewAttributes];
                   
                    UICollectionViewLayoutAttributes *decorationAttributes = [self decorationAttributesForSupplementaryViewAttributes:attributes indexPath:indexKey];
                    
                    if (decorationAttributes) {
                        [allAttributes addObject:decorationAttributes];
                    }
                    
                }

                if (CGRectIntersectsRect(rect, attributes.frame) && indexKey.section >= self.topMostSupIndex - self.numberOfClingedCards) {
                    [allAttributes addObject:attributes];
                }
                
            } else {
                
                if (CGRectIntersectsRect(rect, attributes.frame)) {
                    [allAttributes addObject:attributes];
                }
            }
        }
    }
    
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = self.layoutInfo[cellReuseIdentifier][indexPath];
    
    return attributes;
}

- (CoolSupplementaryLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    CoolSupplementaryLayoutAttributes *attributes = self.layoutInfo[elementKind][indexPath];
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (newBounds.size.width != self.collectionView.bounds.size.width) {
        return YES;
    }
    
    return self.cardBehaviourEnabled;
}

#pragma mark - Taging

- (NSIndexPath *)indexPathForTag:(NSNumber *)tag {
    NSInteger intTag = [tag integerValue];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    NSInteger totalRow = 0;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            if (totalRow == intTag) {
                return [NSIndexPath indexPathForItem:item inSection:section];
            }
            
            totalRow++;
        }
    }
    
    return nil;
}

- (NSNumber *)tagForIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionSum = 0;
    
    for (int i = 0; i < indexPath.section; i++) {
        sectionSum += [self.collectionView numberOfItemsInSection:i];
    }
    
    NSInteger tag = sectionSum + indexPath.item;
    return [NSNumber numberWithInteger:tag];
}

#pragma mark IndexPath

- (NSIndexPath *)previousIndexPathForIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    
    if (item == 0) {
        
        if (section == 0) {
            item -= 1;
            section = 0;
        } else {
            item = [self.collectionView numberOfItemsInSection:indexPath.section-1] - 1;
            section -= 1;
        }
        
    } else {
        item -= 1;
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (BOOL)isTheLastItemInSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
}

#pragma mark - Card Behaviour

- (CGFloat)clingYOffsetForIndexPath:(NSIndexPath *)indexPath {
    return self.clingYOffset;
}

#pragma mark - Size

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [self.delegate heightForCellAtIndexPath:indexPath];
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
}

- (CGSize)sizeForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.item) return CGSizeZero;
    
    CGFloat height = [self.delegate heightForSupplementaryViewAtIndexPath:indexPath];
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
    
}

#pragma mark - Decorations

- (UICollectionViewLayoutAttributes *)decorationAttributesForTopView {
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"topLine" withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    
    decorationAttributes.frame = CGRectMake(0.0f,
                                            self.collectionView.contentOffset.y,
                                            self.collectionViewContentSize.width,
                                            20);
    
    decorationAttributes.zIndex = -1;
    
    return decorationAttributes;
}

- (UICollectionViewLayoutAttributes *)decorationAttributesForSupplementaryViewAttributes:(UICollectionViewLayoutAttributes *)supplementaryAttributes indexPath:(NSIndexPath *)indexPath {
    
    CGRect supplemetaryViewFrame = supplementaryAttributes.frame;
    
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"bottomLine" withIndexPath:indexPath];
    
    decorationAttributes.frame = CGRectMake(0.0f,
                                            supplemetaryViewFrame.origin.y + supplemetaryViewFrame.size.height,
                                            self.collectionViewContentSize.width,
                                            1);
    
    decorationAttributes.zIndex = indexPath.section;
    
    
    // --- тут высчитывается alpha
    
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingedCards - 1));
    
    NSIndexPath *firstCardIndexInCurrentSection = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    UICollectionViewLayoutAttributes *cardAttributes = self.layoutInfo[cellReuseIdentifier][firstCardIndexInCurrentSection];
    
    CGFloat decorationAlpha = (cardAttributes.frame.origin.y - collectionViewYOffset - clingYOffset) / supplemetaryViewFrame.size.height;
    decorationAlpha = MIN(1, 1 - decorationAlpha);
    decorationAttributes.alpha = decorationAlpha;
    
    // --- тут высчитывается alpha
    
    NSIndexPath *nextItemIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section + 1];
    CoolSupplementaryLayoutAttributes *nextItemAttributes = [self.layoutInfo[supplementaryKind] objectForKey:nextItemIndexPath];
    
    if (supplemetaryViewFrame.origin.y < nextItemAttributes.frame.origin.y - supplemetaryViewFrame.size.height + 20 || !nextItemAttributes) {
        
        return decorationAttributes;
        
    }
 
    return nil;
}

#pragma mark - Supplementary Layout Info


#pragma mark - Cell Layout Info

- (NSDictionary *)cellLayoutInfoForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
    NSNumber *tag = [self tagForIndexPath:previousIndexPath];
    
    
    CGFloat previousBottomY = [self.cellBottomY[tag] floatValue];
    
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    CGFloat sectionOffset = [self isTheLastItemInSectionForIndexPath:indexPath] && indexPath.section != sectionCount-1 ? self.interSectionSpaceY : 0;

    
    CGFloat itemOffset = [self isTheLastItemInSectionForIndexPath:indexPath] ? 0 : self.interItemSpaceY;
    
    CGSize cellSize = [self sizeForCellAtIndexPath:indexPath];
    CGSize supplementaryViewSize = [self sizeForSupplementaryViewAtIndexPath:indexPath];
    
    
    CGFloat currentBottomY = previousBottomY + itemOffset + cellSize.height + sectionOffset + supplementaryViewSize.height;
    
    
    NSDictionary *info = @{@"previousBottomY": [NSNumber numberWithFloat:previousBottomY],
                           @"sectionOffset": [NSNumber numberWithFloat:sectionOffset],
                           @"itemOffset": [NSNumber numberWithFloat:itemOffset],
                           @"supplementaryViewSize": [NSValue valueWithCGSize:supplementaryViewSize],
                           @"cellSize": [NSValue valueWithCGSize:cellSize],
                           @"currentBottomY": [NSNumber numberWithFloat:currentBottomY]};
    
    return info;
}



@end
