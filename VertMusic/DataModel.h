//
//  DataModel.h
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject <NSURLSessionDataDelegate>

@property (weak, nonatomic) id delegate;

+ (id)getDataModel;

- (void)login:(NSDictionary*)cred;

- (void)downloadSongs:(NSInteger)index;

- (void)loadSong:(NSInteger)index;

- (NSArray*)getPlaylists;

- (NSArray*)getSongs;

- (NSString*)getSongTitle;

- (void)logout;

- (void)playSong;

- (void)pauseSong;

- (void)skipSong;

@end
