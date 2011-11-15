//
//  LoginPageNewViewController.m
//  Google Music Player
//
//  Created by Julius Parishy on 10/20/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "LoginPageNewViewController.h"

#define kWaitingForegroundInY   (75.0f)
#define kWaitingForegroundOutY (-96.0f)

#define kInfoTextFailed  (@"Failed to login. Tap to try again.")
#define kInfoTextSuccess (@"Logged in!")

@implementation LoginPageNewViewController

@synthesize usernameField;
@synthesize passwordField;

@synthesize waitingForeground;
@synthesize activityIndicator;
@synthesize faceView;
@synthesize infoLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
    [googleSecureAuth release];
    
    [super dealloc];
}

#pragma mark - Login steps

-(void)sendLoginRequest
{
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    
    [googleSecureAuth release];
    googleSecureAuth = [[GoogleSecureAuthentication alloc] initWithUsername:username password:password];
    
    [googleSecureAuth setDelegate:self];
    [googleSecureAuth authenticate];
    
    [self.activityIndicator startAnimating];
}

-(void)authenticationFailed:(GoogleSecureAuthentication *)auth error:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    
    self.faceView.image = [UIImage imageNamed:@"LoginFailed.png"];
    self.infoLabel.text = kInfoTextFailed;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        
        self.activityIndicator.alpha = 0.0f;
        
        self.faceView.alpha = 1.0f;
        self.infoLabel.alpha = 1.0f;
        
    }];
    
    logInSuccessful = NO;
}

-(void)authenticationSucceeded:(GoogleSecureAuthentication *)auth sessionToken:(NSString *)sessionToken
{
    [self.activityIndicator stopAnimating];
    
    self.faceView.image = [UIImage imageNamed:@"LoginSuccessful.png"];
    self.infoLabel.text = kInfoTextSuccess;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        
        self.activityIndicator.alpha = 0.0f;
        
        self.faceView.alpha = 1.0f;
        self.infoLabel.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
    
        [self performSelector:@selector(returnToFirstTab) withObject:nil afterDelay:1.0f];
    
    }];
    
    logInSuccessful = YES;
}

-(IBAction)foregroundButtonPressed:(id)sender
{
    if(logInSuccessful == NO)
    {
        // Woops, try again...
        [self animateWaitingForegroundOut];
    }
}

#pragma mark - View lifecycle
    
-(void)returnToFirstTab
{
    UITabBarController* tabBarController = (UITabBarController*)self.parentViewController;
    [tabBarController setSelectedIndex:0];
}

-(void)animateWaitingForegroundIn
{
    [UIView animateWithDuration:0.25f animations:^(void) {
       
        CGRect frame = self.waitingForeground.frame;
        frame.origin.y = kWaitingForegroundInY;
        
        self.waitingForeground.frame = frame;
    }];
}

-(void)animateWaitingForegroundOut
{
    [UIView animateWithDuration:0.25f animations:^(void) {
        
        CGRect frame = self.waitingForeground.frame;
        frame.origin.y = kWaitingForegroundOutY;
        
        self.waitingForeground.frame = frame;
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.usernameField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else
    {
        [self reset];
        
        [self animateWaitingForegroundIn];
        [self sendLoginRequest];
    }
    
    return NO;
}

-(void)reset
{
    // Reset the waiting foreground view just in case
    CGRect frame = self.waitingForeground.frame;
    frame.origin.y = kWaitingForegroundOutY;
    self.waitingForeground.frame = frame;
    
    self.activityIndicator.alpha = 1.0f;
    
    self.faceView.alpha = 0.0f;
    self.infoLabel.alpha = 0.0f;
    
    logInSuccessful = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self reset];
    
    // Bring up the keyboard
    [self.usernameField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
