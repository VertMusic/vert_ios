//
//  SettingsViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import "SettingsViewController.h"
#import "DataModel.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    DataModel* _dataModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataModel = [DataModel getDataModel];
}

- (IBAction)userWantsToLogout:(id)sender {
    [_dataModel logout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
