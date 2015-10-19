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

@interface ViewController ()

-(cv::CascadeClassifier*)loadClassifier;

@end

@implementation ViewController

cv::CascadeClassifier *faceCascade;
UIImage *faceImage;
Boolean faceDetected;
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
    
    self.resultText.text = @"result";
    
    self.camera = [[CvVideoCamera alloc] initWithParentView:_camView];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 15;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self;
    
    faceCascade = [self loadClassifier];
    
   
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSLog(@"face detected!");
        cv::rectangle(image, faces[0].tl(), faces[0].br(),cv::Scalar(84.36,170,0), 2, CV_AA);
        
        cv::Mat(rgbMat, faces[0]).copyTo(face);
        
        faceImage = [self UIImageFromCVMat:face];
        
    }
    
    if(faces.size() == 0)
        faceDetected = false;
    
    
    grayMat.release();
    originalMat.release();
    rgbMat.release();
    
    
}


- (IBAction)sendFace:(id)sender {
    
    [self postImage];
    
    
}
- (IBAction)resultButton:(id)sender {
    
    //[self getResponse];
   /* if(happy != nil){
        self.resultText.text = happy;
        [self.resultView setImage:[UIImage imageNamed:@"happy.jpeg"]];
    }*/
    
    if([mainEmotion isEqual: @"happy"])
        [self.resultView setImage:[UIImage imageNamed:@"happy.jpeg"]];
    if([mainEmotion  isEqual: @"surprise"])
        [self.resultView setImage:[UIImage imageNamed:@"surprise.jpeg"]];
    if([mainEmotion isEqual: @"fear"])
        [self.resultView setImage:[UIImage imageNamed:@"scared.jpeg"]];
    if([mainEmotion isEqual: @"sad"])
        [self.resultView setImage:[UIImage imageNamed:@"sad.jpeg"]];
    if([mainEmotion isEqual: @"neutral"])
        [self.resultView setImage:[UIImage imageNamed:@"neutral.jpeg"]];
    if([mainEmotion isEqual: @"angry"])
        [self.resultView setImage:[UIImage imageNamed:@"angry.jpeg"]];
    if([mainEmotion isEqual: @"disgust"])
        [self.resultView setImage:[UIImage imageNamed:@"disgust.jpeg"]];
    
}

- (IBAction)startCam:(id)sender {
    
    [self.camera start];
}

-(void) getResponse {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0),^{
        
       /* NSURL *url = [NSURL URLWithString:@"http://emo.vistawearables.com/bookmarks.json"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"json: %@", responseObject);
            
            // 3
            emotions = (NSDictionary *)responseObject;
            //self.title = @"JSON Retrieved";
            happy = emotions[@"happy"];
            NSLog(@"HAPPY: %@",happy);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            NSLog(@"json error");
        }];
        
        // 5
        [operation start];*/
        
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
        if(emo[i] == largest)
            largest = emo[1];
    }
    
    for(int i=0;i<=6;i++){
        if(emo[i] == largest)
            mainEmotion = emoString[i];
    }
    
    
}
    /*AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://emo.vistawearables.com/bookmarks.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        happy = json[@"happy"];
       
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    self.resultText.text = happy;*/
    
//}

-(void) postImage {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // NSDictionary *parameters = @{@"bookmark[title]" : @"photo.jpg"};
    NSData *imageData = UIImageJPEGRepresentation(faceImage, 0.5);
    //NSData *imageData = UIImageJPEGRepresentation(self.faceView.image,0.5);
    [manager POST:@"http://emo.vistawearables.com/bookmarks" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"bookmark[photo]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
       // [self getResponse];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self getResponse];
        NSLog(@"Error: %@", error);

    }];
    
    
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
