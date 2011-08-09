//
//  GMManager.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMManager.h"

#define kPlaylistNameKey (@"playlistId")
#define kPlaylistKey (@"playlist")

@implementation GMManager

@synthesize delegate;
@synthesize songs;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)dealloc
{
    [songs release];
    [audioPlayer release];
    
    [super dealloc];
}

-(NSURLConnection*)sendGoogleMusicRequest:(NSString*)path method:(NSString*)method
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://music.google.com/%@", path]]];
    
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

    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:headers];
    
    if([method isEqualToString:@"POST"])
    {
        NSString* body = @"json={}";
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(!connection)
    {
        NSLog(@"Failed to create connection.");
    }
    
    [currentResponse release];
    currentResponse = [[NSMutableData alloc] init];
    
    return connection;
}

-(void)downloadLibrary
{
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    //NSLog(@"--- Cookies ---");
    //NSArray* cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"http://music.google.com"]];
    for(NSHTTPCookie* cookie in [cookieStorage cookies])
    {
        if([[cookie name] isEqualToString:@"xt"])
        {
            xtValue = [cookie value];
            //NSLog(@"Got xt: %@", xtValue);
        }
        
        //NSLog(@"Cookie: %@ (%@)", [cookie name], [cookie domain]);
    }
    
    NSLog(@"--- End Cookies ---");
    
    songListConnection = [self sendGoogleMusicRequest:[NSString stringWithFormat:@"music/services/loadalltracks?u=0&xt=%@", xtValue] method:@"POST"];
}

-(void)handleLibrary
{
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    
    NSString* responseString = [[NSString alloc] initWithData:currentResponse encoding:NSUTF8StringEncoding];
    //NSLog(@"Data:\n\n%@\n\n", responseString);
    
    id object = [parser objectWithString:responseString];
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* library = object;
        
        NSLog(@"Parsing playlist: %@", [library objectForKey:kPlaylistNameKey]);
        NSArray* playlist = [library objectForKey:kPlaylistKey];
        
        NSLog(@"Found %u songs", [playlist count]);
        
        [songs release];
        songs = [[NSMutableArray alloc] initWithCapacity:[playlist count]];
        
        for(NSDictionary* song in playlist)
        {
            //NSLog(@"Song: %@ (id=%@)", [song objectForKey:@"title"], [song objectForKey:@"id"]);
            
            GMSong* gmSong = [[GMSong alloc] init];
            
            gmSong.googleMusicId = [song objectForKey:@"id"];
            
            gmSong.title = [song objectForKey:@"title"];
            gmSong.artist = [song objectForKey:@"artist"];
            gmSong.album = [song objectForKey:@"album"];
            gmSong.genre = [song objectForKey:@"genre"];
            
            gmSong.coverArtURLString = [song objectForKey:@"albumArtUrl"];
            
            [songs addObject:gmSong];
            
            [gmSong release];
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(songsListedSuccessfully)])
    {
        [self.delegate songsListedSuccessfully];
    }
    
    [responseString release];
    [parser release];
}

-(void)downloadStreamInfoForSong:(NSString *)songId
{
    NSString* path = [NSString stringWithFormat:@"music/play?songid=%@&pt=e", songId];
    songStreamInfoConnection = [self sendGoogleMusicRequest:path method:@"GET"];
}

-(void)handleStreamInfo
{
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    
    NSString* responseString = [[NSString alloc] initWithData:currentResponse encoding:NSUTF8StringEncoding];
    
    id object = [parser objectWithString:responseString];
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* library = object;
        
        NSString* streamUrl = [library objectForKey:@"url"];
        [self openAudioStreamWithUrl:streamUrl];
    }
    
    [responseString release];
    [parser release];
}

-(void)openAudioStreamWithUrl:(NSString *)streamUrl
{
    [audioPlayer release];
    audioPlayer = [[GMAudioPlayer alloc] initWithURL:[NSURL URLWithString:streamUrl]];
}

-(void)playSong:(GMSong *)song
{
    if(audioPlayer)
    {
    }
    
    [self downloadStreamInfoForSong:song.googleMusicId];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Got response: %@ (%lld bytes expected)", [response MIMEType], [response expectedContentLength]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Received data chunk. Size: %u", [data length]);
    [currentResponse appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Data size: %u bytes", [currentResponse length]);
    
    if(connection == songListConnection)
    {
        [self handleLibrary];
    }
    else if(connection == songStreamInfoConnection)
    {
        [self handleStreamInfo];
    }
    else if(connection == songStreamConnection)
    {
        //[currentResponse writeToFile:@"/Users/jparishy/Desktop/Google Music/test.mp3" atomically:YES];
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

@end
