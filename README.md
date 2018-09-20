
# iOS如何在容器中弱引用对象


### 思考：
实际项目中的一些工具类或管理类（单例），需要向多个位置（页面）传递（回调）一些信息，在设计时如果采用过程更清晰的protocol / delegate模式，如何设计？

- 答：写一个数组、字典或集合给代理对象存起来！
- 问：这样会使得代理对象引用计数+1，释放是个问题，怎么办？
- 答：那就写一个regist方法，再写一个remove方法，在不同位置成对调用！
- 问：那如果想让这个单例类自动进行remove操作呢？或者说某些remove的时机不好掌控怎么办？
- 答：那这个单例就不能强持有这些代理对象，需要弱引用这些代理对象！
- 问：怎样才能弱引用多个代理对象？
- 答：请看下文 ！


#### 首先要明确一个概念： 

 
  在ARC中如果一个对象不再有任何strong指针指向它时，这个对象将被释放。

（NSArray、NSSet、NSDictionary<copy，retain>这三种容器会强持有对象，使其引用计数加1 ！）

#### 下面我将介绍几种弱引用对象的方式：

一、利用block来weak对象，并将block存入容器中：

```swift
// weak obj by block
    __weak id weakObj = observer;
    WeakObjBlock weakBlock = ^{
        return weakObj;
    };
```
二、利用NSValue包装成weak对象存入容器中：

```swift
    NSValue *weakValue = [NSValue valueWithNonretainedObject:observer]; //save 
    id delegate = weakValue.nonretainedObjectValue; //get
```
详情请见demo!

# NSPointerArray

#### 对应着`NSArray`，先来看看 API 中介绍的特点：
> 
   NSPointerArray.h
>
   A PointerArray acts like a traditional array that slides elements on insertion or deletion.
   Unlike traditional arrays, it holds NULLs, which can be inserted or extracted (and contribute to count).
   Also unlike traditional arrays, the 'count' of the array may be set directly.
   Using NSPointerFunctionsWeakMemory object references will turn to NULL on last release.
   
>
   The copying and archiving protocols are applicable only when NSPointerArray is configured for Object uses.
   The fast enumeration protocol (supporting the for..in statement) will yield NULLs if present.  It is defined for all types of pointers although the language syntax doesn't directly support this.



- 和传统 `Array` 一样，用于有序的插入或移除；
- 与传统 `Array` 不同的是，可以存储 NULL，并且 NULL 还参与 count 的计算；
- 与传统 `Array` 不同的是，count 可以 set，如果直接 set count，那么会使用 NULL 占位；
- 可以使用 `weak` 来修饰成员；
- 成员可以是所有指针类型；
- 遵循 `NSFastEnumeration`，可以通过 `for...in` 来进行遍历。

`NSPointerArray` 与 `NSMutableArray` 很像，都是可变有序集合。最大的不同就是它们的初始化方法，`NSPointerArray` 有两个初始化方法：

```swift 
- (instancetype)initWithOptions:(NSPointerFunctionsOptions)options;
- (instancetype)initWithPointerFunctions:(NSPointerFunctions *)functions;
```

#### 首先来看一下` NSPointerFunctionsOptions`，它是个 `位移枚举`，主要分为三大类：

一、内存管理
 
- NSPointerFunctionsStrongMemory：缺省值，在 GC 和 MRC 下强引用成员
- NSPointerFunctionsZeroingWeakMemory：已废弃，在 GC 下，弱引用指针，防止悬挂指针
- NSPointerFunctionsMallocMemory 与 NSPointerFunctionsMachVirtualMemory： 用于 Mach 的虚拟内存管理
- NSPointerFunctionsWeakMemory：在 GC 或者 ARC 下，弱引用成员

二、特性，用于标明对象判等方式

- NSPointerFunctionsObjectPersonality：hash、isEqual、对象描述
- NSPointerFunctionsOpaquePersonality：pointer 的 hash 、直接判等
- NSPointerFunctionsObjectPointerPersonality：pointer 的 hash、直接判等、对象描述
- NSPointerFunctionsCStringPersonality：string 的 hash、strcmp 函数、UTF-8 编码方式的描述
- NSPointerFunctionsStructPersonality：内存 hash、memcmp 函数
- NSPointerFunctionsIntegerPersonality：值的 hash

三、内存标识

- NSPointerFunctionsCopyIn：根据第二类的选择，来具体处理。如果是 NSPointerFunctionsObjectPersonality，则根据 NSCopying 来拷贝。

#### 再来看看`NSPointerFunctions`这个类

自定义成员的处理方式，如：内存管理、hash、isEqual 等，可以看到 API 中定义了一系列属性，它们都是函数指针，使用注释分段：

```swift

@interface NSPointerFunctions : NSObject <NSCopying>
// construction
- (instancetype)initWithOptions:(NSPointerFunctionsOptions)options NS_DESIGNATED_INITIALIZER;
+ (NSPointerFunctions *)pointerFunctionsWithOptions:(NSPointerFunctionsOptions)options;

// pointer personality functions
@property (nullable) NSUInteger (*hashFunction)(const void *item, NSUInteger (* _Nullable size)(const void *item));
@property (nullable) BOOL (*isEqualFunction)(const void *item1, const void*item2, NSUInteger (* _Nullable size)(const void *item));
@property (nullable) NSUInteger (*sizeFunction)(const void *item);
@property (nullable) NSString * _Nullable (*descriptionFunction)(const void *item);

// custom memory configuration
@property (nullable) void (*relinquishFunction)(const void *item, NSUInteger (* _Nullable size)(const void *item));
@property (nullable) void * _Nonnull (*acquireFunction)(const void *src, NSUInteger (* _Nullable size)(const void *item), BOOL shouldCopy);
```

