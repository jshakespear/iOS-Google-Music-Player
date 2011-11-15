//
//  ArtistTableViewCell.m
//  Google Music Player
//
//  Created by Julius Parishy on 9/15/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "ArtistTableViewCell.h"

@implementation ArtistTableViewCell

@synthesize artistName;
@synthesize songCount;
@synthesize coverArt;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
