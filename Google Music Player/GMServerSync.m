//
//  GMServerSync.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMServerSync.h"

#import "GMAlbum.h"

#import "SBJson/SBJson.h"

#import <MessageUI/MessageUI.h>

// Send POST command to this URL to obtain a JSON response containing all the songs in the users
// library. Must append the xt HTTP cookie for it to work.
#define kGMLoadTracksURL (@"http://music.google.com/music/services/loadalltracks?u=0&xt=")

#define kGMSessionCookieURL (@"music.google.com")
#define kGMSessionCookieName (@"xt")

#define kGMPlaylistNameKey (@"playlistId")
#define kGMPlaylistKey (@"playlist")

@interface GMServerSync ()

-(void)showErrorAlert:(NSString*)error;

-(void)postErrorNotificationForObjectLoader:(RKObjectLoader*)objectLoader error:(NSError*)error;

@end

@implementation GMServerSync

@synthesize songCache;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)synchronize
{
    /*
    NSString* xt = nil;    
    NSMutableString* cookiesHeader = [NSMutableString string];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* cookies = [defaults objectForKey:@"GMCookies"];
    
    //NSArray* neededCookies = [NSArray arrayWithObjects:@"xt", @"sjpref", @"NID", @"PREF", @"HSID", @"APISID", @"SID", @"sjsaid", nil];
    
    NSArray* neededCookies = [NSArray arrayWithObjects:@"xt", @"HSID", @"APISID", @"SID", nil];
    
    if(cookies != nil)
    {
        for(NSString* key in [cookies allKeys])
        {
           // if([neededCookies containsObject:key] == NO)
           //     continue;
            
          //  NSLog(@"Added cookie: %@", key);
            
            //
            // NOTE:
            //
            // Cookies that are IMPORTANT
            //
            // xt
            // SID
            // APISID
            // HSID
            //
            // to be continued when I figure out why...
            
            
//            if([key isEqualToString:@"SID"])
//            {
//                [cookiesHeader appendString:@"SID=DQAAANcAAAC3LgnFmmWqfkQStcZ3UCL4YjdKH0seHITl7SImjBTCPYQtc5KG2bZ3S5Ty35tO4HQUayMZkYMglPAuThdlE3aYmICRsfRgew5kEk5EXF8Kiutr7Ac7BLrknhTX3FOCAt0eyi_-9yEwC9xdWXoNctLil6gYVZHbiuOThCJgF2AVbWGEOD9s0LKTTyFDBKSbvmNVOdF0HhuKY88LAi5SBCpEIHQNtYyW99HohkYOu3DFc2o1Moq_CjVD5l--UOPt47wGlCkslmr47-sYLiDutcwhBrzmJ901SfWpSm3mqcBWgw;"];
//            }
//            else if([key isEqualToString:@"APISID"])
//            {
//                [cookiesHeader appendString:@"APISID=aa0CLorwC0o4Vhse/AJzJO7skukWZJBrxp;"];
//            }
//            else if([key isEqualToString:@"HSID"])
//            {
//                [cookiesHeader appendString:@"HSID=Aqr_Kjm2vRlYeSyoh;"];
//            }
            if([key isEqualToString:@"xt"])
            {
                xt = [cookies valueForKey:key];
               // xt = @"AM-WbXhWUcdoBQPE5q-8pDDEG4yzuDklHw:1316640305";
                
                //[cookiesHeader appendFormat:@"xt=AM-WbXhWUcdoBQPE5q-8pDDEG4yzuDklHw:1316640305; "];
            }
            //else
            
            NSLog(@"Using needed cookie: %@ (%@)", key, [cookies objectForKey:key]);
            
            [cookiesHeader appendFormat:@"%@=%@; ", key, [cookies objectForKey:key]];
        }
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
    
    if(xt == nil)
    {
        [self showErrorAlert:@"You are not logged in to Google Music!"];
        return;
    }

    //[cookiesHeader appendString:@"sjpref=v:100|;"];
    //[cookiesHeader appendString:@"NID=51=nraeSokfdficUfsBWDqny9xazgQIfX7gmSefsH7r3tQAdKj6eIzqF3WefFwdmQ5McCMr8z62bRptkc4BBL3OHpBI92WGz3DH-gelhpdal3iIaGaGv8kI2u7UcUgw8baM; PREF=ID=44794f6f8656d2f9:U=0cf1a049125d9829:FF=0:TM=1316639573:LM=1316639574:S=jDOXn8qhJIFOvOi8;"];
    
    // Replicate a genuine HTTP request
// [[RKObjectManager sharedManager].client setValue:cookiesHeader forHTTPHeaderField:@"Cookie"];
    //[[RKObjectManager sharedManager].client setValue:@"music.google.com" forHTTPHeaderField:@"Host"];
    //[[RKObjectManager sharedManager].client setDisableCertificateValidation:YES];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithKeysAndObjects:@"u", @"0", @"xt", xt, nil];
    NSString* path = [NSString stringWithFormat:@"/music/services/loadalltracks?u=0&xt=%@", xt];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:path delegate:self block:^(RKObjectLoader* loader) {
        loader.method = RKRequestMethodPOST;
        loader.HTTPBodyString = @"json: { } ";
        //loader.additionalHTTPHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"http://music.google.com", @"Origin", @"http://music.google.com/music/listen", @"Referer", @"GMPlayer/1.0.07", @"User-Agent", @"*/*", @"Accept", cookiesHeader, @"Cookie", @"application/x-www-form-urlencoded;charset=UTF-8", @"Content-Type", @"gzip,deflate,sdch", @"Accept-Encoding", @"en-US,en;q=0.8", @"Accept-Language", @"ISO-8859-1,utf-8;q=0.7,*;q=0.3", @"Accept-Charset", nil];
        //loader.additionalHTTPHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"music.google.com", @"Host", @"0", @"Content-Length", cookiesHeader, @"Cookie", nil];
    }];
}

-(void)requestDidStartLoad:(RKRequest *)request
{
    NSLog(@"=== Sending Request ===");
    NSLog(@"URL: %@", [request.URLRequest.URL absoluteString]);
    
    NSDictionary* headers = [request.URLRequest allHTTPHeaderFields];
    for(NSString* key in [headers allKeys])
    {
        NSLog(@"Header Field - %@: %@", key, [headers objectForKey:key]);
    }
    
    NSLog(@"=== Finished ===");
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"Loaded.");
    songCache.songs = objects;
    
    [songCache setupCache];
    
    [songCache postSynchronizedNotification];
    
    //NSError* error = [NSError errorWithDomain:@"JPDomain" code:0 userInfo:nil];
    //[self postErrorNotificationForObjectLoader:objectLoader error:error];
}

/*
-(void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Response" message:[NSString stringWithFormat:@"An unexpected HTTP response was received from the Google Music servers.\nStatus code: %i\nMIME Type: %@", objectLoader.response.statusCode, objectLoader.response.MIMEType] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [self postErrorNotification:nil];
} */

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [self showErrorAlert:[error localizedDescription]];
    
    [self postErrorNotificationForObjectLoader:objectLoader error:error];
}

-(void)showErrorAlert:(NSString*)error
{
    NSString* message = [NSString stringWithFormat:@"Failed to sync with Google Music server.\n\n%@", error];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)postErrorNotificationForObjectLoader:(RKObjectLoader*)objectLoader error:(NSError*)error
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"rkError", objectLoader, @"objectLoader", nil];
    NSNotification* notification = [NSNotification notificationWithName:kGMServerSyncFailedNotification object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
