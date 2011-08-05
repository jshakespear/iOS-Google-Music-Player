//
//  GMArtist.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/1/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMAlbum.h"
#import "GMSong.h"

@interface GMArtist : NSObject {
    NSString* name;
    
    NSMutableArray* albums;
    NSMutableArray* songs;
}

@property (nonatomic, assign) NSString* name;

@property (nonatomic, retain) NSMutableArray* albums;
@property (nonatomic, retain) NSMutableArray* songs;

@end
