//
//  LoginPageNewViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 10/20/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GoogleSecureAuthentication.h"

@interface LoginPageNewViewController : UIViewController<GoogleSecureAuthenticationDelegate> {
    
    GoogleSecureAuthentication* googleSecureAuth;
    BOOL logInSuccessful;
}

@property (nonatomic, retain) IBOutlet UITextField* usernameField;
@property (nonatomic, retain) IBOutlet UITextField* passwordField;

@property (nonatomic, retain) IBOutlet UIView* waitingForeground;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView* faceView;
@property (nonatomic, retain) IBOutlet UILabel* infoLabel;

-(IBAction)foregroundButtonPressed:(id)sender;

-(void)returnToFirstTab;

-(void)reset;
-(void)animateWaitingForegroundIn;
-(void)animateWaitingForegroundOut;

-(void)sendLoginRequest;

@end
