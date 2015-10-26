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
    
    self.clingYOffset = 6;
    self.magicOffset = 40;
    self.lastClingedCardIndex = 0;
    self.interClingCellsSpaceY = -20;
    
    self.cellBottomY = [NSMutableDictionary dictionary];
    
}

- (void)registerDecorationViews {
    [self registerClass:[CoolCardDecorationView class] forDecorationViewOfKind:@"bottomLine"];
    [self registerClass:[CoolCardTopDecorationView class] forDecorationViewOfKind:@"hideLine"];
}

#pragma mark - Getters

- (BOOL)cardBehaviourEnabled {
    if (self.collectionView) {
        return ((CoolCardCollectionView *)self.collectionView).cardBehaviourEnabled;
    } else {
        return NO;
    }
}

- (BOOL)cardMagicEnabled {
    if (self.collectionView) {
        return ((CoolCardCollectionView *)self.collectionView).cardMagicEnabled;
    } else {
        return NO;
    }
}

- (NSInteger)numberOfClingingCards {
    if (self.collectionView) {
        return ((CoolCardCollectionView *)self.collectionView).numberOfClingingCards;
    } else {
        return NO;
    }
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
            
            
            if (!indexPath.item) { // тут создаётся supplementary
                
                if (self.cardBehaviourEnabled) {
                    
                    if (self.cardMagicEnabled) {
                        
                        if (indexPath.section > self.numberOfClingingCards - 1 && indexPath.section == self.lastClingedCardIndex + 1) {
                            
                            [self makeMagicMoveForSupplementaryInfo:&supplementaryFullInfo cellsInfo:&cellLayoutFullInfo beforeSupplementaryViewAtIndexPath:indexPath]; // тут двигаем подъезд карточек друг к другу
                            
                        }
                        
                    }
                    
                }
                
                
                CoolCardLayoutAttributes *supAttributes = [self supplementaryViewLayoutAttributesForCellLayoutAttributes:cellLayoutInfo atIndexPath:indexPath];
                
                supplementaryFullInfo[indexPath] = supAttributes;
                
                
            }
            
            
        }
    }
    
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
                
                if (self.cardBehaviourEnabled) {
                    
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
                            [allAttributes addObject:attributes];
                        }
                    } else {
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

- (NSIndexPath *)indexPathForFirstItemInSection:(NSInteger)section {
    if (section > [self.collectionView numberOfSections] - 1) return nil;
    
    return [NSIndexPath indexPathForItem:0 inSection:section];
}

- (NSIndexPath *)indexPathForLastItemInSection:(NSInteger)section {
    if (section > [self.collectionView numberOfSections] - 1) return nil;
    
    NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
    
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

- (BOOL)isCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    return [self.delegate isCellClingingForIndexPath:indexPath];
    
}

- (BOOL)isPreviousCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previousIndexPath = [self previousIndexPathForIndexPath:indexPath];
    
    if (previousIndexPath.section < 0 || previousIndexPath.item < 0) return NO;
    
    if ([self isCellClingingForIndexPath:previousIndexPath]) {
        return YES;
    }
    
    return NO;
}

// нужно ли?
- (BOOL)isNextCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:indexPath];
    if (!nextIndexPath) return NO;
    
    
    if ([self isCellClingingForIndexPath:nextIndexPath]) {
        return YES;
    }
    
    return NO;
}

- (CGFloat)clingYOffsetForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    return MIN(self.clingYOffset * indexPath.section, self.clingYOffset * (self.numberOfClingingCards - 1));
}

- (CGFloat)clingYOffsetForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate heightForCellAtIndexPath:indexPath] * indexPath.item + [self sizeForSupplementaryViewInSection:indexPath.section].height;
}

#pragma mark Cling Index

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


#pragma mark ZIndex

