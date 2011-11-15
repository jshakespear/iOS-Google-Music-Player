//
//  GMSongRKTest.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/21/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface GMSong : NSManagedObject

/*
 * These properties coorespond directly to the data
 * returned in the JSON response when querying the GM
 * server for the user's music.
 */

@property (nonatomic, retain) NSString* genre;
@property (nonatomic, assign) NSNumber* beatsPerMinute;
@property (nonatomic, retain) NSString* albumArtistNorm;
@property (nonatomic, retain) NSString* artistNorm;
@property (nonatomic, retain) NSString* album;
@property (nonatomic, assign) NSNumber* lastPlayed;
@property (nonatomic, assign) NSNumber* disc;
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* composer;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* albumArtist;
@property (nonatomic, assign) NSNumber* totalTracks;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) NSNumber* totalDiscs;
@property (nonatomic, assign) NSNumber* year;
@property (nonatomic, retain) NSString* titleNorm;
@property (nonatomic, retain) NSString* artist;
@property (nonatomic, retain) NSString* albumNorm;
@property (nonatomic, assign) NSNumber* track;
@property (nonatomic, assign) NSNumber* durationMillis;
@property (nonatomic, retain) NSString* albumArtUrl;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, assign) NSNumber* creationDate;
@property (nonatomic, assign) NSNumber* playCount;
@property (nonatomic, assign) NSNumber* rating;
@property (nonatomic, retain) NSString* comment;

@end
