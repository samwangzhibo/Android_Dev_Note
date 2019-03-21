-  [注解](#1.注解)
	+ [`getAnnotation` 过程](#getAnnotation的流程)
- [内部类](#2. 内部类)
- [final](#final)
- [动态代理](#动态代理)
- [线程](#线程)
	+ [Thread类](#Thread类)
	+ [Object类](#Object类)
	+ [线程的生命周期](#线程生命周期)
-  [ThreadLocal](#ThreadLocal)
-  [final、finally、finalize()分别表示什么含义](#final、finally、finalize)
-  [kotlin](#kotlin)
- [布局优化](#布局优化)
-  [线程池](#线程池)
- [异常](#异常)
- [枚举](#枚举)
- [范型](#范型)

---
### <a id="1.注解">1.注解</a>
注解的引入主要是为了和代码紧耦合的添加注释信息，java中常见的注解有@Override、@Deprecated，用Override修饰的方法，在编译的时候会去检查是否是父类存在这个方法，然后编译器提示。
注解我们使用的时候是这样声明的，其中上面的 `@Retention` 和 `@Target` 是元注解。 `@Retention` 主要是用于修饰注解的的运行时机，是在运行时还是编译时。`@Target` 用于修饰注解修饰的域，是类还是成员变量还是方法。
```java
@Retention 修饰运行时机  编译 运行时
@Target 修饰类型 比如方法 类 成员变量
@interface Path{
	String value() defalut "";
}
```
然后使用的时候我们是这样的，用注解去注释方法，然后通过Method的`getAnnotation` 方法获取注解，然后通过 `value()` 方法获取 `value` 属性。
```java
@Path("/aaa")
void a();

(Path(getMethod("a").getAnnotation(Path.class))) .value();
```
可以看到实际上注解是一个接口，`Method`有一个成员变量map<<? extends Annotation>, Annotations> ，我们通过Method的getAnnotation方法获取注解，再通过value()方法获取我们注解的时候设置的value属性值。因为Method、Construcator、Class等其实都是集成自 `AnnotatedElement` 这个接口，里面有 `getAnnotation` 方法，所以他们都可以获取注解。
![](https://img-blog.csdnimg.cn/20190307221124191.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
他们之所以能获取注解，实际上编译器会在编译时会把注解信息写入class里面 `Method` 的属性表，然后我们调用 `getAnnotation` 去获取注解，首先是判断本地有没有 `annotations` 这个成员变量。没有的话，实际上是生成继承至这个注解接口的动态代理对象，然后这里面会实例化一个 `annotationInvocationHandler` 对象，通过注解解析器去解析字节码里面的属性表，维护到这个 `annotationInvocationHandler`里面的 Map<key, value>。然后调用  `value` 方法的时候，判断Method 的名字 `value` 交给 `invocationHandler`，然后去 `InvocationHandler` 里面去取数据。

[JAVA 注解的基本原理](https://juejin.im/post/5b45bd715188251b3a1db54f)

#### <a id="getAnnotation的流程">getAnnotation的流程</a>
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190308115403444.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190308140942229.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
### <a id="2. 内部类">2. 内部类</a>
内部类的引入主要是为了解决Java没有多重继承然后提供的语法糖。内部类定义在另外一个类里面的类。它隐藏在外部类中，封装性更强，不允许除外部类外的其他类访问它；根据内部类定义的位置，可以分为几类。
-  成员内部类
  能够访问外围类的所有变量和方法，包括私有变量，同时还能集成其他的类。外围类也能访问它的私有变量和方法。编译器会给他们生成access方法。而非静态内部类需要通过生成外部类来间接生成。
-  静态内部类
  能够访问外围类的静态变量和静态方法，包括私有属性的。静态内部类是指被声明为static的内部类，可不依赖外部类实例化；
-  局部内部类
   访问方法的变量需要使用 `final` 修饰，因为参数在方法调用完之后就出栈了，那么内部类就不能访问到这个变量了。用final申明变量，如果是基础类型，会直接变成值，如果是引用类型，会通过构造函数传进来。
-  匿名内部类
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
- 使用：通过 `Proxy.newProxyInstance(classLoader，Class<?>[] inters, invocationHandler)` 生成代理对象
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
### <a id="线程">线程</a>
#### <a id="Thread"类>Thread类</a>
- sleep：暂停当前正在执行的线程；不释放锁（类方法）
- yield：暂停当前正在执行的线程，并执行其他线程；（类方法）
> 释放CPU时间片
- join：暂停调用线程，等该线程终止之后再执行当前线程；

```java
Thread thread1 = new Thread();
Thread thread2 = new Thread(){
    void run(){
        thread1.join(); 
    }
};
```



- interrupt：中断该线程，当线程调用wait(),sleep(),join()或I/O操作时，将收到InterruptedException或 ClosedByInterruptException；

#### <a id="Object类">Object类</a>
锁池：存放竞争锁的线程
等待池：等待线程，当被唤醒的时候，会进入锁池
- wait：暂停当前正在执行的线程，直到调用notify()或notifyAll()方法或超时，退出等待状态；(需要先获得锁)
- notify：唤醒在该对象上等待的一个线程；(需要先获得锁) 
>需要注意的是，notify只会随机唤醒一个线程，如果线程
- notifyAll：唤醒在该对象上等待的所有线程；(需要先获得锁)

参考 [Java线程中yield与join方法的区别](http://www.importnew.com/14958.html)
<a id="线程生命周期">线程生命周期</a>
![线程生命周期](https://img-blog.csdnimg.cn/20190313180412384.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

### ThreadLocal
ThreadLocal类

- 背景：可实现线程本地存储的功能，把共享数据的可见范围限制在同一个线程之内，无须同步就能保证线程之间不出现数据争用的问题，这里可理解为ThreadLocal很方便的找到本线程的Looper。
  使用：ThreadLocal<T>.set(T)  ThreadLocal.get()
- 原理：每个线程的Thread对象中都有一个ThreadLocalMap 对象`ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue)`，它存储了一组以ThreadLocal.threadLocalHashCode为key、以本地线程变量为value的键值对，而ThreadLocal对象就是当前线程的ThreadLocalMap的访问入口，也就包含了一个独一无二的threadLocalHashCode值，通过这个值就可以在线程键值值对中找回对应的本地线程变量。
  需要注意的点就是ThreadLocal的Entry使用的是弱引用，是因为ThreadLocal变量会被线程一直持有，容易造成内存泄露 ，所以使用弱引用。



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





### `Q：什么是线程安全？保障线程安全有哪些手段？`

>  技术点：线程安全
>
> 思路：详见[要点提炼| 理解JVM之线程安全&锁优化](https://www.jianshu.com/p/ca8801044352) 
>
> 参考回答：线程安全就是当多个线程访问一个对象时，如果不用考虑这些线程在运行时环境下的调度和交替执行，也不需要进行额外的同步，或者在调用方进行任何其他的协调操作，调用这个对象的行为都可以获得正确的结果，那这个对象是线程安全的。保证线程安全可从多线程三特性出发： 
>
> - 原子性
>
>   （Atomicity）：单个或多个操作是要么全部执行，要么都不执行 
>
>   - Lock：保证同时只有一个线程能拿到锁，并执行申请锁和释放锁的代码
>   - synchronized：对线程加独占锁，被它修饰的类/方法/变量只允许一个线程访问
>
> - 可见性
>
>   （Visibility）：当一个线程修改了共享变量的值，其他线程能够立即得知这个修改 
>
>   - volatile：保证新值能**立即**同步到主内存，且每次使用前立即从主内存刷新；
>   - synchronized：在释放锁之前会将工作内存新值更新到主存中
>
> - 有序性
>
>   （Ordering）：程序代码按照指令顺序执行 
>
>   - volatile： 本身就包含了禁止指令重排序的语义
>   - synchronized：保证一个变量在同一个时刻只允许一条线程对其进行lock操作，使得持有同一个锁的两个同步块只能串行地进入
[java多线程系列(五)---synchronized ReentrantLock volatile Atomic 原理分析](http://www.cnblogs.com/-new/p/7326820.html)


### <a id="线程池">线程池</a>

`execute和submit的区别`

- 参数不同

  - `void execute(Runnable command)` 提交的是 `Runnable`。

  - ` <T> Future<T> submit(Callable<T> task)`  提交一个实现了Callable接口的对象，而Callable接口中是一个有返回值的call方法，当主线程调用Future的get方法的时候会获取到从线程中返回的结果数据，如果在线程的执行过程中发生了异常，get会获取到异常的信息。

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



### <a id="异常">异常</a>

- 分类
  -  Error
    - 错误，不能通过代码修复的，可以不用处理
  - Exception
    - 执行异常（RuntimeException）
      - 特点：可能在执行方法期间抛出但未被捕获的`RuntimeException`的任何子类都无需在`throws`子句中进行声明
      - 举例：`Java.lang.IndexOutOfBoundsException` `Java.lang.ClassCastException`  `Java.lang.NullPointerException`
    - 检查异常（Checked Exceptions）
      - 特点：一个方法必须通过throws语句在方法的声明部分说明它可能抛出但并未捕获的所有checkedException
      - 举例：`Java.lang.ClassNotFoundException` `Java.lang.NoSuchMethodException` `InterruptedException` 

### <a id="枚举">枚举<a/>
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




### <a id="范型">范型</a>






