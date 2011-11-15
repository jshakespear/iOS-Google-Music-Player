//
//  ArtistTableViewCell.h
//  Google Music Player
//
//  Created by Julius Parishy on 9/15/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtistTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel* artistName;
@property (nonatomic, retain) IBOutlet UILabel* songCount;
@property (nonatomic, retain) IBOutlet UIImageView* coverArt; // First album's cover art

@end
