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
@property (weak, nonatomic) IBOutlet UILabel *songDescription;

@end

@implementation PlaySongViewController {
    DataModel* _dataModel;
}

@synthesize songDescription;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _dataModel = [DataModel getDataModel];
    songDescription.text = [_dataModel getSongTitle];
}

- (IBAction)play:(id)sender {
    [_dataModel playSong];
}

- (IBAction)pause:(id)sender {
    [_dataModel pauseSong];
}

- (IBAction)skip:(id)sender {
    [_dataModel skipSong];
    songDescription.text = [_dataModel getSongTitle];
}

- (IBAction)prev:(id)sender {
    [_dataModel prevSong];
    songDescription.text = [_dataModel getSongTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
