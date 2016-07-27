//
//  GotyeGroupListController.m
//  GotyeIM
//
//  Created by Peter on 14-10-9.
//  Copyright (c) 2014年 Gotye. All rights reserved.
//

#import "GotyeGroupListController.h"

#import "GotyeContactViewController.h"
#import "GotyeUIUtil.h"

#import "GotyeOCAPI.h"

#import "GotyeChatViewController.h"

#import "GotyeGroupSearchController.h"

#import "GotyeLoadingView.h"

@interface GotyeGroupListController () <GotyeOCDelegate>
{
    GotyeLoadingView *loadingView;
    BOOL haveMoreData;
    int  _pageIndex;
}
@end

#define TestCount 10

@implementation GotyeGroupListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    self.navigationItem.title = @"我的群组";
    
    grouplistReceive = [GotyeOCAPI getLocalGroupList];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"nav_button_search"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(groupSearchClick:)];
    
    _pageIndex = 1;
    haveMoreData = YES;
    loadingView = [[GotyeLoadingView alloc] init];
    loadingView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GotyeOCAPI addListener:self];
    
    [GotyeOCAPI reqGroupList:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GotyeOCAPI removeListener:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)groupSearchClick:(UIButton*)sender
{
    GotyeGroupSearchController *viewController = [[GotyeGroupSearchController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(loadingView.hidden && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height +20)
    {
        loadingView.frame = CGRectMake(0, scrollView.contentSize.height, ScreenWidth, 40);
        [scrollView insertSubview:loadingView atIndex:0];
        loadingView.hidden = NO;
        [loadingView showLoading:haveMoreData];
        
        if(haveMoreData)
        {
            _pageIndex ++;
            [GotyeOCAPI reqGroupList:_pageIndex];
        }
    }
}

#pragma mark - Gotye UI delegates

- (void)onGetGroupList:(GotyeStatusCode)code pageIndex:(unsigned)pageIndex grouplist:(NSArray *)grouplist
{
    if (grouplist.count == grouplistReceive.count) {
        haveMoreData = NO;
    }
    grouplistReceive = grouplist;
    
    [self.tableView reloadData];
    loadingView.hidden = YES;

    for(GotyeOCGroup* group in grouplist)
        [GotyeOCAPI downloadMedia:group.icon];
}

-(void)onDownloadMedia:(GotyeStatusCode)code media:(GotyeOCMedia*)media
{
    for (int i=0; i<grouplistReceive.count; i++)
    {
        GotyeOCGroup* group = grouplistReceive[i];
        if([group.icon.path isEqualToString:media.path])
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

#pragma mark - table delegate & data

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return grouplistReceive.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ContactCellIdentifier = @"ContactCellIdentifier";
    
    GotyeContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GotyeContactCell" owner:self options:nil] firstObject];
    }
    
    GotyeOCGroup* group = grouplistReceive[indexPath.row];

    cell.imageHead.image = [GotyeUIUtil getHeadImage:group.icon.path defaultIcon:@"head_icon_group"];
    
    cell.labelUsername.text = group.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GotyeOCGroup* group = grouplistReceive[indexPath.row];
    
    GotyeChatViewController*viewController = [[GotyeChatViewController alloc] initWithTarget:group];
    [self.navigationController pushViewController:viewController animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
