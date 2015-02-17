//
//  FiltersViewController.m
//  Yelp
//
//  Created by Rose Marie Philip on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) BOOL dealsOn;
@property (nonatomic, assign) NSInteger sortMode;
@property (nonatomic, strong) NSArray *sortModeTitles;
@property (nonatomic, assign) NSInteger distanceMode;
@property (nonatomic, strong) NSArray *distanceTitles;
@property (nonatomic, strong) NSArray *distances;

- (void)initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    
    if (self) {
        self.title = @"Filters";
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
        self.dealsOn = NO;
        self.sortMode = 0;
        self.sortModeTitles = @[@"Best Match", @"Distance", @"Highest Rated"];
        self.distanceMode = 0;
        self.distanceTitles = @[@"Best Match", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"];
        self.distances = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:482],[NSNumber numberWithInt:1609],[NSNumber numberWithInt:8047],[NSNumber numberWithInt:32187],nil]; // distanceTitles in meters
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:       // deals
            return 1;
            break;
        case 1:       // category
            return 5;
            break;
        case 2:       // radius (maybe needs only a text field)
            return 5;
            break;
        case 3:
            return 3; // sort
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:       // deals
            return @"Most Popular";
            break;
        case 1:       // category
            return @"Categories";
            break;
        case 2:       // radius (maybe needs only a text field)
            return @"Distance";
            break;
        case 3:       // sort
            return @"Sort By";
            break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            cell.titleLabel.text = @"Offering a deal";
            cell.on = self.dealsOn;
            cell.delegate = self;
            return cell;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            cell.delegate = self;
            return cell;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            cell.titleLabel.text = self.distanceTitles[indexPath.row];
            cell.on = (self.distanceMode == indexPath.row);
            cell.delegate = self;
            return cell;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            cell.titleLabel.text = self.sortModeTitles[indexPath.row];
            cell.on = (self.sortMode == indexPath.row);
            cell.delegate = self;
            return cell;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            return cell;
    }
}

