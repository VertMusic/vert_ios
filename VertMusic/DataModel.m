//
//  LoginModel.m
//  VertMusic
//
//  Created by Glenn Contreras on 2/16/15.
//  Copyright (c) 2015 Glenn Contreras. All rights reserved.
//

#import "DataModel.h"

static DataModel* _dataModel;

@implementation DataModel
{
    NSURL *_url_login;
    NSURL *_url_playlists;
    NSDictionary* _session;
    NSDictionary* _playlists;
    BOOL _isLoggedIn;
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
    
    return self;
}

- (BOOL)loginWithUsername:(NSString*)username andPassword:(NSString*)password {
    
    NSDictionary *username_pass = @{@"session":@{@"username":username,@"password":password}};
    NSData *json = [NSJSONSerialization dataWithJSONObject:username_pass options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url_login];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:json];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *cred = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if (cred == nil) {
        NSLog(@"%@", cred);
        _isLoggedIn = false;
        return false;
    }
    _isLoggedIn = true;
    
    NSLog(@"%@", cred);
    _session = [cred valueForKey:@"session"];
    [self downloadPlayLists];
    
    return true;
}

- (BOOL)downloadPlayLists {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url_playlists];
    [request setHTTPMethod:@"GET"];
    //[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setValue:[_session valueForKey:@"accessToken"] forHTTPHeaderField:@"authorization"];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    _playlists = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if (_playlists == nil) {
        NSLog(@"%@", _playlists);
        return false;
    }
    NSLog(@"%@", _playlists);
    return true;
}

- (NSDictionary*)getSession {
    return _session;
}

- (NSArray*)getPlaylists {
    return [_playlists valueForKey:@"playlists"];
}

- (void)logout {
    _isLoggedIn = false;
    _session = nil;
    _playlists = nil;
}

@end
