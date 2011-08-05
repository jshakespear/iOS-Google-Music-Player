//
//  LoginViewController.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize usernameCell;
@synthesize passwordCell;

@synthesize loginButtonCell;

@synthesize usernameField;
@synthesize passwordField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [webView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)loginButtonPressed:(id)sender
{
    [self sendGoogleLoginRequest];
  
    
   // [webView 
    
  //  NSString* string = [webView stringByEvaluatingJavaScriptFromString:@"document.elements[\'Email\'].value = \'Test\'"];
    
   // [self.view addSubview:webView];
    
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(void)sendGoogleLoginRequest
{
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/accounts/ServiceLoginAuth"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSString* galx = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('GALX').item(0).value"];
    NSLog(@"%@", galx);
    
    NSString* body = [[NSString alloc] initWithFormat:@"Email=%@&Passwd=%@&GALX=%@&continue=http://music.google.com/",username, password, galx];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [body release];
    
    [responseData release];
    responseData = [[NSMutableData alloc] init];
    
    clientLoginConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(!clientLoginConnection)
    {
        NSLog(@"Failed to create sign in connection.");
    }
    
    loginSuccessful = NO;
}

-(void)saveCookies
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for(NSHTTPCookie* cookie in cookies)
    {
        NSLog(@"Saved cookie %@", cookie.name);
        [dictionary setValue:cookie.value forKey:cookie.name];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dictionary forKey:@"GMCookies"];
    [defaults synchronize];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"Status: %i", httpResponse.statusCode);
    
    if(connection == clientLoginConnection)
    {
    }
    else if(connection == musicTestConnection)
    {
        NSDictionary* headers = [httpResponse allHeaderFields];
        NSString* cookies = [headers objectForKey:@"Set-Cookie"];
        
        NSLog(@"Cookies: %@", cookies);
        
        if([cookies rangeOfString:@"xt"].location != NSNotFound)
        {
            loginSuccessful = YES;
            
            NSURL* url = [NSURL URLWithString:@"music.google.com"];
            NSArray* cookiesToSet = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:url];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookiesToSet forURL:url mainDocumentURL:nil];
        }
        else
        {
            loginSuccessful = NO;
        }
    }

   /* NSLog(@"Got response: %@ (%lld bytes expected)", [response MIMEType], [response expectedContentLength]); */
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSString* response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
   // NSLog(@"Response:\n%@\n", response);
    [response release];

    if(connection == clientLoginConnection)
    {
       // if(loginSuccessful)
       // {
            musicTestConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://music.google.com/music/listen"]] delegate:self];
            
            [responseData release];
            responseData = [[NSMutableData alloc] init];
      /*  }
        else
        {
            NSLog(@"Response:\n%@\n", response);
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to login to Google Music" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } */
    }
    else if(connection == musicTestConnection)
    {
    
        if(loginSuccessful)
        {
            NSString* response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            //NSLog(@"Music Response:\n%@\n", response);
            [response release];
            
            [self saveCookies];
        }
        else
        {
           // NSLog(@"Response:\n%@\n", response);
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to login to Google Music" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } 
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed. Reason: %@", [error localizedDescription]);
    
    NSDictionary* info = [error userInfo];
    for(id value in [info allValues])
    {
        NSLog(@"Error Info: %@", value);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.usernameField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.usernameField becomeFirstResponder];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView setDelegate:self];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/accounts/ServiceLogin?service=sj"]]];
    
    loginSuccessful = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.usernameCell = nil;
    self.passwordCell = nil;
    
    self.loginButtonCell = nil;
    
    self.usernameField = nil;
    self.passwordField = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
        return 2;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell = self.usernameCell;
        }
        else
        {
            cell = self.passwordCell;
        }
    }
    else
    {
        cell = self.loginButtonCell;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
