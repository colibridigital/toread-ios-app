//
//  BarcodeScannerViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 24/06/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BarcodeScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface BarcodeScannerViewController ()  <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *mCaptureSession;
    AVCaptureVideoPreviewLayer *_prevLayer;
    NSMutableString *mCode;
    
    UIView *_highlightView;
    UILabel *_label;
}
@end

@implementation BarcodeScannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1
    mCaptureSession = [[AVCaptureSession alloc] init];
    
    // 2
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // 3
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    if ([mCaptureSession canAddInput:videoInput]) {
        [mCaptureSession addInput:videoInput];
    } else {
        NSLog(@"Could not add video input: %@", [error localizedDescription]);
    }
    
    // 4
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    if ([mCaptureSession canAddOutput:metadataOutput]) {
        [mCaptureSession addOutput:metadataOutput];
        
        // 5
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]];
    } else {
        NSLog(@"Could not add metadata output.");
    }
    
    // 6
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:mCaptureSession];
    previewLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:previewLayer];
    
    // 7
    [mCaptureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 1
    if (mCode == nil) {
        mCode = [[NSMutableString alloc] initWithString:@""];
    }
    
    // 2
    [mCode setString:@""];
    
    // 3
    for (AVMetadataObject *metadataObject in metadataObjects) {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        
        // 4
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            [mCode appendFormat:@"%@ (QR)", readableObject.stringValue];
        } else if ([metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            [mCode appendFormat:@"%@ (EAN 13)", readableObject.stringValue];
        }
    }
    
    // 5
    if (![mCode isEqualToString:@""]) {
        [self dismissViewControllerAnimated:YES completion:nil];
}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([mCaptureSession isRunning] == NO)
        [mCaptureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([mCaptureSession isRunning])
        [mCaptureSession stopRunning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
