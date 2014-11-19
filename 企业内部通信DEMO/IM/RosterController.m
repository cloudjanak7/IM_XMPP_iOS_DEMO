//
//  RosterController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-14.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "RosterController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface RosterController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    NSFetchedResultsController *_fetchedReseultController;
    NSIndexPath *_removeIndexPath;
}


@end

@implementation RosterController

#pragma mark - AppDelegate助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFetchedController];
}

#pragma mark - UITableView数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fetchedReseultController.sections.count;
}

#pragma mark - 实例化NSFetchedResultsController
- (void)setupFetchedController
{
    //针对CoreData做数据访问，无论怎么包装，都离不开NSManagedObjectContext
    NSManagedObjectContext *context = [[[self appDelegate] xmppRosterStorage] mainThreadManagedObjectContext];
    //实例化
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    [request setSortDescriptors:@[sort]];
    
    _fetchedReseultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"sectionNum" cacheName:nil];
    
    //设置fetchedresultsController的代理
    _fetchedReseultController.delegate = self;
    
    //查询数据
    NSError *error = nil;
    if (![_fetchedReseultController performFetch:&error])
    {
        NSLog(@"error ---- > %@",[error description]);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
#pragma mark 控制器数据发生改变(因为Roster是添加了代理的)
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //当数据变化时，重新刷新表格
    [self.tableView reloadData];
}

#pragma mark - 对应分组中单元格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionData = _fetchedReseultController.sections;
    if (sectionData.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sectionData objectAtIndex:section];
        NSLog(@"num --- > %lu", [sectionInfo numberOfObjects]);
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //1.取出控制器中的所有分组
    NSArray *array = [_fetchedReseultController sections];
    //2.根据section值取出对应的分组信息对象
    id <NSFetchedResultsSectionInfo> sectionInfo = array[section];
    NSString *stateName = nil;
    NSInteger state = [[sectionInfo name] integerValue];
    switch (state)
    {
        case 0:
            stateName = @"在线";
            break;
        case 1:
            stateName = @"离开";
            break;
        case 2:
            stateName = @"下线";
            break;
        default:
            stateName = @"未知";
            break;
    }
    return stateName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"RosterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    XMPPUserCoreDataStorageObject *user = [_fetchedReseultController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    //    cell.imageView.image = [self loadUserImage:user];
    
    return cell;
}

#pragma mark - tableview delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //1.取出当前的用户数据
        XMPPUserCoreDataStorageObject *user = [_fetchedReseultController objectAtIndexPath:indexPath];
        _removeIndexPath = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除好友" message:user.jidStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        XMPPUserCoreDataStorageObject *user = [_fetchedReseultController objectAtIndexPath:_removeIndexPath];
        //2.将用户数据删除
        [[xmppDelegate xmppRoster] removeUser:user.jid];
    }
}

//#pragma mark 加载头像
//- (UIImage *)loadUserImage:(XMPPUserCoreDataStorageObject *)user
//{
//    if (user.photo)
//    {
//        return user.photo;
//    }
//
//    NSData *photoData = [self appDelegate] xmp
//}
@end
