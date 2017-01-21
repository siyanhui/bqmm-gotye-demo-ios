//
//  GotyeAppDelegate.m
//  GotyeIM
//
//  Created by Peter on 14-9-26.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeAppDelegate.h"
#import "GotyeTabViewController.h"

#import "GotyeUIUtil.h"
#import "GotyeOCAPI.h"

//BQMM集成  引入头文件
#import <BQMM/BQMM.h>

#import <Bugly/Bugly.h>

#define DEFAULT_APPKEY      (@"0835b16b-1981-4e56-af09-72ce8aca5c5d")//*/(@"9c236035-2bf4-40b0-bfbf-e8b6dec54928")

void set_login_config(const char* server, int port);

@implementation GotyeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[GotyeTabViewController alloc] initWithNibName:@"GotyeTabViewController.xib" bundle:nil];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navController.navigationBar.translucent = NO;
    [self.navController.navigationBar setBarTintColor:Common_Color_Def_Nav];
    [self.navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window.rootViewController = self.navController;

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedAppKey = [userDefaults stringForKey:AppkeySelectedKey];
    if(selectedAppKey == nil || selectedAppKey.length == 0)
    {
        selectedAppKey = DEFAULT_APPKEY;
        [userDefaults setObject:selectedAppKey forKey:AppkeySelectedKey];
        [userDefaults synchronize];
    }
    
    [userDefaults setObject:selectedAppKey forKey:AppkeySelectedKey];
    [userDefaults setObject:DEFAULT_APPKEY forKey:AppkeyDefaultKey];
    
    [GotyeOCAPI init:selectedAppKey  packageName:@"gotyeimapp"];
    [GotyeOCAPI initIflySpeechRecognition];
    
    NSString *serverStr = [userDefaults stringForKey:ServerSelectedKey];
    if(selectedAppKey != nil && selectedAppKey.length > 0)
    {
        NSString *serverAddr = [serverStr substringToIndex:[serverStr rangeOfString:@":"].location];
        NSString *serverPort = [serverStr substringFromIndex:[serverStr rangeOfString:@":"].location + 1];
        set_login_config([serverAddr cStringUsingEncoding:NSUTF8StringEncoding], serverPort.integerValue);
    }
    
#ifdef __IPHONE_8_0
#if __IPHONE_8_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }
#endif
#else
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
#endif
    
    [self.window makeKeyAndVisible];
    //BQMM集成  初始化BQMM
    [[MMEmotionCentre defaultCentre] setAppId:@"15e0710942ec49a29d2224a6af4460ee"
                                       secret:@"b11e0936a9d04be19300b1d6eec0ccd5"];

    
    //初始化bugly
    [Bugly startWithAppId:@"900038006"];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"注册设备成功: %@", deviceToken);
#ifdef DEBUG
    NSString *certName = @"GotyeIMDev"; 
#else
    NSString *certName = @"GotyeIMDis";
#endif
    
    [GotyeOCAPI registerAPNS:[deviceToken description] certName:certName];
    //[GotyeAPI registerRemoteNotificationWithDeviceToken:deviceToken certName:certName];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"注册设备失败: %@", error);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"注册推送失败" message:[error description] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    int unread = [GotyeOCAPI getTotalUnreadMessageCount];
    application.applicationIconBadgeNumber = unread;
    [GotyeOCAPI updateUnreadMessageCount:unread];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[MMEmotionCentre defaultCentre] clearSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    self.navController.view.userInteractionEnabled = YES;
    //BQMM集成
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Foreground"
                                                        object:self
                                                      userInfo:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
