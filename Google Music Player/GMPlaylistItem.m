//
//  GMPlaylistItem.m
//  Google Music Player
//
//  Created by Julius Parishy on 8/9/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMPlaylistItem.h"

@implementation GMPlaylistItem

@synthesize song;
@synthesize played;

- (id)initWithSong:(GMSong *)aSong
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.song = aSong;
        self.played = NO;
    }
    
    return self;
}

@end
