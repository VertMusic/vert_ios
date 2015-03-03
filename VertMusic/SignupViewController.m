//
//  SignupViewController.m
//  VertMusic
//
//  Created by Glenn Contreras on 2/17/15.
//  Copyright (c) 2015 Glenn Contreras. All rights reserved.
//

#import "SignupViewController.h"
#import "DataModel.h"

@interface SignupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPasswordField;

@end

@implementation SignupViewController
{
    DataModel* _dataModel;
}

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize reEnterPasswordField = _reEnterPasswordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataModel = [DataModel getDataModel];
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    _reEnterPasswordField.delegate = self;
    _passwordField.secureTextEntry = YES;
    _reEnterPasswordField.secureTextEntry = YES;
}
- (IBAction)userWantsToSignUp:(id)sender {
    if ([_passwordField.text isEqualToString:_reEnterPasswordField.text]) {
        UIViewController* loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        [self addChildViewController:loginViewController];
        [self.view addSubview:loginViewController.view];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Password does not match." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

@end
