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
 //   NSLog(@"секции: %lu", (unsigned long)[self.data count]);
    return [self.data count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *sectionKey = [self.data allKeys][section];
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
 //   NSLog(@"количество айтемов %lu в секции: %@", (unsigned long)sectionData.count, sectionKey);
    return sectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%@", indexPath);
    
    NSString *sectionKey = [self.data allKeys][indexPath.section];
  //  NSLog(@"КИ: %@", sectionKey);
    NSArray *sectionData = [self.data objectForKey:sectionKey];
    
    NSString *title = [sectionData objectAtIndex:indexPath.item];
    
    
    CardItem *item = [[CardItem alloc] init];
    item.type = CardItemTypeFirst;
    
    CollectionCardCell<CollectionCard> *cardCell;
    
    for (Class<CollectionCard> cellClass in self.cellClasses) {
        if ([cellClass handleItem:item]) {
            cardCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
            
        //    NSLog(@"%@", title);
            cardCell.title = title;
        }
        
     //   [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
 //   FirstCardCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier: forIndexPath:indexPath];
    
  //  cardCell.backgroundColor = [UIColor redColor];
    cardCell.layer.zPosition = -1;
    
    return cardCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = [self.data allKeys][indexPath.section];
    
  //  NSLog(@"%@", title);
    
    SupplementaryCell *supCell = [self.collectionView dequeueReusableSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier forIndexPath:indexPath];
    supCell.titleLabel.text = title;//title = @"ЛОООООООООООЛ";
  //  NSLog(@"%@", supView.privateTitleLabel);
    supCell.layer.zPosition = indexPath.section;
  //  supCell.backgroundColor = [UIColor yellowColor];
    supCell.backView.hidden = !!indexPath.section;
    
  //  supCell.layer.shouldRasterize = YES;
    //supCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return supCell;
}

#pragma mark - UICollectionViewDelegate



#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellClasses = @[[FirstCardCell class]];
    
    NSDictionary *dict = @{@"Первая секция": @[@"Перв", @"Перк", @"Пы", @"По", @"Пры"],
                           @"Вторая секцушка": @[@"Ва", @"Вы", @"Вивы"],
                           @"2.5 секция": @[@"Дйййййй", @"Двыа", @"Двыаыва"],
                           @"Треться секция": @[@"Твац", @"Тцуацуа"],
                           @"Четвёртая секция": @[@"Чцуа", @"Чуца", @"Чуца", @"Ч32к", @"Чйук"]
                  };
    
    self.data = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSLog(@"ставлю дату");
    
 //   [self.collectionView registerClass:[FirstCardCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    for (Class<CollectionCard> cellClass in self.cellClasses) {
        [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil]  forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    //[self.collectionView registerNib:[UINib nibWithNibName:@"FirstCardCell" bundle:nil] forCellWithReuseIdentifier:cellReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SupplementaryCell" bundle:nil] forSupplementaryViewOfKind:@"title" withReuseIdentifier:viewReuseIdentifier];

    
}

@end
