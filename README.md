# CoreData-
CoreData简单使用
先理解几个概念：
1.NSManagedObjectContext（负责应用和数据库的交互，所有对数据库的操作都是通过它来完成的）
NSManagedObjectContext拥有一个NSPersistentStoreCoordinator类的实例对象
2.NSPersistentStoreCoordinator（用来添加持久化存储库，这里是SQLite数据库）

NSPersistentStoreCoordinator拥有一个 NSManagedObjectModel类的实例对象 存储调度器: 负责将数据保存到磁盘，

3. NSManagedObjectModel（CoreData的模型文件，本例中就是上面创建CoreDataBasis.xcdatamodeld的模型）

NSManagedObjectModel有entities(数组)这个属性（本例中就是指Person,因为只创建了Person这一个实体，所以数组中就只有这一个元素）

4.NSManagedObject 托管对象类，所有CoreData中的托管对象都必须继承自当前类，根据实体创建托管对象类文件。（对象模型，例如下面代码中要新建的personOne） 

5.NSEntityDescription(用来描述实体)想要添加到数据库的模型不能用alloc init 来创建，只能用NSEntityDescription来描述

CoreData简单创建流程

模型文件操作

1.1 创建模型文件，后缀名为.xcdatamodeld。创建模型文件之后，可以在其内部进行添加实体等操作(用于表示数据库文件的数据结构)

1.2 添加实体(表示数据库文件中的表结构)，添加实体后需要通过实体，来创建托管对象类文件。

1.3 添加属性并设置类型，可以在属性的右侧面板中设置默认值等选项。(每种数据类型设置选项是不同的)

1.4 创建获取请求模板、设置配置模板等。

1.5 根据指定实体，创建托管对象类文件(基于NSManagedObject的类文件)

实例化上下文对象

2.1 创建托管对象上下文(NSManagedObjectContext)

2.2 创建托管对象模型(NSManagedObjectModel)

2.3 根据托管对象模型，创建持久化存储协调器(NSPersistentStoreCoordinator)

2.4 关联并创建本地数据库文件，并返回持久化存储对象(NSPersistentStore)

2.5 将持久化存储协调器赋值给托管对象上下文，完成基本创建。

初识CoreData ----> 可以参考：http://www.cocoachina.com/ios/20160729/17245.html
