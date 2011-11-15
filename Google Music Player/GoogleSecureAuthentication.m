//
//  GoogleSecureAuthentication.m
//  GoogleSecureAuthenticationTest
//
//  Created by Julius Parishy on 9/22/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GoogleSecureAuthentication.h"

@interface GoogleSecureAuthentication ()

-(void)sendLoginPageRequest;
-(void)sendLoginPostRequest;
-(void)sendCheckCookieRequest;
-(void)sendHomePageRequest;

-(NSString*)parseFormValue:(NSString*)name response:(NSString*)response;

@end

@implementation GoogleSecureAuthentication

@synthesize username;
@synthesize password;
@synthesize delegate;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.username = aUsername;
        self.password = aPassword;
    }
    
    return self;
}

-(void)dealloc
{
    [loginPageRequest release];
    [loginPostRequest release];
    [cookieCheckRedirectRequest release];
    [homePageRequest release];
    
    [username release];
    [password release];
    
    [super dealloc];
}

+(BOOL)alreadyAuthenticated
{
    
    return true;
}

-(void)authenticate
{
    // Start the process
    [self sendLoginPageRequest];
}

-(void)sendLoginPageRequest
{
    NSURL* pageURL = [NSURL URLWithString:@"https://accounts.google.com/ServiceLogin?service=sj"];
    loginPageRequest = [[ASIHTTPRequest alloc] initWithURL:pageURL];
    
    [loginPageRequest setDelegate:self];
    [loginPageRequest startAsynchronous];
}

-(void)sendLoginPostRequest
{
    NSString* dsh = [self parseFormValue:@"dsh" response:loginPageRequest.responseString];
    NSString* galx = [self parseFormValue:@"GALX" response:loginPageRequest.responseString];
    
    NSURL* loginURL = [NSURL URLWithString:@"https://accounts.google.com/ServiceLoginAuth"];
    loginPostRequest = [[ASIFormDataRequest alloc] initWithURL:loginURL];
    
    [loginPostRequest setPostValue:self.username forKey:@"Email"];
    [loginPostRequest setPostValue:self.password forKey:@"Passwd"];
    [loginPostRequest setPostValue:dsh forKey:@"dsh"];
    [loginPostRequest setPostValue:galx forKey:@"GALX"];
    [loginPostRequest setPostValue:@"http://music.google.com/music/listen" forKey:@"continue"];
    [loginPostRequest setPostValue:@"http://music.google.com/music/listen" forKey:@"followup"];
    
    [loginPostRequest setValidatesSecureCertificate:NO];
    
    [loginPostRequest setDelegate:self];
    [loginPostRequest startAsynchronous];
}

-(void)sendCheckCookieRequest
{
    NSString* redirectLocation = [loginPostRequest.responseHeaders objectForKey:@"Location"];
    NSURL* redirectURL = [NSURL URLWithString:redirectLocation];
    
    cookieCheckRedirectRequest = [[ASIHTTPRequest alloc] initWithURL:redirectURL];
    
    [cookieCheckRedirectRequest setDelegate:self]; 
    [cookieCheckRedirectRequest startAsynchronous];
}

-(void)sendHomePageRequest
{
    NSURL* url = [NSURL URLWithString:@"http://music.google.com/music/listen"];
    homePageRequest = [[ASIHTTPRequest alloc] initWithURL:url];
    
    [homePageRequest setDelegate:self];
    [homePageRequest startSynchronous];
}

