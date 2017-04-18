//
//  ViewController.m
//  CoreData简单使用
//
//  Created by changcai on 17/4/17.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "ViewController.h"
#import "Persion+CoreDataClass.h"
#import "TestViewController.h"
@interface ViewController ()
/** 创建coreData上下文对象，用于处理所有与存储相关的请求 */
@property (nonatomic, strong) NSManagedObjectContext *context;
/** 创建一个数组，用于存储数组的数据*/
@property (nonatomic, strong) NSMutableArray *totalData;


@property (weak, nonatomic) IBOutlet UIButton *insert;

@property (weak, nonatomic) IBOutlet UIButton *revampe;

@property (weak, nonatomic) IBOutlet UIButton *query;

@property (weak, nonatomic) IBOutlet UIButton *delete;

- (IBAction)insert:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)revampe:(UIButton *)sender;

- (IBAction)query:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"Persion.sqlite"]];//设置数据库的路径和文件名称和类型
    //添加持久化存储库，这里使用SQLite作为存储库
    NSError *error = nil;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    if(store == nil){//直接抛异常
         [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
    }
    //初始化上下文  设置persistentStoreCoordinator属性
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.persistentStoreCoordinator = psc;
    NSLog(@"%@",NSHomeDirectory());//数据库会存在沙盒目录的Documents文件夹下

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//插入数据
- (IBAction)insert:(id)sender {
    NSManagedObject *s1 = [NSEntityDescription insertNewObjectForEntityForName:@"Persion" inManagedObjectContext:self.context];
    [s1 setValue:@"小明" forKey:@"name"];
    [s1 setValue:@"001" forKey:@"uid"];
    [s1 setValue:@"www.test.com" forKey:@"url"];
    NSError *error = nil;
    BOOL isSuccess = [self.context save:&error];
    if(!isSuccess){
        [NSException raise:@"访问数据库错误" format:@"%@",[error localizedDescription]];
    }else{
        NSLog(@"插入成功");
    }
}
//删除数据
- (IBAction)delete:(id)sender {
    //删除之前首先需要用到查询
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; //创建请求
    request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];//找到我们的Person
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@", @"001"];//创建谓词语句，条件是uid等于001
    request.predicate = predicate; //赋值给请求的谓词语句
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];//执行我们的请求
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];//抛出异常
    }
    //遍历数据
    for (NSManagedObject *obj in objs) {
        NSLog(@"name = %@  uid = %@   url = %@", [obj valueForKey:@"name"],[obj valueForKey:@"uid"],[obj valueForKey:@"url"]); //打印符合条件的数据
        [self.context deleteObject:obj];//删除数据
    }
    BOOL success = [self.context save:&error];
    if (!success){
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }else{
        NSLog(@"删除成功，sqlite");
    }
}
//查询数据
- (IBAction)revampe:(UIButton *)sender {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];//创建请求
    request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];//找到我们的Person
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*小明*"];//查询条件：name等于小明
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];//执行请求
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }else{
        NSLog(@"查询成功，sqlite--%@", objs);
    }
}
//修改数据
- (IBAction)query:(UIButton *)sender {
    //修改数据，肯定也是要先查询，再修改
    NSFetchRequest *request = [[NSFetchRequest alloc] init];//创建请求
    request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];//找到我们的Person
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*小明*"];//查询条件：name等于小明
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];//执行请求
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    // 遍历数据
    for (NSManagedObject *obj in objs) {
        [obj setValue:@"小红" forKey:@"name"];//查到数据后，将它的name修改成小红
    }
    BOOL success = [self.context save:&error];
    
    if (!success) {
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
        
    }else
    {
        NSLog(@"修改成功");
    }
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.navigationController pushViewController:[[TestViewController alloc]init] animated:YES];
}
@end
