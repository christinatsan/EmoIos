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

@property (nonatomic,retain) CvVideoCamera *camera;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *resButton;

@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UITextView *resultText;


@property (weak, nonatomic) IBOutlet UIImageView *camView;
@property (weak, nonatomic) IBOutlet UIImageView *resultView;

@end

