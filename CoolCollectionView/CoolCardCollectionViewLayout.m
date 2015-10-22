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
#import "CoolCollectionCell.h"
#import "CoolCardLayoutAttributes.h"

typedef NS_ENUM(NSInteger, ViewType) {
    ViewTypeNone,
    ViewTypeCell,
    ViewTypeSupplementaryView,
    ViewTypeLineDecorationView,
    ViewTypeHideDecorationView
};

@interface CoolCardCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo; 
@property (nonatomic, strong) NSMutableDictionary *cellBottomY;

@property (nonatomic) NSInteger numberOfClingingCards;
@property (nonatomic) CGFloat clingYOffset;

@property (nonatomic) BOOL cardBehaviourEnabled;
@property (nonatomic) BOOL cardMagicEnabled;

@property (nonatomic) CGFloat magicOffset;

@property (nonatomic) NSInteger lastClingedCardIndex;

@property (nonatomic) CGFloat interClingCellsSpaceY;


@end

@implementation CoolCardCollectionViewLayout

#pragma mark - Base

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

#pragma mark - Setups

- (void)setupLayout {

    [self setupDefaultValues];
    [self registerDecorationViews];
    
}

- (void)setupDefaultValues {
    
    // External
    self.interItemSpaceY = 0;
    self.interSectionSpaceY = 0;
    // External
    
    if (self.collectionView) {
        self.cardBehaviourEnabled = ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled;
        self.cardMagicEnabled = ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
        self.numberOfClingingCards = ((CoolCardCollectionView *)self.collectionView).numberOfClingingCards;
    } else {
        self.cardBehaviourEnabled = NO;
        self.cardMagicEnabled = NO;
        self.numberOfClingingCards = 3;
    }
    
    
    self.clingYOffset = 6;
    self.magicOffset = 40;
    self.lastClingedCardIndex = 0;//self.numberOfClingingCards;
    self.interClingCellsSpaceY = -20;
    
    self.cellBottomY = [NSMutableDictionary dictionary];
    
}

