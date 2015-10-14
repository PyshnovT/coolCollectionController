//
//  CoolFeedViewController.m
//  rocketbank
//
//  Created by Vitaly Berg on 29/09/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolFeedViewController.h"

#import "CoolCardCollectionView.h"

#import "CoolCardSupplementaryCell.h"
#import "CollectionCardCell.h"

#import "CoolCollectionCell.h"
#import "CoolCellItem.h"

#import "CoolCardCollectionViewLayout.h"

#import "CoolBuyCardCell.h"
#import "CoolNoteCardCell.h"

@interface CoolFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CardColletionViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet CoolCardCollectionView *collectionView;

@property (nonatomic, strong) NSArray *cellClasses;
@property (strong, nonatomic) NSMutableDictionary *data;

@end

@implementation CoolFeedViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.data count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *sectionKey = [self.data allKeys][section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    return sectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCellItem *item = [sectionData objectAtIndex:indexPath.item];
    UICollectionViewCell *cell = [self configuredCellForItem:item atIndexPath:indexPath];

    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    return [self configuredSupplementaryViewAtIndexPath:indexPath];
    
}

#pragma mark - Cell config

- (UICollectionViewCell *)configuredCellForItem:(CoolCellItem *)item atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell <CoolCollectionCell> *cell;
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
        }
    }
    
    NSString *title = item.title;
    
    cell.layer.zPosition = -2;
    cell.title = title;
    
    return cell;
}

- (UICollectionViewCell *)configuredSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    CoolCardSupplementaryCell *supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:supplementaryKind withReuseIdentifier:supplementaryReuseIdentifier forIndexPath:indexPath];
    
    NSString *title = [self.data allKeys][indexPath.section];
    supCell.title = title;
    supCell.layer.zPosition = indexPath.section;
    
    NSLog(@"SUPPLEMENTARY %@", title);
    
    return supCell;
}

#pragma mark - UICollectionViewDelegate


#pragma mark - CardColletionViewLayoutDelegate

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCellItem *item = [sectionData objectAtIndex:indexPath.item];
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            return [cellClass heightOfCell];
        }
    }
    
    return 0;
}

- (CGFloat)heightForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CellItemType)cellItemTypeForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionKey = [self.data allKeys][indexPath.section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    CoolCellItem *item = [sectionData objectAtIndex:indexPath.item];
    
    if (item) {
        return item.type;
    }
    
    return CellItemTypeNone;
    
}

#pragma mark - Setup

- (void)setupData {
    NSDictionary *nameDict = @{@"Пара": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры"],
                               @"Вата": @[@"Ва", @"Вы", @"Вивы"],
                               @"Дыня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Тёрка": @[@"Твац", @"Тцуацуа"],
                               @"Чdучмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучaмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чуaчмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучaмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Дaыня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Дыgня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Дыsня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Дынaя": @[@"Дйййййй", @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"],
                               @"Паsdaра": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"]
                               };
    
    NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in nameDict) {
        
        NSArray *array = nameDict[key];
        NSMutableArray *itemsArray = [NSMutableArray array];
        
        for (int i = 0; i < array.count; i++) {
            CoolCellItem *item = [[CoolCellItem alloc] init];
            item.title = array[i];
            item.type = arc4random() % 2 ? CellItemTypeBuy : CellItemTypeNote;
            
            [itemsArray addObject:item];
        }
        
        itemDict[key] = itemsArray;
    }
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:itemDict];
}

- (void)registerCells {
    
    self.cellClasses = @[[CoolBuyCardCell class],
                         [CoolNoteCardCell class]];
    
    for (Class<CoolCollectionCell> cellClass in self.cellClasses) {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CoolCardSupplementaryCell" bundle:nil] forSupplementaryViewOfKind:supplementaryKind withReuseIdentifier:supplementaryReuseIdentifier];
    
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self registerCells];
    
    ((CoolCardCollectionViewLayout *)self.collectionView.collectionViewLayout).delegate = self;
}

@end
