//
//  GMSongCache.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMSongCache.h"

#import "GMArtist.h"
#import "GMAlbum.h"
#import "GMServerSync.h"

@implementation GMSongCache

@synthesize songs;
@synthesize artists;
@synthesize albums;

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
    [serverSync release];
    serverSync = [[GMServerSync alloc] init];
    serverSync.songCache = self;
    
    [serverSync synchronize];
}

-(void)loadFromLocalStore
{
    NSFetchRequest* request = [GMSong fetchRequest];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	self.songs = [[GMSong objectsWithFetchRequest:request] retain];
    
    [self setupCache];
    
    [self postSynchronizedNotification];
}

-(void)postSynchronizedNotification
{
    NSNotification* notification = [NSNotification notificationWithName:kGMServerSyncFinishedNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)setupCache
{
    // List the individual artists
    NSMutableArray* artistNames = [NSMutableArray array];

    for(GMSong* song in self.songs)
    {
        NSString* name = song.artist;
        
        if([artistNames containsObject:name] == NO)
        {
            [artistNames addObject:name];
        }
    }
    
    //NSArray* sortedArtists = [artistNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    //    return [obj1 compare:obj2];
    //}];
    
    // Get all songs for individual artists
    NSMutableDictionary* songsForArtists = [NSMutableDictionary dictionary];
    
    for(GMSong* song in self.songs)
    {
        NSMutableArray* theSongs = [songsForArtists objectForKey:song.artist];
        if(theSongs == nil)
        {
            theSongs = [NSMutableArray array];
            [songsForArtists setObject:theSongs forKey:song.artist];
        }
        
        [theSongs addObject:song];
    }
    
    // Separate songs into individual albums
    NSMutableDictionary* albumsForArtists = [NSMutableDictionary dictionary];
    NSMutableDictionary* albumsByName = [NSMutableDictionary dictionary];
    
    for(NSString* artist in [songsForArtists allKeys])
    {
        NSArray* songsForArtist = [songsForArtists objectForKey:artist];
        
        for(GMSong* song in songsForArtist)
        {
            NSMutableArray* albumsForThisArtist = [albumsForArtists objectForKey:artist];
            if(albumsForThisArtist == nil)
            {
                albumsForThisArtist = [NSMutableArray array];
                [albumsForArtists setObject:albumsForThisArtist forKey:artist];
            }
            
            if(![albumsForThisArtist containsObject:song.album])
            {
                [albumsForThisArtist addObject:song.album];
            }
            
            NSMutableArray* songsInAlbum = [albumsByName objectForKey:song.album];
            if(songsInAlbum == nil)
            {
                songsInAlbum = [NSMutableArray array];
                [albumsByName setObject:songsInAlbum forKey:song.album];
            }
            
            [songsInAlbum addObject:song];
        }
    }
    
    NSLog(@"Found %i songs", [self.songs count]);
    NSLog(@"Found %i artists", [artistNames count]);
    NSLog(@"Found %i albums", [albumsByName count]);
    
    NSLog(@"Building song cache...");
    
    NSMutableArray* tempArtists = [NSMutableArray array];
    NSMutableArray* tempAlbums = [NSMutableArray array];
    
    // First setup the artists
    for(NSString* artistName in artistNames)
    {
        GMArtist* artist = [[GMArtist alloc] init];
        artist.name = artistName;
        artist.songs = [songsForArtists objectForKey:artistName];
        
        NSMutableArray* albumsWithGMAlbumObjects = [NSMutableArray array];
        
        NSArray* albumNamesForArtist = [albumsForArtists objectForKey:artistName];
        for(NSString* albumName in albumNamesForArtist)
        {
            NSArray* songsInAlbum = [albumsByName objectForKey:albumName];
            
            GMAlbum* album = [[GMAlbum alloc] init];
            album.title = albumName;
            album.artist = artist;
            album.songs = songsInAlbum;
            
            [albumsWithGMAlbumObjects addObject:album];
            
            [tempAlbums addObject:album];
        }
        
        artist.albums = albumsWithGMAlbumObjects;
        
        [tempArtists addObject:artist];
    }
    
    self.artists = tempArtists;
    self.albums = tempAlbums;
    
    NSLog(@"Finished building song cache.");

    [self performSelectorInBackground:@selector(retrieveCoverArt) withObject:nil];
}

-(GMAlbum*)albumForSong:(GMSong*)song
{
    for(GMAlbum* album in self.albums)
    {
        if([album.title isEqualToString:song.album])
        {
            return album;
        }
    }
    
    return nil;
}

-(void)retrieveCoverArt
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // Find unique cover URLs
    NSMutableArray* coverArtURLs = [NSMutableArray array];
    
    NSLog(@"Retrieving album art.");
    
    for(GMAlbum* album in self.albums)
    {
        GMSong* firstSong = [album.songs objectAtIndex:0];
        NSString* fuckedUpUrl = firstSong.albumArtUrl;
        if([coverArtURLs containsObject:fuckedUpUrl])
            continue; // Did this one already
        
        NSString* formattedURLString = [NSString stringWithFormat:@"http:%@", fuckedUpUrl];
        
        NSURL* url = [NSURL URLWithString:formattedURLString];
        //NSLog(@"File: %@", [url lastPathComponent]);
        
        NSArray* directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [directories objectAtIndex:0];
        
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[url lastPathComponent]];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            //NSLog(@"Used cached image for album: %@", album.title);
            UIImage* imageFromFile = [UIImage imageWithContentsOfFile:filePath];
            album.coverArt = [imageFromFile retain];
            continue;
        }
        
        NSData* imageData = [NSData dataWithContentsOfURL:url];
        if(imageData == nil)
        {
           // NSLog(@"Failed to download album cover art for song: %@", album.title);
            continue;
        }
        
        
        // Cache it, yo
        if([imageData writeToFile:filePath atomically:YES] == NO)
            NSLog(@"Failed to write image to cache.");
        
        UIImage* image = [UIImage imageWithData:imageData];
       // NSLog(@"Downloaded cover art for album: %@", album.title);
        
        album.coverArt = [image retain];
        
        [coverArtURLs addObject:url];
    }
    
    NSLog(@"Finished retrieving album art.");
    
    [pool release];
}

@end
