//
//  DataModel.h
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProtocol.h"

@interface DataModel : NSObject <NSURLSessionDataDelegate>

@property (weak, nonatomic) id delegate;

+ (id)getDataModel;

- (void)login:(NSDictionary*)cred;

- (void)downloadPlaylist;

- (void)downloadSongs:(NSInteger)index;

- (void)loadSong:(NSInteger)index;

- (NSArray*)getPlaylists;

- (NSArray*)getSongs;

- (NSDictionary*)getSongInfo;

- (void)logout;

- (BOOL)togglePlaySong;

- (void)skipSong;

- (void)prevSong;

@end
