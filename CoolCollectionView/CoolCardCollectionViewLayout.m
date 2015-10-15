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

@property (nonatomic) CGFloat magicOffset;

@property (nonatomic) NSInteger nextClingSupplementaryViewIndex;


@end

@implementation CoolCardCollectionViewLayout

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
    
    // External
    
    if (!self.interItemSpaceY) {
        self.interItemSpaceY = 0;
    }
    
    if (!self.interSectionSpaceY) {
        self.interSectionSpaceY = 0;
    }
    
    // External
    
    
    // Internal
    
    if (self.collectionView) {
        self.cardBehaviourEnabled = ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled;
        self.cardMagicEnabled = ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
    } else {
        self.cardBehaviourEnabled = self.cardMagicEnabled = YES;
    }
    
    self.numberOfClingedCards = 3;
    self.clingYOffset = 8;
    self.magicOffset = 40;
    self.nextClingSupplementaryViewIndex = self.numberOfClingedCards;
    

    
    self.cellBottomY = [NSMutableDictionary dictionary];
    
    [self registerClass:[CoolCardDecorationView class] forDecorationViewOfKind:@"bottomLine"];
    [self registerClass:[CoolCardTopDecorationView class] forDecorationViewOfKind:@"topLine"];
    
    // Internal
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    NSInteger lastItemIndex = MAX(0, [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:numberOfSections - 1] - 1);
    NSIndexPath *indexPathForLastCard = [NSIndexPath indexPathForItem:lastItemIndex inSection:numberOfSections-1];
    
    
    CGFloat bottomYForLastCell = [self bottomYForIndexPath:indexPathForLastCard];
    CGFloat height = self.collectionView.contentInset.top + bottomYForLastCell + self.collectionView.contentInset.bottom;
    
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, height);
    
    return size;
}

- (void)prepareLayout {
    NSMutableDictionary *newLayoutFullInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutFullInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplementaryFullInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSDictionary *cellLayoutInfo = [self cellLayoutInfoForIndexPath:indexPath];

            CGFloat currentBottomY = [[cellLayoutInfo objectForKey:@"currentBottomY"] floatValue];
            [self setBottomY:currentBottomY forCellAtIndexPath:indexPath]; // ставим frame ячейке
            
            cellLayoutFullInfo[indexPath] = [self cellLayoutAttributesForCellLayoutInfo:cellLayoutInfo atIndexPath:indexPath];
            
            
         //   CellItemType itemType = [self.delegate cellItemTypeForCellAtIndexPath:indexPath];
            
            if (!indexPath.item) { // тут создаётся supplementary
               
                if (self.cardBehaviourEnabled) {
                    
                    if (self.cardMagicEnabled && indexPath.section > self.numberOfClingedCards - 1 && indexPath.section <= self.nextClingSupplementaryViewIndex + 1) {
                        
                        [self makeMagicMoveForSupplementaryInfo:&supplementaryFullInfo beforeSupplementaryViewAtIndexPath:indexPath]; // тут двигаем подъезд карточек друг к другу

                    }
                    
                }
                
                
                CoolSupplementaryLayoutAttributes *supAttributes = [self supplementaryViewLayoutAttributesForCellLayoutAttributes:cellLayoutInfo atIndexPath:indexPath];
                    
                supplementaryFullInfo[indexPath] = supAttributes;
                
                
            }
            
            
        }
    }
    
  //  NSLog(@"FullInfo: %@", supplementaryFullInfo);
    
    newLayoutFullInfo[cellReuseIdentifier] = cellLayoutFullInfo;
    newLayoutFullInfo[supplementaryKind] = supplementaryFullInfo;
    
    self.layoutInfo = newLayoutFullInfo;
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

                if (CGRectIntersectsRect(rect, attributes.frame) && indexKey.section >= self.nextClingSupplementaryViewIndex - self.numberOfClingedCards) {
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

- (CGFloat)clingYOffsetForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    return MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingedCards - 1));
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
/*
- (NSDictionary *)layoutInfo {
 
}
*/

