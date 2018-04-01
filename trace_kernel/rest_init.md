## 分析

### `rest_init()`的主要任务

查看`rest_init()`的代码，发现它主要做三件事：

1. 创建`init`进程
2. 创建`kthread`进程
3. 调用`cpu_startup_entry(CPUHP_ONLINE)`

接下来依次分析这三个任务。

### `kernel_init()`

这个函数首先调用了`kernel_init_freeable()`，做如下几件事：

* 等待`kthreadd`就绪
* 为即将启动的`init`做一系列必要的准备
* 设置ramdisk中的init路径
* 加载默认的内核模块

执行ramdisk中的init，然后执行内核参数指定的命令或者几个可能的init以及shell，如果都失败就panic。

这个进程最后成为pid为1的init进程（在比较新的发行版中为systemd）。

### `kthreadd()`

`kthreadd`是一个特殊的内核线程，作用是管理和调度其他的内核线程，运行一个全局链表中维护的内核线程。

### `cpu_startup_entry()`

这个函数依次调用了如下三个函数：

#### `arch_cpu_idle_prepare()`

这个函数调用了`local_fiq_enable()`，显然它的功能是启用一个叫`fiq`的东西，查阅了一下维基百科，`fiq`是`Fast Interrupt Request`的缩写，是一类特殊的中断请求，用来处理那些一旦发生就需要立即处理的事件，比如从网卡上接收数据、键盘和鼠标事件。事实上这个只在arm架构上出现……

用gdb跟踪到此也发现这个函数的函数体是空的。

#### `cpuhp_online_idle()`

对于boot CPU，返回继续执行；

对于非boot CPU，将状态置为CPUHP_AP_ONLINE_IDLE后返回。

#### `cpu_idle_loop()`

这个函数的大致结构如下：

```C
static void cpu_idle_loop(void)
{
    // ...
    while (1) {
        while (!need_resched()) {
           // ...
        }
        // ...
    }
    // ...
}
```

它的主要作用是消耗CPU的空闲周期，检测是否有新的任务需要调度，如果有就切换过去。它相当于windows中的system idle process。

## 总结

内核在启动的最后阶段产生pid为1的init进程和pid为2的kthreadd进程，然后自身演变为pid为0的idle进程，用于消耗CPU空闲周期，等待新的任务调度。

## 参考链接

[linux-insides, Kernel initialization. Part 10.](https://0xax.gitbooks.io/linux-insides/content/Initialization/linux-initialization-10.html)