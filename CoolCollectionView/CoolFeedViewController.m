//
//  CoolFeedViewController.m
//  rocketbank
//
//  Created by Vitaly Berg on 29/09/15.
//  Copyright © 2015 RocketBank. All rights reserved.
//

#import "CoolFeedViewController.h"

#import "CoolCollectionView.h"

#import "SupplementaryCell.h"
#import "CollectionCardCell.h"
#import "FirstCardCell.h"
#import "CollectionCard.h"
#import "CardItem.h"

@interface CoolFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet CoolCollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellClasses;
@property (strong, nonatomic) NSMutableDictionary *data;

@end

@implementation CoolFeedViewController

static NSString * const cellReuseIdentifier = @"Cell";
static NSString * const viewReuseIdentifier = @"View";

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
    
    NSString *title = [sectionData objectAtIndex:indexPath.item];
    
    CardItem *item = [[CardItem alloc] init];
    item.type = CardItemTypeFirst;
    
    CollectionCardCell<CollectionCard> *cardCell;
    
    for (Class<CollectionCard> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            cardCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
        }
    }
    
    cardCell.layer.zPosition = -1;
    cardCell.title = title;
    
    return cardCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = [self.data allKeys][indexPath.section];
    
  //  NSLog(@"%@", title);
    
    SupplementaryCell *supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier forIndexPath:indexPath];
    supCell.titleLabel.text = title;
    supCell.layer.zPosition = indexPath.section;
    supCell.backView.hidden = !!indexPath.section;
    
    return supCell;
}

#pragma mark - UICollectionViewDelegate


#pragma mark - Cells

- (void)registerCells {
    
    self.cellClasses = @[[FirstCardCell class]];
    
    for (Class<CollectionCard> cellClass in self.cellClasses) {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SupplementaryCell" bundle:nil] forSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier];
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = @{@"Пара": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры"],
                           @"Вата": @[@"Ва", @"Вы", @"Вивы"],
                           @"Дыня": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                           @"Тёрка": @[@"Твац", @"Тцуацуа"],
                           @"Чучмек": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"]
                  };
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [self registerCells];
    
    
}

@end
