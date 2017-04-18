//
//  TestViewController.m
//  CoreData简单使用
//
//  Created by changcai on 17/4/18.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "TestViewController.h"
#import "AppDelegate.h"
#import "Student+CoreDataClass.h"
static NSString *cellIdentifier = @"UITableViewCell";
@interface TestViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 创建表视图  */
@property (nonatomic, strong) UITableView *tableView;
/** 创建coreData上下文对象，用于处理所有与存储相关的请求 */
@property (nonatomic, strong) NSManagedObjectContext *myContext;
/** 创建一个数组，用于存储数组的数据*/
@property (nonatomic, strong) NSMutableArray *allData;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self setRightNavigationBarItem];
    //1、创建模型对象
    //获取模型路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataBasis" withExtension:@"momd"];
    //根据模型文件创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    // NSManagedObjectModel *model = [NSManagedObjectModel  mergedModelFromBundles:nil];
    //2、创建持久化助理
    //利用模型对象创建助理对象
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //数据库的名称和路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"Student.sqlite"];
    NSLog(@"path = %@", sqlPath);
    NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
    //设置数据库相关信息
    //添加存储器
    /**
     * type:一般使用数据库存储方式NSSQLiteStoreType
     * configuration:配置信息 一般无需配置
     * URL:要保存的文件路径
     * options:参数信息 一般无需设置
     */
    NSError *error = nil;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
    if(store == nil){//直接抛异常
        [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
    }
    //3、创建上下文
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //关联持久化助理
    [context setPersistentStoreCoordinator:store];
    _myContext = context;
    self.allData = [NSMutableArray array];
    // 通过CoreData读取本地所有的数据
    [self getAllDataFromCoreData];
    
}

// 点击cell的响应事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 先查询
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.myContext];
    [fetchRequest setEntity:entity];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.myContext executeFetchRequest:fetchRequest error:&error];
    Student *stu = self.allData[indexPath.row];
    stu.name = @"尼古拉斯-赵四";
    stu.age = 15;
    // 更新数据源
    [self.allData removeAllObjects];
    [self.allData addObjectsFromArray:fetchedObjects];
    // 刷新UI
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    // 将修改本地持久化
    NSError *error1 = nil;
    BOOL success = [self.myContext save:&error1];
    if (!success) {
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }else
    {
        NSLog(@"修改成功");
    }
}
//设定编辑时间右滑删除

// 当点击tableViewCell的删除按钮的时候回调用(提交编辑请求的时候)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取当前cell代表的数据
    Student *stu = self.allData[indexPath.row];
    // 更新数据源
    [self.allData removeObject:stu];
    // 更新UI
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // 将临时数据库里进行删除并进行本地持久化
    [self.myContext deleteObject:stu];
    NSError *error = nil;
    BOOL success = [self.myContext save:&error];
    if (!success) {
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }else
    {
        NSLog(@"修改成功");
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Student *stu = self.allData[indexPath.row];
    cell.textLabel.text = stu.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",stu.age];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)setRightNavigationBarItem
{
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 20);
    [rightButton setTitle:@"添加" forState:UIControlStateNormal];
    rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)getAllDataFromCoreData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.myContext];
    [fetchRequest setEntity:entity];
    // 排序条件
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSError *error = nil;
    NSMutableArray<Student *> *array = [NSMutableArray array];
    NSArray *fetchedObjects = [self.myContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count == 0) {
        NSEntityDescription *stuDis = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.myContext];
        Student *stu = [[Student alloc] initWithEntity:stuDis insertIntoManagedObjectContext:self.myContext];
        // 给属性赋值
        stu.name = @"李四";
        stu.age = arc4random() % 73 + 1;
        [array addObject:stu];
        [self.allData addObjectsFromArray:array];
    }else{
       // 将查询到的数据添加到数据源
       [self.allData addObjectsFromArray:fetchedObjects];
    }
    // 从新加载tableView
    [self.tableView reloadData];
}

- (void) rightButtonClick:(UIButton *)sender
{
    // 创建student对象
    // 创建一个实体描述对象
    NSEntityDescription *stuDis = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.myContext];
    Student *stu = [[Student alloc] initWithEntity:stuDis insertIntoManagedObjectContext:self.myContext];
    // 给属性赋值
    stu.name = @"张三";
    stu.age = arc4random() % 73 + 1;
    // 更新数据源
    [self.allData addObject:stu];
    // 修改界面
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.allData.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    // 将数据保存到文件中进行持久化
    NSError *error = nil;
    BOOL success = [self.myContext save:&error];
    if (!success) {
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }else
    {
        NSLog(@"修改成功");
    }
    [((AppDelegate *)[UIApplication sharedApplication].delegate) saveContext];
}


@end
