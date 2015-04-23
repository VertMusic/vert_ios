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
    
    NSString* _accessToken;
    NSArray* _playlists;
    NSArray* _songs;
    
    AVAudioPlayer* _audioPlayer;
    NSInteger _track;
    
    BOOL _isSongPlaying;
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
    
    _accessToken = nil;
    _playlists = nil;
     _songs = nil;
    
    _audioPlayer = nil;
    _track = 0;
    
    _isSongPlaying = NO;
    
    return self;
}

- (void)login:(NSDictionary*)cred {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:cred options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Login error: %@", error);
        return;
    }
    
    NSMutableURLRequest *request = [self request:_url_login];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [self taskWithRequest:request andTaskType:LOGIN];
}

- (void)downloadPlaylist {
    NSMutableURLRequest *request = [self request:_url_playlists];
    [request setHTTPMethod:@"GET"];
    [request setValue:_accessToken forHTTPHeaderField:@"authorization"];
    [self taskWithRequest:request andTaskType:PLAYLISTS];
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
    NSMutableURLRequest *request = [self request:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:_accessToken forHTTPHeaderField:@"authorization"];
    [self taskWithRequest:request andTaskType:SONGS];
}

- (NSMutableURLRequest*)request:(NSURL*)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

- (void)taskWithRequest:(NSMutableURLRequest*)req andTaskType:(TaskType)type {
    NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode] == 401) {
                [delegate sessionDidFinish:false taskType:type];
            }
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            BOOL isDictValid = (dict != nil);
            if (isDictValid) {
                [self handleData:dict withTask:type];
                [delegate sessionDidFinish:true taskType:type];
            }
            
        });
    }];
                                          
    [uploadTask resume];
}

- (void)handleData:(NSDictionary*)data withTask:(TaskType)task {
    switch (task) {
        case LOGIN:
            _accessToken = [[data objectForKey:@"session"] objectForKey:@"accessToken"];
            NSLog(@"Access token: %@", _accessToken);
            [self downloadPlaylist];
            break;
        case PLAYLISTS:
            _playlists = [data valueForKey:@"playlists"];
            NSLog(@"Playlists: %@", _playlists);
            break;
        case SONGS:
            _songs = [data valueForKey:@"songs"];
            NSLog(@"Songs: %@", _songs);
            break;
        default:
            NSLog(@"Wrong Task Type");
            break;
    }
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

- (BOOL)togglePlaySong {
    if (_isSongPlaying)
        [self pauseSong];
    
    else [self playSong];
    
    return _isSongPlaying;
}

- (void)playSong {
    if (_audioPlayer == nil) return;
    [_audioPlayer play];
    _isSongPlaying = YES;
}

- (void)pauseSong {
    if (_audioPlayer == nil) return;
    [_audioPlayer pause];
    _isSongPlaying = NO;
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

- (NSDictionary*)getSongInfo {
    return [_songs objectAtIndex:_track];
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
    _playlists = nil;
    _songs = nil;
    if(_audioPlayer != nil) {
        [self pauseSong];
        _audioPlayer = nil;
    }
}

@end
