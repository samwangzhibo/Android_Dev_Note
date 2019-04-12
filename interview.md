**Java基础**

-  [JVM内存模型](内存模型)
-  [注解](#1.注解)
    -  [`getAnnotation` 过程](#getAnnotation的流程)
-  [内部类](#内部类)
-  [final](#final)
-  [动态代理](#动态代理)
-  [枚举](#枚举)
-  [范型](#范型)
-  [容器](#容器)
-  [异常](#异常)

---

**Java并发编程**

-  [线程](#线程)
  + [Thread类(sleep、join、yield、interrupt)](#Thread类)
  + [Object类(wait、notify、notifyAll)](#Object类)
  + [线程的生命周期(新建、就绪，阻塞(等待)、运行、终止](#线程生命周期)
-  [ThreadLocal](#ThreadLocal)
-  [Synchronized](#Synchronized)
-  [ReentrantLock](#ReentrantLock)
-  [volatile](#volatile)
-  [cas](#cas)
-  [线程池](#线程池)

---

**Android**

- Handler
- Binder
- App启动过程
- View绘制过程
- TouchEvent事件分发
- ListView、RecyclerView
- 滚动机制(Scroll、Fling)
- 动画机制(Drawable Animation、View Animation、Property Animation)

- 性能调优
  - 布局优化
  - 启动优化
  - 绘制优化

---

**开源框架**

- EventBus优化

-  [final、finally、finalize()分别表示什么含义](#final、finally、finalize)
-  [kotlin](#kotlin)
-  [布局优化](#布局优化)
-  [死锁](#死锁)

---
### <a id="内存模型">0. JVM内存模型</a>

| Java堆：存对象，gc最重要的区域 分为年轻代、年老代和永久代 | （Program Counter）程序计数器  一小块内存区域 记录字节码执行 的位置  比如线程切换回来的时候，找到执行入口  特点:无OOM |
| --------------------------------------------------------- | ------------------------------------------------------------ |
|                                                           | 虚拟机栈：方法 栈帧  **局部变量**  **入参**，异常Outofmemory和stackoverflow |
| 方法区：静态常量、class类描述、常量池                     | 本地方栈：native方法                                         |
| **线程共享**                                              | **线程私有**                                                 |

- **GC背景**: `System.gc()` 建议jvm gc，在gc之前会调用对象的 `finalized()`

- gc算法分类
  - 1.程序计数器，引用+1，销毁、失效-1 
  - 2.可达性分析 
    -  GRoot 静态对象、常量池对象
- 分代回收
  - **新生代**： 一个eden区，两个存活区。Eden满后，把存活的对象复制到存活区。存活区满后，把仍存活的对象复制到另一个存活区，这个也满了后，仍存活的复制到另一个存活区。**一次只有一个存活区**
    - young gc：停止复制算法stop-the-world 
       ![在这里插入图片描述](https://img-blog.csdnimg.cn/20190404012731306.png)
  - **年老代** ：young gc几次（默认8次，可调参）后仍存活的复制到年老代、大对象存年老代
    - full gc：标记整理算法，即标记出存活的对象，清除没有引用的对象，并压缩
    - 特殊：如果**年老代对年轻代**对象存在引用，young gc时查询年老代确定是否可清理。查询方式，查 `card table` 表。年老代维护了一个512byte 的card table，存储的是年老代堆年轻代对象的引用。
- 垃圾收集器
  - 并行和串行收集器
  - CMS 收集器 “最短回收停顿优先”收集器（标记—清除算法：初始标记—并发标记—重新标记—并发清除）

### <a id="1.注解">1.注解</a>

- 背景

注解的引入主要是为了和代码紧耦合的添加注释信息，java中常见的注解有@Override、@Deprecated，用Override修饰的方法，在编译的时候会去检查是否是父类存在这个方法，然后编译器提示。

- 使用

注解我们使用的时候是这样声明的，其中上面的 `@Retention` 和 `@Target` 是元注解。 `@Retention` 主要是用于修饰注解的的运行时机，是在运行时还是编译时。`@Target` 用于修饰注解修饰的域，是类还是成员变量还是方法。

```java
@Retention 修饰运行时机  编译 运行时
@Target 修饰类型 比如方法 类 成员变量
@interface Path{
	String value() defalut "";
}
```
然后使用的时候我们是这样的，用注解去注释方法，然后通过**Method**的`getAnnotation` 方法获取注解，然后通过 `value()` 方法获取 `value` 属性。
```java
@Path("/aaa")
void a();

(Path(getMethod("a").getAnnotation(Path.class))) .value();
```
可以看到实际上注解是一个接口，`Method`有一个成员变量map<<? extends Annotation>, Annotations> ，我们通过Method的getAnnotation方法获取注解，再通过value()方法获取我们注解的时候设置的value属性值。因为Method、Construcator、Class等其实都是集成自 `AnnotatedElement` 这个接口，里面有 `getAnnotation` 方法，所以他们都可以获取注解。

- 原理

![AnnotationElement的继承结构](https://img-blog.csdnimg.cn/20190307221124191.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
他们之所以能获取注解，实际上编译器会在编译时会把注解信息写入class里面 `Method` 的属性表，然后我们调用 `getAnnotation` 去获取注解，首先是判断本地有没有 `annotations` 这个成员变量。没有的话，实际上是生成继承至这个注解接口的动态代理对象，然后这里面会实例化一个 `annotationInvocationHandler` 对象，通过注解解析器去解析字节码里面的属性表，维护到这个 `annotationInvocationHandler`里面的 Map<key, value>。然后调用  `value` 方法的时候，判断Method 的名字 `value` 交给 `invocationHandler`，然后去 `InvocationHandler` 里面去取数据。

[JAVA 注解的基本原理](https://juejin.im/post/5b45bd715188251b3a1db54f)

#### <a id="getAnnotation的流程">getAnnotation的流程</a>
![getAnnotation函数调用](https://img-blog.csdnimg.cn/20190308115403444.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
> `getAnnotation()` 发现没有缓存的 `Annotation` 对象， 通过`AnnotationParser` 解析属性表里面的注解信息到一个map，然后生成 `AnnotationInvocationHandler`，并且生成一个动态代理的Proxy类，然后把代理方法派发给`Handler`，`Handler` 通过方法名比如`value`从Map里面获取属性表参数.

![memberValues存放方法名、值](https://img-blog.csdnimg.cn/20190308140942229.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
![动态代理与invocationHandler](https://img-blog.csdnimg.cn/20190403123142530.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

#####简单说：

1.首先注解是一个 `@interface` 声明的，编译的时候，编译器会把注解信息写入 `class` 类信息的属性表里面

2.当我们 `getAnnotation()` 的时候，`annotationParser` 会从属性表解析出



### <a id="内部类">2. 内部类</a>
内部类的引入主要是为了解决Java没有多重继承然后提供的语法糖。内部类定义在另外一个类里面的类。它隐藏在外部类中，封装性更强，**不允许除外部类外的其他类访问它**；根据内部类定义的位置，可以分为几类。
-  **成员内部类**
  能够访问外围类的所有变量和方法，包括私有变量，同时还能集成其他的类。外围类也能访问它的私有变量和方法。编译器会给他们生成access方法。而非静态内部类需要通过生成外部类来间接生成。
-  **静态内部类**
  能够访问外围类的静态变量和静态方法，包括私有属性的。静态内部类是指被声明为static的内部类，可不依赖外部类实例化；
-  **局部内部类**
   访问方法的变量需要使用 `final` 修饰，因为参数在方法调用完之后就出栈了，那么内部类就不能访问到这个变量了。用final申明变量，如果是基础类型，会直接变成值，如果是引用类型，会通过构造函数传进来。
-  **匿名内部类**
  不能用权限修饰符修饰，局部内部类和匿名内部类都默认持有外部类的引用。一般android中，我们为了防止 `Activity` 内存泄露，都是把匿名内部类声明成静态内部类，然后传递Activity的 WeakReference。

[java提高篇(十)-----详解匿名内部类https://www.cnblogs.com/chenssy/p/3390871.html](https://www.cnblogs.com/chenssy/p/3390871.html)
[java提高篇(八)----详解内部类](https://www.cnblogs.com/chenssy/p/3388487.html)


### <a id="final">3. final</a>
- 修饰类 类不能被继承，比如String就是final类型的，内部是字符串的封装操作，系统不希望它被重写。
- 修饰方法 方法不能被子类重写。
  比如View的measure、layout、draw，因为它们内部有缓存逻辑，比如measure会通过计算父布局传过来的MeasureSpec和缓存的meaSpec做比较，然后来控制onMeasure的调用。这个会MeasureSpec是父布局通过父View的measureSpec和子View的LayoutParams 生成的measureSpec，最终传给子View的onMeasure方法。MeasureSpec是32位的整型。前2位是模式，后30位是size。模式分为 `Unspesfic`、`At_most`、`Exctly`，我们自定义View需要处理 `at_most` 模式，比如`TextView` 的 `at_most` 模式就是按照字体的大小和个数来计算出来的。
  比如View的layout方法，主要也是做一些缓存的功能，会去看布局是否变化，如果变化了才去调用 `onLayout` 布局。其中的l、t、r、b参数，最开始是由 `ViewRootImpl` 的 `performLayout` 里面调用 `DecorView` 的 `layout` 方法，传递的参数是子布局在父布局里面的位置，这里是 `DecorView` 在 `PhoneWindow` 里面的位置。
  比如View的 `draw` 方法，实际上了系统固定的绘制流程，比如先绘制background，实际是调用`backgroundDrawable` 的 `draw()` 方法，比如说颜色，ColorDrawable。然后调用 `onDraw()` 在绘制内容区域，然后调用 `dispatchDraw` 去绘制子布局，这个方法是 `ViewGroup` 实现的。之后画滚动条啥的。这里说一下，这个canvas 其实是 `Surface` 对象 lockCanvas 得来的，绘制完成后，封装成 `FrameBuffer` 然后发送给 `SurfaceFlinger` 进程绘制。
- 修饰变量（说明final变量引用指向的对象地址不能变）
  * 局部变量
    主要是局部内部类或者是匿名内部类使用，因为方法在调用完成之后会出栈，然后形参和局部变量就失效，因为变量需要给匿名内部类使用，所以声明成 `final` ，让它指向的地址不能变。如果 `final` 变量是基础类型，编译的时候就确定，直接替换成基础的确认的值，如果是引用，会把引用通过构造函数传进来。
```java
public Destionation destionation(final String str) {
        /**
         * 在局部变量中声明为final就好了，这个原因是由于method方法调用完毕之后就从栈中弹出了，
         * 但是这个时候由于局部内部类中使用了这个方法中的局部变量，而这个类还是不会立即回收的，
         * 所以只能将局部变量声明为final，表示常量。
         */
        final int num = 1; //局部内部类引用类，所以要声明为final

        class PDestionation implements Destionation { //不能加访问修饰符
            private String label;

            private PDestionation(String whereTo) {
                label = whereTo;
                outterNoStaticMethod(); //可以访问外部类的方法
            }

            public String readLabel() {
                System.out.println(numOutter);//可以直接访问外部类私有变量 生成access$100方法
                System.out.println(numOutterStatic);//可以直接访问外部类私有静态变量
                return label + num + str; //引用函数的变量，会通过构造函数传进来
            }

            @Override
            public void destionate() {

            }
        }
        return new PDestionation(str);
    }
```
```java
 class Parcel5$1PDestionation implements Destionation {
    private String label;
//局部变量构造函数传入
    Parcel5$1PDestionation(Parcel5 this$0, String whereTo, String var3) {
        this.this$0 = this$0;
        this.val$str = var3;
        this.label = whereTo;
        Parcel5.access$000(this$0);
    }
	
    public String readLabel() {
        System.out.println(Parcel5.access$100(this.this$0)); //外部私有非静态变量
        System.out.println(Parcel5.access$200()); //外部私有静态变量
        return this.label + 1 + this.val$str;
    }

    public void destionate() {
    }
}
```

* 成员变量 
  只能被初始化一次。

### <a id="动态代理">动态代理</a>
- 好处：比静态代理灵活，不需要每次一个方法都实现一遍。还有一个注意的地方就是，相当于把接口的方法全部拦截给 `InvocationHandler` 了，`Retrofit` 使用这个特性，把 `RPC` 的接口，拦截掉然后生成 `Request` 请求对象。
- 使用：通过 `Proxy.newProxyInstance(classLoader，Class<?>[] interfaces, invocationHandler)` 生成代理对象
- 原理：自己组装了一个继承自`Proxy`类实现 `inters` 接口的名字叫 `Proxy$0`的类，`Proxy` 类有一个`InvocationHandler` 成员，通过构造函数传入。所有实现的方法通过 `invoke` 方法把 `this`，`method`，`params`转发出去，然后调用一个 `native` 方法把这个字节流交给 `classLoader` 完成类加载。
```java
//动态代理类 代理类继承了IBossImpl 接口
public final class $Proxy0 extends Proxy implements IBossImpl {
    private static Method m1;
    private static Method m3;
    private static Method m2;
    private static Method m4;
    private static Method m0;
 
    public $Proxy0(InvocationHandler var1) throws  {
        super(var1);
    }
 
    public final boolean equals(Object var1) throws  {
        try {
            return ((Boolean)super.h.invoke(this, m1, new Object[]{var1})).booleanValue();
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }
    
    //实现buy方法
    public final String buy(Object var1) throws  {
        try {
            return (String)super.h.invoke(this, m3, new Object[]{var1});
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }
 
    public final String toString() throws  {
        try {
            return (String)super.h.invoke(this, m2, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }
 
    //实现发邮件方法 
    public final String email(Object var1) throws  {
        try {
            return (String)super.h.invoke(this, m4, new Object[]{var1});
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }
 
    public final int hashCode() throws  {
        try {
            return ((Integer)super.h.invoke(this, m0, (Object[])null)).intValue();
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }
 
    static {
        try {
            m1 = Class.forName("java.lang.Object").getMethod("equals", new Class[]{Class.forName("java.lang.Object")});
            m3 = Class.forName("com.example.wangzhibo.lovestudy.jvm.dproxy.IBossImpl").getMethod("buy", new Class[]{Class.forName("java.lang.Object")});
            m2 = Class.forName("java.lang.Object").getMethod("toString", new Class[0]);
            m4 = Class.forName("com.example.wangzhibo.lovestudy.jvm.dproxy.IBossImpl").getMethod("email", new Class[]{Class.forName("java.lang.Object")});
            m0 = Class.forName("java.lang.Object").getMethod("hashCode", new Class[0]);
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }
}
```




### <a id="范型">范型</a>

- **背景**：如果没有范型，比如 `Object[] a = new String[100];`，你修改a的时候，比如放入`1`，取出来使用的时候，可能会抛出 `ClassCastException`

- **范型使用**

  - `class Stack<T> ` 修饰类
  - `<T> T poll(T element) ` 修饰方法

- **注意点**

  - 不可变  `List<Object> a = new ArrayList<String>()`报错，因为如果能赋值的话，`new ArrayList<Integer>()` 也能放，所以就会又出现 `classCastException`

- **特点**

  - 非限定通配符 ? 表示任意类型 `Class<? extends Annotation>`
  - 上下界
    -  `super` 是某个类的父类 比如 `<? super Integer>`  
    -  `extends` 某个类的子类 比如 `<? extends Number>` 

- **原理**：范型擦除  最终都是`Object` 类

- **问题**

  - **范型本质是 `object`，如果调用方法呢？**

    `class Util<T extends Number>`，那么`T` 就是 `Number` 的子类，可以调用 `Number` 的方法。

  - **什么是通配符？**

    范型是不可变的，也就是说如果一个 `ArrayList<Integer>` 赋值给 `ArrayList<Object>` 是不行的，如果我们用 `ArrayList<?>` 表示可以接受任意参数的 `ArrayList`。

[Java泛型常见面试题](https://blog.csdn.net/qq_25827845/article/details/76735277)



### <a id="容器">容器</a>

`ArrayList`

- 数据结构

  - 数组

- 扩容

  - **扩容时机**，存放的时候，大小已经达到最大(和HashMap不同，HashMap有一个相关因子0.75，当元素个数到 `size * 0.75`时，双倍扩容 )，扩容方式，**1.5倍**

- 原理

  - `System.arraycopy()` 拷贝高效

  - [`memmove` ](<https://www.cnblogs.com/xiehy/archive/2010/10/29/1864532.html>)

    `extern void *memmove(void *dest, const void *src, unsigned int count);`

    功能：由src所指内存区域复制count个字节到dest所指内存区域。

    说明：src和dest所指内存区域可以重叠，但复制后dest内容会被更改。函数返回指向dest的指针。

- 优化 初始化时指定默认大小



`HashMap`

 - **数据结构**

    -  数组+链表 默认大小16，上限2^31，扩容因子0.75，容量加倍
       - 优化：如果知道使用的个数，能够指定一个值，以免不必要的扩容
       - Entry里面有K、V、next

- **put操作**：对象的 `hashcode`除以length取余，这个优化是与数组 `(length-1)` 做按位 `&`，然后冲突之后就使用**头插法(1.7)** 把当前节点插到头部(可能是为了Lru的考虑)

- **扩容** 16的倍数扩容 相关因子0.75 

- **线程不安全：**

  - **数据脏写** 同时读 同时写 如果同时写到链表头 有一个修改就丢弃了

  - `resize` **扩容死循环**

    - 原因：`resize` `transfer`

      ![image-20190406125940779](/Users/didi/Library/Application Support/typora-user-images/image-20190406125940779.png)

    - 解决：[老生常谈，HashMap的死循环](<https://juejin.im/post/5a66a08d5188253dc3321da0#heading-1>)
  - **Fast fail 策略**，迭代的时候，做了操作， 修改了modCount的值

    - 解决：使用`CopyOnWriteArrayList`

- **1.8版本特性**：

    - **查询性能**：转树，当冲突个数达到8个，链表转变成红黑树(二叉平衡树)，查找时间复杂度O(lgn)
    - **死循环解决**，尾插法

- **线程安全的Map**



`ConcurrentHashMap`

- 修改了迭代器没有使用modCount

- 1.7版本
  - 使用的16个 `Segment`，每个 `Segment`是一个`ReentrantLock`重入锁，锁一块的时候，不会影响其他块，提高写性能
- 1.8版本 
  - **CAS操作**：initTable  transfer(扩容)等操作使用  `CAS`无锁机制(缺点cpu 100%)
  - 直接锁冲突头结点的元素
- **读操作没有锁**  [怎么保证读到的不是脏数据?](<https://juejin.im/entry/5b98b89bf265da0abd35034c>)  `volatile` 保证**可见性**、**有序性**



### <a id="枚举">枚举</a>

通过 `enum` 关键字声明，实际上会生成一个继承 `Enum 类的子类，他是final的，其中通过 静态块完成 `static final` 成员变量的初始化操作，其中 `values()` 方法返回枚举数组，`valueOf(String name)` 方法通过遍历数组，通过名字查找枚举。枚举里面能够申明 `abstract` 方法，然后每个枚举对象就会重写这个方法，实际上编译器会给枚举添加 `abstract` 申明，然后每个枚举的常量其实是一个匿名类内部类。

```java
enum Week{
	Monday, Tuesday
}
```

```java
/**
 * 一个enum除了不能继承自一个enum之外(编译器不让)，我们基本上可以将enum看作一个常规的类。也就是说我们可以向enum中添加方法。
 *
 * 生成的CustomEnum自动继承自Enum<CustomEnum>，所以我们不能再继承Enum了，单继承。
 * Created by samwangzhibo on 2019/3/21.
 */

public enum CustomEnum {
    Normal("平常", 1) {
        @Override
        String getInfo() {
            return "平常信息";
        }
    }, High("高", 2) {
        @Override
        String getInfo() {
            return "高信息";
        }
    }, Low("低", 3) {
        @Override
        String getInfo() {
            return "低信息";
        }
    };

    private String description;
    private int value;

    CustomEnum(String description, int value) {
        this.description = description;
        this.value = value;
    }

    public String getDescription() {
        return description;
    }

    public int getValue() {
        return value;
    }

    /**
     * 抽象方法，类没有生命成abstract 编译器会自动生成abstract
     * Normal High Low 会自动申明匿名内部类
     * @return
     */
    abstract String getInfo();

}
```

[深入理解Java枚举类型(enum)](https://blog.csdn.net/javazejian/article/details/71333103)
![枚举的匿名内部类](https://img-blog.csdnimg.cn/20190321143730452.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

---

### `Q：什么是线程安全？保障线程安全有哪些手段？`

> 技术点：线程安全
>
> 思路：详见[要点提炼| 理解JVM之线程安全&锁优化](https://www.jianshu.com/p/ca8801044352) 
>
> 参考回答：线程安全就是当多个线程访问一个对象时，如果不用考虑这些线程在运行时环境下的调度和交替执行，也不需要进行额外的同步，或者在调用方进行任何其他的协调操作，调用这个对象的行为都可以获得正确的结果，那这个对象是线程安全的。保证线程安全可从多线程三特性出发： 
>
> - 原子性
>
> （Atomicity）：单个或多个操作是要么全部执行，要么都不执行 
>
> - Lock：保证同时只有一个线程能拿到锁，并执行申请锁和释放锁的代码
>
> - synchronized：对线程加独占锁，被它修饰的类/方法/变量只允许一个线程访问
> - 可见性
>
> （Visibility）：当一个线程修改了共享变量的值，其他线程能够立即得知这个修改 
>
> - volatile：保证新值能**立即**同步到主内存，且每次使用前立即从主内存刷新；
> - synchronized：在释放锁之前会将工作内存新值更新到主存中
> - 有序性
>
> （Ordering）：程序代码按照指令顺序执行 
>
> - volatile： 本身就包含了禁止指令重排序的语义
> - synchronized：保证一个变量在同一个时刻只允许一条线程对其进行lock操作，使得持有同一个锁的两个同步块只能串行地进入
> [java多线程系列(五)---synchronized ReentrantLock volatile Atomic 原理分析](http://www.cnblogs.com/-new/p/7326820.html)



### <a id="线程">线程</a>

#### <a id="Thread">Thread类(sleep、join、yield、interrupt)</a>
- sleep：暂停当前正在执行的线程；不释放锁（有限等待、native方法）

- yield：释放当前线程CPU时间片，让他回到就绪状态，并执行其他线程；（native方法）

- join：暂停调用线程，等该线程终止之后再执行当前线程；(有限等待、用的wait实现)

  > - join如何阻塞调用的当前线程？
  >
  > 获取线程的`lock`锁，调用`wait()`，等线程执行完之后 JVM调用该线程的lock对象的`notify()`

```java
Thread thread1 = new Thread();
Thread thread2 = new Thread(){
    void run(){
        thread1.join(); 
    }
};
```



- interrupt：中断该线程，当线程调用wait(),sleep(),join()或I/O操作时，将收到InterruptedException或 ClosedByInterruptException；(native)

  >  如果线程正在运行，interrupt方法只会设置标志位，如果线程阻塞状态，将会抛出`interruptedException`
  >
  >  **注意**：如果线程在`wait`状态，并且不能获取锁，`Interrupt` 没有反应

#### <a id="Object类">Object类(wait、notify、notifyAll)</a>

锁池：存放竞争锁的线程
等待池：等待线程，当被唤醒的时候，会进入锁池(wait-set)

- wait：暂停当前正在执行的线程，直到调用notify()或notifyAll()方法或超时，退出等待状态；(需要先获得锁)

  > **重点**: 调用`wait()`，立马释放锁，线程拥塞

  > - 限时等待时，锁被占了，还能恢复吗？
  >
  > 不能，限时等待的前提是线程要能获得锁，这一点和 `interrupt` 方法很像，如果当前线程`wait`，并且不能获取锁，那么不能抛出 `interrupt` 异常
- notify：唤醒在该对象上等待的一个线程；(需要先获得锁 synchronized) 
>**注意**：notify只会随机唤醒一个线程，如果其他线程没有被notify，会导致线程饥饿
>
>notify只是唤醒其他线程，其他线程的执行需要等到方法执行完之后释放锁才行。
- notifyAll：唤醒在该对象上等待的所有线程；(需要先获得锁)

参考 [Java线程中yield与join方法的区别](http://www.importnew.com/14958.html)

<a id="线程生命周期">线程生命周期(新建、就绪、阻塞(运行) 、运行、终止)</a>

![线程生命周期](https://img-blog.csdnimg.cn/20190313180412384.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190404163529864.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

#### 相关问题：

`Wait和Sleep的区别`

- Wait和Sleep都不占用CPU，wait 会释放锁，sleep不释放锁
- wait必须要在`synchronized`块里面使用，wait可以携带等待时间参数(限时等待，但是如果这个时候锁被占用，不能被分配给它，限时等待不能唤醒，原理就是jvm会在一段时间后，分配锁和时间片给它)，也可以不携带等待时间参数(不限时等待，直到其他线程调用 `notify`或者`notifyAll`唤醒他，`notify`的话是随机唤醒，没有处理好，容易造成线程一直处理等待状态，线程饥饿)， sleep的话是必须传入一个时间，阻塞一段时间后，再由操作系统唤醒。



---



### <a id="ThreadLocal">ThreadLocal</a>
ThreadLocal类

- 背景：可实现线程本地存储的功能，把共享数据的可见范围限制在同一个线程之内，无须同步就能保证线程之间不出现数据争用的问题，这里可理解为ThreadLocal很方便的找到本线程的Looper。
  使用：ThreadLocal<T>.set(T)  ThreadLocal.get()
- 原理：每个线程的Thread对象中都有一个ThreadLocalMap 对象`ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue)`，它存储了一组以ThreadLocal.threadLocalHashCode为key、以本地线程变量为value的键值对，而ThreadLocal对象就是当前线程的ThreadLocalMap的访问入口，也就包含了一个独一无二的threadLocalHashCode值，通过这个值就可以在线程键值值对中找回对应的本地线程变量。
  需要注意的点就是ThreadLocal的Entry使用的是弱引用，是因为ThreadLocal变量会被线程一直持有，容易造成内存泄露 ，所以使用弱引用。

### <a id="Synchronized">synchronized</a>

- **背景** 多线程安全的三个特性，原子性（保证线程执行完才能执行其他线程）、可见性（`synchronized执行完之前把工作内存的值写回主存`）、有序性

- **使用**

  - 修饰方法
    - 静态方法，获取的是方法区 `class` 类文件的锁，所以**不影响非静态同步方法**
    - 非静态方法，获取的是 `this` 的锁
  - 修饰对象  获取的是对象的`monitor` 监控器

- **特点**  重入锁、悲观锁、独占锁、重量级锁

- **原理**

  如果是`class`类锁，静态方法或者class对象代码块，其实是在字节码的flag字段里面加入 `ACC_SYNCHRONIZED`

  `synchronized` 关键字同步的实现依赖于字节码，会在 `synchronized` 同步块的前后适用 `monitorenter` 和 `monitorexit` 指令，`monitorenter` 操作会去获取对象的锁(每个对象头部有一个监控器monitor 对象的头文件)，如果这个对象没被锁或者当前线程已经获得了锁(**重入锁**)，那么monitor的**计数器+1**，如果已经被其他线程锁住了，**自旋**等待一会最后阻塞，知道其他线程释放锁。执行 `monitorexit` 指令，**计数器-1**，直到计数器为0，释放锁。但是监视器锁本质又是依赖于底层的操作系统的**Mutex Lock**来实现的。

- **适用场景和缺点**

  悲观锁，**多写**的环境，多读的环境用乐观锁。**CPU切换**上下文**内核态和用户态**切换开销，**线程阻塞和唤醒**开销。

- 版本优化

  - 1.6之后， **偏向锁** 和 **轻量级锁** 。synchronized的底层实现主要依靠 **Lock-Free** 的队列，基本思路是 **自旋后阻塞**，**竞争切换后继续竞争锁**，**稍微牺牲了公平性，但获得了高吞吐量**。在线程冲突较少的情况下，可以获得和CAS类似的性能；而线程冲突严重的情况下，性能远高于CAS。

- 参考 [java多线程系列(五)---synchronized ReentrantLock volatile Atomic 原理分析](http://www.cnblogs.com/-new/p/7326820.html)

### 扩展

---



#### 1. [非公平锁与公平锁](<https://www.jianshu.com/p/f584799f1c77>)

- 线程饥饿 
  - 背景
    - **高优先级线程**占用大多数CPU时间片，低优先级线程饥饿
    - 线程被永远阻塞在等待同步块的状态(synchronized同步块一直不释放锁)
    - `notify` 和 `synchronized`  **不保证线程唤醒的顺序**
  - 解决 **Lock公平锁**
  - 参考 [线程饥饿](<https://cloud.tencent.com/developer/article/1193092>)

#### 2. 无锁状态、偏向锁、轻量级锁、重量级锁

- 偏向锁

  - 背景：为了在无多线程竞争的情况下尽量**减少不必要的轻量级锁执行路径**

- 轻量级锁

  通过`CAS`操作修改Mark Word锁标志位，如果成功，说明执行代码操作，如果竞争失败，则膨胀为重量级锁，阻塞线程。

- 重量级锁

  - 适用**Mutex Lock**，用户态到内核态的切换

| 锁       | 优点                                                         | 缺点                                             | 适用场景                             |
| -------- | ------------------------------------------------------------ | ------------------------------------------------ | ------------------------------------ |
| 偏向锁   | 加锁和解锁不需要额外的消耗，和执行非同步方法比仅存在纳秒级的差距。 | 如果线程间存在锁竞争，会带来额外的锁撤销的消耗。 | 适用于只有一个线程访问同步块场景。   |
| 轻量级锁 | 竞争的线程不会阻塞，提高了程序的响应速度。                   | 如果始终得不到锁竞争的线程使用自旋会消耗CPU。    | 追求响应时间。同步块执行速度非常快。 |
| 重量级锁 | 线程竞争不使用自旋，不会消耗CPU。                            | 线程阻塞，响应时间缓慢。                         | 追求吞吐量。同步块执行速度较长。     |

- 优化

  - **适应性自旋（Adaptive Spinning）** 

    ​	线程如果自旋成功了，那么下次自旋的次数会更加多，因为虚拟机认为既然上次成功了，那么此次自旋也很有可能会再次成功，那么它就会允许自旋等待持续的次数更多。反之，如果对于某个锁，很少有自旋能够成功的，那么在以后要或者这个锁的时候自旋的次数会减少甚至省略掉自旋过程，以免浪费处理器资源

  - **锁粗化（Lock Coarsening）** 编译器优化，比如 `StringBuffer` 拼接的时候，扩大锁的范围

  - **锁消除（Lock Elimination）** 编译器优化，如果某个操作只可能被一个线程适用，那么消除锁

- 缺点：

  优化在锁竞争很激烈的情况反而降低了效率，可以通过 `-XX:-UseBiasedLocking` 来禁用偏向锁 

- 参考 [Java并发编程：Synchronized底层优化（偏向锁、轻量级锁）](https://www.cnblogs.com/paddix/p/5405678.html) [**死磕 Java 并发 - 深入分析 synchronized 的实现原理**](https://juejin.im/entry/589981fc1b69e60059a2156a)

![img](https://ccqy66.github.io/2018/03/07/java%E9%94%81%E5%81%8F%E5%90%91%E9%94%81/consulusion.jpg)

[java锁偏向锁](<https://ccqy66.github.io/2018/03/07/java%E9%94%81%E5%81%8F%E5%90%91%E9%94%81/>)

### JIT(HotSpot 虚拟机)

- 背景：加速热点代码的运行

- 原理 

  Java程序最初是通过解释器进行解释执行的，当虚拟机发现**某个方法或代码块**运行的**特别频繁**时，就会把这些代码认定为**“热点代码”（Hot Spot Code）**。为了提高热点代码的执行效率，在运行时，虚拟机将会把这些代码编译成为**本地平台相关的机器码**，并进行优化，而完成这个任务的编译器称为及时编译器（Just In Time Compiler，简称JIT）。

---



### <a id="ReentrantLock">ReentrantLock</a>

- 背景：`synchronized` 的缺点是 **等待不可中断**、**非公平模式**(可能线程饥饿)、一个 `synchronized` 内部只能使用一个对象 `wait` 

- 优点

  - 等待可中断
  - 公平模式
  - 一个 `ReentrantLock` 创建多个 `condition`，每个 `condition` 有 `await(等待)` 和 `signal(唤醒)`

- 使用

  - 等待可中断 `lockInterruptibly()`  限时等待 `tryLock()` 解决死锁
  - 公平模式 `new ReentrantLock(true)`
  - 多个condition

  ```java
  ReentrantLock lock = new ReentrantLock();
  Condition notEmpty = lock.newCondition();
  public static void main(String[] args) throws InterruptedException {
          lock.lock();
          new Thread(new SignalThread()).start();
          System.out.println("主线程等待通知");
          try {
              condition.await();
          } finally {
              lock.unlock();
          }
          System.out.println("主线程恢复运行");
      }
      static class SignalThread implements Runnable {
  
          @Override
          public void run() {
              lock.lock();
              try {
                  condition.signal();
                  System.out.println("子线程通知");
              } finally {
                  lock.unlock();
              }
          }
      }
  ```

  ```java
  //reentrantLock实现阻塞队列
  public class MyBlockingQueue<E> {
  
      int size;//阻塞队列最大容量
  
      ReentrantLock lock = new ReentrantLock();
  
      LinkedList<E> list=new LinkedList<>();//队列底层实现
  
      Condition notFull = lock.newCondition();//队列满时的等待条件
      Condition notEmpty = lock.newCondition();//队列空时的等待条件
  
      public MyBlockingQueue(int size) {
          this.size = size;
      }
  
      public void enqueue(E e) throws InterruptedException {
          lock.lock();
          try {
              while (list.size() ==size)//队列已满,在notFull条件上等待
                  notFull.await();
              list.add(e);//入队:加入链表末尾
              System.out.println("入队：" +e);
              notEmpty.signal(); //通知在notEmpty条件上等待的线程
          } finally {
              lock.unlock();
          }
      }
  
      public E dequeue() throws InterruptedException {
          E e;
          lock.lock();
          try {
              while (list.size() == 0)//队列为空,在notEmpty条件上等待
                  notEmpty.await();
              e = list.removeFirst();//出队:移除链表首元素
              System.out.println("出队："+e);
              notFull.signal();//通知在notFull条件上等待的线程
              return e;
          } finally {
              lock.unlock();
          }
      }
  }
  ```

  

- 和 `synchronized` 比较

  | 名称          | 相同点                                   | 不同点                                               |
  | ------------- | ---------------------------------------- | ---------------------------------------------------- |
  | ReentrantLock | 独占锁,只允许线程互斥的访问临界区 可重入 | 1.手动加锁和解锁 2.公平锁 3.等待中断 4.多个condition |
  | Synchronized  |                                          | synchronized加锁解锁的过程是隐式的                   |

- 原理 [从源码角度彻底理解ReentrantLock(重入锁)](https://www.cnblogs.com/takumicx/p/9402021.html)

  AbstractQueuedSynchronizer

  - 进入队列 `CAS`

  - 阻塞 `LockSupport` 

    ```java
    private final boolean parkAndCheckInterrupt() {
        LockSupport.park(this);
        return Thread.interrupted();
    }
    ```

  - 唤醒

    ```java
     LockSupport.unpark(s.thread);
    ```

- 扩展

- 参考 [ReentrantLock(重入锁)功能详解和应用演示](https://www.cnblogs.com/takumicx/p/9338983.html) [阻塞和唤醒线程——LockSupport功能简介及原理浅析](https://www.cnblogs.com/takumicx/p/9328459.html)

#### ReadWriteLock

### LockSupport

- Why? `wait`、`notify` 的缺点，1.wait和notify使用的时候只能在同步块 2.`notify` 只能唤醒随机的线程，无法唤醒指定线程

- 使用

  ```java
  public class LockSupportTest {
  
      public static void main(String[] args) {
          Thread parkThread = new Thread(new ParkThread());
          parkThread.start();
          System.out.println("开始线程唤醒");
          LockSupport.unpark(parkThread);
          System.out.println("结束线程唤醒");
  
      }
  
      static class ParkThread implements Runnable{
  
          @Override
          public void run() {
              System.out.println("开始线程阻塞");
              LockSupport.park();
              System.out.println("结束线程阻塞");
          }
      }
  }
  ```

- 原理
- 特点
- 缺点



### <a id="volatile">`volatile`</a>

(背景) `volatile` 的引入保证了线程并发的可见性。

>  **为什么需要处理器缓存?**
>
> ​	相对于CPU的执行顺序，主寸的读取数据慢，所以引入寄存器缓存和高速缓存
>
> **缓存带来的问题**
>
> ​	缓存一致性问题，不同线程的缓存变量

 (使用)被 `volatile` 修饰的变量，线程每次修改之后，都把结果写回主内存，而不是 cpu缓存，然后通知其他线程缓存无效，需要从主内存读取，而不是用cpu缓存，这保证了内存一致性，还有就是 `volatile` 可以**禁止指令重排序**，重排序是编译器为了优化指令而不影响执行结果做的操作。

(例子) `volatile` 经常在单例的 `double check` 中使用。

(原理) `volatile` 会让编译的汇编代码加上 `lock`前缀，`lock` 之后的写操作，会让其他CPU的相关缓存失效，从而重新从主内存加载最新数据。

![img](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554958780132&di=882d13580a89f9e483259ba19d8674a1&imgtype=0&src=http%3A%2F%2Fwx2.sinaimg.cn%2Fmw690%2F006Xp67Kly1fq13iwg31vj30mp09jtbz.jpg)

### <a id="cas">CAS (compare and swap)</a>

- 背景

乐观锁，比 `synchronized` 更轻量级，`synchronized` 涉及到内核状态的线程切换，cas则是通过自旋请求，缺点是CPU占用率高

- 特点：**乐观锁**

- 使用

  cas中有3个参数，A是变量的地址(A的值)，B是变量的期待值，C是要设置的值

- 举例

  比如有个变量i=0，A、B 2个线程都做`i++` 操作，这其实涉及到3个操作，`read` `load``use` `assign` `write``store`等原子操作[java并发内存模型以及内存操作规则](<https://blog.csdn.net/l1394049664/article/details/81475380>)，A、B同时读出值为0，然后A修改后值为1，B修改之后还是1，A同步会主内存之后i的值为1，然后B `cas` 操作，第二个参数为0，第三个参数为1，由于第二个参数预期的值0和内存的值1不一样，所以 `cas` 设置是失败，自旋重试，然后就设置上了.

- 原理

  由于compareAndSwap是`Unsafe`包里面的，这个操作CPU保证的原子指令

- 使用场景 **多读的应用类型，这样可以提高吞吐量**

- 缺点：

  - ####  [ABA问题](<https://juejin.im/post/5b4977ae5188251b146b2fc8>)  

    - `AtomicStampedReference` 检查当前引用是否等于预期引用，并且当前标志是否等于预期标志

  - 只能保证一个共享变量的原子操作 

    - 多个对象封装到 `AtomicReference类`

  - CPU占比很高、吞吐量很高

- 参考 [面试必备之乐观锁与悲观锁](<https://juejin.im/post/5b4977ae5188251b146b2fc8>)



### <a id="线程池">线程池</a>

- 背景：线程池主要是为了解决**频繁创建线程的CPU和资源开销**，还可以**控制最大的线程数量**，核心的线程数量，回收线程，队列化的处理，还有拒绝策略
- 使用：核心线程数，最大线程数，回收时间、拥塞队列、线程工厂、拒绝Handler

```java
public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler)
```

- 例子

**FixThreadPool：**定长线程池，全是**核心**线程，快速处理

```java
 public static ExecutorService newFixedThreadPool(int nThreads) {
        return new ThreadPoolExecutor(nThreads, nThreads,0L, TimeUnit.MILLISECONDS,
                                      new LinkedBlockingQueue<Runnable>());
    }
```

使用的 `LinkedBlockingQueue`，默认是 `Integer.Max`的队列长度，`LinkedBlockingQueue` 的底层实现用的`ReentarintLock` 和 `Condition`，这是一个**生产者消费者**问题，当队列满的时候，阻塞生产者的 `put`操作(用的condition的await())，唤醒消费者去 `take`(用的condition的`signal`)， 当队列空的时候，阻塞消费者的 `take`， 通知生产者 `put`。

**SingleThreadPool：**只有**一个核心**线程，请求同步执行，适合同步非耗时请求

```java
new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>())
```

**CacheThreadPool：**缓存线程池，没有核心线程，都是**非核心**线程，适合处理高频非耗时请求

```java
new ThreadPoolExecutor(0, Integer.MAX_VALUE, 60L, TimeUnit.SECONDS,
                                      new SynchronousQueue<Runnable>());
```



> **特殊**：队列使用的是 `SynchronousQueue`，这个队列的特点是大小为0，**取操作之后才能放**
>
> 为什么使用这个队列？因为 `ThreadPoolExecutor`的策略，先是判断核心线程，这个队列核心线程数为0，则判断队列，队列也为0 ，所以就创建非核心线程，然后非核心线程就需要超时回收。

**ScheduledThreadPool**：核心线程数量**固定**，非核心线程数量**不定**；可进行**定时**任务和**固定**周期的任务。

```java
 super(corePoolSize, Integer.MAX_VALUE,
              DEFAULT_KEEPALIVE_MILLIS, MILLISECONDS,
              new DelayedWorkQueue());
```

> ```java
> scheduledThreadPool.schedule(runnable, 1, TimeUnit.SECONDS); //1s之后执行
> //1s之后执行，每隔1s执行一次
> scheduledThreadPool.scheduleAtFixedRate(runnable, 1, 1, TimeUnit.SECONDS);
> ```
>
> 实现：使用 **[DelayWorkQueue](<https://www.jianshu.com/p/587901245c95>)**，保证添加到队列中的任务，会按照任务的延时时间进行排序，延时时间少的任务首先被获取。

- 策略
  - **当前线程数量小于核心线程数**，直接创建线程。 `addWorker()`
  - **当前线程数量等于核心**，放入`BlockingQueue`，等线程`take`出来执行
  - **`BlockingQueue`满了** , 就创建非核心线程执行任务(`addWorker()`)，然后用限时等待的 `poll(6000)`取消息，如果消息为 `null` 就回收线程，当线程等于核心线程时就不回收了。
  - **非核心线程数大于最大线程数**，执行拒绝策略(或者shutdown)。

- 原理

  - 数据结构 ArrayList<Worker> workers BlockingQueue queue

  - 线程如何共享任务的？

    每个线程死循环从 `BlockingQueue` 取消息，然后执行 `Runnable`

  - 非核心线程如何进行回收？

  

额外

`execute和submit的区别？`

- 参数不同

  - `void execute(Runnable command)` 提交的是 `Runnable`。

  - ` <T> Future<T> submit(Callable<T> task)`  提交一个实现了Callable接口的对象，而Callable接口中是一个有返回值的call方法，当主线程调用**Future的 `get` **方法的时候会获取到从线程中返回的**结果**数据，如果在线程的执行过程中发生了异常，get会获取到**异常**的信息。

  - ```java
    public <T> Future<T> submit(Callable<T> task) {
        if (task == null) throw new NullPointerException();
        RunnableFuture<T> ftask = newTaskFor(task);
        execute(ftask);
        return ftask;
    }
    
    public interface Callable<V> {
        /**
         * Computes a result, or throws an exception if unable to do so.
         *
         * @return computed result
         * @throws Exception if unable to compute a result
         */
        V call() throws Exception;
    }
    ```

- 描述

`execute` 和  `submit` 的参数不同，`execute` 的参数是 `Runnable`， 没有返回值，而`submit` 的参数是 `Callback`，其中有个 `call` 方法可以返回值，然后 `submit` 返回一个`Future` 对象，`Future`对象的`get` 方法可以获取值还能捕获异常

---

### Android

### Handler

##### Looper

```java
private static void prepare(boolean quitAllowed) {
  if (sThreadLocal.get() != null) {
    throw new RuntimeException("Only one Looper may be created per thread");
  }
  sThreadLocal.set(new Looper(quitAllowed));
}

void loop(){
  for(;){
    Message msg = next(); //may blocking 
    if(msg == null){ //退出
      break;
    }
  }
} ;

public void quit() {
    mQueue.quit(false);
}

```

##### MessageQueue

```java
 Message next(){}

 void quit(boolean safe) {
  removeAllMessagesLocked();
  // We can assume mPtr != 0 because mQuitting was previously false.
  nativeWake(mPtr);
}
}
```



#### epoll

```c++
void Looper::rebuildEpollLocked() {
    if (mEpollFd >= 0) {
        close(mEpollFd); //关闭旧的epoll实例
    }
    mEpollFd = epoll_create(EPOLL_SIZE_HINT); //创建新的epoll实例，并注册wake管道
    struct epoll_event eventItem;
    memset(& eventItem, 0, sizeof(epoll_event)); //把未使用的数据区域进行置0操作
    eventItem.events = EPOLLIN; //可读事件
    eventItem.data.fd = mWakeEventFd;
    //将唤醒事件(mWakeEventFd)添加到epoll实例(mEpollFd)
    int result = epoll_ctl(mEpollFd, EPOLL_CTL_ADD, mWakeEventFd, & eventItem);

    for (size_t i = 0; i < mRequests.size(); i++) {
        const Request& request = mRequests.valueAt(i);
        struct epoll_event eventItem;
        request.initEventItem(&eventItem);
        //将request队列的事件，分别添加到epoll实例
        int epollResult = epoll_ctl(mEpollFd, EPOLL_CTL_ADD, request.fd, & eventItem);
    }
}
```

### Binder

- **Why?** 
  - **高效**，只拷贝一次，socket那些都需要拷贝2次，从用户空间到内核空间，再从内核空间到用户空间。`binder` 适用 `mmap` 系统调用，把用户空间和内核空间都映射到同一块物理页，4M，然后只需要拷贝到 这个地址，用户空间就完成了内容传递。
  - **安全**，协议里面带有uid验证

- **use?**

  ![img](https:////note.youdao.com/src/33C915661F2042D585D764C60E993FCB)

- **Sample (aidl)**

  - Impl 接口
  - Stub 这个一个 `Binder`，继承impl接口，是服务端用的，有`onTransact`方法
  - Proxy，是`BinderProxy`的代理，继承impl接口，有`Transact` 方法。

- **跨进程观察者**

  - Why? 

    服务端主动通知客户端，比如有个下载服务，多进程复用下载服务，提交一个地址下载文件，并且会返回**下载百分比**。如果没有观察者，我们需要主动去轮训百分比结果，有观察者的话，服务端可以主动通知客户端。

  - how？

    1.首先需要定义一个接口，因为binder传递的对象只能是序列化的，所以接口的定义也是用aidl

    2.把这个aidl接口调用服务端`register`方法注册的 `Proxy` 对象，这里注册的是 `Stub`对象，实际上服务端持有的是 `Stub.asInterface()`之后的代理对象，我们在这个 `Stub` 使用数据，比如进度的百分比，然后我们就使用 `ProgressBar` 来展示。

    3.然后客户端调用下载方法，服务器线程池开启线程下载，然后调用客户端的回调通知客户端，这里这个回调就是 `Proxy`，相当于是客户端的binder客户端。

  - **key point**

    这里因为客户端持有的是binder的服务端，所以回调其实是在 **binder线程池** 调用的，所以回调需要抛到主线程处理。

- **原理**

  ![img](https:////note.youdao.com/src/42E5A2E26A3F41EB8DCF965586B19975)

- **缺点** 因为映射的物理页大小设置问题，通常是1Mb限制



### App启动流程

- 主流程



### 绘制机制

##### MeasureSpec

unspecefic



### <a id="final、finally、finalize()">final、finally、finalize()分别表示什么含义</a>

> - 技术点：final、finally、finalize()
> - 参考回答：
> * final关键字表示不可更改，具体体现在：
>   * final修饰的变量必须要初始化，且赋初值后不能再重新赋值
>   * final修饰的方法不能被子类重写
>   * final修饰的类不能被继承
> * finally：和try、catch成套使用进行异常处理，无论是否捕获或处理异常，finally块里的语句都会被执行，在以下4种特殊情况下，finally块才不会被执行：
>   * 在finally语句块中发生了异常
>   * 在前面的代码中用了System.exit()退出程序
>   * 程序所在的线程死亡
>   * 关闭CPU
> * finalize()：是Object中的方法，当垃圾回收器将回收对象从内存中清除出去之前会调用finalize()，但此时并不代表该回收对象一定会“死亡”，还有机会“逃脱”



### <a id="kotlin">kotlin</a>
[用Kotlin去提高生产力:汇总Kotlin相对于Java的优势 kotlin_tips](https://juejin.im/post/5abe031af265da238059c18c#heading-0)



### <a id="布局优化">`Q：布局上如何优化？`</a>
> - 技术点：布局优化
> - 参考回答：布局优化的核心就是尽量减少布局文件的层级，常见的方式有：
>   + 多嵌套情况下可使用RelativeLayout减少嵌套。
>   + 布局层级相同的情况下使用LinearLayout，它比RelativeLayout更高效。
>
>   + 使用 `<include>` 标签重用布局、`<merge>` 标签减少层级、`<ViewStub>` 标签懒加载。



### <a id="异常">异常</a>

- 分类
  -  Error
    - 错误，不能通过代码修复的，可以不用处理 
    - 例子：`StackOverFlowError` `OutOfMemoryError`
  -  Exception
    - 执行异常（RuntimeException）
      - 特点：可能在执行方法期间抛出但未被捕获的`RuntimeException`的任何子类都**无需在`throws`**子句中进行声明
      - 举例：`Java.lang.IndexOutOfBoundsException` `Java.lang.ClassCastException`  `Java.lang.NullPointerException` `ConcurrentModifyException`
    - 检查异常（Checked Exceptions）
      - 特点：一个方法**必须通过throws**语句在方法的声明部分说明它可能抛出但并未捕获的所有checkedException
      - 举例：`Java.lang.ClassNotFoundException` `Java.lang.NoSuchMethodException` `InterruptedException` `Java.lang.NoSuchFieldException`









### RecyclerView

- 相对于ListView优点
  - 架构更合理，使用 `LayoutManager` 来随意的制定排列样式(Grid、Linear、Stagge)，还能处理用户手势，使用 `ItemDecoration` 来设置分割线等。
  - 支持单个Item刷新

[RecyclerView的新机制：预取（Prefetch）](https://juejin.im/entry/58a30bf461ff4b006b5b53e3)





### Retrofit





### InputManagerService

[十分钟了解Android触摸事件原理（InputManagerService）](https://juejin.im/post/5a291aca51882531926e9e3d)





### CopyOnWriteArrayList

[先简单说一说Java中的CopyOnWriteArrayList](https://juejin.im/post/5aaa2ba8f265da239530b69e)

- 背景：concurrentModifyException(在迭代的时候添加了数据)







### Iterator

- 出现背景：因为有迭代器，容器的遍历可以不考虑其存储结构，用迭代器的统一接口完成遍历.

- 注意点：迭代的时候能够删除节点，但是不能新增节点，否则会抛出 `ConcurrentModifyException` 
- 使用

```java
  Iterator iterator = list.iterator();
  while(iterator.hasNext()) {
    int i = (int) iterator.next();
    System.out.println(i + "");
  }
```

- 实现原理：

```java
  protected int limit = ArrayList.this.size;
        int cursor;       // 表示下一个要访问的元素的索引，从next()方法的具体实现就可看出
        int lastRet = -1; // 表示上一个访问的元素的索引; -1 if no such
        int expectedModCount = modCount; //表示对ArrayList修改次数的期望值，它的初始值为modCount。
        public boolean hasNext() {
                    //如果没超出limit
                    return cursor < limit;
        }

        public E next() {
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            int i = cursor;
            if (i >= limit)
                throw new NoSuchElementException();
            Object[] elementData = ArrayList.this.elementData;
            if (i >= elementData.length)
                throw new ConcurrentModificationException();
            cursor = i + 1;
            return (E) elementData[lastRet = i];
        }

        public void remove() {
            if (lastRet < 0)
                throw new IllegalStateException();
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();

            try {
                ArrayList.this.remove(lastRet);
                cursor = lastRet;
                lastRet = -1;
                expectedModCount = modCount;
                limit--;
            } catch (IndexOutOfBoundsException ex) {
                throw new ConcurrentModificationException();
            }
        }
```

- ConcurrentModifyException：(调用list.remove()方法导致 `modCount` 和 `expectedModCount` 的值不一致。) [Java ConcurrentModificationException异常原因和解决方法](https://www.cnblogs.com/dolphin0520/p/3933551.html)
  - 单线程环境 ：`remove()` 可以使用 直接操作 `list` 的话 会导致 `modCount` 和 `expectedModCount`不一致
  - 多线程环境 `remove()`不能使用，因为不同线程遍历的时候生成了不同的 `Iterator`，也就是 `expectModCount` 是私有的，但是 `modCount` 是共有的，一个线程把 `modCount++` 了，另一个线程的 `expectModCount` 并不知道
  - 如何解决 1.在使用iterator迭代的时候使用synchronized或者Lock进行同步； 2.使用并发容器CopyOnWriteArrayList代替ArrayList和Vector。





[Java面试必问-死锁终极篇](<https://juejin.im/post/5aaf6ee76fb9a028d3753534>)











### 图片相关

#### Gif图的加载

- 要点：自定义 `Drawable` ，在系统回调 `setVisible`的时候开启 `gif` 动画，在 `setInVisible` 的时候关掉 `gif` 动画。开启的时候，先设置第一帧，然后抛一个延时消息到主线程，等待延时完成之后，加载下一帧，然后调用 `invalidate` 刷新，最后调用 `Drawale#draw(canvas)`  



###  <a id="View相关">View相关</a>

####  `invalidate`原理

`View#invalidate()` -> `View#invalidateInternal` -> `ViewGroup#invalidateChild()` -> `ViewGroup#invalidateChildInParent` ->  `ViewRootImpl#scheduleTraversals()`