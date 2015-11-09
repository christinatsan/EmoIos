//
//  ViewController.h
//  together
//
//  Created by Christina Tsangouri on 10/17/15.
//  Copyright © 2015 Christina Tsangouri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>

@interface ViewController : UIViewController <CvVideoCameraDelegate>
{
    CvVideoCamera *camera;
    
}
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDown;

@property (strong, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationSwipe;

// Audio Players
@property (nonatomic, strong) AVAudioPlayer *happyPlayer;
@property (nonatomic, strong) AVAudioPlayer *disgustPlayer;
@property (nonatomic, strong) AVAudioPlayer *neutralPlayer;
@property (nonatomic, strong) AVAudioPlayer *sadPlayer;
@property (nonatomic, strong) AVAudioPlayer *fearPlayer;
@property (nonatomic, strong) AVAudioPlayer *surprisedPlayer;
@property (nonatomic, strong) AVAudioPlayer *angryPlayer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUp;

@property (nonatomic,retain) CvVideoCamera *camera;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIToolbar *onButton;
@property (weak, nonatomic) IBOutlet UIToolbar *offButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resultButton;


@property (weak, nonatomic) IBOutlet UIImageView *camView;
@property (weak, nonatomic) IBOutlet UIImageView *resultView;

@end

