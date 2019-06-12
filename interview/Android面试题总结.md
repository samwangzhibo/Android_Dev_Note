## 1. Android
### 1.1 View相关
#### 1.1.1 基础
- Q：SurfaceView和View的区别？
- Q：自定义View/ViewGroup需要注意什么？

#### 1.1.2 系统View组件
 - ListView
 	* Q：`ListView`为什么可以加载1000个条目不崩？
 	* Q：什么是`RecycleBin`，它是怎么和`ListView`回收和复用的？
 	* Q：你知道`notifyDataSetChanged`方法干了啥吗？调用之后为啥`ListView`就刷新了？
 	* Q：你知道`ListView`的跟手滑动和`fling`是怎么实现的吗？

 - ScrollView
 	* Q：`ScrollView`的测量过程，滑动过程以及`fling`的实现？
 - FrameLayout
 	* Q：`FrameLayout`的布局过程？
 - LinearLayout
 	* Q：`LinearLayout`的布局过程?
 - RecyclerView
    - Q: 相对于ListView的优点？
 - CoordinatorLayout(协同布局)
 - ConstraintLayout(约束布局)

#### 1.1.3 测量
- Q：[View的三次measure,两次layout和一次draw](https://segmentfault.com/a/1190000007325345)
- Q：onMeasure里面的MeasureSpec哪里来的？它的数据结构怎么样？怎么用？
- Q：LinearLayout和RelativeLayout选择哪个更好？为什么RelativeLayout需要测量2次
- Q：requestLayout()的原理，什么是责任链模式?

#### 1.1.4 绘制相关
- Q：什么是 `SurfaceFlinger`  `FrameBuffer` ` Surface`  ？
- Q：为什么我们说主线程的操作不要操作16ms？
- Q：什么是VSYNC(垂直同步)、格栅化？
- Q：什么是掉帧jank，怎么处理?(双缓冲和三缓存机制)
- Q：invalidate()和postInvalidate()的区别？

#### 1.1.5 事件传递
- Q：谈一谈View的事件分发机制？
- Q：MotionEvent是什么？包含几种事件？什么条件下会产生？
- Q：如何解决View的滑动冲突(方向相同、方向不同)？
- Q：onTouch()、onTouchEvent()和onClick()关系？
- Q: `InputManageService`的事件是怎么传递到Activity的？
- Q：主线程和InputManageService的通信建立？(`WindowState`、`WindowSession`)
- Q：InputReader、InputDispatcher线程是干嘛的？运行在哪个进程？

#### 1.1.6 滑动
- Q：Scroller中最重要的两个方法是什么？主要目的是？
- Q：scrollTo()和scrollBy()的区别？
- Q：fling方法的实现？

### 2. 图片相关
- Q：什么是LRU，什么是LinkedHashMshap?
- Q：本地、内存2级缓存怎么设计？
- Q：怎么加载一张大图又防止OOM？
- Q：了解哪些Drawable？适用场景？

### 3 系统组件
#### 3.1 Activity
- Q：Activity的启动过程？
- Q：说下Activity的生命周期？
- Q：onStart()和onResume()/onPause()和onStop()的区别？
- Q：Activity A启动另一个Activity B会回调哪些方法？如果Activity B是完全透明呢？如果启动的是一个Dialog呢？
- 状态存储
  * Q：谈谈onSaveInstanceState()方法？何时会调用？
  * Q：onSaveInstanceState()与onPause()的区别？
- Q：如何避免配置改变时Activity重建？
- Q：优先级低的Activity在内存不足被回收后怎样做可以恢复到销毁前状态？
- ActivityStack
  * Q：说下Activity的四种启动模式？（有时会出个实际问题来分析返回栈中Activity的情况）
  * Q：谈谈singleTop和singleTask的区别以及应用场景
  * Q：onNewIntent()调用时机？
  * Q：了解哪些Activity启动模式的标记位？
- Q：如何启动其他应用的Activity？

#### 3.2 Fragment
Q：谈一谈Fragment的生命周期？
Q：Activity和Fragment的异同？
Q：Activity和Fragment的关系？
Q：何时会考虑使用Fragment？

#### 3.3 Service
Q：谈一谈Service的生命周期？
Q：Service的两种启动方式？区别在哪？
Q：一个Activty先start一个Service后，再bind时会回调什么方法？此时如何做才能回调Service的destory()方法？
Q：Service如何和Activity进行通信？
Q：用过哪些系统Service？
Q：是否能在Service进行耗时操作？如果非要可以怎么做？
Q：AlarmManager能实现定时的原理？
Q：前台服务是什么？和普通服务的不同？如何去开启一个前台服务？
Q：是否了解ActivityManagerService，谈谈它发挥什么作用？
Q：如何保证Service不被杀死？

#### 3.4 Broadcast Receiver
- Q：广播的注册、解绑过程？发送广播过程？
- Q：广播有几种形式？什么特点？
- Q：广播的两种注册形式？区别在哪？

#### 3.5 ContentProvider
- Q：ContentProvider启动过程？原理？有哪些坑？

####  3.6 Window
- Q：Activity、View、Window三者之间的关系？
- Q：Window(phoneWindow)、WindowManager(WindowManagerImpl)、WindowState、WindowSession、WMS分别是什么？
- Q：Window有哪几种类型？
- Q：Activity创建和Dialog创建过程的异同？

####  3.7 ActivityManagerService
- Q：Instrumentation、ActivityStack、PackageInfo是什么？

####  3.8 Context
- Q：Context、ContextImpl、ContextWrapper是什么？

### 4 线程
#### 4.1 线程通信
- `Handler`
  * Q：谈谈消息机制Hander？作用？有哪些要素？流程是怎样的？
  * Q：可以在子线程直接new一个Handler吗？那该怎么做？
  * Q：使用Hanlder的postDealy()后消息队列会发生什么变化？
- `Looper`
  * Q：这里的ThreadLocal有什么作用？为什么Looper是ThreadLocal的？
  * Q：主线程中Looper死循环为何没有卡死主线程？
- `Message`
  * Q：Message可以如何创建？哪种效果更好(回收池)？为什么需要回收池？
- Q：为什么系统不建议在子线程访问UI？
- Q：一个Thread可以有几个Looper(1)？几个Handler(多个)？
- Q：如何将一个Thread线程变成Looper线程(prepare loop)？Looper线程有哪些特点？
- Q：MessageQueue是怎么实现取消息时拥塞，放置消息时唤醒的(epoll、pipe)？
- Q：Thread直接调用run方法会怎么样？start方法作用是什么？

- Q：AsyncTask的原理，以及线程池？
- Q：HandlerThread是什么(自带looper的线程，通过getHandler方法对外暴露Handler给外部使用)？
- Q：IntentService是什么(自带looper线程的工作Service，回调onHandleIntent方法)？
- Q：线程池的好处、原理、类型？

### 5 进程通信IPC
#### 5.1基础
- Q：Android中进程和线程的关系？区别？
- Q：为何需要进行IPC？多进程通信可能会出现什么问题？
- Q：什么是序列化？Serializable接口和Parcelable接口的区别？为何推荐使用后者？
#### 5.2 binder
- Q：Android中为何新增Binder来作为主要的IPC方式？
- Q：使用Binder(binder binderProxy BBinder BpBinder)进行数据传输的具体过程？
- Q：Binder框架中ServiceManager的作用？
- Q：Android中有哪些基于Binder的IPC方式(Messenger、Aidl)？简单对比下？
- Q：是否了解AIDL？原理(stub(binder) proxy(binderProxy的代理))是什么？如何优化多模块都使用AIDL的情况？



### 6. Animation
- Q：Android中有哪几种类型的动画？
- Q：帧动画在使用时需要注意什么？
- Q：View动画和属性动画的区别？
- Q：View动画为何不能真正改变View的位置？而属性动画为何可以？
- Q：属性动画插值器和估值器的作用？

### 7. 数据存储
- Q：Android中提供哪些数据持久存储的方法？
- Q：Java中的I/O流读写怎么做？
- Q：SharePreferences适用情形？使用中需要注意什么？
- `SQLite`
  * Q：了解`SQLite`中的事务处理吗？是如何做的？
  * Q：使用`SQLite`做批量操作有什么好的方法吗？
  * Q：如果现在要删除`SQLite`中表的一个字段如何做？
  * Q：使用`SQLite`时会有哪些优化操作?

### 8. 性能优化
- Q：`merge` 标签、`ViewStub` 标签、 `include` 标签
- Q：性能优化方向(绘制优化、内存泄露、布局优化)
- Q：如何优化app启动？
- Q：了解哪些性能优化的工具(内存、方法时间、布局结构分析)？
- Q：布局上如何优化？列表呢？
- Q：什么情况会导致内存溢出？
- Q：内存泄漏和内存溢出的区别？
- Q：内存泄漏是什么？为什么会发生？常见哪些内存泄漏的例子？都是怎么解决的？

#### 遇到的问题
- Q：什么是ANR？什么情况会出现ANR？如何避免？在不看代码的情况下如何快速定位出现ANR问题所在？



## 2.Java
###  2.1 基础
- Q：Java封装、集成、多态
- Q：重写和重载的区别？
- Q：抽象类和接口的异同？
- Q：泛型的本质是什么？什么是泛型擦除？
- Q：怎么使用注解？注解的本质是什么？
- Q：String、StringBuffer和StringBuilder的区别？
- Q：String a=""和String a=new String("")的的关系和异同？
- Q：装箱、拆箱什么含义？为什么ArrayList\<Integer>能够添加int 数字?
- Q：int和Integer的区别？
- Q：遇见过哪些运行时异常？异常处理机制知道哪些？
- Q：什么是反射，有什么作用和应用？
- Q：final、finally、finalize()分别表示什么含义？
- `Object`
  * Q：有哪些公用方法(finalize、toString、hashcode、clone、getclass、wait、notify)？
  * Q：深克隆与浅克隆？
  * Q：`wait`、`notify`方法怎么使用？
  * Q： `Object` 的 `equal()` 和 `==` 的区别？
- Q：[动态代理的原理？](https://blog.csdn.net/wangzhibo666/article/details/86677197)
- `system.out.println` 是怎么实现不同终端(windows、mac)打印效果不同的？
- 内部类
	* Q：内部类的作用？
	* Q：匿名内部类、静态内部类、内部类的区别？
	* Q：为什么内部类可以访问外部类的私有成员和方法？外部类能够访问内
部类的私有变量和方法？
  * Q：为什么匿名内部类中使用局部变量要用final修饰？

### 2.2 集合
- Q：Java集合框架中有哪些类？都有什么特点
- Q：集合、数组、泛型的关系，并比较
- Q：ArrayList和LinkList的区别(数组与链表)？
- Q：ArrayList和Vector的区别？
- Q：HashSet和TreeSet的区别？
- HashMap
  * Q：`HashMap`和`Hashtable`的区别？
  * Q：`HashMap`在put、get元素的过程？数据结构是什么样的？如何解决Hash冲突(拉链法)？
  * Q：如何保证`HashMap`线程安全？什么原理？
  * Q：`HashMap`是有序的吗？如何实现有序(`LinkedHashMap`)？
  * Q：`HashMap`是如何扩容的？如何避免扩容？
- Q：hashcode()的作用，与equal()有什么区别？
- Q：ConcurrentHashmap的同步原理？
- Q：Lru算法与LinkedHashMap？

###  2.3 并发
- Q：什么是ThreadLocal？原理(主内存与工作内存)
- Q：开启一个线程的方法有哪些？销毁一个线程的方法呢？
- Q：同步和非同步、阻塞和非阻塞的概念
- Q：Thread的join()有什么作用？
- Q：线程的有哪些状态？
- Q：什么是线程安全？保障线程安全有哪些手段？
- Q：ReentrantLock和synchronized的区别?
- Q：synchronized和volatile的区别？
- Q：synchronized同步代码块还有同步方法本质上锁住的是谁？为什么？
- Q：sleep()和wait()的区别？
- Q：怎么安全停止一个线程任务？原理是什么？线程池里有类似机制吗？
- Q：Java有哪些线程池？他们的区别是什么？线程池工作流程是怎样的？线程池实现原理是怎样的？Cache线程池有哪些弊端？
---------------------------
## 3. JVM
- Q：JVM内存是如何划分的？
- Q：谈谈垃圾回收机制？为什么引用计数器判定对象是否回收不可行？知道哪些垃圾回收算法？
- Q：介绍下分代回收?
- Q：Java中引用有几种类型？在Android中常用于什么情景？
- Q：类加载的全过程是怎样的？什么是双亲委派模型？
- Q：工作内存和主内存的关系？在Java内存模型有哪些可以保证并发过程的原子性、可见性和有序性的措施？
- Q：JVM、Dalvik、ART的区别？
- Q：Java中堆(对象)和栈(局部变量)的区别？
- Q：垃圾回收机制？有哪些对象可以作为GC roots？





## 4. 计算机网络
###  4.1 基础
- Q：五层协议的体系结构分别是什么？每一层都有哪些协议？

  ​	应用层、运输层、网络层、数据链路层、物理层

- Q：为何有MAC地址还要IP地址？

  ​	Mac是物理的口，属于数据链路层的，同一局域网的设备通过mac通信。IP是网络层的概念，是网络拓扑结构中的节点，IP是可以变的，而mac是不变的，局域网与局域网之间通过ip地址，路由通信，路由内部通信通过arp广播，ip地址映射到mac地址，找到实际的mac地址通信。

### 4.2 TCP
- Q：TCP和UDP的区别？

  ​	TCP是面向连接的，可靠的，保证时序的。UDP是非连接的、不可靠、不保证时序。

- Q：TCP如何保证传输是可靠的？数据不丢失？连续且按序？

  ​	

- Q：拥塞控制和流量控制都是什么，两者的区别？

- Q：谈谈TCP为什么要三次握手？为什么要四次挥手？

- Q：播放视频用TCP还是UDP？为什么？

- Q：cookie是用来干嘛的？

### 4.3 HTTP
- Q：HTTP报文样式与header字段
- Q：了解哪些响应状态码？
- Q：get和post的区别？
- Q：Http1.0、Http1.1、Http2.0的区别？
- Q：HTTP和TCP的区别?
- Q：HTTP和HTTPS的区别?
- Q：HTTP和Socket的区别?
- Q：在地址栏打入http://www.baidu.com会发生什么(DNS -> HTTPS -> HTTP -> TCP -> IP -> 数据链路)？





## 5. 设计模式
 - 依赖注入
 - 代理模式与[动态代理](https://blog.csdn.net/wangzhibo666/article/details/86677197)
 - 观察者模式
 - 单例模式
- 谈谈MVC、MVP和MVVM？





## 6. 操作系统
- Q：操作系统中进程和线程的区别？
- Q：死锁的产生和避免(银行家算法)?
- Q：如何理解生产者消费者模型？





## 7. 算法
- Q：什么是斐波那契数列？
- Q：迭代和递归的特点，并比较优缺点
- Q：了解哪些查找算法，时间复杂度都是多少？
- Q：了解哪些排序算法，并比较一下，以及适用场景
- Q：快排的基本思路是什么？最差的时间复杂度是多少？如何优化？
- Q：100盏灯问题
- Q：老鼠和毒药问题，加个条件，必须要求第二天出结果
- Q：海量数据问题
- Q：（手写算法）二分查找
- Q：（手写算法）反转链表
- Q：（手写算法）用两个栈实现队列
- Q：（手写算法）多线程轮流打印问题
- Q：（手写算法）如何判断一个链有环/两条链交叉
- Q：（手写算法）快速从一组无序数中找到第k大的数/前k个大的数
- Q：（手写算法）最长（不）重复子串

## 8.数据结构

- Q：AVL树插入或删除一个节点的过程是怎样的？
- Q：什么是红黑树？





## 为什么不写答案
> 这篇文章主要是把题目总结下来，做一个抛砖引玉，实际上技术的题目没有标准答案，不同的人看的维度和深度是不同的，下篇文章[2019最全Android面试题总结解密(持续更新中。。。)](https://blog.csdn.net/wangzhibo666/article/details/87879500)将会提供题目答案，仅是我自己的理解，大佬请勿拍我。




## 完整Android学习路径 请戳[我的Android学习之旅](https://blog.csdn.net/wangzhibo666/article/details/86647871)
> - [**基于AIDL的 Activity、Service跨进程观察者模式实现与源码解读**](https://blog.csdn.net/wangzhibo666/article/details/86667934)
> - [**走进源码，Android面试最常见Handler、Looper、Message问题总结与解答**](https://blog.csdn.net/wangzhibo666/article/details/86514518)
> - [**Android面试---ListView原理及fling分析**](https://blog.csdn.net/wangzhibo666/article/details/87370137)
> - [**5分钟告诉你，Activity的视图绘制流程(onMeasure、onLayout、onDraw的调用和参数解释**)](https://blog.csdn.net/wangzhibo666/article/details/86656675)
> - [**2019最全Android面试题总结(持续更新中。。。)**](https://blog.csdn.net/wangzhibo666/article/details/87881677)

## 感谢
[厘米姑娘](https://www.jianshu.com/u/203b606b956c)的 [文章汇总|学习Android的一点一滴](https://www.jianshu.com/p/c44d7a106302)