- (void)registerDecorationViews {
    [self registerClass:[CoolCardDecorationView class] forDecorationViewOfKind:@"bottomLine"];
    [self registerClass:[CoolCardTopDecorationView class] forDecorationViewOfKind:@"hideLine"];
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    
    NSIndexPath *lastCellIndexPath = [self indexPathForLastCell];
    
    CGFloat bottomYForLastCell = [self bottomYForIndexPath:lastCellIndexPath];
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
#warning Refactor itemType Calls

           //
            if (!indexPath.item) { // тут создаётся supplementary
                
                if (((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled) {
                    
                    if (((CoolCardCollectionView *)self.collectionView).cardMagicEnabled) {
                        
                       //  NSLog(@"%d", self.lastClingedCardIndex);
                        
                        //if (indexPath.section > self.numberOfClingingCards - 1 && indexPath.section <= self.lastClingedCardIndex + 1) {
                        
                        if (indexPath.section > self.numberOfClingingCards - 1 && indexPath.section == self.lastClingedCardIndex + 1) {
                            
                             NSLog(@"Делать мэйджик для %d", indexPath.section);
                            [self makeMagicMoveForSupplementaryInfo:&supplementaryFullInfo cellsInfo:&cellLayoutFullInfo beforeSupplementaryViewAtIndexPath:indexPath]; // тут двигаем подъезд карточек друг к другу

                        }
                        
                    }
                    
                }
                
                
                CoolCardLayoutAttributes *supAttributes = [self supplementaryViewLayoutAttributesForCellLayoutAttributes:cellLayoutInfo atIndexPath:indexPath];
                
                supplementaryFullInfo[indexPath] = supAttributes;
                
                
            }
            
            
        }
    }
    
  //  NSLog(@"FullInfo: %@", supplementaryFullInfo);
    
    newLayoutFullInfo[cellReuseIdentifier] = cellLayoutFullInfo;
    newLayoutFullInfo[supplementaryKind] = supplementaryFullInfo;
    
    self.layoutInfo = newLayoutFullInfo;
    
    [self updateNextClingSupplementaryViewIndex];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    for (NSString *key in self.layoutInfo) {
        NSDictionary *attributesDict = [self.layoutInfo objectForKey:key];
        
        for (NSIndexPath *indexKey in attributesDict) {
            
            UICollectionViewLayoutAttributes *attributes = [attributesDict objectForKey:indexKey];
            
            if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) { // тут добавляем decoration
                
                if (((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled) {
                   
                    UICollectionViewLayoutAttributes *decorationLineAttributes = [self decorationLineAttributesForSupplementaryViewAttributes:attributes withIndexPath:indexKey];
                    
                    if (decorationLineAttributes) {
                        [allAttributes addObject:decorationLineAttributes];
                    }
                    
                    UICollectionViewLayoutAttributes *decorationHideAttributes = [self decorationHideAttributesForAttributes:attributes withIndexPath:indexKey];
                    
                    if (decorationHideAttributes) {
                        [allAttributes addObject:decorationHideAttributes];
                    }
                    
                }

                if (CGRectIntersectsRect(rect, attributes.frame) ) {
                    
                    if (self.cardMagicEnabled && self.cardBehaviourEnabled) {
                        if (indexKey.section >= self.lastClingedCardIndex - self.numberOfClingingCards) {
                          //  NSLog(@"Пропустить indexKey %@", indexKey);
                            [allAttributes addObject:attributes];
                        }
                    } else {
                  //  NSLog(@"показываем %d", indexKey.section);
                        [allAttributes addObject:attributes];
                    }
                }
                
            } else {
                
                UICollectionViewLayoutAttributes *decorationHideAttributes = [self decorationHideAttributesForAttributes:attributes withIndexPath:indexKey];
                
                if (decorationHideAttributes) {
                    [allAttributes addObject:decorationHideAttributes];
                }
                
                if (CGRectIntersectsRect(rect, attributes.frame) && attributes.size.height > 0) {
                    [allAttributes addObject:attributes];
                }
                
            }
        }
    }
    
    
    return allAttributes;
}

- (CoolCardLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoolCardLayoutAttributes *attributes = self.layoutInfo[cellReuseIdentifier][indexPath];
    
    return attributes;
}

- (CoolCardLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    CoolCardLayoutAttributes *attributes = self.layoutInfo[elementKind][indexPath];
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (newBounds.size.width != self.collectionView.bounds.size.width) {
        return YES;
    }
    
    return ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled;
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
    
    NSIndexPath *endIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    
    if ([self isIndexPathLegal:indexPath]) {
        return endIndexPath;
    }
    
    return nil;
}

- (NSIndexPath *)nextIndexPathForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == [self indexPathForLastCell]) return nil;
    
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    
    if ([self isTheLastItemInSectionForIndexPath:indexPath]) {
        item = 0;
        
        if (section < [self.collectionView numberOfSections] - 1) {
            section++;
        }

    } else {
        item++;
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (BOOL)isTheLastItemInSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
}

- (NSIndexPath *)indexPathForLastCell {
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    NSInteger lastSectionIndex = MAX(numberOfSections - 1, 0);
    NSInteger lastItemIndex = MAX(0, [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:lastSectionIndex] - 1);
    
    return [NSIndexPath indexPathForItem:lastItemIndex inSection:lastSectionIndex];
    
}

- (BOOL)isIndexPathLegal:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.item < 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Clinging

- (BOOL)isCellItemTypeClinging:(CellItemType)itemType {
    
    CoolCardCollectionView *collectionView = (CoolCardCollectionView *)self.collectionView;
    
    for (Class<CoolCollectionCell> cellClass in collectionView.clingingCellClasses) {
        if ([cellClass itemType] == itemType) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isPreviousCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
    
    if (previousIndexPath.section < 0 || previousIndexPath.item < 0) return NO;
    
    CellItemType itemType =  [self.delegate cellItemTypeForCellAtIndexPath:previousIndexPath];
    
    if ([self isCellItemTypeClinging:itemType]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    CellItemType itemType = [self.delegate cellItemTypeForCellAtIndexPath:indexPath];
    
    if ([self isCellItemTypeClinging:itemType]) {
        return YES;
    }
    
    return NO;
    
}

// нужно ли?
- (BOOL)isNextCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:indexPath];
    if (!nextIndexPath) return NO;
    
    CellItemType itemType = [self.delegate cellItemTypeForCellAtIndexPath:nextIndexPath];
    
    if ([self isCellItemTypeClinging:itemType]) {
        return YES;
    }
    
    return NO;
}

