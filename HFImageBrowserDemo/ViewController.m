//
//  ViewController.m
//  HFImageBrowserDemo
//
//  Created by liuguangde on 15/10/24.
//  Copyright © 2015年 liuguangde. All rights reserved.
//

#import "ViewController.h"
#import "HFImageBrowser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 100, screenWidth - 30, 200.0)];
    [imgView setImage:[UIImage imageNamed:@"test.jpg"]];
    [self.view addSubview:imgView];
    
    HFImageBrowser *imgBrowser = [HFImageBrowser sharedInstance];
    [imgBrowser setBrowseImageView:imgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