-(NSString*)parseFormValue:(NSString*)name response:(NSString*)response
{
    NSRange nameRange = [response rangeOfString:[NSString stringWithFormat:@"%@\"", name]];
    //NSLog(@"Found form value at index: %i", nameRange.location);
    
    NSRange valueRange = [response rangeOfString:@"value=\"" options:0 range:NSMakeRange(nameRange.location + nameRange.length, 256)];
    //NSLog(@"Value: %i", valueRange.location);
    
    NSRange endRange = [response rangeOfString:@"\"" options:0 range:NSMakeRange(valueRange.location + valueRange.length, 256)];
    //NSLog(@"End: %i", endRange.location);
    
    NSString* formValue = [response substringWithRange:NSMakeRange(valueRange.location + valueRange.length, endRange.location - (valueRange.location + valueRange.length))];
    
    //NSLog(@"\n\n%@\n\n", [response substringWithRange:NSMakeRange(valueRange.location - 100, 200)]);
    
   // NSLog(@"%@ = %@", name, formValue);
    
    return formValue;
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    /*
    NSDictionary* headers = [request requestHeaders];
    for(NSString* key in [headers allKeys])
    {
        NSLog(@"Request Header - %@: %@", key, [headers objectForKey:key]);
    }*/
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    /*
    if(request == loginPostRequest)
        NSLog(@"Post response headers");
    
    for(NSString* key in [responseHeaders allKeys])
    {
        NSLog(@"Header - %@: %@", key, [responseHeaders objectForKey:key]);
    } */
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
   // NSLog(@"Redirecting to: %@", newURL);
    
    if(request == loginPostRequest)
    {
        [loginPostRequest cancel];
        [self sendCheckCookieRequest];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //if(request == loginPostRequest)
        //NSLog(@"post finished");
    
    if(request == loginPageRequest)
    {
       // NSLog(@"[STATUS] Downloaded login page.");
        if(loginPageRequest.responseStatusCode == 200)
        {
            [self sendLoginPostRequest];
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(authenticationFailed:error:)])
            {
                NSError* error = [NSError errorWithDomain:@"kGoogleSecureAuthenticationErrorDomain" code:1 userInfo:nil];
                [self.delegate authenticationFailed:self error:error];
            }
        }
    }
    else if(request == loginPostRequest)
    {
        if(loginPostRequest.responseStatusCode == 302)
        {
            //NSLog(@"[STATUS] POST'd login info, was directed.");
            [self sendCheckCookieRequest];
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(authenticationFailed:error:)])
            {
                NSError* error = [NSError errorWithDomain:@"kGoogleSecureAuthenticationErrorDomain" code:2 userInfo:nil];
                [self.delegate authenticationFailed:self error:error];
            }
        }
    }
    else if(request == cookieCheckRedirectRequest)
    {
        if(cookieCheckRedirectRequest.responseStatusCode == 200)
        {
            //NSLog(@"[STATUS] Passed cookie check, getting home page.");
            [self sendHomePageRequest];
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(authenticationFailed:error:)])
            {
                NSError* error = [NSError errorWithDomain:@"kGoogleSecureAuthenticationErrorDomain" code:3 userInfo:nil];
                [self.delegate authenticationFailed:self error:error];
            }
        }
    }
    else if(request == homePageRequest)
    {
        /*
        NSDictionary* headers = homePageRequest.responseHeaders;
        for(NSString* key in headers)
        {
            NSLog(@"Home Page Header - %@: %@", key, [headers objectForKey:key]);
        } */
        
        NSString* xt = nil;
        
        NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for(NSHTTPCookie* cookie in cookies)
        {
            if([cookie.name isEqualToString:@"xt"])
            {
                xt = cookie.value;
            }
        }
        
       // NSLog(@"[STATUS] Got session token (xt=%@)", xt);
        
        if(xt == nil)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(authenticationFailed:error:)])
            {
                NSError* error = [NSError errorWithDomain:@"kGoogleSecureAuthenticationErrorDomain" code:4 userInfo:nil];
                [self.delegate authenticationFailed:self error:error];
            }
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(authenticationSucceeded:sessionToken:)])
            {
                [self.delegate authenticationSucceeded:self sessionToken:xt];
            }
        }
        
        /*
         NSURL* songsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://music.google.com/music/services/loadalltracks?u=0&xt=%@", xt]];
         ASIFormDataRequest* songsRequest = [ASIFormDataRequest requestWithURL:songsURL];
         [songsRequest setPostValue:@"fuck" forKey:@"you"];
         [songsRequest startAsynchronous]; */
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(authenticationFailed:error:)])
    {
        // TODO: Fill this with legitimate information
        [self.delegate authenticationFailed:self error:nil];
    }
}

- (void)requestRedirected:(ASIHTTPRequest *)request
{
}

@end
