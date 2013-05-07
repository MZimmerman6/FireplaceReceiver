//
//  ViewController.m
//  FireplaceReceiver
//
//  Created by Matthew Zimmerman on 12/20/12.
//  Copyright (c) 2012 Matthew Zimmerman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController

@synthesize fireplacePic,moviePlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    fireplacePic.image = [UIImage imageNamed:@"fireplace1.jpg"];
    [self.view setNeedsDisplay];
    gettingUpdate = false;
    musicPaused = false;
    currentSong = @"crackling";
    updateData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath],currentSong]];
    NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = -1;
    [audioPlayer setVolume:0.1];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    
    NSURL *movieURL = [NSURL fileURLWithPath:
                       [[NSBundle mainBundle] pathForResource:@"fireplace"
                                                       ofType:@"mp4"]];
//    NSLog(@"%@",movieURL);
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    [[moviePlayer view] setFrame:CGRectMake(-221, -166, 1466, 1100)];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer prepareToPlay];
//    [moviePlayer setFullscreen:YES];
    [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    [moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    [moviePlayer play];
    moviePlaying = YES;
    
	if (audioPlayer == nil) {
		NSLog(@"%@",[error description]);
    } else {
		[audioPlayer play];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkForUpdates) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) checkForUpdates {
    
    if (!gettingUpdate) {
        updateData = [[NSMutableData alloc] init];
        gettingUpdate = true;
        autonext = false;
        NSURL *updateURL = [NSURL URLWithString:@"http://mzimm16.dyndns.org/Fireplace/getUpdate.php"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:updateURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:2.0];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        connection = nil;
    }
    
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [updateData appendData:data];
    gettingUpdate = false;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSDictionary *updateDictionary = [NSJSONSerialization JSONObjectWithData:updateData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
    float volume = [[updateDictionary objectForKey:@"volume"] floatValue];
    NSString *song = [updateDictionary objectForKey:@"song"];
    int shouldPause = [[updateDictionary objectForKey:@"pause"] intValue];
    
    BOOL newSong = NO;
    if ([song caseInsensitiveCompare:currentSong] != NSOrderedSame && !autonext) {
        currentSong = song;
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath],currentSong]];
        [audioPlayer stop];
        musicPaused = YES;
        NSError *error;
        audioPlayer = [audioPlayer initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = -1;
        newSong = YES;
//        NSLog(@"new song selected");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    }
    if (shouldPause == 1) {
        [audioPlayer stop];
//        if (moviePlaying == YES) {
//            [moviePlayer pause];
//            moviePlaying = NO;
//        }
    } else {
        [audioPlayer play];
//        if (moviePlaying == NO) {
//            [moviePlayer play];
//            moviePlaying = YES;
//        }
    }
    [audioPlayer setVolume:volume];
    gettingUpdate = false;
//    NSLog(@"%@",[NSString stringWithFormat:@"Song: %@, Volume: %f",song,volume]);
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    gettingUpdate = false;
}

@end
