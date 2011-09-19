//
//  RootViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBCurlView.h"


@interface RootViewController : UIViewController {
    UIDatePicker *pickerView;
}

@property (nonatomic, retain) XBCurlView *curlView;
@property (nonatomic, retain) IBOutlet UIView *messyView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;

- (IBAction)curlButtonAction:(id)sender;
- (IBAction)uncurlButtonAction:(id)sender;

@end
