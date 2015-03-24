//
//  DataModel.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import "DataModel.h"

static DataModel* _dataModel;

@implementation DataModel
{
    NSURL *_url_login;
    NSURL *_url_playlists;
    NSDictionary* _session;
    NSDictionary* _playlists;
    NSDictionary* _songs;
    BOOL _isLoggedIn;
    LoginViewController* _lvc;
    PlayListTableViewController* _pltvc;
    
}

+ (DataModel*)getDataModel {
    if (_dataModel == nil) {
        _dataModel = [[DataModel alloc] init];
    }
    return _dataModel;
}

- (DataModel*)init {
    _url_login = [NSURL URLWithString:@"http://192.168.56.101:8080/vert/data/session"];
    _url_playlists = [NSURL URLWithString:@"http://192.168.56.101:8080/vert/data/playlists"];
    _session = nil;
    _playlists = nil;
    _isLoggedIn = false;
    _lvc = nil;
    _pltvc = nil;
    
    return self;
}

- (void)synchLoginViewController:(LoginViewController*)lvc {
    _lvc = lvc;
}

-  (void)synchPlayListTableViewController:(PlayListTableViewController *)pltvc {
    _pltvc = pltvc;
}

- (void)loginWithUsername:(NSString*)username andPassword:(NSString*)password {
    NSError *error = nil;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSDictionary *username_pass = @{@"session":@{@"username":username,@"password":password}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:username_pass options:kNilOptions error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url_login];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:data];
    
    
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data
                                                          completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                                            {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    
                                                                    NSDictionary *cred = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                                    if (!error) {
                                                                        _session = [cred valueForKey:@"session"];
                                                                        [_lvc didLogin:true];
                                                                    }
                                                                    else {
                                                                        NSLog(@"%@", error);
                                                                        [_lvc didLogin:false];
                                                                    }
                                                                });
                                                                
                                                            
                                                            }];
        
        [uploadTask resume];
    }
    else {
        NSLog(@"%@", error);
    }
}

- (void)downloadPlayLists {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url_playlists];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[_session valueForKey:@"accessToken"] forHTTPHeaderField:@"authorization"];
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
                                                    downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if (!error) {
                                                                _playlists = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:NSJSONReadingAllowFragments error:nil];
                                                                [_lvc didFinishDownloadingPlaylist:true];
                                                            }
                                                            else {
                                                                NSLog(@"%@", error);
                                                                [_lvc didFinishDownloadingPlaylist:false];
                                                            }
                                                        });
                                                        
                                                    }];
    
    [downloadTask resume];
}

- (void)downloadSongsWithPlaylistIndex:(NSInteger)index {
    NSString* songURL = @"http://192.168.56.101:8080/vert/data/songs?";
    NSArray* playLists = [self getPlaylists];
    NSArray* songArray = [[playLists objectAtIndex:index] objectForKey:@"songs"];
    
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
    [request setValue:[_session valueForKey:@"accessToken"] forHTTPHeaderField:@"authorization"];
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
                                              downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if (!error) {
                                                          _songs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:NSJSONReadingAllowFragments error:nil];
                                                          [_pltvc didFinishDownloadingSongs:true];
                                                      }
                                                      else {
                                                          NSLog(@"%@", error);
                                                          [_pltvc didFinishDownloadingSongs:false];
                                                      }
                                                });
                                              }];
    
    [downloadTask resume];

}

- (NSDictionary*)getSession {
    return _session;
}

- (NSArray*)getPlaylists {
    return [_playlists valueForKey:@"playlists"];
}

- (NSArray*)getSongs {
    return [_songs valueForKey:@"songs"];
}

- (void)logout {
    _isLoggedIn = false;
    _session = nil;
    _playlists = nil;
}
@end
