//
//  LoginViewController.h
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

- (void)failedToLogin;

- (void)didDownloadPlaylists:(BOOL)isSuccessful;

@end
