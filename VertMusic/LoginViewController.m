//
//  LoginViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 3/3/15.
//  Copyright (c) 2015 Vert. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation LoginViewController {
    DataModel* _dataModel;
}

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataModel = [DataModel getDataModel];
    [_dataModel synchLoginViewController:self];
    _passwordField.secureTextEntry = YES;
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    self.activityIndicator.hidden = YES;
    
}

- (IBAction)userWantsToLogin:(id)sender {
    [_dataModel loginWithUsername:_usernameField.text andPassword:_passwordField.text];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)didLogin:(BOOL)successful {
    NSLog(@"DidFinish");
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    if (successful) {
        [_dataModel downloadPlayLists];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"No match for username or password." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)didFinishDownloadingPlaylist:(BOOL)successful {
    NSLog(@"DidFinish");
    if (successful) {
        UITabBarController* tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        [self addChildViewController:tabBarController];
        [self.view addSubview:tabBarController.view];
    }
    else {
        NSLog(@"Sorry could not download playlists");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
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