- (CGFloat)clingYOffsetForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    return MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingingCards - 1));
}


#pragma mark ZIndex

- (NSInteger)zIndexForIndexPath:(NSIndexPath *)indexPath forViewOfType:(ViewType)viewType {
    
    if (viewType == ViewTypeLineDecorationView) {
        return indexPath.section;
    } else if (viewType == ViewTypeHideDecorationView) {
        return indexPath.section - 2;
    } else if (viewType == ViewTypeSupplementaryView) {
        return indexPath.section;
    } else if (ViewTypeCell) {
        CellItemType itemType = [self.delegate cellItemTypeForCellAtIndexPath:indexPath];
        
        if ([self isCellItemTypeClinging:itemType]) {
            return indexPath.section;
        } else {
            return indexPath.section - 1;
        }
        
    }
    
    
    return indexPath.section;
}

#pragma mark - Size

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [self.delegate heightForCellAtIndexPath:indexPath];
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
}

- (CGSize)sizeForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.item) return CGSizeZero;
    
    if ([self isCellItemTypeClinging:[self.delegate cellItemTypeForCellAtIndexPath:indexPath]]) {
        return CGSizeZero;
    }
    
    CGFloat height = [self.delegate heightForSupplementaryViewAtIndexPath:indexPath];
    CGFloat width = self.collectionView.bounds.size.width;
    
    return CGSizeMake(width, height);
    
}

- (CGSize)sizeForSupplementaryViewInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    return [self sizeForSupplementaryViewAtIndexPath:indexPath];
}

#pragma mark - Decorations

- (UICollectionViewLayoutAttributes *)decorationHideAttributesForAttributes:(UICollectionViewLayoutAttributes *)attributes withIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isPreviousCellClingingForIndexPath:indexPath]) return nil;
    
    if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
        if (![self isCellClingingForIndexPath:indexPath]) return nil;
    }
    
    CGRect frame = attributes.frame;
    
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"hideLine" withIndexPath:indexPath];
    
    decorationAttributes.frame = CGRectMake(0.0f,
                                            frame.origin.y,
                                            self.collectionViewContentSize.width,
                                            20);
    
    decorationAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeHideDecorationView];
    
    if ([self canShowDecorationViewForCellAttributes:attributes withIndexPath:indexPath andViewType:ViewTypeHideDecorationView]) {
        return decorationAttributes;
        
    }
    
    return nil;

}

- (UICollectionViewLayoutAttributes *)decorationLineAttributesForSupplementaryViewAttributes:(UICollectionViewLayoutAttributes *)supplementaryAttributes withIndexPath:(NSIndexPath *)indexPath {
    
    if (self.lastClingedCardIndex > self.numberOfClingingCards && indexPath.section < self.lastClingedCardIndex) return nil;
    
    CGRect supplemetaryViewFrame = supplementaryAttributes.frame;
    
    UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"bottomLine" withIndexPath:indexPath];
    
    decorationAttributes.frame = CGRectMake(0.0f,
                                            supplemetaryViewFrame.origin.y + supplemetaryViewFrame.size.height,
                                            self.collectionViewContentSize.width,
                                            1);
    
    decorationAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeLineDecorationView];
    
    
    // --- тут высчитывается alpha
    
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingingCards - 1));
    
    NSIndexPath *firstCellIndexInCurrentSection = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    UICollectionViewLayoutAttributes *cellAttributes = self.layoutInfo[cellReuseIdentifier][firstCellIndexInCurrentSection];
    
    CGFloat decorationAlpha = (cellAttributes.frame.origin.y - collectionViewYOffset - clingYOffset) / supplemetaryViewFrame.size.height;
    decorationAlpha = MIN(1, 1 - decorationAlpha);
    decorationAttributes.alpha = decorationAlpha;
    
    // --- тут высчитывается alpha
    
    if ([self canShowDecorationViewForCellAttributes:supplementaryAttributes withIndexPath:indexPath andViewType:ViewTypeLineDecorationView]) {
        
        return decorationAttributes;
        
    }
 
    return nil;
}

