//
//  ViewController.h
//  FireplaceReceiver
//
//  Created by Matthew Zimmerman on 12/20/12.
//  Copyright (c) 2012 Matthew Zimmerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableData *updateData;
    BOOL gettingUpdate;
    BOOL autonext;
    NSString *currentSong;
    float currentVolume;
    BOOL musicPaused;
    AVAudioPlayer *audioPlayer;
    BOOL moviePlaying;
}


@property (strong, nonatomic) IBOutlet UIImageView *fireplacePic;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

-(void) checkForUpdates;

@end
