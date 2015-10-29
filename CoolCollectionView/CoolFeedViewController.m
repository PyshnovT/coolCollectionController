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
#import "ThirdCardCell.h"
#import "UIColor+Randomizer.h"

@interface CoolFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CardColletionViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet CoolCardCollectionView *collectionView;

//@property (strong, nonatomic) CoolCardCollectionView *collectionView;

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
    
    NSLog(@"Cell");
    
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
    
    cell.title = title;
    
    return cell;
}

- (UICollectionViewCell *)configuredSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    
    CoolCardSupplementaryCell *supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:supplementaryKind withReuseIdentifier:supplementaryReuseIdentifier forIndexPath:indexPath];
    
    NSString *title = [self.data allKeys][indexPath.section];
    supCell.title = title;
    
    return supCell;
}

#pragma mark - UICollectionViewDelegate
/*
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.collectionView) {
        self.scrollInfo.velocity = velocity;
        self.scrollInfo.targetContentOffset = *(targetContentOffset);
    }
}
 */
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        self.scrollInfo.currentDate = [NSDate date];
    }
}
*/
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

- (BOOL)isCellClingingForIndexPath:(NSIndexPath *)indexPath {
    
    CellItemType itemType = [self cellItemTypeForCellAtIndexPath:indexPath];
    
    for (Class<CoolCollectionCell> cellClass in self.collectionView.clingingCellClasses) {
        if ([cellClass itemType] == itemType) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Setup

- (void)setupData {
    NSDictionary *nameDict = @{@"Пара": @[@"Перв"],
                               @"Вата": @[@"Ва", @"в"],
                               @"Дыня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                               @"Тёрка": @[@"Твац"],
                               @"Чdучмек": @[@"Чцуа"],
                               @"Чучaмек": @[@"Чцуа", @"Ч32к", @"Чйук"],
                               @"Чуaчмек": @[@"Чцуа", @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы"],
                               @"Чучмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"],
                               @"Чучaмек": @[@"Чцуа"],
                               @"Дaыня": @[@"Дйййййй", @"Двыа", @"Двыаыва",  @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы"],
                               @"Дыgня": @[@"Дйййййй"],
                               @"Дыsня": @[@"Дйййййй",  @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы",],
                               @"Дынaя": @[@"Дйййййй", @"Двыа", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Двыаыва", @"Перв", @"Перк", @"Пы", @"По", @"Пры", @"Двыа", @"Двыаыва", @"Чцуа", @"Чуца", @"Чуца", @"Ч32к"],
                               @"Паsdaра": @[@"Перв", @"Перк", @"Чцуа", @"Чцуа", @"Чуца", @"Чуца", @"Двыаыва", @"Перв"]
                               };
    
    NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in nameDict) {
        
        NSArray *array = nameDict[key];
        NSMutableArray *itemsArray = [NSMutableArray array];
        
        for (int i = 0; i < array.count; i++) {
            CoolCellItem *item = [[CoolCellItem alloc] init];
            item.title = array[i];
        
            if (array.count == 1) {
                //item.type = CellItemTypeBuy;
                item.type = CellItemTypeNote;
            } else {
                item.type = CellItemTypeBuy;
            }
            
            [itemsArray addObject:item];
        }
        
        itemDict[key] = itemsArray;
    }
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:itemDict];
    
    self.collectionView.clingingCellClasses = @[[CoolNoteCardCell class], [ThirdCardCell class]];
}

- (void)registerCells {
    
    self.cellClasses = @[[CoolBuyCardCell class],
                         [CoolNoteCardCell class],
                         [ThirdCardCell class]];
    
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
    /*
    CoolCardCollectionViewLayout *collectionViewLayout = [[CoolCardCollectionViewLayout alloc] init];
    collectionViewLayout.interSectionSpaceY = 0;
    collectionViewLayout.interItemSpaceY = 0;
    
    self.collectionView = [[CoolCardCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:collectionViewLayout];
    self.collectionView.collectionViewLayout = collectionViewLayout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    */
    [self setupData];
    [self registerCells];

    
    ((CoolCardCollectionViewLayout *)self.collectionView.collectionViewLayout).delegate = self;
}

@end
