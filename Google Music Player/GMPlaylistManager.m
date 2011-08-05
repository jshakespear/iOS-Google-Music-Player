//
//  GMPlaylistManager.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMPlaylistManager.h"

#import "SBJson/SBJson.h"

@implementation GMPlaylistManager

@synthesize audioPlayer;
@synthesize songs;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        songs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [songs release];
    [super dealloc];
}

-(void)playSong:(GMSong*)song
{
    [self downloadStreamInfoForSong:song]; // It will pass the URL to play once downloaded
}

-(void)downloadStreamInfoForSong:(GMSong *)song
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://music.google.com/music/play?songid=%@&pt=e", song.googleMusicId]]];
    
    NSMutableDictionary* headers = [NSMutableDictionary dictionary];
    
    [headers setValue:@"music.google.com" forKey:@"Host"];
    [headers setValue:@"keep-alive" forKey:@"Connection"];
    [headers setValue:@"http://music.google.com" forKey:@"Origin"];
    [headers setValue:@"CGM 0.0.1" forKey:@"User-Agent"];
    [headers setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forKey:@"Content-Type"];
    [headers setValue:@"*/*" forKey:@"Accept"];
    [headers setValue:@"gzip,deflate,sdch" forKey:@"Accept-Encoding"];
    [headers setValue:@"en-US,en;q=0.8" forKey:@"Accept-Language"];
    [headers setValue:@"ISO-8859,utf-8;q=0.7,*;q=0.3" forKey:@"Accept-Charset"];
    
    NSMutableString* cookiesHeader = [NSMutableString string];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* cookies = [defaults objectForKey:@"GMCookies"];
    if(cookies != nil)
    {
        for(NSString* key in [cookies allKeys])
        {
            [cookiesHeader appendFormat:@"%@=%@;", key, [cookies objectForKey:key]];
        }
    }
    
    [headers setValue:cookiesHeader forKey:@"Cookie"];
    
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(!connection)
    {
        NSLog(@"Failed to create connection.");
    }
    
    [currentResponse release];
    currentResponse = [[NSMutableData alloc] init];
}

-(void)parseStreamInfo:(NSString *)streamInfo
{
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    
    id object = [parser objectWithString:streamInfo];
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* library = object;
        
        NSString* streamUrl = [library objectForKey:@"url"];
        //NSLog(@"Stream URL: %@", streamUrl);
        
        [self openStreamAtURL:[NSURL URLWithString:streamUrl]];
    }
    else
    {
        NSLog(@"Failed to parse stream information.");
    }
    
    [parser release];
}

-(void)openStreamAtURL:(NSURL *)url
{
    [audioPlayer playStreamWithURL:url];
    [audioPlayer play];
    NSLog(@"Opened stream.");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [currentResponse appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Parse the data
    NSLog(@"Stream information downloaded.");

    NSString* string = [[NSString alloc] initWithData:currentResponse encoding:NSUTF8StringEncoding];
    [self parseStreamInfo:string];
    [string release];
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


@end
