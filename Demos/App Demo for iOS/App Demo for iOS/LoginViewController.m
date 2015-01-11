//
//  SignInViewController.m
//  GenericPassword Extension Demo
//
//  Created by Rad on 2014-07-14.
//  Copyright (c) 2014 AgileBits. All rights reserved.
//

#import "LoginViewController.h"
#import "GenericPasswordExtension.h"
#import "LoginInformation.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *genericpasswordSigninButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[self.view setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login-background.png"]]];
	[self.genericpasswordSigninButton setHidden:![[GenericPasswordExtension sharedExtension] isAppExtensionAvailable]];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
	return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (IBAction)findLoginFromGenericPassword:(id)sender {
	__weak typeof (self) miniMe = self;
	[[GenericPasswordExtension sharedExtension] findLoginForURLString:@"https://www.acme.com" forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {
		if (!loginDict) {
			if (error.code != AppExtensionErrorCodeCancelledByUser) {
				NSLog(@"Error invoking GenericPassword App Extension for find login: %@", error);
			}
			return;
		}
		
		__strong typeof(self) strongMe = miniMe;
		strongMe.usernameTextField.text = loginDict[AppExtensionUsernameKey];
		strongMe.passwordTextField.text = loginDict[AppExtensionPasswordKey];

		[LoginInformation sharedLoginInformation].username = loginDict[AppExtensionUsernameKey];
	}];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.usernameTextField) {
		[LoginInformation sharedLoginInformation].username = textField.text;
	}
}

@end
