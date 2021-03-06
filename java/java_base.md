# Java

## <a id="内存模型">0. JVM内存模型</a>

| Java堆：存对象，gc最重要的区域 分为年轻代、年老代和永久代 | （Program Counter）程序计数器  一小块内存区域 记录字节码执行 的位置  比如线程切换回来的时候，找到执行入口  特点:无OOM |
| --------------------------------------------------------- | ------------------------------------------------------------ |
|                                                           | 虚拟机栈：方法 栈帧  **局部变量**  **入参**，异常Outofmemory和stackoverflow |
| 方法区：静态常量、class类描述、常量池                     | 本地方栈：native方法                                         |
| **线程共享**                                              | **线程私有**                                                 |

- **GC背景**: `System.gc()` 建议jvm gc，在gc之前会调用对象的 `finalized()`
- gc算法分类
  - 1.程序计数器，引用+1，销毁、失效-1 
  - 2.可达性分析 
    - GRoot 静态对象、常量池对象
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



Android虚拟机的特性



## <a id="1.注解">1.注解</a>

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

### <a id="getAnnotation的流程">getAnnotation的流程</a>

![getAnnotation函数调用](https://img-blog.csdnimg.cn/20190308115403444.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

> `getAnnotation()` 发现没有缓存的 `Annotation` 对象， 通过`AnnotationParser` 解析属性表里面的注解信息到一个map，然后生成 `AnnotationInvocationHandler`，并且生成一个动态代理的Proxy类，然后把代理方法派发给`Handler`，`Handler` 通过方法名比如`value`从Map里面获取属性表参数.

![memberValues存放方法名、值](https://img-blog.csdnimg.cn/20190308140942229.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
![动态代理与invocationHandler](https://img-blog.csdnimg.cn/20190403123142530.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

### 简单说：

1.首先注解是一个 `@interface` 声明的，编译的时候，编译器会把注解信息写入 `class` 类信息的属性表里面

2.当我们 `getAnnotation()` 的时候，`annotationParser` 会从属性表解析出 `Map<K,V>`，然后存放到`AnnotationInvocationHandler` 的 `map` 里面，然后会生成一个 继承自 `Proxy` 的 `Proxy$0` 子类，  然后比如把 `value` 方法拦截给 `AnnotationInvocationHandler`，再从 `AnnotationInvocationHandler` 里面查询K 为 `value` 的V. 



## <a id="内部类">2. 内部类</a>

**why?**

​	内部类的引入主要是为了解决Java没有多重继承然后提供的语法糖。

**特点：**

​	内部类定义在另外一个类里面的类。它隐藏在外部类中，封装性更强，**不允许除外部类外的其他类访问它**；

**分类**

​	根据内部类定义的位置，可以分为几类。

- **成员内部类**
  能够访问外围类的所有变量和方法，包括私有变量，同时还能集成其他的类。外围类也能访问它的私有变量和方法。编译器会给他们生成access方法。而非静态内部类需要通过生成外部类来间接生成。
- **静态内部类**
  能够访问外围类的静态变量和静态方法，包括私有属性的。静态内部类是指被声明为static的内部类，可不依赖外部类实例化；
- **局部内部类**
       访问方法的变量需要使用 `final` 修饰，因为参数在方法调用完之后就出栈了，那么内部类就不能访问到这个变量了。用final申明变量，如果是基础类型，会直接变成值，如果是引用类型，会通过构造函数传进来。
- **匿名内部类**
       不能用权限修饰符修饰，局部内部类和匿名内部类都默认持有外部类的引用。一般android中，我们为了防止 `Activity` 内存泄露，都是把匿名内部类声明成静态内部类，然后传递Activity的 WeakReference。

[java提高篇(十)-----详解匿名内部类https://www.cnblogs.com/chenssy/p/3390871.html](https://www.cnblogs.com/chenssy/p/3390871.html)
[java提高篇(八)----详解内部类](https://www.cnblogs.com/chenssy/p/3388487.html)

## <a id="final">3. final</a>

- 修饰类 类不能被继承，比如String就是final类型的，内部是字符串的封装操作，系统不希望它被重写。
- 修饰方法 方法不能被子类重写。
      比如View的measure、layout、draw，因为它们内部有缓存逻辑，比如measure会通过计算父布局传过来的MeasureSpec和缓存的meaSpec做比较，然后来控制onMeasure的调用。这个会MeasureSpec是父布局通过父View的measureSpec和子View的LayoutParams 生成的measureSpec，最终传给子View的onMeasure方法。MeasureSpec是32位的整型。前2位是模式，后30位是size。模式分为 `Unspesfic`、`At_most`、`Exctly`，我们自定义View需要处理 `at_most` 模式，比如`TextView` 的 `at_most` 模式就是按照字体的大小和个数来计算出来的。
       比如View的layout方法，主要也是做一些缓存的功能，会去看布局是否变化，如果变化了才去调用 `onLayout` 布局。其中的l、t、r、b参数，最开始是由 `ViewRootImpl` 的 `performLayout` 里面调用 `DecorView` 的 `layout` 方法，传递的参数是子布局在父布局里面的位置，这里是 `DecorView` 在 `PhoneWindow` 里面的位置。
       比如View的 `draw` 方法，实际上了系统固定的绘制流程，比如先绘制background，实际是调用`backgroundDrawable` 的 `draw()` 方法，比如说颜色，ColorDrawable。然后调用 `onDraw()` 在绘制内容区域，然后调用 `dispatchDraw` 去绘制子布局，这个方法是 `ViewGroup` 实现的。之后画滚动条啥的。这里说一下，这个canvas 其实是 `Surface` 对象 lockCanvas 得来的，绘制完成后，封装成 `FrameBuffer` 然后发送给 `SurfaceFlinger` 进程绘制。
- 修饰变量（说明final变量引用指向的对象地址不能变）
  - 成员变量 
    只能被初始化一次。
  - 局部变量
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

- 扩展

  防止重排序 cpu总线 内存屏障

  [jvm内存模型 重排序 内存屏障](https://www.cnblogs.com/flystar32/p/6684593.html)



## <a id="动态代理">4.动态代理</a>

- **好处：**

  ​	静态代理灵活，不需要每次一个方法都实现一遍。还有一个注意的地方就是，相当于把接口的方法全部拦截给 `InvocationHandler` 了，`Retrofit` 使用这个特性，把 `RPC` 的接口，拦截掉然后生成 `Request` 请求对象。

- **使用：** 

  ​	通过 `Proxy.newProxyInstance(classLoader，Class<?>[] interfaces, invocationHandler)` 生成代理对象

- **原理：**

  ​	自己组装了一个继承自`Proxy`类实现 `inters` 接口的名字叫 `Proxy$0`的类，`Proxy` 类有一个`InvocationHandler` 成员，通过构造函数传入。所有实现的方法通过 `invoke` 方法把 `this`，`method`，`params`转发出去，然后调用一个 `native` 方法把这个字节流交给 `classLoader` 完成类加载。(具体例子参考  [LoveStudy](https://github.com/samwangzhibo/LoveStudy) 项目 `com.example.wangzhibo.lovestudy.jvm.dproxy`)

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



## <a id="范型">5.范型</a>

- **背景**：如果没有范型，比如 `Object[] a = new String[100];`，你修改a的时候，比如放入`1`，取出来使用的时候，可能会抛出 `ClassCastException`

- **范型使用**

  - `class Stack<T> ` 修饰类
  - `<T> T poll(T element) ` 修饰方法

- **注意点**

  - 不可变  `List<Object> a = new ArrayList<String>()`报错，因为如果能赋值的话，`new ArrayList<Integer>()` 也能放，所以就会又出现 `classCastException`

- **特点**

  - 非限定通配符 ? 表示任意类型 `void a(List<?> list)`
  - 上下界
    - `super` 是某个类的父类 比如 `void a(List<? super Integer> list)`  
    - `extends` 某个类的子类 比如 `void a(List<? extends Number> list)` 

- **原理**：范型擦除  最终都是`Object` 类

- **问题**

  - **范型本质是 `object`，如果调用方法呢？**

    `class Util<T extends Number>`，那么`T` 就是 `Number` 的子类，可以调用 `Number` 的方法。

  - **什么是通配符？**

    范型是不可变的，也就是说如果一个 `ArrayList<Integer>` 赋值给 `ArrayList<Object>` 是不行的，如果我们用 `ArrayList<?>` 表示可以接受任意参数的 `ArrayList`。

[Java泛型常见面试题](https://blog.csdn.net/qq_25827845/article/details/76735277)



## <a id="容器">6.容器</a>

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

  - 数组+链表 默认大小16，上限2^31，扩容因子0.75，容量加倍
    - 优化：如果知道使用的个数，能够指定一个值，以免不必要的扩容
    - Entry里面有K、V、next

- **put操作**：对象的 `hashcode`除以length取余，这个优化是与数组 `(length-1)` 做按位 `&`，然后冲突之后就使用**头插法(1.7)** 把当前节点插到头部(可能是为了Lru的考虑)

- **扩容** 16的倍数扩容 相关因子0.75 

- **线程不安全：**

  - **数据脏写** 同时读 同时写 如果同时写到链表头 有一个修改就丢弃了

  - `resize` **扩容死循环**

    - 原因：`resize` `transfer`

      ![image-20190418150348602](https://ws1.sinaimg.cn/large/006tNc79ly1g26t1es1shj30u00ub7gb.jpg)

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

### CopyOnWriteArrayList

[先简单说一说Java中的CopyOnWriteArrayList](https://juejin.im/post/5aaa2ba8f265da239530b69e)

- **背景：**concurrentModifyException(在迭代的时候添加了数据，导致容器内部的 `modCount` 和 迭代内部的 `expectCount` 不一致，抛出异常)，写时拷贝策略(add操作的时候，先复制一个新的数组，然后修改新的数组，完成之后再赋值回原数组)
- **how?** 

写时拷贝策略，add操作的时候，先复制一个新的数组，然后修改新的数组，完成之后再赋值回原数组，这样就不会修改modCount字段了，而是直接把修改完的结果，覆盖原`object[]`



## <a id="枚举">7.枚举</a>

通过 `enum` 关键字声明，实际上会生成一个继承 `Enum` 类的子类，他是final的，其中通过 静态块完成 `static final` 成员变量的初始化操作，其中 `values()` 方法返回枚举数组，`valueOf(String name)` 方法通过遍历数组，通过名字查找枚举。枚举里面能够申明 `abstract` 方法，然后每个枚举对象就会重写这个方法，实际上编译器会给枚举添加 `abstract` 申明，然后每个枚举的常量其实是一个匿名类内部类。

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



## <a id="异常">8.异常</a>

- 分类
  - Error
    - 错误，不能通过代码修复的，可以不用处理 
    - 例子：`StackOverFlowError` `OutOfMemoryError`
  - Exception
    - 执行异常（RuntimeException）
      - 特点：可能在执行方法期间抛出但未被捕获的`RuntimeException`的任何子类都**无需在`throws`**子句中进行声明
      - 举例：`Java.lang.IndexOutOfBoundsException` `Java.lang.ClassCastException`  `Java.lang.NullPointerException` `ConcurrentModifyException`
    - 检查异常（Checked Exceptions）
      - 特点：一个方法**必须通过throws**语句在方法的声明部分说明它可能抛出但并未捕获的所有checkedException
      - 举例：`Java.lang.ClassNotFoundException` `Java.lang.NoSuchMethodException` `InterruptedException` `Java.lang.NoSuchFieldException`



## **9. Java其他**

### <a id="final、finally、finalize()">9.1 final、finally、finalize()分别表示什么含义</a>

> - 技术点：final、finally、finalize()
> - 参考回答：
> - final关键字表示不可更改，具体体现在：
>   - final修饰的变量必须要初始化，且赋初值后不能再重新赋值
>   - final修饰的方法不能被子类重写
>   - final修饰的类不能被继承
> - finally：和try、catch成套使用进行异常处理，无论是否捕获或处理异常，finally块里的语句都会被执行，在以下4种特殊情况下，finally块才不会被执行：
>   - 在finally语句块中发生了异常
>   - 在前面的代码中用了System.exit()退出程序
>   - 程序所在的线程死亡
>   - 关闭CPU
> - finalize()：是Object中的方法，当垃圾回收器将回收对象从内存中清除出去之前会调用finalize()，但此时并不代表该回收对象一定会“死亡”，还有机会“逃脱”



