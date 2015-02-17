//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FilterViewControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BusinessCell *prototypeBusinessCell;
@property (strong, nonatomic) IBOutlet UISearchBar *navSearchBar;
@property (strong, nonatomic) NSMutableDictionary *filtersDictionary;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self fetchBusinessesWithQuery:@"Restaurants" params:self.filtersDictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.title = @"Yelp";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    self.navSearchBar = [[UISearchBar alloc] initWithFrame:self.tableView.bounds];
    [self.navSearchBar sizeToFit];
    self.navSearchBar.delegate = self;
    self.navigationItem.titleView = self.navSearchBar;
    self.filtersDictionary = [[NSMutableDictionary alloc] init];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.businesses.count - 1) {
        [self.filtersDictionary setObject:[NSNumber numberWithUnsignedInteger:self.businesses.count] forKey:@"offset"];
        [self fetchBusinessesWithQuery:@"Restaurants" params:self.filtersDictionary];
    }
}

- (BusinessCell *)prototypeBusinessCell {
    if (_prototypeBusinessCell == nil) {
        _prototypeBusinessCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    }
    return _prototypeBusinessCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.prototypeBusinessCell.business = self.businesses[indexPath.row];
    CGSize size = [self.prototypeBusinessCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Filter delegate methods

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.filtersDictionary = [filters mutableCopy];
    [self fetchBusinessesWithQuery:@"Restaurants" params:self.filtersDictionary];
}

#pragma mark - SearchBar delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.navSearchBar resignFirstResponder];
    [self.filtersDictionary removeAllObjects];
    [self fetchBusinessesWithQuery:self.navSearchBar.text params:self.filtersDictionary];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.navSearchBar performSelector: @selector(resignFirstResponder)
                             withObject: nil
                             afterDelay: 0.1];
        [self.filtersDictionary removeAllObjects];
        [self fetchBusinessesWithQuery:@"Restaurants" params:self.filtersDictionary];
    }
}

#pragma mark - Private methods

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:190/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];
        NSNumber *value = params[@"offset"];
        if (value.intValue > 0) {
            [self.businesses addObjectsFromArray:[Business businessWithDictionaries:businessDictionaries]];
        } else {
            self.businesses = [Business businessWithDictionaries:businessDictionaries];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}
@end
