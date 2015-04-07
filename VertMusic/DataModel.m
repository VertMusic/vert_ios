//
//  DataModel.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DataModel.h"
#import "LoginViewController.h"
#import "PlayListTableViewController.h"

static DataModel* _dataModel;

@implementation DataModel
{
    NSURL *_url_login;
    NSURL *_url_playlists;
    
    NSURLSessionConfiguration* _config;
    NSURLSession* _session;
    
    NSString* _accessToken;
    NSArray* _playlists;
    NSArray* _songs;
    
    AVAudioPlayer* _audioPlayer;
    NSInteger _track;
}

@synthesize delegate;

+ (DataModel*)getDataModel {
    if (_dataModel == nil) {
        _dataModel = [[DataModel alloc] init];
    }
    return _dataModel;
}

- (DataModel*)init {
    _url_login = [NSURL URLWithString:@"http://192.168.56.101:8080/vert/data/session"];
    _url_playlists = [NSURL URLWithString:@"http://192.168.56.101:8080/vert/data/playlists"];
    
    
    _config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _config.allowsCellularAccess = NO;
    _config.timeoutIntervalForRequest = 30.0;
    _config.timeoutIntervalForResource = 60.0;
    _config.HTTPMaximumConnectionsPerHost = 1;
    
    _session = [NSURLSession sessionWithConfiguration:_config
                                             delegate:self
                                        delegateQueue:nil];
    
    _accessToken = nil;
    _playlists = nil;
     _songs = nil;
    
    _audioPlayer = nil;
    _track = 0;
    
    return self;
}

- (void)login:(NSDictionary*)cred {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:cred options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Login error: %@", error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url_login];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:data];
    [self beginLoginTask:request];;
}


- (void)beginLoginTask:(NSMutableURLRequest*)req {
    NSURLSessionUploadTask *uploadTask = [_session uploadTaskWithRequest:req fromData:nil
                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  
                                                  NSDictionary *cred = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                  
                                                  BOOL isCredValid = (cred != nil);
                                                  if (isCredValid) {
                                                      _accessToken = [[cred objectForKey:@"session"] objectForKey:@"accessToken"];
                                                      NSLog(@"Access token: %@", _accessToken);
                                                      [self downloadPlaylist];
                                                  }
                                                  else [(LoginViewController*)delegate failedToLogin];
                                              });
                                          }];
    
    [uploadTask resume];
}

- (void)downloadPlaylist {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url_playlists];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:_accessToken forHTTPHeaderField:@"authorization"];
    [self beginPlaylistTask:request];
}

- (void)beginPlaylistTask:(NSMutableURLRequest*)req {
    NSURLSessionDownloadTask *downloadTask = [_session
                                              downloadTaskWithRequest:req completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      NSDictionary* playlists = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:NSJSONReadingAllowFragments error:nil];

                                                      BOOL isPlaylistValid = (playlists != nil);
                                                      if (isPlaylistValid) {
                                                          _playlists = [playlists valueForKey:@"playlists"];
                                                          NSLog(@"Playlists: %@", _playlists);
                                                      }
                                                      [(LoginViewController*)delegate didDownloadPlaylists:isPlaylistValid];
                                                  });
                                                  
                                              }];
    [downloadTask resume];
}

- (void)downloadSongs:(NSInteger)index {
    NSString* songURL = @"http://192.168.56.101:8080/vert/data/songs?";
    NSArray* songArray = [[_playlists objectAtIndex:index] objectForKey:@"songs"];
    
    for (int i=0;i<songArray.count;i++) {
        if (i != 0){
            songURL = [songURL stringByAppendingString:@"&"];
        }
        NSString *songID = [songArray objectAtIndex:i];
        songURL = [songURL stringByAppendingFormat:@"ids[]=%@", songID];
    }
    
    NSURL* url = [NSURL URLWithString:songURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:_accessToken forHTTPHeaderField:@"authorization"];
    [self beginSongTask:request];
}

- (void)beginSongTask:(NSMutableURLRequest*)req {
    NSURLSessionDownloadTask *downloadTask = [_session
                                              downloadTaskWithRequest:req completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      NSDictionary* songs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:NSJSONReadingAllowFragments error:nil];
                                                      
                                                      BOOL isSongsValid = (songs != nil);
                                                      
                                                      if (isSongsValid) {
                                                          _songs = [songs valueForKey:@"songs"];
                                                          NSLog(@"Songs: %@", _songs);
                                                      }
                                                      [(PlayListTableViewController*)delegate didFinishDownloadingSongs:isSongsValid];
                                                  });
                                              }];
    
    [downloadTask resume];
}

- (void)loadSong:(NSInteger)index {
    _track = index;
    if (_audioPlayer != nil) _audioPlayer = nil;
    
    NSString* song_id = [[_songs objectAtIndex:index] objectForKey:@"id"];
    NSString* songUrlString = @"http://192.168.56.101:8080/vert/file/song/";
    NSURL* songURL = [NSURL URLWithString:[songUrlString stringByAppendingString:song_id]];
    
    _audioPlayer = [AVPlayer playerWithURL:songURL];
    [self playSong];
}

- (void)playSong {
    if (_audioPlayer == nil) return;
    [_audioPlayer play];
}

- (void)pauseSong {
    if (_audioPlayer == nil) return;
    [_audioPlayer pause];
}


- (NSArray*)getPlaylists {
    if (_playlists == nil)
        return [NSArray array];
    
    return _playlists;
}

- (NSArray*)getSongs {
    if (_songs == nil)
        return [NSArray array];
    
    return _songs;
}

- (NSString*)getSongTitle {
    return [[_songs objectAtIndex:_track] objectForKey:@"title"];
}

- (void)skipSong {
    if (_track < _songs.count-1) _track++;
    [self loadSong:_track];
}

- (void)prevSong {
    if (_track > 0) _track--;
    [self loadSong:_track];
}

- (void)logout {
    _session = nil;
    _playlists = nil;
    _songs = nil;
    if(_audioPlayer != nil) {
        [self pauseSong];
        _audioPlayer = nil;
    }
}


@end
