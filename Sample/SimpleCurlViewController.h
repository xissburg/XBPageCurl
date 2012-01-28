//
//  SimpleCurlViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBCurlView.h"


@interface SimpleCurlViewController : UIViewController <UITextFieldDelegate> {
    UIDatePicker *pickerView;
}

@property (nonatomic, retain) XBCurlView *curlView;
@property (nonatomic, retain) IBOutlet UIView *messyView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITextView *textView;

- (IBAction)curlButtonAction:(id)sender;
- (IBAction)uncurlButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end
