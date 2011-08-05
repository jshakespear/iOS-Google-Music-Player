//
//  GMSong.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMSong.h"

@implementation GMSong

@synthesize googleMusicId;

@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize genre;

@synthesize coverArtURLString;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
