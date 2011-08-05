//
//  GMServerSync.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMServerSync.h"

#import "SBJson/SBJson.h"

// Send POST command to this URL to obtain a JSON response containing all the songs in the users
// library. Must append the xt HTTP cookie for it to work.
#define kGMLoadTracksURL (@"http://music.google.com/music/services/loadalltracks?u=0&xt=")

#define kGMSessionCookieURL (@"music.google.com")
#define kGMSessionCookieName (@"xt")

#define kGMPlaylistNameKey (@"playlistId")
#define kGMPlaylistKey (@"playlist")

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

-(void)parseData
{
    parseStartTime = [[NSDate date] retain];
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    
    NSString* responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    id object = [parser objectWithString:responseString];
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* library = object;
        
        //NSLog(@"Parsing playlist: %@", [library objectForKey:kGMPlaylistNameKey]);
        NSArray* playlist = [library objectForKey:kGMPlaylistKey];
        
        //NSLog(@"Found %u songs", [playlist count]);
        
        NSMutableArray* songs = [NSMutableArray array];
        
        NSMutableDictionary* artists = [NSMutableDictionary dictionary];
        NSMutableDictionary* albums = [NSMutableDictionary dictionary];
        
        for(NSDictionary* song in playlist)
        {
           // NSLog(@"Song: %@ (id=%@)", [song objectForKey:@"title"], [song objectForKey:@"id"]);
            
            // Get the song
            GMSong* gmSong = [[GMSong alloc] init];
            
            gmSong.googleMusicId = [song objectForKey:@"id"];
            
            gmSong.title = [song objectForKey:@"title"];
            gmSong.artist = [song objectForKey:@"artist"];
            gmSong.album = [song objectForKey:@"album"];
            gmSong.genre = [song objectForKey:@"genre"];
            
            gmSong.coverArtURLString = [song objectForKey:@"albumArtUrl"];
            
            // Get the artist info ready
            GMArtist* artist = [artists objectForKey:gmSong.artist];
            if(artist == nil)
            {
                artist = [[GMArtist alloc] init];
                artist.albums = [[NSMutableArray alloc] init];
                artist.songs = [[NSMutableArray alloc] init];
                [artists setObject:artist forKey:gmSong.artist];
                
                artist.name = gmSong.artist;
            }
            
            [artist.songs addObject:gmSong];
            
            GMAlbum* album = [albums objectForKey:gmSong.album];
            if(album == nil)
            {
                album = [[GMAlbum alloc] init];
                album.songs = [[NSMutableArray alloc] init];
                [albums setObject:album forKey:gmSong.album];
                
                album.artist = artist;
                
                [artist.albums addObject:album];
                
                album.title = gmSong.album;
            }
            
            [album.songs addObject:gmSong];
            
            [songs addObject:gmSong];
            
            [gmSong release];
        }
        
        parseEndTime = [[NSDate date] retain];
        
        NSLog(@"Parsed Google Music Library:\n");
        NSLog(@"\tFound %i songs", [songs count]);
        NSLog(@"\tFound %i artists", [artists count]);
        NSLog(@"\tFound %i albums", [albums count]);
        NSLog(@"\tElapsed download time: %f sec", [downloadEndTime timeIntervalSinceDate:downloadStartTime]);
        NSLog(@"\tElapsed parse time: %f sec", [parseEndTime timeIntervalSinceDate:parseStartTime]);
        
        songCache.artists = [artists allValues];
        songCache.albums = [albums allValues];
        songCache.songs = songs;
        
        // Post the notification
        NSNotification* notification = [NSNotification notificationWithName:kGMServerSyncFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else
    {
        NSLog(@"Not JSON, failed to download song listing.");
        NSLog(@"%@", responseString);
    }
    
    [responseString release];
    [parser release];
}

-(void)synchronize
{
    NSString* sessionCookieValue = nil;
    
    NSMutableString* cookiesHeader = [NSMutableString string];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* cookies = [defaults objectForKey:@"GMCookies"];
    if(cookies != nil)
    {
        for(NSString* key in [cookies allKeys])
        {
            [cookiesHeader appendFormat:@"%@=%@;", key, [cookies objectForKey:key]];

            if([key isEqualToString:kGMSessionCookieName])
            {
                sessionCookieValue = [cookies valueForKey:key];
                //NSLog(@"Got session cookie: %@", sessionCookieValue);
            }
        }
    }
    
    NSString* fullGMURL = [NSString stringWithFormat:@"%@%@", kGMLoadTracksURL, sessionCookieValue];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullGMURL]];
    
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
    [headers setValue:cookiesHeader forKey:@"Cookie"];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    // Maybe need this? It was in the webapp's POST command
    NSString* body = @"json={}";
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(!connection)
    {
        NSLog(@"Failed to create connection to Google Music server.");
    }
    
    downloadStartTime = [[NSDate date] retain];
}

-(NSArray*)sortSongsAlphabetically:(NSArray *)unorderedSongs
{
    return [unorderedSongs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 title] compare:[obj2 title]];
    }];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* headers = [httpResponse allHeaderFields];
        
        for(NSString* key in [headers allKeys])
        {
            //NSLog(@"Key: %@", key);
        }
        
       // NSString* cookies = [headers objectForKey:@"Set-Cookie"];
        //NSLog(@"Cookies for response: %@", cookies);
    }
    
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    downloadEndTime = [[NSDate date] retain];
    [self parseData];
    
    [responseData release];
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
