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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor greenColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshPlaylists)
                  forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.view setBackgroundColor:[UIColor colorWithRed:51 green:51 blue:51 alpha:1]];
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
    if (type == SONGS) {
        if (successful) {
            UITableViewController* songTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SongTableViewController"];
            [self.navigationController pushViewController:songTableViewController animated:YES];
        }
        else {
            NSLog(@"Sorry, could not download songs");
        }
    }
    if (type == PLAYLISTS) {
        if (successful) {
            _playlists = [_dataModel getPlaylists];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            [self.refreshControl endRefreshing];
        }
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
    
    NSDictionary* playlist = [_playlists objectAtIndex:indexPath.row];
    cell.textLabel.text = [playlist objectForKey:@"name"];
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:51 green:51 blue:51 alpha:0]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
