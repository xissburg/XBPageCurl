//
//  PageCurlViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "XBPageDragView.h"

@interface PageCurlViewController : UIViewController

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *frontView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet XBPageDragView *pageDragView;

- (IBAction)buttonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)standardButtonAction:(id)sender;
- (IBAction)satelliteButtonAction:(id)sender;
- (IBAction)hybridButtonAction:(id)sender;
- (IBAction)saveImageButtonAction:(id)sender;

@end
