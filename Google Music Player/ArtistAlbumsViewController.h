//
//  AristAlbumsViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/7/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMArtist.h"
#import "GMPlaylistManager.h"

@interface ArtistAlbumsViewController : UITableViewController {
    GMPlaylistManager* playlistManager;
}

@property (nonatomic, assign) GMPlaylistManager* playlistManager;

@property (nonatomic, assign) GMArtist* artist;

@end
