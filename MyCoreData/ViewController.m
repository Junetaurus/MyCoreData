//
//  ViewController.m
//  MyCoreData
//
//  Created by Taurus on 16/5/28.
//  Copyright © 2016年 Taurus. All rights reserved.
//

#import "ViewController.h"

#import "MyCoreDataManager.h"
#import "UserInfor.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (void)initView
{
    //addRightBarItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addDataSource)];
    
    //addLeftBarItem
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteALLDataSource)];
    
    //addCenterBarItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"查找" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(searchDataSource) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = btn;
    
    //addTableView
    self.tableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //addDataSorce
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserInfor"];
    NSError *error = nil;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:NO];
    NSArray *array = [[MyCoreDataManager shareCoreDataManager].managedObjectContext executeFetchRequest:request error:&error];
    [self.dataSource addObjectsFromArray:[array sortedArrayUsingDescriptors:@[sortDescriptor]]];
}

#pragma mark - addDataSource
- (void)addDataSource
{
    NSEntityDescription *description = [NSEntityDescription entityForName:@"UserInfor" inManagedObjectContext:[MyCoreDataManager shareCoreDataManager].managedObjectContext];
    
    UserInfor *user = [[UserInfor alloc] initWithEntity:description insertIntoManagedObjectContext:[MyCoreDataManager shareCoreDataManager].managedObjectContext];
    
    user.name = @"Jack";
    user.age = [NSString stringWithFormat:@"%u",arc4random() % 100 + 1];
    
    unsigned int sexId = arc4random() % 2 + 1;
    if (sexId == 1) {
        user.sex = @"男";
    } else {
        user.sex = @"女";
    }
    
    [self.dataSource addObject:user];
    [[MyCoreDataManager shareCoreDataManager] saveContext];
    
    //inserDataSource
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    //scrowBottom
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - deleteALLDataSource
- (void)deleteALLDataSource
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserInfor"];
    NSError *error = nil;
    NSArray *array = [[MyCoreDataManager shareCoreDataManager].managedObjectContext executeFetchRequest:request error:&error];
    if (!error && array.count) {
        for (UserInfor *user in array) {
            [[MyCoreDataManager shareCoreDataManager].managedObjectContext deleteObject:user];
            if ([self.dataSource containsObject:user]) {
                [self.dataSource removeObject:user];
            }
        }
        [[MyCoreDataManager shareCoreDataManager] saveContext];
    }
    [self.tableView reloadData];
}

#pragma mark - searchDataSource
- (void)searchDataSource
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"查找数据" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.delegate = self;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.placeholder = @"请输入查询条件";
    [alertView show];
}

#pragma mark - tableViewDelegateAndDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    UserInfor *user = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@--%@--%@",user.name,user.sex,user.age];
    return cell;
}

- (NSArray <UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleGateAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[MyCoreDataManager shareCoreDataManager].managedObjectContext deleteObject:_dataSource[indexPath.row]];
        [[MyCoreDataManager shareCoreDataManager] saveContext];
        [_dataSource removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [_dataSource exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
        [_tableView reloadData];
    }];
    topRowAction.backgroundColor = [UIColor blueColor];
    
    NSArray *testArr = @[deleGateAction,topRowAction];
    return testArr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfor *user = self.dataSource[indexPath.row];
    user.name = @"Tom";
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[MyCoreDataManager shareCoreDataManager] saveContext];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.dataSource removeAllObjects];
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserInfor"];
        NSError *error = nil;
        NSArray *array = [[MyCoreDataManager shareCoreDataManager].managedObjectContext executeFetchRequest:request error:&error];
        if (!error || array.count > 0) {
            for (UserInfor *user in array) {
                if ([user.age integerValue] == [textField.text integerValue]) {
                    [self.dataSource addObject:user];
                }
            }
        }
        [self.tableView reloadData];
    }
}

@end
