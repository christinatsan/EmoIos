//
//  ViewController.m
//  together
//
//  Created by Christina Tsangouri on 10/17/15.
//  Copyright © 2015 Christina Tsangouri. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/imgproc/imgproc_c.h>
#import <dispatch/dispatch.h>
#import <AudioToolbox/AudioToolbox.h>


@interface ViewController ()

-(cv::CascadeClassifier*)loadClassifier;

@end

@implementation ViewController

cv::CascadeClassifier *faceCascade;
UIImage *faceImage;
Boolean faceDetected = false;
cv::Mat originalMat;
cv::Mat grayMat;
cv::Mat tempMat;
cv::Mat faceMat;
cv::Rect roi;
NSString *happy;
NSString *sad;
NSString *fear;
NSString *neutral;
NSString *surprise;
NSString *angry;
NSString *disgust;
NSDictionary *emotions;
NSString *mainEmotion;
Boolean realtimeMode = true;


-(cv::CascadeClassifier*)loadClassifier
{
    NSString* haar = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface" ofType:@"xml"];
    cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
    cascade->load([haar UTF8String]);
    return cascade;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back2.jpeg"]];
    [self.view addSubview:backgroundView];
    
    self.resultText.text = @"";
    
    self.camera = [[CvVideoCamera alloc] initWithParentView:_camView];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 15;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self;
    
    faceCascade = [self loadClassifier];
    
    [self createTimer];
    

    [self camTimer];
    
    NSError *error = nil;
    
    // Audio Player Initialization - figure out why some tracks dont play
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"disgust" ofType:@"mp3"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    

    
    self.disgustPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
    [self.disgustPlayer prepareToPlay];
    
  //  NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath2 = [mainBundle pathForResource:@"scream" ofType:@"mp3"];
    NSData *fileData2 = [NSData dataWithContentsOfFile:filePath2];
    
    self.angryPlayer = [[AVAudioPlayer alloc] initWithData:fileData2 error:&error];
    [self.angryPlayer prepareToPlay];
    
    NSBundle *mainBundle3 = [NSBundle mainBundle];
    NSString *filePath3 = [mainBundle3 pathForResource:@"river" ofType:@"mp3"];
    NSData *fileData3 = [NSData dataWithContentsOfFile:filePath3];
    
    
    self.neutralPlayer = [[AVAudioPlayer alloc] initWithData:fileData3 error:&error];
    [self.neutralPlayer prepareToPlay];
    
    NSBundle *mainBundle4 = [NSBundle mainBundle];
    NSString *filePath4 = [mainBundle4 pathForResource:@"heartbeat" ofType:@"mp3"];
    NSData *fileData4 = [NSData dataWithContentsOfFile:filePath4];
    
    self.fearPlayer = [[AVAudioPlayer alloc] initWithData:fileData4 error:&error];
    [self.fearPlayer prepareToPlay];
    
    NSBundle *mainBundle5 = [NSBundle mainBundle];
    NSString *filePath5 = [mainBundle5 pathForResource:@"bell" ofType:@"mp3"];
    NSData *fileData5 = [NSData dataWithContentsOfFile:filePath5];
    
    
    self.happyPlayer = [[AVAudioPlayer alloc] initWithData:fileData5 error:&error];
    [self.happyPlayer prepareToPlay];
    
    NSBundle *mainBundle6 = [NSBundle mainBundle];
    NSString *filePath6 = [mainBundle6 pathForResource:@"comic" ofType:@"mp3"];
    NSData *fileData6 = [NSData dataWithContentsOfFile:filePath6];

    self.surprisedPlayer = [[AVAudioPlayer alloc] initWithData:fileData6 error:&error];
    [self.surprisedPlayer prepareToPlay];
    
    NSBundle *mainBundle7 = [NSBundle mainBundle];
    NSString *filePath7 = [mainBundle7 pathForResource:@"well" ofType:@"mp3"];
    NSData *fileData7 = [NSData dataWithContentsOfFile:filePath7];
    
    self.sadPlayer = [[AVAudioPlayer alloc] initWithData:fileData7 error:&error];
    [self.sadPlayer prepareToPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// When swipe down turn realtime mode off
- (IBAction)swipeDownAction:(id)sender {
    
    [self.resultView setImage:[UIImage imageNamed:@"white.png"]];
    self.resultText.text= @"";
    realtimeMode = false;
    self.resultButton.enabled = YES;
}

// When swipe up up turn realtime mode on
- (IBAction)swipeUpAction:(id)sender {
    [self.resultView setImage:[UIImage imageNamed:@"white.png"]];
    self.resultText.text= @"";
    realtimeMode = true;
    self.resultButton.enabled = NO;
    [self.angryPlayer play];
}

// If realtime mode is off tap twice to get result

// Find different gesture for this too same as down swipe :(
- (IBAction)rotationSwipeAction:(id)sender {
    [self getResponse];
}


- (IBAction)onClick:(id)sender {
    [self.resultView setImage:[UIImage imageNamed:@"white.png"]];
    self.resultText.text= @"";
    realtimeMode = true;
    self.resultButton.enabled = NO;
    [self.angryPlayer play];
    
    
}

- (IBAction)offClick:(id)sender {
    [self.resultView setImage:[UIImage imageNamed:@"white.png"]];
    self.resultText.text= @"";
    realtimeMode = false;
    self.resultButton.enabled = YES;
}

- (IBAction)resultClick:(id)sender {
    
    [self getResponse];
    
}



#pragma mark - Protocol CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV stuff with the image
    cv::Mat grayMat;
    cv::Mat face;
    cv::Mat rgbMat;
    grayMat = cv::Mat(image.rows, image.cols, CV_8UC3);
    cvtColor(image, grayMat, CV_BGRA2GRAY);
    rgbMat = cv::Mat(image.rows, image.cols, CV_8UC3);
    cvtColor(image, rgbMat, CV_BGRA2RGB);
    
    int height = grayMat.rows;
    double faceSize = (double) height * 0.25;
    cv::Size sSize;
    sSize.height = faceSize;
    sSize.width = faceSize;
    std::vector<cv::Rect> faces;
    
    faceCascade->detectMultiScale(grayMat,faces,1.1,4,2, sSize);
    if(faces.size() > 0)
    {
        faceDetected = true;
        NSLog(@"face detected!");
        cv::rectangle(image, faces[0].tl(), faces[0].br(),cv::Scalar(84.36,170,0), 2, CV_AA);
        
        cv::Mat(rgbMat, faces[0]).copyTo(face);
        
        faceImage = [self UIImageFromCVMat:face];
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        
    }
    
    if(faces.size() == 0)
        faceDetected = false;
    
    
    grayMat.release();
    originalMat.release();
    rgbMat.release();
    
    
}





-(void) getResponse {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0),^{
        
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager GET:@"http://emo.vistawearables.com/bookmarks.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            emotions = (NSDictionary *)responseObject;
            happy = emotions[@"happy"];
            surprise = emotions[@"surprise"];
            sad = emotions[@"sad"];
            fear = emotions[@"fear"];
            neutral = emotions[@"neutral"];
            disgust = emotions[@"disgust"];
            angry = emotions[@"angry"];
            
            NSLog(@"HAPPY: %@",happy);
            
           // [self findHighest];
            
            

//            happy = json[@"happy"];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"after get main %@",happy);
            [self findHighest];
            self.resultText.text = mainEmotion;
            if([mainEmotion isEqual: @"happy"]){
                [self.resultView setImage:[UIImage imageNamed:@"happy.jpeg"]];
                [self.happyPlayer play];
            }
            if([mainEmotion  isEqual: @"surprise"]){
                [self.surprisedPlayer play];
                [self.resultView setImage:[UIImage imageNamed:@"surprise.jpeg"]];
            }
            if([mainEmotion isEqual: @"fear"]){
                [self.resultView setImage:[UIImage imageNamed:@"scared.jpeg"]];
                [self.fearPlayer play];
            }
            if([mainEmotion isEqual: @"sad"]){
                [self.resultView setImage:[UIImage imageNamed:@"sad.jpeg"]];
                [self.sadPlayer play];
            }
            if([mainEmotion isEqual: @"neutral"]){
                [self.resultView setImage:[UIImage imageNamed:@"neutral.jpeg"]];
                [self.neutralPlayer play];
            }
            if([mainEmotion isEqual: @"angry"]){
                [self.resultView setImage:[UIImage imageNamed:@"angry.jpeg"]];
                [self.angryPlayer play];
            }
            if([mainEmotion isEqual: @"disgust"]){
                [self.resultView setImage:[UIImage imageNamed:@"disgust.jpeg"]];
                [self.disgustPlayer play];
            }
        });
        
        
    });
    
}

