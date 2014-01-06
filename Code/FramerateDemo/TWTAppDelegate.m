//
//  TWTAppDelegate.m
//  FramerateDemo
//
//  Created by Kevin Conner on 1/6/14.
//  Copyright (c) 2014 Two Toasters. All rights reserved.
//

#import "TWTAppDelegate.h"
#import "TWTTableViewController.h"

@implementation TWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[TWTTableViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}
							
@end
