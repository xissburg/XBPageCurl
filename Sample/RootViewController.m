//
//  RootViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#define kNameKey @"name"
#define kNibNameKey @"nib"


@interface RootViewController ()

@property (nonatomic, retain) NSMutableArray *dataArray;

@end


@implementation RootViewController

@synthesize tableView=_tableView, dataArray;

- (void)dealloc
{
    self.tableView = nil;
    self.dataArray = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"XBPageCurl Demos";
    self.dataArray = [NSMutableArray array];
    [self.dataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Simple Curl", kNameKey, @"SimpleCurlViewController", kNibNameKey, nil]];
    [self.dataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Page Curl", kNameKey, @"PageCurlViewController", kNibNameKey, nil]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    self.dataArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *item = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:kNameKey];

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = [self.dataArray objectAtIndex:indexPath.row];
    NSString *baseClassName = [item objectForKey:kNibNameKey];
    NSString *postfix = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? @"_iPad": @"_iPhone";
    NSString *className = [baseClassName stringByAppendingString:postfix];
    Class viewControllerClass = NSClassFromString(className);
    
    if (viewControllerClass == nil) {
        viewControllerClass = NSClassFromString(baseClassName);
    }
    
    UIViewController *viewController = [[viewControllerClass alloc] initWithNibName:className bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

@end
