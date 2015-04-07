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
    _passwordField.secureTextEntry = YES;
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    self.activityIndicator.hidden = YES;
}

- (void)startActivityIndicator {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)stopActivityIndicator {
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (IBAction)userWantsToLogin:(id)sender {
    [self startActivityIndicator];
    _dataModel = [DataModel getDataModel];
    _dataModel.delegate = self;
    [_dataModel login:@{@"session":@{@"username":_usernameField.text,@"password":_passwordField.text}}];
}

- (void)failedToLogin {
    [self showError:@"Incorrect username or password."];
    [self stopActivityIndicator];
}

- (void)didDownloadPlaylists:(BOOL)isSuccessful {
    if (isSuccessful) [self loadPlaylists];
    else [self showError:@"Could not download playlists."];
}

- (void)showError:(NSString*)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alertView show];
    [self stopActivityIndicator];
}

- (void)loadPlaylists {
    UITabBarController* tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self addChildViewController:tabBarController];
    [self.view addSubview:tabBarController.view];
    [self stopActivityIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

@end
