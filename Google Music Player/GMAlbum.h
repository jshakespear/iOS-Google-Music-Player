//
//  GMAlbum.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/1/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMArtist;

@interface GMAlbum : NSObject {
    GMArtist* artist;
    NSString* title;
    
    NSMutableArray* songs;
}

@property (nonatomic, assign) GMArtist* artist;
@property (nonatomic, assign) NSString* title;

@property (nonatomic, retain) NSMutableArray* songs;

@end
