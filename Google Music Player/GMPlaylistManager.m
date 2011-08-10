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
@synthesize items;
@synthesize currentItem;

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        items = [[NSMutableArray alloc] init];
        
        lastStreamerState = AS_INITIALIZED;
        [self registerForAudioStreamerStateChanges];
    }
    
    return self;
}

-(void)dealloc
{
    [items release];
    [super dealloc];
}

-(void)registerForAudioStreamerStateChanges
{
    [[NSNotificationCenter defaultCenter] addObserverForName:ASStatusChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) {
        
        AudioStreamer* streamer = notification.object;
        AudioStreamerState state = streamer.state;
        
        /*
         * State Flow:
         *
         *  1. AS_STARTING_FILE_THREAD
         *  2. AS_WAITING_FOR_DATA
         *  3. AS_WAITING_FOR_QUEUE_TO_START
         *  4. AS_PLAYING
         *  ... // Room here to pause (AS_PAUSED), etc, etc
         *  5. AS_STOPPING
         *  6. AS_STOPPED
         *  7. AS_INITIALIZED
         */
        
        if(state == AS_INITIALIZED)
        {
        }
        else if(state == AS_PLAYING)
        {
            BOOL resuming = NO;
            
            if(lastStreamerState == AS_PAUSED || lastStreamerState == AS_STOPPED)
            {
                // Just started playing
                resuming = YES;
            }
            
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(playlistManagerDidPlayItem:resuming:)])
            {
                [self.delegate playlistManagerDidPlayItem:self.currentItem resuming:resuming];
            }
        }
        else if(state == AS_PAUSED)
        {
            // Paused
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(playlistManagerDidPauseItem:)])
            {
                [self.delegate playlistManagerDidPauseItem:self.currentItem];
            }
        }
        else if(state == AS_STOPPING)
        {
        }
        else if(state == AS_STOPPED)
        {
            if(streamer.stopReason != AS_STOPPING_USER_ACTION)
            {
                if(self.delegate != nil && [self.delegate respondsToSelector:@selector(playlistManagerDidFinishPlayingItem:)])
                {
                    [self.delegate playlistManagerDidFinishPlayingItem:self.currentItem];
                }
                
                if(![self isFinished])
                {
                    [self playNextItem];
                }
                else
                {
                    NSLog(@"Playlist finished.");
                }
            }
        }
        else if(state == AS_WAITING_FOR_DATA)
        {
        }
        else if(state == AS_WAITING_FOR_QUEUE_TO_START)
        {
        }
        else if(state == AS_STARTING_FILE_THREAD)
        {
        }
        else if(state == AS_BUFFERING)
        {
        }
        else
        {
            NSLog(@"Unhandled state");
        }
               
        
        lastStreamerState = state;
        
    }];
}

-(BOOL)isFinished
{
    BOOL finished = YES;
    for(GMPlaylistItem* item in self.items)
    {
        if(item.played == NO)
        {
            finished = NO;
            break;
        }
    }
    
    return finished;
}

-(void)playSong:(GMSong*)song
{
    [self downloadStreamInfoForSong:song]; // It will pass the URL to play once downloaded
    //self.currentItem = nil;
    songToPlay = song;
}

-(void)playItem:(GMPlaylistItem *)item
{
    [self playSong:item.song];
    item.played = YES;
}

-(void)playNextItem
{
   /* int i = 0;
    for(GMPlaylistItem* item in self.items)
    {
        NSLog(@"[%i] %@", i++, item.song.title);
    } */
    
    int index = [self.items indexOfObject:self.currentItem];
    assert(index != NSNotFound);
    
    BOOL foundNextItem = NO;
    
    while(index < [self.items count])
    {
        index++;
        GMPlaylistItem* potentialItem = [self.items objectAtIndex:index];
        if(!potentialItem.played)
        {
            foundNextItem = YES;
            break;
        }
    }
    
    self.currentItem = [self.items objectAtIndex:index]; 
    [self playItem:self.currentItem];
}

-(void)setItemsWithSongs:(NSArray *)songs firstIndex:(int)index
{
    //NSLog(@"Setting current playlist to %i songs, playing song at index = %i", [songs count], index);
    
    NSMutableArray* newItems = [[NSMutableArray alloc] init];
    
    // Do this weird to maintain order!
    for(int i = index; i < [songs count]; ++i)
    {
        GMSong* song = [songs objectAtIndex:i];
        [newItems addObject:[[GMPlaylistItem alloc] initWithSong:song]];
    }
    
    for(int i = 0; i < index; ++i)
    {
        GMSong* song = [songs objectAtIndex:i];
        [newItems addObject:[[GMPlaylistItem alloc] initWithSong:song]];
    }
    
    self.items = newItems;
    [newItems release];
    
    //NSLog(@"self.items.count = %i", [self.items count]);
    
    self.currentItem = [self.items objectAtIndex:0];
    
    [self playItem:self.currentItem];
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
    
    songToPlay = nil;
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
