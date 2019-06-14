# Java并发

## 0. 为什么需要多线程
好处：
1. 解决了一个进程中可以同时执行多个任务的问题。
2. 提高了资源的利用率。
弊端：
1. 增加了CPU的负担，
2. 降低了一个进程中线程的执行概率（CPU是进程之间不断来回切换的）
3. 出现了线程安全问题。
4. 会引发死锁现象。

##  0.1 锁的引入
学习锁之前我们肯定要学习下线程，线程是CPU调度的最小单元。
```java
public class ThreadTest {
    public static int num = 0;
    public static void main(String[] args) {
        //1.开启10个线程去修改num的值 可以看到每次执行的结果不同
        for (int i=0; i< 10; i++){
            new Thread(){
                @Override
                public void run() {
                    super.run();
                    num++;
                }
            }.start();
        }
        System.out.println("num = " + num);
    }
}
```
如果开10个线程去给 `num` 变量自增1，那么结果是多少呢？ 
10?  答案是不确定。因为i++操作可以看成3个操作

1. 从主内存获取 `num` 的值，拷贝到线程工作内存
2. 执行`num = num+1` 操作，把 `i` 的值添加1，然后赋值给i
3. 把 `num` 的值写回主存

所以我们可以看到，如果在第1步 中2个线程同时取值，然后在第3步写的时候，那么他们写的值是一样的，那么最后得到的 `num` 值肯定不是10

那么怎么处理这个问题呢？

