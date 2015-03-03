//
//  LoginModel.h
//  VertMusic
//
//  Created by Glenn Contreras on 2/16/15.
//  Copyright (c) 2015 Glenn Contreras. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (weak, nonatomic) NSString *currentUserName;

+ (DataModel*)getDataModel;

- (DataModel*)init;

- (BOOL)loginWithUsername:(NSString*)username andPassword:(NSString*)password;

- (BOOL)downloadPlayLists;

- (NSDictionary*)getSession;

- (NSArray*)getPlaylists;

- (void)logout;

@end
