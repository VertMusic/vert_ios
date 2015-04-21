//
//  PlayListTableViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import "PlayListTableViewController.h"
#import "DataModel.h"
#import "DataProtocol.h"

@interface PlayListTableViewController () <DataProtocol>

@end

@implementation PlayListTableViewController {
    DataModel* _dataModel;
    NSArray* _playlists;
    UIColor* _grey;
    UIColor* _lightGrey;
    UIColor* _green;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    _lightGrey = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1];
    _grey = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    _green = [UIColor colorWithRed:159.0/255.0 green:200.0/255.0 blue:71.0/255.0 alpha:1];
    
    self.navigationController.navigationBar.barTintColor = _lightGrey;
    self.navigationController.navigationBar.tintColor = _green;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: _green};
    
    self.tabBarController.tabBar.barTintColor = _lightGrey;
    self.tabBarController.tabBar.tintColor = _green;
    
    [self.view setBackgroundColor:_grey];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = _green;
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshPlaylists)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _dataModel = [DataModel getDataModel];
    _dataModel.delegate = self;
    _playlists = [_dataModel getPlaylists];
    
    [self.tableView reloadData];
}

- (void)refreshPlaylists {
    [_dataModel downloadPlaylist];
}

- (void)sessionDidFinish:(BOOL)successful taskType:(TaskType)type {
    if (type == SONGS)
        [self loadSongController:successful];
    else if (type == PLAYLISTS)
        [self loadPlaylists:successful];
    else
        NSLog(@"Invalid type of task.");
}

- (void)loadSongController:(BOOL)successful {
    if (successful) {
        UITableViewController* songTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SongTableViewController"];
        [self.navigationController pushViewController:songTableViewController animated:YES];
    }
    else {
        NSLog(@"Sorry, could not download songs");
    }
}

- (void)loadPlaylists:(BOOL)successful {
    if (successful) {
        _playlists = [_dataModel getPlaylists];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
    else {
        [self.refreshControl endRefreshing];
        NSLog(@"Sorry, could not download playlists");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [_dataModel downloadSongs:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _playlists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayListCell" forIndexPath:indexPath];
    cell.textLabel.backgroundColor = _grey;
    cell.contentView.backgroundColor = _grey;
    
    NSDictionary* playlist = [_playlists objectAtIndex:indexPath.row];
    cell.textLabel.text = [playlist objectForKey:@"name"];
    
    [cell.textLabel setTextColor:_green];
    
    return cell;
}

@end
