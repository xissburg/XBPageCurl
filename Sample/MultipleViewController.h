//
//  MultipleViewController.h
//  XBPageCurl
//
//  Created by xissburg on 3/7/13.
//
//

#import <UIKit/UIKit.h>

@interface MultipleViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *topView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

- (IBAction)topCurlButtonTouchUpInside:(id)sender;
- (IBAction)topUncurlButtonTouchUpInside:(id)sender;
- (IBAction)bottomCurlButtonTouchUpInside:(id)sender;
- (IBAction)bottomUncurlButtonTouchUpInside:(id)sender;

@end