- (BOOL)canShowDecorationViewForCellAttributes:(UICollectionViewLayoutAttributes *)attributes withIndexPath:(NSIndexPath *)indexPath andViewType:(ViewType)viewType {
    
    NSInteger relativeY = round(attributes.frame.origin.y - self.collectionView.contentOffset.y);
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    CGFloat supplementaryViewHeight = [self.delegate heightForSupplementaryViewAtIndexPath:indexPath];
    
    if (viewType == ViewTypeLineDecorationView) {
        
      //  NSLog(@"relativeY %d для %d", relativeY, indexPath.section);
        if (relativeY > supplementaryViewHeight + clingYOffset - attributes.size.height) {
          //  NSLog(@"%f > %f", relativeY, supplementaryViewHeight + clingYOffset - attributes.size.height);
           // NSLog(@"не показывать для %d", indexPath.section);
            return NO;
        }
        
        NSIndexPath *nextItemIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section + 1];
        CoolCardLayoutAttributes *nextItemAttributes = [self.layoutInfo[supplementaryKind] objectForKey:nextItemIndexPath];
        
        if (attributes.frame.origin.y < nextItemAttributes.frame.origin.y - attributes.size.height + 20 || !nextItemAttributes) {
            
        }
        
    } else if (viewType == ViewTypeHideDecorationView) {
        
        CGFloat collectionViewBottomY = self.collectionView.bounds.size.height + self.collectionView.contentOffset.y;

        
        if (relativeY > collectionViewBottomY) {
            return NO;
        }
        
        if (relativeY < supplementaryViewHeight * 0.5 + clingYOffset) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Next Cling Management

- (void)updateNextClingSupplementaryViewIndex {
    for (NSInteger i = [self.collectionView numberOfSections] - 1; i >= 0; i--) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        
        CGFloat previousBottomY = [self previousBottomYForIndexPath:indexPath];
        CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
        CGFloat clingYOfsset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
        
        if (previousBottomY < collectionViewYOffset + clingYOfsset) {
            self.lastClingedCardIndex = i;
            
            break;
        }
        
    }
}

#pragma mark - Cell Layout Info

- (NSDictionary *)cellLayoutInfoForIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat previousBottomY = [self previousBottomYForIndexPath:indexPath];
    CGSize cellSize = [self sizeForCellAtIndexPath:indexPath];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    BOOL cellClinging = [self isCellClingingForIndexPath:indexPath];
    
    CGFloat sectionOffset = 0;
    
    if (cellClinging) {
        sectionOffset = self.interClingCellsSpaceY;
    } else {
        sectionOffset = [self isTheLastItemInSectionForIndexPath:indexPath] && indexPath.section != sectionCount-1 ? self.interSectionSpaceY : 0;
    }
    
    
    CGFloat itemOffset = [self isTheLastItemInSectionForIndexPath:indexPath] ? 0 : self.interItemSpaceY;
    
    
    CGSize supplementaryViewSizeForSection = [self sizeForSupplementaryViewInSection:indexPath.section];
    CGSize supplementaryViewSize = indexPath.item ? CGSizeZero : supplementaryViewSizeForSection;
    
    
    CGFloat currentBottomY = previousBottomY + itemOffset + cellSize.height + sectionOffset + supplementaryViewSize.height;
    
    
    NSDictionary *info = @{@"previousBottomY": [NSNumber numberWithFloat:previousBottomY],
                           @"sectionOffset": [NSNumber numberWithFloat:sectionOffset],
                           @"itemOffset": [NSNumber numberWithFloat:itemOffset],
                           @"supplementaryViewSizeForSection": [NSValue valueWithCGSize:supplementaryViewSizeForSection],
                           @"cellSize": [NSValue valueWithCGSize:cellSize],
                           @"currentBottomY": [NSNumber numberWithFloat:currentBottomY]};
    
    return info;
}