- (void) findHighest {
    
    
    NSArray *emoString = [NSArray arrayWithObjects:@"happy",@"surprise",@"sad",@"fear",@"neutral",@"disgust",@"angry",nil];
    
    float happyInt = [happy floatValue];
    float surpriseInt = [surprise floatValue];
    float sadInt = [sad floatValue];
    float fearInt = [fear floatValue];
    float neutralInt = [neutral floatValue];
    float disgustInt = [disgust floatValue];
    float angryInt = [angry floatValue];
    
    float emo[7] = {happyInt,surpriseInt,sadInt,fearInt,neutralInt,disgustInt,angryInt};
    
    double largest = 0;
    
    for(int i=0;i<=6;i++){
        if(emo[i]>largest)
            largest = emo[i];
        
    }
    
    for(int i=0;i<=6;i++){
        if(emo[i] == largest)
            mainEmotion = emoString[i];
    }
    
    
}


-(void) postImage {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0),^{
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        // NSDictionary *parameters = @{@"bookmark[title]" : @"photo.jpg"};
        if (faceImage!=Nil){
            NSData *imageData = UIImageJPEGRepresentation(faceImage, 0.5);
            //NSData *imageData = UIImageJPEGRepresentation(self.faceView.image,0.5);
            [manager POST:@"http://emo.vistawearables.com/bookmarks" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData name:@"bookmark[photo]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success: %@", responseObject);
                // [self getResponse];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                if(realtimeMode == true)
                    [self getResponse];
                
                    
                NSLog(@"Error: %@", error);
                
            }];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"get here");
            
        });
        
        
        
    });
    
    
}

- (NSTimer*) createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(faceTimer:) userInfo:nil repeats:YES];
}

- (void) faceTimer:(NSTimer*)timer {
    // Start loop
    
    if(faceDetected == true)
        [self postImage];
    if(faceDetected == false)
    {
        self.resultText.text = @"";
        //also add a blank image or make imageview blank
    }
    
}

- (NSTimer*) camTimer {
    return [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(cam:) userInfo:nil repeats:NO];

}

- (void) cam:(NSTimer*)timer{
    [self.camera start];
    
}



- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}




@end