## 1. Q：什么是线程安全？保障线程安全有哪些手段？`

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
>   [java多线程系列(五)---synchronized ReentrantLock volatile Atomic 原理分析](http://www.cnblogs.com/-new/p/7326820.html)



## <a id="线程">2. 线程</a>

### <a id="Thread">Thread类(sleep、join、yield、interrupt)</a>

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

  > 如果线程正在运行，interrupt方法只会设置标志位，如果线程阻塞状态，将会抛出`interruptedException`
  >
  > **注意**：如果线程在`wait`状态，并且不能获取锁，`Interrupt` 没有反应

### <a id="Object类">Object类(wait、notify、notifyAll)</a>

锁池：存放竞争锁的线程
等待池：等待线程，当被唤醒的时候，会进入锁池(wait-set)

- wait：暂停当前正在执行的线程，直到调用notify()或notifyAll()方法或超时，退出等待状态；(需要先获得锁)

  > **重点**: 调用`wait()`，立马释放锁，线程拥塞

  > - 限时等待时，锁被占了，还能恢复吗？
  >
  > 不能，限时等待的前提是线程要能获得锁，这一点和 `interrupt` 方法很像，如果当前线程`wait`，并且不能获取锁，那么不能抛出 `interrupt` 异常

- notify：唤醒在该对象上等待的一个线程；(需要先获得锁 synchronized) 

> **注意**：notify只会随机唤醒一个线程，如果其他线程没有被notify，会导致线程饥饿
>
> notify只是唤醒其他线程，其他线程的执行需要等到方法执行完之后释放锁才行。

- notifyAll：唤醒在该对象上等待的所有线程；(需要先获得锁)

参考 [Java线程中yield与join方法的区别](http://www.importnew.com/14958.html)

### <a id="线程生命周期">线程生命周期(新建、就绪、阻塞(运行) 、运行、终止)</a>

![线程生命周期](https://img-blog.csdnimg.cn/20190313180412384.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190404163529864.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)

### 相关问题：

`Wait和Sleep的区别`

- Wait和Sleep都不占用CPU，wait 会释放锁，sleep不释放锁
- wait必须要在`synchronized`块里面使用，wait可以携带等待时间参数(限时等待，但是如果这个时候锁被占用，不能被分配给它，限时等待不能唤醒，原理就是jvm会在一段时间后，分配锁和时间片给它)，也可以不携带等待时间参数(不限时等待，直到其他线程调用 `notify`或者`notifyAll`唤醒他，`notify`的话是随机唤醒，没有处理好，容易造成线程一直处理等待状态，线程饥饿)， sleep的话是必须传入一个时间，阻塞一段时间后，再由操作系统唤醒。



------



## <a id="ThreadLocal">3. ThreadLocal</a>

ThreadLocal类

- 背景：可实现线程本地存储的功能，把共享数据的可见范围限制在同一个线程之内，无须同步就能保证线程之间不出现数据争用的问题，这里可理解为ThreadLocal很方便的找到本线程的Looper。
  使用：ThreadLocal<T>.set(T)  ThreadLocal.get()
- 原理：每个线程的Thread对象中都有一个ThreadLocalMap 对象`ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue)`，它存储了一组以ThreadLocal.threadLocalHashCode为key、以本地线程变量为value的键值对，而ThreadLocal对象就是当前线程的ThreadLocalMap的访问入口，也就包含了一个独一无二的threadLocalHashCode值，通过这个值就可以在线程键值值对中找回对应的本地线程变量。
  需要注意的点就是ThreadLocal的Entry使用的是弱引用，是因为ThreadLocal变量会被线程一直持有，容易造成内存泄露 ，所以使用弱引用。

## <a id="Synchronized">4. synchronized</a>

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

## 5. 扩展

### 1. [非公平锁与公平锁](<https://www.jianshu.com/p/f584799f1c77>)

- 线程饥饿 
  - 背景
    - **高优先级线程**占用大多数CPU时间片，低优先级线程饥饿
    - 线程被永远阻塞在等待同步块的状态(synchronized同步块一直不释放锁)
    - `notify` 和 `synchronized`  **不保证线程唤醒的顺序**
  - 解决 **Lock公平锁**
  - 参考 [线程饥饿](<https://cloud.tencent.com/developer/article/1193092>)

### 2. 无锁状态、偏向锁、轻量级锁、重量级锁

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

- 参考 [Java并发编程：Synchronized底层优化（偏向锁、轻量级锁）](https://www.cnblogs.com/paddix/p/5405678.html) [**死磕 Java 并发 - 深入分析 synchronized 的实现原理**](https://juejin.im/entry/589981fc1b69e60059a2156a) [java锁偏向锁](<https://ccqy66.github.io/2018/03/07/java%E9%94%81%E5%81%8F%E5%90%91%E9%94%81/>)  [Java面试必问-死锁终极篇](<https://juejin.im/post/5aaf6ee76fb9a028d3753534>)

![img](https://ccqy66.github.io/2018/03/07/java%E9%94%81%E5%81%8F%E5%90%91%E9%94%81/consulusion.jpg)



## 6. JIT(HotSpot 虚拟机)

- 背景：加速热点代码的运行

- 原理 

  Java程序最初是通过解释器进行解释执行的，当虚拟机发现**某个方法或代码块**运行的**特别频繁**时，就会把这些代码认定为**“热点代码”（Hot Spot Code）**。为了提高热点代码的执行效率，在运行时，虚拟机将会把这些代码编译成为**本地平台相关的机器码**，并进行优化，而完成这个任务的编译器称为及时编译器（Just In Time Compiler，简称JIT）。

------

## 7. Lock

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

### ReadWriteLock

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



## <a id="volatile">8. volatile</a>

(背景) `volatile` 的引入保证了线程并发的可见性。

> **为什么需要处理器缓存?**
>
> ​	相对于CPU的执行顺序，主寸的读取数据慢，所以引入寄存器缓存和高速缓存
>
> **缓存带来的问题**
>
> ​	缓存一致性问题，不同线程的缓存变量

 (使用)被 `volatile` 修饰的变量，线程每次修改之后，都把结果写回主内存，而不是 cpu缓存，然后通知其他线程缓存无效，需要从主内存读取，而不是用cpu缓存，这保证了内存一致性，还有就是 `volatile` 可以**禁止指令重排序**，重排序是编译器为了优化指令而不影响执行结果做的操作。

(例子) `volatile` 经常在单例的 `double check` 中使用。

(原理) `volatile` 会让编译的汇编代码加上 `lock`前缀，`lock` 之后的写操作，会让其他CPU的相关缓存失效，从而重新从主内存加载最新数据。

![image-20190612162615576](/Users/wzb/Documents/Android_Dev_Note/assets/image-20190612162615576.png)

## <a id="cas">9. CAS (compare and swap)</a>

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

  - #### [ABA问题](<https://juejin.im/post/5b4977ae5188251b146b2fc8>)  

    - `AtomicStampedReference` 检查当前引用是否等于预期引用，并且当前标志是否等于预期标志

  - 只能保证一个共享变量的原子操作 

    - 多个对象封装到 `AtomicReference类`

  - CPU占比很高、吞吐量很高

- 参考 [面试必备之乐观锁与悲观锁](<https://juejin.im/post/5b4977ae5188251b146b2fc8>) [面试难点：你了解乐观锁和悲观锁吗？](https://mp.weixin.qq.com/s/OsQYHZfLYKqY6QtReO4qww)



## <a id="线程池">10. 线程池</a>

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

- 参考

  [Java ThreadPoolExecutor线程池学习笔记(使用、原理、常见问题总结)-这一篇就够了](https://blog.csdn.net/wangzhibo666/article/details/88305797)

  

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

`execute` 和  `submit` 的参数不同，`execute` 的参数是 `Runnable`， 没有返回值，而`submit` 的参数是 `Callback`，其中有个 `call` 方法可以返回值，然后 `submit` 返回一个`Future` 对象，`Future`对象的`get` 方法可以获取值还能捕获异常https://www.jianshu.com/p/ca8801044352)