- (NSInteger)zIndexForIndexPath:(NSIndexPath *)indexPath forViewOfType:(ViewType)viewType {
    
    if (viewType == ViewTypeLineDecorationView) {
        return indexPath.section;
    } else if (viewType == ViewTypeHideDecorationView) {
        return indexPath.section - 2;
    } else if (viewType == ViewTypeSupplementaryView) {
        return indexPath.section;
    } else if (ViewTypeCell) {
        
        if ([self isCellClingingForIndexPath:indexPath]) {
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
    
    if ([self isCellClingingForIndexPath:indexPath]) {
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
        
        if (relativeY > supplementaryViewHeight + clingYOffset - attributes.size.height) {
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
    CGSize supplementaryViewSizeForIndexPath = [self sizeForSupplementaryViewAtIndexPath:indexPath]; // может дать CGSizeZero, в этом и смысл
    
    
    CGFloat currentBottomY = previousBottomY + itemOffset + cellSize.height + sectionOffset + supplementaryViewSizeForIndexPath.height;
    
    
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
    CGFloat cellY = previousBottomY + supplementaryViewSize.height;
    // -- start info
    
    
    CoolCardLayoutAttributes *cellAttributes = [CoolCardLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    cellAttributes.shadowVisible = YES;
    
    if (self.cardBehaviourEnabled) {
        
        if ([self isCellClingingForIndexPath:indexPath]) {
            
            CGFloat newCellY = [self clingedYForHeaderAtY:cellY withIndexPath:indexPath];
            
            if (newCellY > cellY) {
                if (indexPath.section > self.numberOfClingingCards - 1) {
                    cellAttributes.shadowVisible = self.cardMagicEnabled;
                }
            }
            
            cellY = newCellY;
            
        } else { // когда начать скрывать ячейку
            
            cellY = [self clingedYForCellAtY:cellY withIndexPath:indexPath];
        
            CGFloat cellRelativeY = cellY - collectionViewYOffset;
            CGFloat supRelativeY = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath] + self.clingYOffset + supplementaryViewSizeForSection.height / 2.0;
            
            
            if (cellRelativeY < supRelativeY) {
                CGFloat offset = supRelativeY - cellRelativeY;
                
                cellY = cellY + offset;
                cellSize = CGSizeMake(cellSize.width, cellSize.height - offset);
                
                cellAttributes.internalYOffset = -offset;
            }
            
            
            
            
        }
        
    }
    
    cellAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeCell];
    cellAttributes.size = cellSize;
    cellAttributes.center = CGPointMake(cellSize.width / 2.0, cellY + cellSize.height / 2.0);
    return cellAttributes;
    
}

- (CoolCardLayoutAttributes *)supplementaryViewLayoutAttributesForCellLayoutAttributes:(NSDictionary *)cellLayoutInfo atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item || [self isCellClingingForIndexPath:indexPath]) return nil;
    
    // -- start info
    CGSize supplementaryViewSize = [[cellLayoutInfo objectForKey:@"supplementaryViewSizeForSection"] CGSizeValue];
    CGFloat previousBottomY = [[cellLayoutInfo objectForKey:@"previousBottomY"] floatValue];
    // -- start info
    
    CGFloat supplementaryY = previousBottomY;
    
    
    CoolCardLayoutAttributes *supAttributes = [CoolCardLayoutAttributes layoutAttributesForSupplementaryViewOfKind:supplementaryKind withIndexPath:indexPath];
    supAttributes.size = supplementaryViewSize;
    supAttributes.shadowVisible = YES;
    
    if (self.cardBehaviourEnabled) { // цеплять наверх
        
        CGFloat newSupplementaryY = [self clingedYForHeaderAtY:supplementaryY withIndexPath:indexPath];
        
        if (newSupplementaryY > supplementaryY) {
            if (indexPath.section > self.numberOfClingingCards - 1) {
                supAttributes.shadowVisible = self.cardMagicEnabled;
            }
        }
        
        supplementaryY = newSupplementaryY;
    }
    
    supAttributes.zIndex = [self zIndexForIndexPath:indexPath forViewOfType:ViewTypeSupplementaryView];
    supAttributes.center = CGPointMake(supplementaryViewSize.width / 2.0, supplementaryY + supplementaryViewSize.height / 2.0);
    
    return supAttributes;
    
}

#pragma mark - Magic

- (CGFloat)clingedYForHeaderAtY:(CGFloat)startY withIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    if ((startY < collectionViewYOffset + clingYOffset)) { // цепляем
        startY = collectionViewYOffset + clingYOffset;
        
        
        if (self.cardMagicEnabled && self.cardBehaviourEnabled) {
            startY = [self magicYForStartY:startY withIndexPath:indexPath];
        }
    }
    
    return startY;
    
}

