//
//  XBPageCurlAppDelegate.m
//  XBPageCurl
//
//  Created by xiss burg on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBPageCurlAppDelegate.h"

@implementation XBPageCurlAppDelegate

@synthesize window=_window, rootViewController=_rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        _rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController_iPad" bundle:nil];
    }
    else {
        _rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController_iPhone" bundle:nil];
    }
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:self.rootViewController] autorelease];
    
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    self.rootViewController = nil;
    self.window = nil;
    [super dealloc];
}

@end
