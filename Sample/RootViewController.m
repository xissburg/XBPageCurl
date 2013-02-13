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

@property (nonatomic, copy) NSArray *demosArray;

@end


@implementation RootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"XBPageCurl Demos";
    self.demosArray = @[@{kNameKey : @"Simple Curl", kNibNameKey : @"SimpleCurlViewController"}, @{kNameKey: @"Page Curl", kNibNameKey : @"PageCurlViewController"}];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.demosArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.demosArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *demo = self.demosArray[indexPath.row];
    cell.textLabel.text = demo[kNameKey];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.demosArray[indexPath.row];
    NSString *baseClassName = item[kNibNameKey];
    NSString *postfix = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? @"_iPad": @"_iPhone";
    NSString *className = [baseClassName stringByAppendingString:postfix];
    Class viewControllerClass = NSClassFromString(className);
    
    if (viewControllerClass == nil) {
        viewControllerClass = NSClassFromString(baseClassName);
    }
    
    UIViewController *viewController = [[viewControllerClass alloc] initWithNibName:className bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