#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.section) {
        case 0:
            self.dealsOn = value;
            break;
        case 1:
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
            break;
        case 2:
        {
            NSInteger prevDistanceMode = self.distanceMode;
            self.distanceMode = indexPath.row;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:prevDistanceMode inSection:2];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
            break;
        case 3:
        {
            NSInteger prevSortMode = self.sortMode;
            self.sortMode = indexPath.row;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:prevSortMode inSection:3];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    [filters setObject:[NSNumber numberWithBool:self.dealsOn] forKey:@"deals_filter"];
    [filters setObject:[NSNumber numberWithInt:(int)self.sortMode] forKey:@"sort"];
    if (self.distanceMode > 0) {
        NSNumber *distance = self.distances[self.distanceMode];
        [filters setObject:distance forKey:@"radius_filter"];
    }
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    self.categories = @[
                        @{@"name" : @"Afghan", @"code": @"afghani" },
                        @{@"name" : @"African", @"code": @"african" },
                        @{@"name" : @"American, New", @"code": @"newamerican" },
                        @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                        @{@"name" : @"Arabian", @"code": @"arabian" },
                      /*  @{@"name" : @"Argentine", @"code": @"argentine" },
                        @{@"name" : @"Armenian", @"code": @"armenian" },
                        @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                        @{@"name" : @"Asturian", @"code": @"asturian" },
                        @{@"name" : @"Australian", @"code": @"australian" },
                        @{@"name" : @"Austrian", @"code": @"austrian" },
                        @{@"name" : @"Baguettes", @"code": @"baguettes" },
                        @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                        @{@"name" : @"Barbeque", @"code": @"bbq" },
                        @{@"name" : @"Basque", @"code": @"basque" },
                        @{@"name" : @"Bavarian", @"code": @"bavarian" },
                        @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                        @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                        @{@"name" : @"Beisl", @"code": @"beisl" },
                        @{@"name" : @"Belgian", @"code": @"belgian" },
                        @{@"name" : @"Bistros", @"code": @"bistros" },
                        @{@"name" : @"Black Sea", @"code": @"blacksea" },
                        @{@"name" : @"Brasseries", @"code": @"brasseries" },
                        @{@"name" : @"Brazilian", @"code": @"brazilian" },
                        @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                        @{@"name" : @"British", @"code": @"british" },
                        @{@"name" : @"Buffets", @"code": @"buffets" },
                        @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                        @{@"name" : @"Burgers", @"code": @"burgers" },
                        @{@"name" : @"Burmese", @"code": @"burmese" },
                        @{@"name" : @"Cafes", @"code": @"cafes" },
                        @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                        @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                        @{@"name" : @"Cambodian", @"code": @"cambodian" },
                        @{@"name" : @"Canadian", @"code": @"New)" },
                        @{@"name" : @"Canteen", @"code": @"canteen" },
                        @{@"name" : @"Caribbean", @"code": @"caribbean" },
                        @{@"name" : @"Catalan", @"code": @"catalan" },
                        @{@"name" : @"Chech", @"code": @"chech" },
                        @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                        @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                        @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                        @{@"name" : @"Chilean", @"code": @"chilean" },
                        @{@"name" : @"Chinese", @"code": @"chinese" },
                        @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                        @{@"name" : @"Corsican", @"code": @"corsican" },
                        @{@"name" : @"Creperies", @"code": @"creperies" },
                        @{@"name" : @"Cuban", @"code": @"cuban" },
                        @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                        @{@"name" : @"Cypriot", @"code": @"cypriot" },
                        @{@"name" : @"Czech", @"code": @"czech" },
                        @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                        @{@"name" : @"Danish", @"code": @"danish" },
                        @{@"name" : @"Delis", @"code": @"delis" },
                        @{@"name" : @"Diners", @"code": @"diners" },
                        @{@"name" : @"Dumplings", @"code": @"dumplings" },
                        @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                        @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                        @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                        @{@"name" : @"Filipino", @"code": @"filipino" },
                        @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                        @{@"name" : @"Fondue", @"code": @"fondue" },
                        @{@"name" : @"Food Court", @"code": @"food_court" },
                        @{@"name" : @"Food Stands", @"code": @"foodstands" },
                        @{@"name" : @"French", @"code": @"french" },
                        @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                        @{@"name" : @"Galician", @"code": @"galician" },
                        @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                        @{@"name" : @"Georgian", @"code": @"georgian" },
                        @{@"name" : @"German", @"code": @"german" },
                        @{@"name" : @"Giblets", @"code": @"giblets" },
                        @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                        @{@"name" : @"Greek", @"code": @"greek" },
                        @{@"name" : @"Halal", @"code": @"halal" },
                        @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                        @{@"name" : @"Heuriger", @"code": @"heuriger" },
                        @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                        @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                        @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                        @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                        @{@"name" : @"Hungarian", @"code": @"hungarian" },
                        @{@"name" : @"Iberian", @"code": @"iberian" },
                        @{@"name" : @"Indian", @"code": @"indpak" },
                        @{@"name" : @"Indonesian", @"code": @"indonesian" },
                        @{@"name" : @"International", @"code": @"international" },
                        @{@"name" : @"Irish", @"code": @"irish" },
                        @{@"name" : @"Island Pub", @"code": @"island_pub" },
                        @{@"name" : @"Israeli", @"code": @"israeli" },
                        @{@"name" : @"Italian", @"code": @"italian" },
                        @{@"name" : @"Japanese", @"code": @"japanese" },
                        @{@"name" : @"Jewish", @"code": @"jewish" },
                        @{@"name" : @"Kebab", @"code": @"kebab" },
                        @{@"name" : @"Korean", @"code": @"korean" },
                        @{@"name" : @"Kosher", @"code": @"kosher" },
                        @{@"name" : @"Kurdish", @"code": @"kurdish" },
                        @{@"name" : @"Laos", @"code": @"laos" },
                        @{@"name" : @"Laotian", @"code": @"laotian" },
                        @{@"name" : @"Latin American", @"code": @"latin" },
                        @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                        @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                        @{@"name" : @"Malaysian", @"code": @"malaysian" },
                        @{@"name" : @"Meatballs", @"code": @"meatballs" },
                        @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                        @{@"name" : @"Mexican", @"code": @"mexican" },
                        @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                        @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                        @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                        @{@"name" : @"Modern European", @"code": @"modern_european" },
                        @{@"name" : @"Mongolian", @"code": @"mongolian" },
                        @{@"name" : @"Moroccan", @"code": @"moroccan" },
                        @{@"name" : @"New Zealand", @"code": @"newzealand" },
                        @{@"name" : @"Night Food", @"code": @"nightfood" },
                        @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                        @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                        @{@"name" : @"Oriental", @"code": @"oriental" },
                        @{@"name" : @"Pakistani", @"code": @"pakistani" },
                        @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                        @{@"name" : @"Parma", @"code": @"parma" },
                        @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                        @{@"name" : @"Peruvian", @"code": @"peruvian" },
                        @{@"name" : @"Pita", @"code": @"pita" },
                        @{@"name" : @"Pizza", @"code": @"pizza" },
                        @{@"name" : @"Polish", @"code": @"polish" },
                        @{@"name" : @"Portuguese", @"code": @"portuguese" },
                        @{@"name" : @"Potatoes", @"code": @"potatoes" },
                        @{@"name" : @"Poutineries", @"code": @"poutineries" },
                        @{@"name" : @"Pub Food", @"code": @"pubfood" },
                        @{@"name" : @"Rice", @"code": @"riceshop" },
                        @{@"name" : @"Romanian", @"code": @"romanian" },
                        @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                        @{@"name" : @"Rumanian", @"code": @"rumanian" },
                        @{@"name" : @"Russian", @"code": @"russian" },
                        @{@"name" : @"Salad", @"code": @"salad" },
                        @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                        @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                        @{@"name" : @"Scottish", @"code": @"scottish" },
                        @{@"name" : @"Seafood", @"code": @"seafood" },
                        @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                        @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                        @{@"name" : @"Singaporean", @"code": @"singaporean" },
                        @{@"name" : @"Slovakian", @"code": @"slovakian" },
                        @{@"name" : @"Soul Food", @"code": @"soulfood" },
                        @{@"name" : @"Soup", @"code": @"soup" },
                        @{@"name" : @"Southern", @"code": @"southern" },
                        @{@"name" : @"Spanish", @"code": @"spanish" },
                        @{@"name" : @"Steakhouses", @"code": @"steak" },
                        @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                        @{@"name" : @"Swabian", @"code": @"swabian" },
                        @{@"name" : @"Swedish", @"code": @"swedish" },
                        @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                        @{@"name" : @"Tabernas", @"code": @"tabernas" },
                        @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                        @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                        @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                        @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                        @{@"name" : @"Thai", @"code": @"thai" },
                        @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                        @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                        @{@"name" : @"Trattorie", @"code": @"trattorie" },
                        @{@"name" : @"Turkish", @"code": @"turkish" },
                        @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                        @{@"name" : @"Uzbek", @"code": @"uzbek" },
                        @{@"name" : @"Vegan", @"code": @"vegan" },
                        @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                        @{@"name" : @"Venison", @"code": @"venison" },
                        @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                        @{@"name" : @"Wok", @"code": @"wok" },
                        @{@"name" : @"Wraps", @"code": @"wraps" },
                        @{@"name" : @"Yugoslav", @"code": @"yugoslav" }*/
                        ];
}

@end
