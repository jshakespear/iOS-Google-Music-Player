//
//  GMSongCache.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMSongCache.h"

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
    GMServerSync* serverSync = [[[GMServerSync alloc] init] autorelease];
    serverSync.songCache = self;
    
    [serverSync synchronize];
}

@end
