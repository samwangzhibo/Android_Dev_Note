

### 为什么需要多线程
好处：
1，解决了一个进程中可以同时执行多个任务的问题。
2，提高了资源的利用率。
弊端：
1，增加了CPU的负担，
2，降低了一个进程中线程的执行概率（CPU是进程之间不断来回切换的）
3，出现了线程安全问题。
4，会引发死锁现象。

###  锁的引入
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


### 线程
在了解锁之前，需要了解下线程。因为我们的锁是最终处理的是线程的并发问题，那么有必要了解下线程生命周期的状态。
#### 线程的生命周期
![线程的生命周期](https://img-blog.csdnimg.cn/20190313175204774.png)
- 新建状态：新建线程对象，并没有调用start()方法之前

- 就绪状态：调用start()方法之后线程就进入就绪状态，但是并不是说只要调用start()方法线程就马上变为当前线程，在变为当前线程之前都是为就绪状态。值得一提的是，线程在睡眠和挂起中恢复的时候也会进入就绪状态哦。

- 运行状态：线程被设置为当前线程，开始执行run()方法。就是线程进入运行状态

- 阻塞状态：线程被暂停，比如说调用sleep()方法后线程就进入阻塞状态

- 死亡状态：线程执行结束

#### 线程的方法
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190313180412384.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190314003223349.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhbmd6aGlibzY2Ng==,size_16,color_FFFFFF,t_70)
- sleep：暂停当前正在执行的线程；不释放锁（类方法）
- yield：暂停当前正在执行的线程，并执行其他线程；（类方法）Thread的静态方法，此方法只是使当前线程重新回到可执行状态，不会阻塞线程，因此执行yield()的线程有可能在进入到可执行状态后马上又被执行。实际上，当某个线程调用了yield方法暂停之后，只有优先级与当前线程相同，或者优先级比当前线程更高的处于就绪状态的线程才会获得执行的机会。
- [join](https://blog.csdn.net/a158123/article/details/78633772)：挂起调用线程，等待该线程终止才执行，常用于线程顺序同步；
- interrupt：中断该线程，当线程调用wait(),sleep(),join()或I/O操作时，将收到InterruptedException或 ClosedByInterruptException；

- suspend：已过时，弃用
- resume：已过时，弃用
- stop：已过时，弃用

`object类的方法`
- wait：暂停当前正在执行的线程，直到调用notify()或notifyAll()方法或超时，退出等待状态；(需要先获得锁)
- notify：唤醒在该对象上等待的一个线程；(需要先获得锁)
- notifyAll：唤醒在该对象上等待的所有线程；(需要先获得锁)




**使用synchronized关键字：**

- 原理：编译后会在同步块的前后分别形成 `monitorenter` 和 `monitorexit` 这两个字节码指令，并通过一个reference类型的参数来指明要锁定和解锁的对象。若明确指定了对象参数，则取该对象的reference；否则，会根据synchronized修饰的是实例方法还是类方法去取对应的对象实例或Class对象来作为锁对象。

- 过程：执行monitorenter指令时先要尝试获取对象的锁。若该对象没被锁定或者已被当前线程获取，那么锁计数器+1；而在执行monitorexit指令时，锁计数器-1；当锁计数器=0时，锁就被释放；若获取对象锁失败，那当前线程会一直被阻塞等待，直到对象锁被另外一个线程释放为止。

- 特别注意： synchronized同步块对同一条线程来说是可重入的，不会出现自我锁死的问题；还有，同步块在已进入的线程执行完之前，会阻塞后面其他线程的进入。


**使用重入锁ReentrantLock：**

- 相同：用法与synchronized很相似，且都可重入。

- 与synchronized的不同：

  * 等待可中断：当持有锁的线程长期不释放锁的时候，正在等待的线程可以选择放弃等待，改为处理其他事情。

  * 公平锁：多个线程在等待同一个锁时，必须按照申请锁的时间顺序来依次获得锁。而synchronized是非公平的，即在锁被释放时，任何一个等待锁的线程都有机会获得锁。ReentrantLock默认情况下也是非公平的，但可以通过带布尔值的构造函数改用公平锁。

  * 锁绑定多个条件：一个ReentrantLock对象可以通过多次调用newCondition()同时绑定多个Condition对象。而在synchronized中，锁对象的wait()和notify()或notifyAl()只能实现一个隐含的条件，若要和多于一个的条件关联不得不额外地添加一个锁。

**选择：**
在synchronized能实现需求的情况下，优先考虑使用它来进行同步。下两张图是两者在不同处理器上的吞吐量对比。




### 参考
[Java线程状态及 wait、sleep、join、interrupt、yield等的区别](https://www.cnblogs.com/z-sm/p/6481268.html)
[要点提炼| 理解JVM之线程安全&锁优化](https://www.jianshu.com/p/ca8801044352)