//
//  ViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 2/16/15.
//  Copyright (c) 2015 Glenn Contreras. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController
{
    DataModel* _dataModel;
}

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set up the data
    _dataModel = [DataModel getDataModel];
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    _passwordField.secureTextEntry = YES;
}

- (IBAction)userWantsToLogin:(id)sender {
    NSLog(@"username: %@ password: %@", _usernameField.text, _passwordField.text);
    if ([_dataModel loginWithUsername:_usernameField.text andPassword:_passwordField.text]) {
        UITabBarController* tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        [self addChildViewController:tabBarController];
        [self.view addSubview:tabBarController.view];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"No match for username or password." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