- (CoolCardLayoutAttributes *)cellLayoutAttributesForCellLayoutInfo:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {
    
    // -- start info
    CGSize cellSize = [[cellLayoutInfo objectForKey:@"cellSize"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    
    CGSize supplementaryViewSizeForSection = [[cellLayoutInfo objectForKey:@"supplementaryViewSizeForSection"] CGSizeValue];
    CGSize supplementaryViewSize = indexPath.item ? CGSizeZero : supplementaryViewSizeForSection;
    
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    // -- start info
    
    
    CoolCardLayoutAttributes *itemAttributes = [CoolCardLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    itemAttributes.shadowVisible = YES;
    
    CGFloat cellY = previousBottomY + supplementaryViewSize.height;
    
    CellItemType itemType = [self.delegate cellItemTypeForCellAtIndexPath:indexPath];
    
    if (((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled) { // цеплять наверх
        
        if ([self isCellItemTypeClinging:itemType]) {
        
            CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
            
            if ((cellY < collectionViewYOffset + clingYOffset)) { // цепляем
            //    NSLog(@"Цепляем");
                cellY = collectionViewYOffset + clingYOffset;
                
                if (indexPath.section > self.numberOfClingingCards - 1) {
                   itemAttributes.shadowVisible = ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
                }
             
                if (((CoolCardCollectionView *)self.collectionView).cardMagicEnabled && ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled) {
                    
                    NSInteger mIndex = self.lastClingedCardIndex - indexPath.section;
                    //  NSInteger
                    
                    if (indexPath.section < self.lastClingedCardIndex) {
                        
                        if (mIndex >= self.numberOfClingingCards) { // карта, которую занизили
                            
                            cellY += self.clingYOffset * mIndex;
                            
                        } else if (mIndex < self.numberOfClingingCards && self.lastClingedCardIndex >= self.numberOfClingingCards) { // поднимать
                            
                            CGFloat zIndex = 0;
                            
                            if (indexPath.section < self.numberOfClingingCards - 1) {
                                
                                NSInteger wowNumber = self.lastClingedCardIndex - self.numberOfClingingCards;
                                zIndex = self.clingYOffset * (mIndex - 1) - wowNumber * self.clingYOffset;
                                
                            }
                            
                            CGFloat offset = (self.clingYOffset * mIndex) - zIndex;
                            cellY = cellY - offset;
                            
                        }
                        
                        
                    }
                }

                
            }
            
        } else { // когда начать скрывать ячейку
            
            CGFloat cellRelativeY = cellY - collectionViewYOffset;
            CGFloat supRelativeY = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath] + self.clingYOffset + supplementaryViewSizeForSection.height / 2.0; // 8 -- отступ для тени; height -- чтобы не было видно из-за сгруглений ячейку
            

            if (cellRelativeY < supRelativeY) {
                CGFloat offset = supRelativeY - cellRelativeY;
                
                cellY = cellY + offset;
                cellSize = CGSizeMake(cellSize.width, cellSize.height - offset);
                
                itemAttributes.internalYOffset = -offset;
            }
            
        }
        
    }
    
    itemAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeCell];
    itemAttributes.size = cellSize;
    itemAttributes.center = CGPointMake(cellSize.width / 2.0, cellY + cellSize.height / 2.0);
    return itemAttributes;
    
}

- (CoolCardLayoutAttributes *)supplementaryViewLayoutAttributesForCellLayoutAttributes:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.item || [self isCellClingingForIndexPath:indexPath]) return nil;
    
    // -- start info
    CGSize supplementaryViewSize = [[cellLayoutInfo objectForKey:@"supplementaryViewSizeForSection"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    // -- start info
    
    
    CGFloat supplementaryY = previousBottomY;
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    
    CoolCardLayoutAttributes *supAttributes = [CoolCardLayoutAttributes layoutAttributesForSupplementaryViewOfKind:supplementaryKind withIndexPath:indexPath];
    supAttributes.size = supplementaryViewSize;
    supAttributes.shadowVisible = YES;
    
    if (((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled) { // цеплять наверх
        
        if ((supplementaryY < collectionViewYOffset + clingYOffset)) { // цепляем
            supplementaryY = collectionViewYOffset + clingYOffset;
            
            if (indexPath.section > self.numberOfClingingCards - 1) {
                supAttributes.shadowVisible = ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
            }
         
            if (((CoolCardCollectionView *)self.collectionView).cardMagicEnabled && ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled) {
                
                NSInteger mIndex = self.lastClingedCardIndex - indexPath.section;
              //  NSInteger
                
                if (indexPath.section < self.lastClingedCardIndex) {
                    
                    if (mIndex >= self.numberOfClingingCards) { // карта, которую занизили
                        
                        supplementaryY += self.clingYOffset * mIndex;
                        
                    } else if (mIndex < self.numberOfClingingCards && self.lastClingedCardIndex >= self.numberOfClingingCards) { // поднимать
                        
                        CGFloat zIndex = 0;
                        
                        if (indexPath.section < self.numberOfClingingCards - 1) {
                            
                            NSInteger wowNumber = self.lastClingedCardIndex - self.numberOfClingingCards;
                            zIndex = self.clingYOffset * (mIndex - 1) - wowNumber * self.clingYOffset;
                            
                        }
                        
                        CGFloat offset = (self.clingYOffset * mIndex) - zIndex;
                        supplementaryY = supplementaryY - offset;
                        
                    }
                    
                    
                }
            }
          
        }
        
     
        
    }
    
    NSInteger zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeSupplementaryView];
    supAttributes.zIndex = zIndex;
    
 //   NSLog(@"%ld - zIndex для supp %ld", (long)zIndex, (long)indexPath.section);
    
    supAttributes.center = CGPointMake(supplementaryViewSize.width / 2.0, supplementaryY + supplementaryViewSize.height / 2.0);
    
    return supAttributes;
    
}
    
- (void)makeMagicMoveForSupplementaryInfo:(NSMutableDictionary **)supplementaryInfo cellsInfo:(NSMutableDictionary **)cellsInfo beforeSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"Before indexPath:%@", indexPath);
    
    CGFloat supplementaryY = [self previousBottomYForIndexPath:indexPath];
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    CGFloat relativeSupplementaryY = supplementaryY - collectionViewYOffset - clingYOffset;
    
    
    if (relativeSupplementaryY <= self.magicOffset && self.magicOffset >= 0) {// && relativeSupplementaryY > -2) {
        
     //   NSLog(@"начать двигать %@", indexPath);
        
        
        CGFloat delta = MIN((self.magicOffset - (relativeSupplementaryY / self.magicOffset * self.magicOffset)) / 4, self.clingYOffset);
        
        
        for (int i = 1; i <= self.numberOfClingingCards; i++) {
            
            if (i == self.numberOfClingingCards) {
                delta = -delta;
                
            }
            
            
            
            NSIndexPath *previousIndexPathSection = [NSIndexPath indexPathForItem:0 inSection:indexPath.section - i];
            
           // NSLog(@"жмакаю %@", previousIndexPathSection);
            
  //          NSLog(@"%@ %f", previousIndexPathSection, delta);
            
            if ([self isCellClingingForIndexPath:previousIndexPathSection]) {
                
                CoolCardLayoutAttributes *prevAttributes = (*cellsInfo)[previousIndexPathSection];
                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - delta);
                
           /*     if (i == self.numberOfClingingCards) {
             //       NSLog(@"%f for %d", prevAttributes.center.y - self.collectionView.contentOffset.y, indexPath.section);
            //        prevAttributes.shadowVisible = NO;
                }*/
                
                (*cellsInfo)[previousIndexPathSection] = prevAttributes;
                
            } else {
            
                CoolCardLayoutAttributes *prevAttributes = (*supplementaryInfo)[previousIndexPathSection];
                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - delta);
                
          //      NSLog(@"%f", prevAttributes.center.y);
                /*
                if (i == self.numberOfClingingCards) {
               //     NSLog(@"%f for %d", prevAttributes.center.y - self.collectionView.contentOffset.y, indexPath.section);
         //           prevAttributes.shadowVisible = NO;
                }*/
                
                (*supplementaryInfo)[previousIndexPathSection] = prevAttributes;
                
            }
            
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
