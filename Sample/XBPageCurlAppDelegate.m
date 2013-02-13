//
//  XBPageCurlAppDelegate.m
//  XBPageCurl
//
//  Created by xiss burg on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBPageCurlAppDelegate.h"
#import "RootViewController.h"

@implementation XBPageCurlAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *nibName = UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? @"RootViewController_iPad": @"RootViewController_iPhone";
    RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:nibName bundle:nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
