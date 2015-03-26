//
//  DataModel.h
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LoginViewController.h"
#import "PlayListTableViewController.h"
#import "SongTableViewController.h"

@interface DataModel : NSObject <NSURLConnectionDelegate>

+ (DataModel*)getDataModel;

- (DataModel*)init;

- (void)synchLoginViewController:(LoginViewController*)lvc;

- (void)synchPlayListTableViewController:(PlayListTableViewController*)pltvc;

- (void)synchSongTableViewController:(SongTableViewController*)stvc;

- (void)loginWithUsername:(NSString*)username andPassword:(NSString*)password;

- (void)downloadPlayLists;

- (void)loadSongAtIndex:(NSInteger)index;

- (void)downloadSongsWithPlaylistIndex:(NSInteger)index;

- (NSDictionary*)getSession;

- (NSArray*)getPlaylists;

- (NSArray*)getSongs;

- (void)logout;

- (void)playSong;

- (void)pauseSong;

- (void)stopSong;

@end
