//
//  AppDelegate.h
//  CoreData简单使用
//
//  Created by changcai on 17/4/17.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

