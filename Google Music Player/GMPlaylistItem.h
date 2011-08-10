//
//  GMPlaylistItem.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/9/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMSong.h"

@interface GMPlaylistItem : NSObject {
    GMSong* song;
    BOOL played;
}

@property (nonatomic, retain) GMSong* song;
@property (nonatomic, assign) BOOL played;

-(id)initWithSong:(GMSong*)aSong;

@end
