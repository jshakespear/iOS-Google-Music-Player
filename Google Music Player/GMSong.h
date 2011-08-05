//
//  GMSong.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMSong : NSObject

@property (nonatomic, copy) NSString* googleMusicId;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* artist;
@property (nonatomic, copy) NSString* album;
@property (nonatomic, copy) NSString* genre;

@property (nonatomic, copy) NSString* coverArtURLString;

@end
