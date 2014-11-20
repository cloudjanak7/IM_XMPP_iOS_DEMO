//
//  VCardController.m
//  企业内部通信DEMO
//
//  Created by 东华创元 on 14-10-11.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "VCardController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "LoginUser.h"
#import "EditvCardController.h"
#import "NSString+Helper.h"

@interface VCardController () <EditvCardControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
{
    NSArray *_titlesArray;
    NSArray *_titleLableArray;
}

@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *nickNameText;
@property (strong, nonatomic) IBOutlet UILabel *jidText;
@property (strong, nonatomic) IBOutlet UILabel *orgNameText;
@property (strong, nonatomic) IBOutlet UILabel *orgUnitText;
@property (strong, nonatomic) IBOutlet UILabel *titleText;
@property (strong, nonatomic) IBOutlet UILabel *photoNumberText;
@property (strong, nonatomic) IBOutlet UILabel *emailText;



@end

@implementation VCardController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titlesArray = @[@[@"头像",@"姓名",@"JID"],@[@"公司",@"部门",@"职务",@"电话",@"邮件"]];
    
    _titleLableArray = @[@[_jidText,_nickNameText,_jidText],
                         @[_orgNameText,_orgUnitText,_titleText,_photoNumberText,_emailText]];
    
    [self setupvCard];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePhoto)];
    [_headImageView addGestureRecognizer:tap];
}


- (IBAction)logout:(id)sender
{
    [[self appDelegate] logout];
}

#pragma mark - AppDelegate助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark - 电子名片处理方法
- (void)setupvCard
{
    //获取当前账号的电子名片
    XMPPvCardTemp *myCard = [[[self appDelegate] xmppvCardModule] myvCardTemp];
    
    //判断当前账号是否有电子名片
    if (myCard == nil)
    {
        NSLog(@"没有电子名片");
        //新建电子名片
        myCard = [XMPPvCardTemp vCardTemp];
        //设置昵称
        myCard.nickname = [[LoginUser sharedLoginUser] userName];
    }
    //设置jid
    if (myCard.jid == nil)
    {
        myCard.jid = [XMPPJID jidWithString:[[LoginUser sharedLoginUser] myJIDName]];
    }
    
    //保存电子名片
    [[[self appDelegate] xmppvCardModule] updateMyvCardTemp:myCard];
    
    NSData *photoData = [[xmppDelegate xmppvCardAvatarModule] photoDataForJID:myCard.jid];
    //使用myCard
    if (photoData)
    {
        NSLog(@"myCard --- %ld", myCard.photo.length);
        _headImageView.image = [UIImage imageWithData:photoData];
    }
    
    _nickNameText.text = myCard.nickname;
    _jidText.text = [myCard.jid full];
    _orgNameText.text = myCard.orgName;
    if (myCard.orgUnits)
    {
        _orgUnitText.text = myCard.orgUnits[0];
    }
    _titleText.text = myCard.title;
    _photoNumberText.text = myCard.note;
    _emailText.text = myCard.mailer;
}

#pragma mark UITableView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 1)
    {
        [self performSegueWithIdentifier:@"EditvCardSeue" sender:indexPath];
    }
    if (cell.tag == 2)
    {
        [self changePhoto];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender
{
    EditvCardController *controller = segue.destinationViewController;
    controller.title = _titlesArray[sender.section][sender.row];
    controller.contentLabel = _titleLableArray[sender.section][sender.row];
    controller.delegate = self;
}

#pragma mark - 更新电子名片
- (void)savevCard
{
    XMPPvCardTemp *myCard = [[[self appDelegate] xmppvCardModule] myvCardTemp];
    myCard.photo = UIImagePNGRepresentation(_headImageView.image);
    myCard.nickname = [_nickNameText.text trimString];
    myCard.orgName = [_orgNameText.text trimString];
    myCard.orgUnits = @[[_orgUnitText.text trimString]];
    myCard.title = [_titleText.text trimString];
    myCard.note = [_photoNumberText.text trimString];
    myCard.mailer = [_emailText.text trimString];
    //保存电子名片
    [[[self appDelegate] xmppvCardModule] updateMyvCardTemp:myCard];
}

#pragma mark - 编辑电子名片视图控制代理方法
- (void)editvCardControllerDidFinished
{
    [self savevCard];
}

#pragma mark - 手势
- (void)changePhoto
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2)
    {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (buttonIndex == 0)
    {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    _headImageView.image = image;
    [self savevCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
