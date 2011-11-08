//
//  RootViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
