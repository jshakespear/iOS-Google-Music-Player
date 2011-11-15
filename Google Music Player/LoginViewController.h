//
//  LoginViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GoogleSecureAuthentication.h"

@interface LoginViewController : UITableViewController<GoogleSecureAuthenticationDelegate> {
    NSMutableData* responseData;
    
    NSURLConnection* clientLoginConnection;
    NSURLConnection* musicTestConnection;
    
    BOOL loginSuccessful;
    
    UIWebView* webView;
    
    GoogleSecureAuthentication* googleAuth;
}

@property (nonatomic, retain) IBOutlet UITableViewCell* usernameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* passwordCell;

@property (nonatomic, retain) IBOutlet UITableViewCell* loginButtonCell;

@property (nonatomic, retain) IBOutlet UITextField* usernameField;
@property (nonatomic, retain) IBOutlet UITextField* passwordField;

-(IBAction)loginButtonPressed:(id)sender;

-(void)sendGoogleLoginRequest;

-(void)saveCookies;

@end