#pragma mark - Cell Layout Info

- (NSDictionary *)cellLayoutInfoForIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat previousBottomY = [self previousBottomYForIndexPath:indexPath];
    
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

- (UICollectionViewLayoutAttributes *)cellLayoutAttributesForCellLayoutInfo:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {
    
    // -- start info
    CGSize cellSize = [[cellLayoutInfo objectForKey:@"cellSize"] CGSizeValue];
    CGSize supplementaryViewSize = [[cellLayoutInfo objectForKey:@"supplementaryViewSize"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    CGFloat cellCenterY = previousBottomY + (cellSize.height) / 2.0 + supplementaryViewSize.height;
    // -- start info
    
    UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    itemAttributes.size = cellSize;
    itemAttributes.center = CGPointMake(cellSize.width / 2.0, cellCenterY);
    
    return itemAttributes;
    
}

- (CoolSupplementaryLayoutAttributes *)supplementaryViewLayoutAttributesForCellLayoutAttributes:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {
 
    // -- start info
    CGSize supplementaryViewSize = [[cellLayoutInfo objectForKey:@"supplementaryViewSize"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    // -- start info
    
    
    
    CGFloat supplementaryY = previousBottomY;
    CGFloat clingYOfsset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    
    
    CoolSupplementaryLayoutAttributes *supAttributes = [CoolSupplementaryLayoutAttributes layoutAttributesForSupplementaryViewOfKind:supplementaryKind withIndexPath:indexPath];
    supAttributes.size = supplementaryViewSize;
    supAttributes.shadowVisible = YES;
    
    if (self.cardBehaviourEnabled) { // цеплять наверх
        
        if ((supplementaryY < collectionViewYOffset + clingYOfsset)) { // цепляем
            supplementaryY = collectionViewYOffset + clingYOfsset;
            
            if (indexPath.section > self.numberOfClingedCards - 1) {
                supAttributes.shadowVisible = self.cardMagicEnabled;
            }
            
        }
        
    }
    
    supAttributes.center = CGPointMake(supplementaryViewSize.width / 2.0, supplementaryY + supplementaryViewSize.height / 2.0);
    
    return supAttributes;
    
}
    
- (void)makeMagicMoveForSupplementaryInfo:(NSMutableDictionary **)supplementaryInfo beforeSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CGFloat supplementaryY = [self previousBottomYForIndexPath:indexPath];
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    CGFloat relativeSupplementaryY = supplementaryY - collectionViewYOffset - clingYOffset;
    
    
    if (relativeSupplementaryY <= self.magicOffset && self.magicOffset >= 0) {
        
        self.nextClingSupplementaryViewIndex = indexPath.section;
        
        CGFloat delta = MIN((self.magicOffset - (relativeSupplementaryY / self.magicOffset * self.magicOffset)) / 4, self.clingYOffset);
        NSInteger rDelta = round(delta);
        
        
        for (int i = 1; i <= 3; i++) {
            
            if (i == 3) {
                rDelta = -rDelta;
            }
            
            
            NSIndexPath *previousSupplementaryIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section - i];
            CoolSupplementaryLayoutAttributes *prevAttributes = (*supplementaryInfo)[previousSupplementaryIndexPath];
            prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - rDelta);
            
            (*supplementaryInfo)[previousSupplementaryIndexPath] = prevAttributes;
            
        }
        
    }

    
}

#pragma mark BottomY Management

- (void)setBottomY:(CGFloat)bottomY forCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *tag = [self tagForIndexPath:indexPath];
    
    self.cellBottomY[tag] = [NSNumber numberWithFloat:bottomY];
    
}

- (CGFloat)bottomYForIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *tag = [self tagForIndexPath:indexPath];
    return [self.cellBottomY[tag] floatValue];
    
}

- (CGFloat)previousBottomYForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
    NSNumber *tag = [self tagForIndexPath:previousIndexPath];
    
    return [self.cellBottomY[tag] floatValue];
    
}

@end