可以自行实现函数，然后将函数指针赋给对应属性即可，比如，`isEqual`：

```swift 
static BOOL IsEqual(const void *item1, const void *item2, NSUInteger (*size)(const void *item)) {
    return *(const int *)item1 == *(const int *)item2;
}

NSPointerFunctions *functions = [[NSPointerFunctions alloc] init];
[functions setIsEqualFunction:IsEqual];
```

之前谈到，NSPointerArray 可以存储 NULL，作为补充，它也提供了 compact 方法，用于剔除数组中为 NULL 的成员。

```swift

// 在调用 compact 之前，手动添加一个 NULL，触发标记
[array addPointer:NULL];
[array compact];
```

# NSMapTable

```swift
// 实例方法，虽然有 capacity 参数，但实际没用到
- (instancetype)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity;
- (instancetype)initWithKeyPointerFunctions:(NSPointerFunctions *)keyFunctions valuePointerFunctions:(NSPointerFunctions *)valueFunctions capacity:(NSUInteger)initialCapacity;

// 便利构造器
+ (NSMapTable<KeyType, ObjectType> *)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions;

// 返回指定 key、value 内存管理类型的 map
+ (NSMapTable<KeyType, ObjectType> *)strongToStrongObjectsMapTable NS_AVAILABLE(10_8, 6_0);
+ (NSMapTable<KeyType, ObjectType> *)weakToStrongObjectsMapTable NS_AVAILABLE(10_8, 6_0);
+ (NSMapTable<KeyType, ObjectType> *)strongToWeakObjectsMapTable NS_AVAILABLE(10_8, 6_0);
+ (NSMapTable<KeyType, ObjectType> *)weakToWeakObjectsMapTable NS_AVAILABLE(10_8, 6_0);
```

初始化时可指定对应的`key`、`value`的引用类型：

- key 为 strong，value 为 strong
- key 为 strong，value 为 weak
- key 为 weak，value 为 strong
- key 为 weak，value 为 weak


#### 对比：
#### NSDictionary 的局限性
`NSDictionary` 提供了 `key -> object` 的映射。从本质上讲，`NSDictionary` 中存储的 `object` 位置是由 `key` 来索引的。

由于对象存储在特定位置，`NSDictionary` 中要求 `key` 的值不能改变（否则 object 的位置会错误）。为了保证这一点，NSDictionary 会始终复制 key 到自己私有空间。

这个 `key` 的复制行为也是 `NSDictionary` 如何工作的基础，但这也有一个限制：你只能使用 `OC` 对象作为 `NSDictionary` 的 `key`，并且必须支持 `NSCopying` 协议。此外，`key` 应该是小且高效的，以至于复制的时候不会对 `CPU` 和内存造成负担。

这意味着，`NSDictionary` 中真的只适合将值类型的对象作为 key（如简短字符串和数字）。并不适合自己的模型类来做对象到对象的映射。

####对象到对象的映射

`NSMapTable`（顾名思义）更适合于一般来说的映射概念。这取决于它的设计方式，`NSMapTable` 可以处理的 `key -> obj` 式映射如 `NSDictionary`，但它也可以处理 `obj -> obj` 的映射 - 也被称为`“关联数组”` 或简称为 `“map”`。

比如一个 `NSMapTable` 的构造如下：

```swift
NSMapTable *keyToObjectMapping =
    [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn
                          valueOptions:NSMapTableStrongMemory];
```
这将会和 `NSMutableDictionary` 用起来一样一样的，复制 `key`，并对它的 `object` 引用计数 `+1`。

一个真正的对象到对象`(object-to-object)`的映射可以构造如下：

```swift
NSMapTable *objectToObjectMapping = [NSMapTable mapTableWithStrongToStrongObjects];
```

一个对象到对象`(object-to-object)`的行为可能以前可以用 `NSDictionary` 来模拟，`Cocoa` 中首次提供了一个真正的对象到对象的映射集合类型那就是 `NSMapTable`。

原因是`NSMapTable`的 `NSPointerFunctionsOptions`选项中有一个
`NSMapTableObjectPointerPersonality`它可以让对象被作为`key`时不调用`isEqual`和`hash`来判断是否相等，而是通过`description`方法判断。

具体请看`demo` !

# NSHashTable

无序，基本可以理解为多功能的NSSet.

初始化方法如下：

```swift
- (instancetype)initWithOptions:(NSPointerFunctionsOptions)options capacity:(NSUInteger)initialCapacity;
- (instancetype)initWithPointerFunctions:(NSPointerFunctions *)functions capacity:(NSUInteger)initialCapacity;
```
值得注意的是，`NSHashTable` 有一个 `allObjectes` 的属性，返回 `NSArray`，即使 `NSHashTable` 是弱引用成员，`allObjects` 依然会对成员进行强引用。








