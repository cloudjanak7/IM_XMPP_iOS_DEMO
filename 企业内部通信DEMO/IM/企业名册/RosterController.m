//
//  RosterController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-14.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "RosterController.h"
#import <CoreData/CoreData.h>
#import "ChatMessageViewController.h"
#import "XMPPGroupCoreDataStorageObject.h"
#import "ChineseToPinyin.h"

@interface RosterController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    NSIndexPath *_removeIndexPath;
}
/** 查询结果集 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedReseultController;
/** 朋友按组形成字典 */
@property (nonatomic, strong) NSMutableDictionary *friendsDict;
/** 组名数组 */
@property (nonatomic, strong) NSMutableDictionary *groupName;
/** 数据处理上下文 */
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation RosterController

#pragma mark - lazy load
- (NSFetchedResultsController *)fetchedReseultController
{
    if (!_fetchedReseultController)
    {
        //实例化
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
        
        NSSortDescriptor *sortSectionNum = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sortDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        
        [request setSortDescriptors:@[sortSectionNum, sortDisplayName]];
        
        _fetchedReseultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:@"sectionNum" cacheName:@""];
        
        //设置fetchedresultsController的代理
        _fetchedReseultController.delegate = self;
        
        //查询数据
        NSError *error = nil;
        if (![_fetchedReseultController performFetch:&error])
        {
            NSLog(@"error ---- > %@",[error description]);
        }
    }
    return _fetchedReseultController;
}

- (NSMutableDictionary *)groupName
{
    if (!_groupName)
    {
        _groupName = [NSMutableDictionary dictionary];
        [self getGroupNameFromFetchRequest];
        NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:@"未分组"];
        [_groupName setObject:@"未分组" forKey:pinyin];
    }
    return _groupName;
}

- (NSManagedObjectContext *)context
{
    if (!_context)
    {
        _context = [[[XMPPTool sharedXMPPTool] xmppRosterStorage] mainThreadManagedObjectContext];
    }
    return _context;
}

- (NSMutableDictionary *)friendsDict
{
    if (!_friendsDict)
    {
        _friendsDict = [NSMutableDictionary dictionary];
        [self fetchedObjcToDict];
    }
    return _friendsDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)dealloc
{
    _fetchedReseultController = nil;
}
#pragma mark - private
#pragma mark 将查询的结果存入字典
- (void)fetchedObjcToDict
{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (NSString *keyName in self.groupName.allKeys)
    {
        [dictM setObject:[NSMutableArray array] forKey:keyName];
    }
    NSString *lastKey = [self.groupName.allKeys lastObject];
    for (XMPPUserCoreDataStorageObject *user in self.fetchedReseultController.fetchedObjects)
    {
        XMPPGroupCoreDataStorageObject *group = [user.groups anyObject];
        for (NSString *keyName in self.groupName.allKeys)
        {
            if ([self.groupName[keyName] isEqualToString:group.name])
            {
                [dictM[keyName] addObject:user];
            }
        }
        if (group.name.length == 0)
        {
            [dictM[lastKey] addObject:user];
        }
    }

    NSMutableSet *cleanSet = [NSMutableSet set];
    for (id Obj in dictM.allKeys) {
        NSArray *array = dictM[Obj];
        if (array.count == 0)
        {
            [cleanSet addObject:Obj];
        }
    }
    
    for (id Obj in cleanSet)
    {
        [dictM removeObjectForKey:Obj];
        [self.groupName removeObjectForKey:Obj];
    }
    self.friendsDict = dictM;
}

#pragma mark 从XMPPGroupCoreDataStorageObject中获取所有组名
- (void)getGroupNameFromFetchRequest
{
    //实例化
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPGroupCoreDataStorageObject"];
    
    NSSortDescriptor *sortDisplayName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    [request setSortDescriptors:@[sortDisplayName]];
    
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    for (XMPPGroupCoreDataStorageObject *group in array)
    {
        NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:group.name];
        [self.groupName setObject:group.name forKey:pinyin];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
#pragma mark 控制器数据发生改变(因为Roster是添加了代理的)
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.friendsDict = nil;
    //当数据变化时，重新刷新表格
    [self.tableView reloadData];
}

#pragma mark - TableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.friendsDict.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.groupName.allKeys[section];
    return [self.friendsDict[key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = self.groupName.allKeys[section];
    return self.groupName[key];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"RosterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    
    NSString *key = self.groupName.allKeys[indexPath.section];
    XMPPUserCoreDataStorageObject *user = self.friendsDict[key][indexPath.row];
    
    cell.textLabel.text = user.displayName;
    
    switch ([user.sectionNum integerValue])
    {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
            
        default:
            break;
    }
    
    cell.imageView.image = [self loadUserImage:user];
    
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ChatSegue" sender:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //1.取出当前的用户数据
        NSString *key = self.groupName.allKeys[indexPath.section];
        XMPPUserCoreDataStorageObject *user = self.friendsDict[key][indexPath.row];
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
        NSString *key = self.groupName.allKeys[_removeIndexPath.section];
        XMPPUserCoreDataStorageObject *user = self.friendsDict[key][_removeIndexPath.row];
        //2.将用户数据删除
        [[[XMPPTool sharedXMPPTool] xmppRoster] removeUser:user.jid];
    }
}

#pragma mark - 加载头像
- (UIImage *)loadUserImage:(XMPPUserCoreDataStorageObject *)user
{
    if (user.photo)
    {
        //user有直接返回
        return user.photo;
    }
    //没有，从用户头像模块取用户头像数据
    NSData *photoData = [[[XMPPTool sharedXMPPTool] xmppvCardAvatarModule] photoDataForJID:user.jid];
    if (photoData)
    {
        return [UIImage imageWithData:photoData];
    }
    return [UIImage imageNamed:@"DefaultProfileHead"];
}

#pragma mark - 准备Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)indexPath
{
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[ChatMessageViewController class]])
    {
        ChatMessageViewController *controller = destVC;
        //获取当前选中的用户
        NSString *key = self.groupName.allKeys[indexPath.section];
        XMPPUserCoreDataStorageObject *user = self.friendsDict[key][indexPath.row];
        controller.bareJidStr = user.jidStr;
        NSData *barePhoto = [[[XMPPTool sharedXMPPTool]  xmppvCardAvatarModule] photoDataForJID:user.jid];
        controller.bareImage = [UIImage imageWithData:barePhoto];
        NSString *myJID = [UserInfo sharedUserInfo].jid;
        NSData *myPhoto = [[[XMPPTool sharedXMPPTool]  xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:myJID]];
        controller.myImage = [UIImage imageWithData:myPhoto];
    }
}
@end
