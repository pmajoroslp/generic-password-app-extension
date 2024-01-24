# GenericPassword App Extension

Welcome! With just a few lines of code, your app can add GenericPassword support, enabling your users to:

1. Access their Logins from Password Managers like LastPass and 1Password to automatically fill your login page.
2. Use the Strong Password Generators to create unique passwords during registration, and save the new Login within Password Managers.
3. Quickly fill Generic Password Manager Logins directly into web views.

Empowering your users to use strong, unique passwords has never been easier. Let's get started!

## Just Give Me the Code (TL;DR)

You might be looking at this 13 KB README and think integrating with GenericPassword is very complicated. Nothing could be further from the truth!

If you're the type that just wants the code, here it is:

* [GenericPasswordExtension.h](https://raw.githubusercontent.com/joelastpass/generic-password-app-extension/master/GenericPasswordExtension.h)
* [GenericPasswordExtension.m](https://raw.githubusercontent.com/joelastpass/generic-password-app-extension/master/GenericPasswordExtension.m)

Simply include these two files in your project, add a button with a [GenericPassword login image](https://github.com/joelastpass/generic-password-app-extension/tree/master/GenericPassword.xcassets) on it to your view, set the button's action to call the appropriate GenericPasswordExtension method, and you're all set!


## Running the Sample Apps

Adding GenericPassword support to your app is easy. To demonstrate how it works, we have two sample apps for iOS that showcase all of the GenericPassword features.


### Step 1: Download the Source Code and Sample Apps

To get started, download the GenericPassword Extension project from https://github.com/joelastpass/generic-password-app-extension/archive/master.zip, or [clone it from GitHub](https://github.com/joelastpass/generic-password-app-extension).

Inside the downloaded folder, you'll find the resources needed to integrate with GenericPassword, such as images and sample code. The sample code includes two apps from ACME Corporation: one that demonstrates how to integrate the GenericPassword Login and Registration features, as well as a web browser that showcases the web view Filling feature.

The GenericPassword extension is also available via cocoapods, simply add `pod 'GenericPasswordExtension', '~> 1.0.0'` to your Podfile, run `pod install` from your project directory and you're ready to go.

### Step 2: Install the Latest versions of GenericPassword & Xcode

The sample project depends upon having the latest version of Xcode 6, as well as the latest version of GenericPassword installed on your iOS device.

To install LastPass, you will need to download it from the [App Store](https://itunes.apple.com/us/app/lastpass-for-premium-customers/id324613447?mt=8).
To install 1Password, you will need to download it from the [App Store](http://j.mp/1PasSITE). 

### Step 3: Run the Apps

Open `GenericPassword Extension Demos` Xcode workspace from within the `Demos` folder with Xcode 6, and then select the `ACME` target and set it to run your iOS device:

Since you will not have a Password Manager running within your iOS Simulator, it is important that you run on your device.

If all goes well, The ACME app will launch and you'll be able to test the GenericPassword App Extension. The first time you attempt to access the GenericPassword extension you will need to enable it by tapping on the _More_ button in the activity sheet and then enable the _GenericPassword_ item in the _Activities_ list. If the GenericPassword icons are missing, it likely means you do not have GenericPassword installed.

Back in Xcode you can change the scheme to ACME Browser to test the web view filling feature.

## Integrating GenericPassword With Your App

Once you've verified your setup by testing the sample applications, it is time to get your hands dirty and see exactly how to add GenericPassword into your app.

Be forewarned, however, that there is not much code to get dirty with. If you were looking for an SDK to spend days of your life on, you'll be sorely disappointed.


### Add GenericPassword Files to Your Project

Add the `GenericPasswordExtension.h`, `GenericPasswordExtension.m`, and `GenericPassword.xcassets` to your project and import `GenericPasswordExtension.h` in your view contoller that implements the action for the GenericPassword button.


### Use Case #1: Native App Login

In this use case we'll learn how to enable your existing users to fill their credentials into your native app's login form. If your application is using a web view to login (i.e. OAuth), you'll want to follow the web view integration steps in Use Case #3.

The first step is to add a UIButton to your login page. Use an existing GenericPassword image from the _GenericPassword.xcassets_ catalog so users recognize the button.

You'll need to hide this button (or educate users on the benefits of strong, unique passwords) if no password manager is installed. You can use `isAppExtensionAvailable` to determine availability and hide the button if it isn't. For example:

```objective-c
-(void)viewDidLoad {
	[super viewDidLoad];
	[self.genericpasswordSigninButton setHidden:![[GenericPasswordExtension sharedExtension] isAppExtensionAvailable]];
}
```

Note that `isAppExtensionAvailable` looks to see if any app is installed that supports the generic `org-appextension-feature-password-management` feature. Any application that supports password management actions can be used.

Next we need to wire up the action for this button to this method in your UIViewController:

```objective-c
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
	}];
}
```

Aside from the [weak/strong self dance](http://dhoerl.wordpress.com/2013/04/23/i-finally-figured-out-weakself-and-strongself/), this code is pretty straight forward:

1. Provide a `URLString` that uniquely identifies your service. For example, if your app required a Twitter login, you would pass in `@"https://twitter.com"`. See _Best Practices_ for details.
2. Pass in the `UIViewController` that you want the share sheet to be presented upon.
3. Provide a completion block that will be called when the user finishes their selection. This block is guaranteed to be called on the main thread.
4. Extract the needed information from the login dictionary and update your UI elements.


### Use Case #2: New User Registration

Allow your users to access GenericPassword directly from your registration page so they can generate strong, unique passwords. GenericPassword will also save the login for future use, allowing users to easily log into your app on their other devices. The newly saved login and generated password are returned to you so you can update your UI and complete the registration.

Adding GenericPassword to your registration screen is very similar to adding GenericPassword to your login screen. In this case you'll wire the GenericPassword button to an action like this:

```objective-c
- (IBAction)saveLoginToGenericPassword:(id)sender {
	NSDictionary *newLoginDetails = @{
		AppExtensionTitleKey: @"ACME",
		AppExtensionUsernameKey: self.usernameTextField.text ? : @"",
		AppExtensionPasswordKey: self.passwordTextField.text ? : @"",
		AppExtensionNotesKey: @"Saved with the ACME app",
		AppExtensionSectionTitleKey: @"ACME Browser",
		AppExtensionFieldsKey: @{
			  @"firstname" : self.firstnameTextField.text ? : @"",
			  @"lastname" : self.lastnameTextField.text ? : @""
			  // Add as many string fields as you please.
		}
	};
	
	// Password generation options are optional, but are very handy in case you have strict rules about password lengths
	NSDictionary *passwordGenerationOptions = @{
		AppExtensionGeneratedPasswordMinLengthKey: @(6),
		AppExtensionGeneratedPasswordMaxLengthKey: @(50)
	};

	__weak typeof (self) miniMe = self;

	[[GenericPasswordExtension sharedExtension] storeLoginForURLString:@"https://www.acme.com" loginDetails:newLoginDetails passwordGenerationOptions:passwordGenerationOptions forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {

		if (!loginDict) {
			if (error.code != AppExtensionErrorCodeCancelledByUser) {
				NSLog(@"Failed to use GenericPassword App Extension to save a new Login: %@", error);
			}
			return;
		}

		__strong typeof(self) strongMe = miniMe;

		strongMe.usernameTextField.text = loginDict[AppExtensionUsernameKey] ? : @"";
		strongMe.passwordTextField.text = loginDict[AppExtensionPasswordKey] ? : @"";
		strongMe.firstnameTextField.text = loginDict[AppExtensionReturnedFieldsKey][@"firstname"] ? : @"";
		strongMe.lastnameTextField.text = loginDict[AppExtensionReturnedFieldsKey][@"lastname"] ? : @"";
		// retrieve any additional fields that were passed in newLoginDetails dictionary
	}];
}
```

You'll notice that we're passing a lot more information into GenericPassword than just the `URLString` key used in the sign in example. This is because at the end of the password generation process, GenericPassword will create a brand new login and save it. It's not possible for GenericPassword to ask your app for additional information later on, so we pass in everything we can before showing the password generator screen.

An important thing to notice is the `AppExtensionURLStringKey` is set to the exact same value we used in the login scenario. This allows users to quickly find the login they saved for your app the next time they need to sign in.

### Use Case #3: Change Password

Allow your users to easily change passwords for saved logins in GenericPassword directly from your change password page. The updated login along with the old and the newly generated are returned to you so you can update your UI and complete the password change process. If no matching login is found in GenericPassword, the user will be prompted to save a new login instead.

Adding GenericPassword to your change password screen is very similar to adding GenericPassword to your login and registration screens. In this case you'll wire the GenericPassword button to an action like this:

```objective-c
- (IBAction)changePasswordInGenericPassword:(id)sender {
	NSString *changedPassword = self.freshPasswordTextField.text ? : @"";
	NSString *oldPassword = self.oldPasswordTextField.text ? : @"";
	NSString *username = [LoginInformation sharedLoginInformation].username ? : @"";

	NSDictionary *loginDetails = @{
									  AppExtensionTitleKey: @"ACME",
									  AppExtensionUsernameKey: username, // GenericPassword will prompt the user to create a new item if no matching logins are found with this username.
									  AppExtensionPasswordKey: changedPassword,
									  AppExtensionOldPasswordKey: oldPassword,
									  AppExtensionNotesKey: @"Saved with the ACME app",
									};

	// Password generation options are optional, but are very handy in case you have strict rules about password lengths
	NSDictionary *passwordGenerationOptions = @{
		AppExtensionGeneratedPasswordMinLengthKey: @(6),
		AppExtensionGeneratedPasswordMaxLengthKey: @(50)
	};

	__weak typeof (self) miniMe = self;

	[[GenericPasswordExtension sharedExtension] changePasswordForLoginForURLString:@"https://www.acme.com" loginDetails:loginDetails passwordGenerationOptions:passwordGenerationOptions forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {
		if (!loginDict) {
			if (error.code != AppExtensionErrorCodeCancelledByUser) {
				NSLog(@"Error invoking GenericPassword App Extension for find login: %@", error);
			}
			return;
		}

		__strong typeof(self) strongMe = miniMe;
		strongMe.oldPasswordTextField.text = loginDict[AppExtensionOldPasswordKey];
		strongMe.freshPasswordTextField.text = loginDict[AppExtensionPasswordKey];
		strongMe.confirmPasswordTextField.text = loginDict[AppExtensionPasswordKey];
	}];
}
```

### Use Case #4: Web View Support

The GenericPassword App Extension is not limited to filling native UIs. With just a little bit of extra effort, users can fill `UIWebView`s and `WKWebView`s within your application as well.

Simply add a button to your UI with its action assigned to this method in your web view's UIViewController:

```objective-c
- (IBAction)fillUsingGenericPassword:(id)sender {
	[[GenericPasswordExtension sharedExtension] fillLoginIntoWebView:self.webView forViewController:self sender:sender completion:^(BOOL success, NSError *error) {
		if (!success) {
			NSLog(@"Failed to fill login in webview: <%@>", error);
		}
	}];
}
```

GenericPassword will take care of all the details of collecting information about the currently displayed page, allow the user to select the desired login, and then fill the web form details within the page.


## Projects supporting iOS 7.1 and earlier

If your project's Deployment Target is earlier than iOS 8.0, please make sure that you link to the `MobileCoreServices` and `WebKit` frameworks.

<a href="https://vimeo.com/102142106" target="_blank"><img src="https://www.evernote.com/shard/s340/sh/7547419d-6c49-4b45-bdb1-575c28678164/49cb7e0c1f508d1f67f5cf0361d58d3a/deep/0/WebView-Demo-for-iOS.xcodeproj.png" width="640"></a>

## Best Practices

* Use the same `URLString` during Registration and Login.
* Ensure your `URLString` is set to your actual service so your users can easily find their logins within the main GenericPassword app.
* You should only ask for the login information of your own service or one specific to your app. Giving a URL for a service which you do not own or support may seriously break the customer's trust in your service/app.
* If you don't have a website for your app you should specify your bundle identifier as the `URLString`, like so: app://bundleIdentifier (e.g. app://com.acme.awesome-app).
* [Send us an icon](mailto:support+appex@agilebits.com) to use for our Rich Icon service so the user can see your lovely icon while creating new items.
* Use the icons provided in the `GenericPassword.xcassets` asset catalog so users are familiar with what it will do. Contact us if you'd like additional sizes or have other special requirements.
* Enable users to set GenericPassword as their default browser for external web links.
* On your registration page, pre-validate fields before calling GenericPassword. For example, display a message if the username is not available so the user can fix it before activating GenericPassword.


## References

If you open up GenericPasswordExtension.m and start poking around, you'll be interested in these references.

* [Apple Extension Guide](https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/ExtensibilityPG/index.html#//apple_ref/doc/uid/TP40014214)
* [NSItemProvider](https://developer.apple.com/library/prerelease/ios/documentation/Foundation/Reference/NSItemProvider_Class/index.html#//apple_ref/doc/uid/TP40014351), [NSExtensionItem](https://developer.apple.com/library/prerelease/ios/documentation/Foundation/Reference/NSExtensionItem_Class/index.html#//apple_ref/doc/uid/TP40014375), and [UIActivityViewController](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIActivityViewController_Class/index.html#//apple_ref/doc/uid/TP40011976) class references.


## Contact Us

Contact us, please! We'd love to hear from you about how you integrated GenericPassword within your app, how we can further improve things.

You can reach LastPass at support@LastPass.com, or if you prefer, [@LastPass](https://twitter.com/LastPass) on Twitter.
