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
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;


@property (weak, nonatomic) IBOutlet UIImageView *backView;

// StoryBoard settings




// Audio Players
@property (strong) AVAudioPlayer *directionsPlayer;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUp;

@property (nonatomic,retain) CvVideoCamera *camera;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIToolbar *onButton;
@property (weak, nonatomic) IBOutlet UIToolbar *offButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resultButton;


@property (weak, nonatomic) IBOutlet UIImageView *camView;
@property (weak, nonatomic) IBOutlet UIImageView *resultView;

@end

