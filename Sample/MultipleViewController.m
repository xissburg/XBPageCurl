//
//  MultipleViewController.m
//  XBPageCurl
//
//  Created by xissburg on 3/7/13.
//
//

#import "MultipleViewController.h"
#import "XBCurlView.h"

@interface MultipleViewController ()

@property (nonatomic, strong) XBCurlView *topCurlView;
@property (nonatomic, strong) XBCurlView *bottomCurlView;

@end

@implementation MultipleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xissburg.com"]]];
    self.title = @"Multiple Views";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Buttons

- (IBAction)topCurlButtonTouchUpInside:(id)sender
{
    CGRect r = self.topView.frame;
    self.topCurlView = [[XBCurlView alloc] initWithFrame:r];
    self.topCurlView.opaque = NO; //Transparency on the next page (so that the view behind curlView will appear)
    self.topCurlView.pageOpaque = YES; //The page to be curled has no transparency
    [self.topCurlView curlView:self.topView cylinderPosition:CGPointMake(r.size.width/3, r.size.height/2) cylinderAngle:M_PI_2+0.23 cylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 80: 50 animatedWithDuration:0.6];
}

- (IBAction)topUncurlButtonTouchUpInside:(id)sender
{
    [self.topCurlView uncurlAnimatedWithDuration:0.6 completion:^{
        self.topCurlView = nil;
    }];
}

- (IBAction)bottomCurlButtonTouchUpInside:(id)sender
{
    CGRect r = self.bottomView.frame;
    self.bottomCurlView = [[XBCurlView alloc] initWithFrame:r];
    self.bottomCurlView.opaque = NO; //Transparency on the next page (so that the view behind curlView will appear)
    self.bottomCurlView.pageOpaque = YES; //The page to be curled has no transparency
    [self.bottomCurlView curlView:self.bottomView cylinderPosition:CGPointMake(r.size.width/3, r.size.height/2) cylinderAngle:M_PI_2+0.23 cylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 80: 50 animatedWithDuration:0.6];
}

- (IBAction)bottomUncurlButtonTouchUpInside:(id)sender
{
    [self.bottomCurlView uncurlAnimatedWithDuration:0.6 completion:^{
        self.bottomCurlView = nil;
    }];
}

@end
