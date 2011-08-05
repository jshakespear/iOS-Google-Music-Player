//
//  SongLibraryViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMManager.h"

@interface SongLibraryViewController : UITableViewController<GMManagerDelegate> {
    GMManager* gmManager;
}

@end
