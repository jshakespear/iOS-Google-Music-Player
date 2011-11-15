//
//  CoreDataTestViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/21/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMSong.h"

@interface CoreDataTestViewController : UITableViewController {
    NSArray* songs;
}

-(void)loadSongsFromDataStore;

@end
