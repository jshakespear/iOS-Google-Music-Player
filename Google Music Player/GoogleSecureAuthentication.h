//
//  GoogleSecureAuthentication.h
//  GoogleSecureAuthenticationTest
//
//  Created by Julius Parishy on 9/22/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

/*
 * Theoretical steps:
 *
 * 1. Download the login page.
 * 2. Parse the form values needed
 *      a. dsh
 *      b. GALX
 * 3. Post to the login URL, using POST values:
 *      a. Email
 *      b. Passwd
 *      c. dsh
 *      d. GALX
 *      e. continue
 *      f. followup
 * 4. Reponse should be the address passed as 'continue' above.
 * 5. Parse cookies for session.
 *
 * Now to see what really happens.
 *
 * Okay:
 * Load Login Page -> Parse Needed Values -> POST to login URL ->
 * Redirected to CheckCookie page, load it -> On 200 (Success) Load Main Page -> Get Session cookie (xt) ->
 * DO WHATEVER YOU WANT, YO.
 */

@class GoogleSecureAuthentication;

@protocol GoogleSecureAuthenticationDelegate<NSObject>

-(void)authenticationFailed:(GoogleSecureAuthentication*)auth error:(NSError*)error;
-(void)authenticationSucceeded:(GoogleSecureAuthentication*)auth sessionToken:(NSString*)sessionToken;

@end

@interface GoogleSecureAuthentication : NSObject<ASIHTTPRequestDelegate> {
    
    ASIHTTPRequest* loginPageRequest;
    ASIFormDataRequest* loginPostRequest;
    
    ASIHTTPRequest* cookieCheckRedirectRequest;
    ASIHTTPRequest* homePageRequest;
    
    NSString* username;
    NSString* password;
    
    id<GoogleSecureAuthenticationDelegate> delegate;
}

@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;

@property (nonatomic, assign) id<GoogleSecureAuthenticationDelegate> delegate;

-(id)initWithUsername:(NSString*)aUsername password:(NSString*)aPassword;

-(void)authenticate;

+(BOOL)alreadyAuthenticated;

@end
