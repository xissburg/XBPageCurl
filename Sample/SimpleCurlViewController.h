//
//  SimpleCurlViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBCurlView.h"


@interface SimpleCurlViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) XBCurlView *curlView;
@property (nonatomic, weak) IBOutlet UIView *messyView;
@property (nonatomic, weak) IBOutlet UIView *backView;

- (IBAction)curlButtonAction:(id)sender;
- (IBAction)uncurlButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end
