//
//  DataProtocol.h
//  VertMusic
//
//  Created by Glenn Contreras on 4/14/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LOGIN,
    PLAYLISTS,
    SONGS
} TaskType;

@protocol DataProtocol <NSObject>

- (void)sessionDidFinish:(BOOL)successful taskType:(TaskType)type;

@end