- (CGFloat)clingedYForCellAtY:(CGFloat)startY withIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = [self clingYOffsetForCellAtIndexPath:indexPath];
    CGFloat headerMagicOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    CGFloat screenHeight = self.collectionView.bounds.size.height;
 //   NSLog(@"Меньше %f", clingYOffset);
    
    NSIndexPath *prevLastIndexPath = [self indexPathForLastItemInSection:indexPath.section - 1]; // Проверить для 0
    NSIndexPath *lastIndexPath = [self indexPathForLastItemInSection:indexPath.section];
    
    CGFloat firstBottomY = [self bottomYForIndexPath:prevLastIndexPath];
    CGFloat lastBottomY = [self bottomYForIndexPath:lastIndexPath];
    
    BOOL below = lastBottomY - firstBottomY > screenHeight;
    
    if (startY < collectionViewYOffset + clingYOffset + headerMagicOffset && !below) {

        startY = collectionViewYOffset + clingYOffset + headerMagicOffset;
        
        
    }
    
  //  NSLog(@"%f %@", startY, indexPath);
    
    return startY;
    
}

- (CGFloat)magicYForStartY:(CGFloat)startY withIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat magicY = startY;
    NSInteger mIndex = self.lastClingedCardIndex - indexPath.section;
    
    if (indexPath.section < self.lastClingedCardIndex) {
        
        if (mIndex >= self.numberOfClingingCards) { // карта, которую занизили
            
            magicY += self.clingYOffset * mIndex;
            
        } else if (mIndex < self.numberOfClingingCards && self.lastClingedCardIndex >= self.numberOfClingingCards) { // поднимать
            
            CGFloat zIndex = 0;
            
            if (indexPath.section < self.numberOfClingingCards - 1) {
                NSInteger wowNumber = self.lastClingedCardIndex - self.numberOfClingingCards;
                zIndex = self.clingYOffset * (mIndex - 1) - wowNumber * self.clingYOffset;
            }
            
            CGFloat offset = (self.clingYOffset * mIndex) - zIndex;
            magicY -= offset;
            
        }
        
    }
    
    return magicY;
    
}

- (void)makeMagicMoveForSupplementaryInfo:(NSMutableDictionary **)supplementaryInfo cellsInfo:(NSMutableDictionary **)cellsInfo beforeSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat supplementaryY = [self previousBottomYForIndexPath:indexPath];
    CGFloat collectionViewYOffset = self.collectionView.contentOffset.y;
    CGFloat clingYOffset = [self clingYOffsetForSupplementaryViewAtIndexPath:indexPath];
    
    CGFloat relativeSupplementaryY = supplementaryY - collectionViewYOffset - clingYOffset;
    
    
    if (relativeSupplementaryY <= self.magicOffset && self.magicOffset >= 0) {
        
        CGFloat delta = MIN((self.magicOffset - (relativeSupplementaryY / self.magicOffset * self.magicOffset)) / 4, self.clingYOffset);
        
        for (int i = 1; i <= self.numberOfClingingCards; i++) {
            
            if (i == self.numberOfClingingCards) {
                delta = -delta;
                
            }
            
            NSIndexPath *previousIndexPathSection = [NSIndexPath indexPathForItem:0 inSection:indexPath.section - i];
            
            if ([self isCellClingingForIndexPath:previousIndexPathSection]) {
                
                CoolCardLayoutAttributes *prevAttributes = (*cellsInfo)[previousIndexPathSection];
                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - delta);
                (*cellsInfo)[previousIndexPathSection] = prevAttributes;
                
            } else {
                
                CoolCardLayoutAttributes *prevAttributes = (*supplementaryInfo)[previousIndexPathSection];
                prevAttributes.center = CGPointMake(prevAttributes.center.x, prevAttributes.center.y - delta);
                (*supplementaryInfo)[previousIndexPathSection] = prevAttributes;
                
            }
            
        }
        
    }
    
    
}

#pragma mark - BottomY Management

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
