//
//  SongTableViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/22/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import "SongTableViewController.h"
#import "DataModel.h"
#import "DataProtocol.h"

@interface SongTableViewController () <DataProtocol>

@end

@implementation SongTableViewController {
    DataModel* _dataModel;
    NSArray* _songs;
    UIColor* _grey;
    UIColor* _green;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    _grey = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    _green = [UIColor colorWithRed:159.0/255.0 green:200.0/255.0 blue:71.0/255.0 alpha:1];

    [self.view setBackgroundColor:_grey];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _dataModel = [DataModel getDataModel];
    _dataModel.delegate = self;
    _songs = [_dataModel getSongs];
    
    [self.tableView reloadData];
}

- (void)sessionDidFinish:(BOOL)successful taskType:(TaskType)type {
    if (successful) {
        NSLog(@"Downloaded songs successfully");
    }
    else {
        NSLog(@"Downloaded songs unsuccessfully");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"%lu", indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [_dataModel loadSong:indexPath.row];
    UIViewController* playSongViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlaySongViewController"];
    playSongViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:playSongViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_songs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                    reuseIdentifier:@"SongCell"];
    cell.textLabel.backgroundColor = _grey;
    cell.contentView.backgroundColor = _grey;
    NSDictionary* song = [_songs objectAtIndex:indexPath.row];
    cell.textLabel.text = [song objectForKey:@"title"];
    cell.detailTextLabel.text = [song objectForKey:@"artist"];
    
    [cell.textLabel setTextColor:_green];
    [cell.detailTextLabel setTextColor:_green];
    
    return cell;
}

@end
