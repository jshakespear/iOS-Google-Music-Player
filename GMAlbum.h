//
//  GMAlbum.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/22/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMArtist;

@interface GMAlbum : NSObject

@property (nonatomic, assign) NSString* title;
@property (nonatomic, assign) GMArtist* artist;
@property (nonatomic, retain) NSArray* songs;

@property (nonatomic, retain) UIImage* coverArt; // Downloaded after syncing

@end
