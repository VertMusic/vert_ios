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

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataModel = [DataModel getDataModel];
}

- (IBAction)play:(id)sender {
    [_dataModel playSong];
}

- (IBAction)pause:(id)sender {
    [_dataModel pauseSong];
}

- (IBAction)stop:(id)sender {
    [_dataModel stopSong];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
