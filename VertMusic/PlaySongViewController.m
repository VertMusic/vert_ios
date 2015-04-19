//
//  PlaySongViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/25/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import "PlaySongViewController.h"
#import "DataModel.h"

@interface PlaySongViewController()
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;

@end

@implementation PlaySongViewController {
    DataModel* _dataModel;
    NSDictionary* _songInfo;
    BOOL _playingSong;
}

@synthesize songTitle, songArtist;

- (void)viewDidLoad {
    [super viewDidLoad];
    _playingSong = NO;
}


- (void)updateSongInfo {
    _songInfo = [_dataModel getSongInfo];
    songTitle.text = [_songInfo objectForKey:@"title"];
    songArtist.text = [_songInfo objectForKey:@"artist"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _dataModel = [DataModel getDataModel];
    [self updateSongInfo];
}

- (IBAction)play:(id)sender {
    [_dataModel togglePlaySong];
    
    if (_playingSong) {
        UIImage* play = [UIImage imageNamed:@"Play_button_unpressed"];
        [sender setImage:play forState:UIControlStateNormal];
    }
    else {
        UIImage* pause = [UIImage imageNamed:@"Pause_button"];
        [sender setImage:pause forState:UIControlStateNormal];
    }
    _playingSong = !_playingSong;
}

- (IBAction)skip:(id)sender {
    [_dataModel skipSong];
    [self updateSongInfo];
}

- (IBAction)prev:(id)sender {
    [_dataModel prevSong];
    [self updateSongInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
