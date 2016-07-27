//
//  GotyeLoginController.m
//  GotyeIM
//
//  Created by Peter on 14-10-13.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeLoginController.h"

#import "GotyeUIUtil.h"

#import "GotyeOCAPI.h"
#import "GotyeSettingManager.h"

void set_login_config(const char* server, int port);

@interface GotyeLoginController () <GotyeOCDelegate>
{
    NSMutableArray *recentAppkeys;
    NSMutableArray *recentServers;
    UIPasteboard *appkeyPasteboard;
    UIPasteboard *serverPasteboard;
}

@end

@implementation GotyeLoginController

@synthesize textUsername, textPassword;
@synthesize contentView, textAppkey, textPort, textServer, appkeyTable, serverTable, serverView;

-(IBAction)doneClick:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)onBtnLoginClick:(id)sender
{
    if(textUsername.text.length > 0)
    {
        NSString *password = textPassword.text.length > 0 ? textPassword.text : nil;
        
        if([GotyeOCAPI login:textUsername.text password:password] == GotyeStatusCodeWaitingCallback)
            [GotyeUIUtil showHUD:@"登录中" toView:self.view];
    }
}

-(IBAction)addServerClick:(id)sender
{
    if(textServer.text.length > 0 && textPort.text.length > 0)
    {
        NSString *serverStr = [NSString stringWithFormat:@"%@:%@", textServer.text, textPort.text];
        if(![recentServers containsObject:serverStr])
        {
            [recentServers addObject:serverStr];
            
            [serverTable reloadData];
        }
    }
}

-(IBAction)deleteServerClick:(id)sender
{
    NSString *serverStr = [NSString stringWithFormat:@"%@:%@", textServer.text, textPort.text];
    if([recentServers containsObject:serverStr])
    {
        [recentServers removeObject:serverStr];
        
        textServer.text = @"";
        textPort.text = @"";
        
        [serverTable reloadData];
    }
}

-(IBAction)addAppkeyClick:(id)sender
{
    if(textAppkey.text.length > 0)
    {
        if(![recentAppkeys containsObject:textAppkey.text])
        {
            [recentAppkeys addObject:textAppkey.text];
            
            [appkeyTable reloadData];
        }
    }
}

-(IBAction)deleteAppkeyClick:(id)sender
{
    if([recentAppkeys containsObject:textAppkey.text])
    {
        [recentAppkeys removeObject:textAppkey.text];
        
        [appkeyTable reloadData];
        
        textAppkey.text = @"";
    }
}

-(IBAction)saveSettingClick:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(textAppkey.text.length > 0)
    {
        [userDefaults setObject:textAppkey.text forKey:AppkeySelectedKey];
        [GotyeOCAPI init:textAppkey.text packageName:@"gotyeimapp"];
    }
    
    //if(textServer.text.length > 0 && textPort.text.length > 0)
    {
        NSString *serverStr = [NSString stringWithFormat:@"%@:%@", textServer.text, textPort.text];
        [userDefaults setObject:serverStr forKey:ServerSelectedKey];
        
        set_login_config([textServer.text cStringUsingEncoding:NSUTF8StringEncoding], textPort.text.intValue);
    }
    
    [userDefaults synchronize];
    appkeyPasteboard.strings = recentAppkeys;
    serverPasteboard.strings = recentServers;
    
    [contentView scrollRectToVisible:CGRectMake(0, 0, ScreenWidth, 480) animated:YES];
}

- (void)onLogin:(GotyeStatusCode)code user:(GotyeOCUser *)user
{
    if(code == GotyeStatusCodeOK || code == GotyeStatusCodeOfflineLoginOK || code == GotyeStatusCodeReloginOK)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[GotyeSettingManager defaultManager] setLoginUserName:[GotyeOCAPI getLoginUser].name];
        
        [GotyeOCAPI beginReceiveOfflineMessage];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:textUsername.text forKey:LoginUserNameKey];
        [userDefaults setObject:textPassword.text forKey:LoginPasswordKey];
        [userDefaults setBool:NO forKey:AutoLoginKey];
        [userDefaults synchronize];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"登录失败"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [GotyeUIUtil hideHUD:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appkeyPasteboard = [UIPasteboard pasteboardWithName:AppkeyRecentKey create:YES];
    appkeyPasteboard.persistent = YES;

    serverPasteboard = [UIPasteboard pasteboardWithName:ServerRecentKey create:YES];
    serverPasteboard.persistent = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    contentView.contentSize = CGSizeMake(ScreenWidth * 2, contentView.frame.size.height);
    [contentView addSubview:serverView];
    serverView.frame = CGRectMake(contentView.frame.size.width, 0, serverView.frame.size.width, serverView.frame.size.height);
    serverView.hidden = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    textUsername.text = [userDefaults stringForKey:LoginUserNameKey];
    textPassword.text = [userDefaults stringForKey:LoginPasswordKey];
    
    recentAppkeys = [NSMutableArray arrayWithArray:appkeyPasteboard.strings];
    if (![recentAppkeys containsObject:[userDefaults objectForKey:AppkeyDefaultKey]]) {
        [recentAppkeys addObject:[userDefaults objectForKey:AppkeyDefaultKey]];
    }
    textAppkey.text = [userDefaults stringForKey:AppkeySelectedKey];
    
    recentServers = [NSMutableArray arrayWithArray:serverPasteboard.strings];
    NSString *serverStr = [userDefaults stringForKey:ServerSelectedKey];
    NSRange colon = [serverStr rangeOfString:@":"];
    if(colon.length == 1)
    {
        textServer.text = [serverStr substringToIndex:colon.location];
        textPort.text = [serverStr substringFromIndex:colon.location + 1];
    }
    
    [serverTable reloadData];
    [appkeyTable reloadData];
    
    NSUInteger index = [recentAppkeys indexOfObject:textAppkey.text];
    if(index<recentAppkeys.count)
    {
        [appkeyTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL autologin = [userDefaults boolForKey:AutoLoginKey];
    if(autologin)
    {
        //[self onBtnLoginClick:nil];
        
        [self performSelector:@selector(onBtnLoginClick:) withObject:nil afterDelay:0.2];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == appkeyTable)
        return recentAppkeys.count;
    else
        return recentServers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AppKeyCellIdentifier = @"AppKeyCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AppKeyCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AppKeyCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSString *str;
    if(tableView == appkeyTable)
        str = [recentAppkeys objectAtIndex:indexPath.row];
    else
        str = [recentServers objectAtIndex:indexPath.row];
    
    cell.indentationWidth = 0;
    cell.indentationLevel = 1;
    cell.textLabel.text = str;
    cell.textLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == appkeyTable)
        textAppkey.text = [recentAppkeys objectAtIndex:indexPath.row];
    else
    {
        NSString *serverStr = [recentServers objectAtIndex:indexPath.row];
        NSRange colon = [serverStr rangeOfString:@":"];
        if(colon.length == 1)
        {
            textServer.text = [serverStr substringToIndex:colon.location];
            textPort.text = [serverStr substringFromIndex:colon.location + 1];
        }
    }
}

@end
