From: Chiyohiko Morita <morita@valinux.co.jp>
Date: Mon, 10 Feb 2014 20:34:17 +0900
Subject: dmeventd generates segfault when creating snapshots
Message-ID: <20140210203415.7529.DDAE3F33@valinux.co.jp>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


(I'm not on this list; please Cc me)

With a high load, the dmeventd daemon sometimes generates 
a segmentation violation when createing a lvm-snapshot.

In _register_for_event(), it may take 10 or more seconds between 
calling _register_for_timeout() and _create_thread(). 
(Please refer to the following _register_for_timeout().)

If the _timeout_thread thread calls pthread_kill() before 
_create_thread() is called, dmeventd will generate segfault.
This is because the value of thread->thread is still NULL.
(Please refer to the following _timeout_thread().)

A related source code and coredump are shown below.

====================================================================
LVM2.2.02.XXX/daemons/dmeventd/dmeventd.c
====================================================================
/*
 * Register for an event.
 *
 * Only one caller at a time here, because we use
 * a FIFO and lock it against multiple accesses.
 */
static int _register_for_event(struct message_data *message_data)
{
	int ret = 0;

	:

	/* If creation of timeout thread fails (as it may), we fail
	   here completely. The client is responsible for either
	   retrying later or trying to register without timeout
	   events. However, if timeout thread cannot be started, it
	   usually means we are so starved on resources that we are
	   almost as good as dead already... */
	if (thread_new->events & DM_EVENT_TIMEOUT) {
		ret = -_register_for_timeout(thread_new);   ----------------+ 
		if (ret) {					            |
		    _unlock_mutex();                                        |
		    goto out;                                               |
		}                                                           |
	}                                         (This may take more than 10 seconds.)
                                                                            |
	if (!(thread = _lookup_thread_status(message_data))) {              |
		_unlock_mutex();                                            |
                                                                            |
		if (!(ret = _do_register_device(thread_new)))   <=(This function may make the current process sleep.)
			goto out;                                           |
                                                                            |
		thread = thread_new;                                        |
		thread_new = NULL;                                          |
                                                                            |
		/* Try to create the monitoring thread for this device. */  |
		_lock_mutex();                                              |
		if ((ret = -_create_thread(thread))) {		<-----------+ 
			_unlock_mutex();
			_do_unregister_device(thread);		
			_free_thread_status(thread);		
			goto out;
		} else
			LINK_THREAD(thread);
	}

	:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
/* Wake up monitor threads every so often. */
static void *_timeout_thread(void *unused __attribute__((unused)))
{
	struct timespec timeout;
	time_t curr_time;

	timeout.tv_nsec = 0;
	pthread_cleanup_push(_exit_timeout, NULL);
	pthread_mutex_lock(&_timeout_mutex);

	while (!dm_list_empty(&_timeout_registry)) {
		struct thread_status *thread;

		timeout.tv_sec = 0;
		curr_time = time(NULL);

		dm_list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {
			if (thread->next_time <= curr_time) {
				thread->next_time = curr_time + thread->timeout;
				pthread_kill(thread->thread, SIGALRM);		<= thread->thread is NULL
			}                                             (_monitor_thread has not been created yet.)

			if (thread->next_time < timeout.tv_sec || !timeout.tv_sec)
				timeout.tv_sec = thread->next_time;
		}

		pthread_cond_timedwait(&_timeout_cond, &_timeout_mutex,
				       &timeout);
	}

	pthread_cleanup_pop(1);

	return NULL;
}
====================================================================



Additional info:

====================================================================
coredump 1
====================================================================
- - -<command>- - - - - - - - - - - - - - - - - - - - - - - - - - -
# lvcreate -s -L 1M -n data01_snap  /dev/test-vg/data01

- - -</var/log/messages>- - - - - - - - - - - - - - - - - - - - - -
	:
Feb  6 15:35:34 COS62-SKR-K038 dmeventd[3662]: dmeventd ready for processing.
Feb  6 15:35:42 COS62-SKR-K038 lvm[3662]: Monitoring snapshot test--vg-data01_snap
Feb  6 15:36:48 COS62-SKR-K038 lvm[3662]: No longer monitoring snapshot test--vg-data01_snap
Feb  6 15:37:24 COS62-SKR-K038 lvm[3662]: Monitoring snapshot test--vg-data01_snap
Feb  6 15:38:29 COS62-SKR-K038 lvm[3662]: No longer monitoring snapshot test--vg-data01_snap
Feb  6 15:39:03 COS62-SKR-K038 lvm[3662]: Monitoring snapshot test--vg-data01_snap
Feb  6 15:40:17 COS62-SKR-K038 lvm[3662]: No longer monitoring snapshot test--vg-data01_snap
Feb  6 15:40:59 COS62-SKR-K038 kernel: dmeventd[3942]: segfault at 2d0 ip 0000003aa720c610 sp 00007fe0a578bdd8 error 4 in libpthread-2.12.so[3aa7200000+17000]
Feb  6 15:41:06 COS62-SKR-K038 abrt[3951]: saved core dump of pid 3662 (/sbin/dmeventd) to /var/spool/abrt/ccpp-2014-02-06-15:40:59-3662.new/coredump (11165696 bytes)
	:

- - -<coredump>- - - - - - - - - - - - - - - - - - - - - - - - - - -

Core was generated by `/sbin/dmeventd'.
Program terminated with signal 11, Segmentation fault.
#0  __pthread_kill (threadid=0, signo=14) at ../nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43
/usr/src/debug/glibc-2.12-2-gc4ccff1/nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43:1539:beg:0x3aa720c610
Missing separate debuginfos, use: debuginfo-install libudev-147-2.51.el6.x86_64
(gdb) info threads
  2 Thread 0x7fe0a5f0f7a0 (LWP 3662)  0x0000003aa66e6d77 in socket () at ../sysdeps/unix/syscall-template.S:82
* 1 Thread 0x7fe0a578c700 (LWP 3942)  __pthread_kill (threadid=0, signo=14) at ../nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43
(gdb) bt full
#0  __pthread_kill (threadid=0, signo=14) at ../nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43
        __x = <value optimized out>
        pd = 0x0
        tid = <value optimized out>
        val = <value optimized out>
#1  0x0000000000403218 in _timeout_thread (unused=<value optimized out>) at dmeventd.c:534
        thread = <value optimized out>
        __clframe = {__cancel_routine = 0x402ab0 <_exit_timeout>, __cancel_arg = 0x0, __do_it = 1, __cancel_type = 0}
        timeout = {tv_sec = 0, tv_nsec = 0}
        curr_time = 1391668859
#2  0x0000003aa72077f1 in start_thread (arg=0x7fe0a578c700) at pthread_create.c:301
        __res = <value optimized out>
        pd = 0x7fe0a578c700
        now = <value optimized out>
        unwind_buf = {cancel_jmp_buf = {{jmp_buf = {140602825557760, 3891965741624072973, 140735593897936, 140602825558464, 0, 3,
                -3908490291094611187, 3924399409031158541}, mask_was_saved = 0}}, priv = {pad = {0x0, 0x0, 0x0, 0x0}, data = {
              prev = 0x0, cleanup = 0x0, canceltype = 0}}}
        not_first_call = <value optimized out>
        pagesize_m1 = <value optimized out>
        sp = <value optimized out>
        freesize = <value optimized out>
#3  0x0000003aa66e5ccd in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:115
No locals.
(gdb) frame 1
#1  0x0000000000403218 in _timeout_thread (unused=<value optimized out>) at dmeventd.c:534
/usr/src/debug/LVM2.2.02.87/daemons/dmeventd/dmeventd.c:534:13457:beg:0x403218
(gdb) print thread
$1 = <value optimized out>
(gdb) print &((struct thread_status *)0)->thread
$2 = (pthread_t *) 0x10
(gdb) disassemble _timeout_thread
Dump of assembler code for function _timeout_thread:
   0x0000000000403160 <+0>:     push   %r13
	:
   0x00000000004031fa <+154>:   mov    0x60(%r12),%eax
   0x00000000004031ff <+159>:   mov    0x10(%r12),%rdi
   0x0000000000403204 <+164>:   mov    $0xe,%esi
   0x0000000000403209 <+169>:   lea    0x0(%r13,%rax,1),%rax
   0x000000000040320e <+174>:   mov    %rax,0x58(%r12)
   0x0000000000403213 <+179>:   callq  0x402740 <pthread_kill@plt>
=> 0x0000000000403218 <+184>:   mov    0x58(%r12),%rax
   0x000000000040321d <+189>:   jmp    0x4031d0 <_timeout_thread+112>
   0x000000000040321f <+191>:   nop
	:
   0x000000000040325c <+252>:   callq  0x402710 <_Unwind_Resume@plt>
End of assembler dump.
(gdb) info reg r12
r12            0x242d520        37934368
(gdb) print (struct thread_status *)0x242d520
$3 = (struct thread_status *) 0x242d520
(gdb) print *$3
$4 = {list = {n = 0x0, p = 0x0}, thread = 0, dso_data = 0x242d4d0, device = {
    uuid = 0x242d5b0 "LVM-XpiJnj24rpQoNi9vDihWFCfsCzh6JD4t0Pq57IIfrKnxacgFLryKxGLMimT3If3u",
    name = 0x1bc1510 "test--vg-data01_snap", major = 253, minor = 3}, event_nr = 0, processing = 0, status = 0, events = 196352,
  current_events = 0, current_task = 0x0, next_time = 1391668869, timeout = 10, timeout_list = {n = 0x606e90, p = 0x606e90},
  dso_private = 0x32}
(gdb) print _timeout_registry
$5 = {n = 0x242d588, p = 0x242d588}
(gdb)  print &_timeout_registry
$6 = (struct dm_list *) 0x606e90

(gdb) thread 2
[Switching to thread 2 (Thread 0x7fe0a5f0f7a0 (LWP 3662))]#0  0x0000003aa66e6d77 in socket ()
    at ../sysdeps/unix/syscall-template.S:82
/usr/src/debug/glibc-2.12-2-gc4ccff1/sysdeps/unix/syscall-template.S:82:3441:beg:0x3aa66e6d77
(gdb) bt full
#0  0x0000003aa66e6d77 in socket () at ../sysdeps/unix/syscall-template.S:82
No locals.
#1  0x0000003aa66e1b94 in openlog_internal (ident=<value optimized out>, logstat=<value optimized out>,
    logfac=<value optimized out>) at ../misc/syslog.c:355
        retry = 0
#2  0x0000003aa66e2347 in __vsyslog_chk (pri=<value optimized out>, flag=1, fmt=0x7fe0a5cac770 "Monitoring snapshot %s\n",
    ap=<value optimized out>) at ../misc/syslog.c:274
        __clframe = {__cancel_routine = 0x3aa66e1920 <cancel_handler>, __cancel_arg = 0x7fff8f14ded0, __do_it = 1,
          __cancel_type = 0}
        now_tm = {tm_sec = 58, tm_min = 40, tm_hour = 15, tm_mday = 6, tm_mon = 1, tm_year = 114, tm_wday = 4, tm_yday = 36,
          tm_isdst = 0, tm_gmtoff = 32400, tm_zone = 0x242cf10 "JST"}
        now = 1391668858
        fd = <value optimized out>
        f = <value optimized out>
        buf = 0x2340ee0 "<14>Feb  6 15:40:58 lvm[3662]: Monitoring snapshot test--vg-data01_snap\n"
        bufsize = 72
        msgoff = 20
        saved_errno = 0
        failbuf = "\000\000\000\000\000\000\000\000P\376B\002\000\000\000\000\200\376B\002\000\000\000\000`\337\024\217\377"
        clarg = {buf = 0x2340ee0, oldaction = 0x0}
#3  0x0000003aa66e2533 in __syslog_chk (pri=<value optimized out>, flag=<value optimized out>, fmt=<value optimized out>)
    at ../misc/syslog.c:131
        ap = {{gp_offset = 32, fp_offset = 48, overflow_arg_area = 0x7fff8f14e020, reg_save_area = 0x7fff8f14df60}}
#4  0x00007fe0a5cabe93 in syslog (device=0x1bc1510 "test--vg-data01_snap", uuid=<value optimized out>,
    major=<value optimized out>, minor=<value optimized out>, private=0x242d598) at /usr/include/bits/syslog.h:32
No locals.
#5  register_device (device=0x1bc1510 "test--vg-data01_snap", uuid=<value optimized out>, major=<value optimized out>,
    minor=<value optimized out>, private=0x242d598) at dmeventd_snapshot.c:247
        percent_check = 0x242d598
        r = 1
#6  0x0000000000403bc0 in _do_register_device (message_data=0x606f00) at dmeventd.c:689
No locals.
#7  _register_for_event (message_data=0x606f00) at dmeventd.c:1010
        ret = 0
        thread = <value optimized out>
        thread_new = 0x242d520
        dso_data = <value optimized out>
#8  0x00000000004045f1 in _handle_request (msg=0x7fff8f14e2e0) at dmeventd.c:1426
        requests = {{cmd = 2, f = 0x403720 <_register_for_event>}, {cmd = 3, f = 0x402fd0 <_unregister_for_event>}, {cmd = 4,
            f = 0x402f80 <_get_registered_device>}, {cmd = 5, f = 0x402f70 <_get_next_registered_device>}, {cmd = 6,
            f = 0x402dc0 <_set_timeout>}, {cmd = 7, f = 0x402d40 <_get_timeout>}, {cmd = 1, f = 0x402870 <_active>}, {cmd = 10,
            f = 0x402ad0 <_get_status>}}
        req = 0x606e00
#9  _do_process_request (msg=0x7fff8f14e2e0) at dmeventd.c:1457
        ret = <value optimized out>
        answer = <value optimized out>
        message_data = {id = 0x1bc1580 "3913:3", dso_name = 0x242d850 "libdevmapper-event-lvm2snapshot.so",
          device_uuid = 0x1bc1ed0 "LVM-XpiJnj24rpQoNi9vDihWFCfsCzh6JD4t0Pq57IIfrKnxacgFLryKxGLMimT3If3u", events = {
            str = 0x2ff00 <Address 0x2ff00 out of bounds>, field = 196352}, timeout = {str = 0xa <Address 0xa out of bounds>,
            secs = 10}, msg = 0x7fff8f14e2e0}
#10 0x0000000000404aec in _process_request (argc=<value optimized out>, argv=<value optimized out>) at dmeventd.c:1488
        die = 0
        msg = {cmd = 2, size = 0, data = 0x0}
#11 main (argc=<value optimized out>, argv=<value optimized out>) at dmeventd.c:1971
        opt = <value optimized out>
        fifos = {client = 5, server = 4, client_path = 0x405ac5 "/var/run/dmeventd-client",
          server_path = 0x405aac "/var/run/dmeventd-server"}
(gdb) frame 7
#7  _register_for_event (message_data=0x606f00) at dmeventd.c:1010
/usr/src/debug/LVM2.2.02.87/daemons/dmeventd/dmeventd.c:1010:24323:beg:0x403bc0
(gdb) print *thread_new
$7 = {list = {n = 0x0, p = 0x0}, thread = 0, dso_data = 0x242d4d0, device = {
    uuid = 0x242d5b0 "LVM-XpiJnj24rpQoNi9vDihWFCfsCzh6JD4t0Pq57IIfrKnxacgFLryKxGLMimT3If3u",
    name = 0x1bc1510 "test--vg-data01_snap", major = 253, minor = 3}, event_nr = 0, processing = 0, status = 0, events = 196352,
  current_events = 0, current_task = 0x0, next_time = 1391668869, timeout = 10, timeout_list = {n = 0x606e90, p = 0x606e90},
  dso_private = 0x32}

(gdb) print _thread_registry_unused
$8 = {n = 0x606df0, p = 0x606df0}
(gdb) print &_thread_registry_unused
$9 = (struct dm_list *) 0x606df0
(gdb) print _thread_registry
$10 = {n = 0x606de0, p = 0x606de0}
(gdb) print &_thread_registry
$11 = (struct dm_list *) 0x606de0


====================================================================
coredump 2
====================================================================
- - -<command>- - - - - - - - - - - - - - - - - - - - - - - - - - -
# lvcreate -s -L 1M -n data01_snap  /dev/test-vg/data01

- - -</var/log/messages>- - - - - - - - - - - - - - - - - - - - - -
	:
Feb  7 00:37:39 COS62-SKR-K038 lvm[5281]: Monitoring snapshot test--vg-data01_snap
Feb  7 00:40:01 COS62-SKR-K038 lvm[5281]: No longer monitoring snapshot test--vg-data01_snap
Feb  7 00:40:23 COS62-SKR-K038 lvm[5281]: Monitoring snapshot test--vg-data01_snap
Feb  7 00:42:32 COS62-SKR-K038 lvm[5281]: No longer monitoring snapshot test--vg-data01_snap
Feb  7 00:42:53 COS62-SKR-K038 lvm[5281]: Monitoring snapshot test--vg-data01_snap
Feb  7 00:45:18 COS62-SKR-K038 lvm[5281]: No longer monitoring snapshot test--vg-data01_snap
Feb  7 00:45:49 COS62-SKR-K038 kernel: dmeventd[6048]: segfault at 2d0 ip 0000003aa720c610 sp 00007f2f908e7dd8 error 4 in libpthread-2.12.so[3aa7200000+17000]
Feb  7 00:46:22 COS62-SKR-K038 abrt[6049]: saved core dump of pid 5281 (/sbin/dmeventd) to /var/spool/abrt/ccpp-2014-02-07-00:45:53-5281.new/coredump (21397504 bytes)
Feb  7 00:46:23 COS62-SKR-K038 abrtd: Directory 'ccpp-2014-02-07-00:45:53-5281' creation detected
Feb  7 00:48:48 COS62-SKR-K038 dmeventd[6071]: dmeventd ready for processing.
Feb  7 00:49:08 COS62-SKR-K038 lvm[6071]: Monitoring snapshot test--vg-data01_snap
Feb  7 00:50:08 COS62-SKR-K038 lvm[6071]: No longer monitoring snapshot test--vg-data01_snap
Feb  7 00:50:34 COS62-SKR-K038 lvm[6071]: Monitoring snapshot test--vg-data01_snap
Feb  7 00:51:34 COS62-SKR-K038 lvm[6071]: No longer monitoring snapshot test--vg-data01_snap
Feb  7 00:51:57 COS62-SKR-K038 lvm[6071]: Monitoring snapshot test--vg-data01_snap
	:

- - -<coredump>- - - - - - - - - - - - - - - - - - - - - - - - - - -
Core was generated by `/sbin/dmeventd'.
Program terminated with signal 11, Segmentation fault.
#0  __pthread_kill (threadid=0, signo=14) at ../nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43
/usr/src/debug/glibc-2.12-2-gc4ccff1/nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43:1539:beg:0x3aa720c610
Missing separate debuginfos, use: debuginfo-install libudev-147-2.51.el6.x86_64
(gdb) info thread
  2 Thread 0x7f2f9127c7a0 (LWP 5281)  _touch_memory () at mm/memlock.c:119
* 1 Thread 0x7f2f908e8700 (LWP 6048)  __pthread_kill (threadid=0, signo=14) at ../nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43

(gdb) bt full
#0  __pthread_kill (threadid=0, signo=14) at ../nptl/sysdeps/unix/sysv/linux/pthread_kill.c:43
        __x = <value optimized out>
        pd = 0x0
        tid = <value optimized out>
        val = <value optimized out>
#1  0x0000000000403218 in _timeout_thread (unused=<value optimized out>) at dmeventd.c:534
        thread = <value optimized out>
        __clframe = {__cancel_routine = 0x402ab0 <_exit_timeout>, __cancel_arg = 0x0, __do_it = 1, __cancel_type = 0}
        timeout = {tv_sec = 0, tv_nsec = 0}
        curr_time = 1391701548
#2  0x0000003aa72077f1 in start_thread (arg=0x7f2f908e8700) at pthread_create.c:301
        __res = <value optimized out>
        pd = 0x7f2f908e8700
        now = <value optimized out>
        unwind_buf = {cancel_jmp_buf = {{jmp_buf = {139842265450240, -2678941760172108955, 140734499851136, 139842265450944, 0, 3,
                2633864390507189093, -2691126274855054491}, mask_was_saved = 0}}, priv = {pad = {0x0, 0x0, 0x0, 0x0}, data = {
              prev = 0x0, cleanup = 0x0, canceltype = 0}}}
        not_first_call = <value optimized out>
        pagesize_m1 = <value optimized out>
        sp = <value optimized out>
        freesize = <value optimized out>
#3  0x0000003aa66e5ccd in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:115
No locals.
(gdb) frame 1
#1  0x0000000000403218 in _timeout_thread (unused=<value optimized out>) at dmeventd.c:534
/usr/src/debug/LVM2.2.02.87/daemons/dmeventd/dmeventd.c:534:13457:beg:0x403218
(gdb) print thread
$1 = <value optimized out>
(gdb) print &((struct thread_status *)0)->thread
$2 = (pthread_t *) 0x10
(gdb) disassemble _timeout_thread
Dump of assembler code for function _timeout_thread:
   0x0000000000403160 <+0>:     push   %r13
	:
   0x00000000004031fa <+154>:   mov    0x60(%r12),%eax
   0x00000000004031ff <+159>:   mov    0x10(%r12),%rdi
   0x0000000000403204 <+164>:   mov    $0xe,%esi
   0x0000000000403209 <+169>:   lea    0x0(%r13,%rax,1),%rax
   0x000000000040320e <+174>:   mov    %rax,0x58(%r12)
   0x0000000000403213 <+179>:   callq  0x402740 <pthread_kill@plt>
=> 0x0000000000403218 <+184>:   mov    0x58(%r12),%rax
   0x000000000040321d <+189>:   jmp    0x4031d0 <_timeout_thread+112>
   0x000000000040321f <+191>:   nop
	:
   0x000000000040325c <+252>:   callq  0x402710 <_Unwind_Resume@plt>
End of assembler dump.
(gdb) info reg r12
r12            0x1a37f20        27492128
(gdb)  print (struct thread_status *)0x1a37f20
$3 = (struct thread_status *) 0x1a37f20
(gdb)  print _timeout_registry
$4 = {n = 0x1a37f88, p = 0x1a37f88}
(gdb) print &_timeout_registry
$5 = (struct dm_list *) 0x606e90

(gdb) thread 2
[Switching to thread 2 (Thread 0x7f2f9127c7a0 (LWP 5281))]#0  _touch_memory () at mm/memlock.c:119
/usr/src/debug/LVM2.2.02.87/lib/mm/memlock.c:119:2720:beg:0x7f2f90bb1eb3
(gdb) bt full
#0  _touch_memory () at mm/memlock.c:119
        pagesize = 4096
        pos = 0x2262c70 ""
        end = 0x2274c68 ""
#1  _allocate_memory () at mm/memlock.c:132
        stack_mem = <value optimized out>
        temp_malloc_mem = 0x1a74c70
#2  0x00007f2f90bb1fc7 in _lock_mem (cmd=0x1a3ae50) at mm/memlock.c:305
No locals.
#3  _lock_mem_if_needed (cmd=0x1a3ae50) at mm/memlock.c:382
No locals.
#4  0x00007f2f90be8946 in lvm2_run (handle=0x1a3ae50, cmdline=<value optimized out>) at lvmcmdlib.c:85
        argc = 1
        ret = 1
        oneoff = 0
        args = {0x1a72290 "_memlock_inc", 0x1a6f170 "libdevmapper-event-lvm2mirror.so", 0x1000 <Address 0x1000 out of bounds>,
          0x7f2f90bc737e "H\213\234$\220", 0x2000 <Address 0x2000 out of bounds>, 0x7f2f90bf2fc3 "mirror",
          0x2000 <Address 0x2000 out of bounds>, 0x3aa698be80 "", 0x6d766c2f6374652f <Address 0x6d766c2f6374652f out of bounds>,
          0x0, 0x0, 0x3aa66797d1 "H\205\300H\211\303t7\203=\210^1", 0x0, 0x1a390a0 "\020\213\002\251:",
          0x2000 <Address 0x2000 out of bounds>,
          0x3aa8e17c54 "H\205\300H\211\303t4H\215@\030N\215$#H\211\003L\211c\bH\213E\020H\211C\020H\211]\020H\211\330H\213l$\bH\213\034$L\213d$\020H\203\304\030\303\017\037", 0x1000 <Address 0x1000 out of bounds>, 0x8 <Address 0x8 out of bounds>,
          0x1a44e10 "libdevmapper-event-lvm2mirror.so",
          0x3aa8e17df9 "H\211\301\061\300\213T$\bH\205\311t\313H\213\061\215B\377H!\360H)\305H\215\004.H\211\001\353\257\017\037@", 0x0, 0x7f2f00000008 <Address 0x7f2f00000008 out of bounds>, 0x1a6f170 "libdevmapper-event-lvm2mirror.so",
          0x1a3a4d0 "\200\256\243\001", 0x1a3ae50 "", 0x7fff4ddf0b10 "P\256\243\001",
          0x6d766c2f6374652f <Address 0x6d766c2f6374652f out of bounds>, 0x0, 0x0, 0x1a3ae50 "", 0x1a3ae80 "\320J\247\001",
          0x7fff4ddf0b10 "P\256\243\001", 0x6d766c2f6374652f <Address 0x6d766c2f6374652f out of bounds>,
          0x7f2f90b7072f "H\205\300t\325L\213` M\205\344t\314E\213\034$L\215\264$\200", 0x7f2f90bb4710 "UH\215\065t_\004",
          0x7f2f90bb5350 "UH\215\065\351U\004", 0x7f2f90b7c8b0 "UH\215\065\340\006\a", 0x7f2f90b8c850 "UH\215\065 ;\006",
          0x7f2f90bc0de0 "H\215\065\005\273\003", 0x7f2f90bc0dd0 "H\215\065\017\273\003", 0x7f2f90bc0dc0 "H\215\065\031\273\003",
          0x7f2f90bc0db0 "H\215\065 \273\003", 0x7f2f90bc0da0 "H\215\065'\273\003", 0x7f2f90bc0d90 "H\215\065.\273\003",
          0x7f2f90bc0d80 "H\215\065\065\273\003", 0x7f2f90bc0d70 "H\215\065$\273\003", 0x7f2f90bc0d60 "H\215\065L\273\003",
          0x7f2f90bc0d50 "H\215\065S\273\003", 0x7f2f90bc0d40 "H\215\065Z\273\003", 0x0, 0x1a3ae50 "",
          0x3aa720e559 "H\211\320H\203\304\bH=\001\360\377\377s\001\303H\213\r\020\212 ", 0x0, 0x7f2f90bb0ed7 "\211?\001",
          0x1a3ae50 "", 0x0, 0x1a3ae50 "", 0x0, 0x1a3ae50 "", 0x7f2f90b71754 "H\213\203", <incomplete sequence \320>,
          0x11cc510 "test--vg-data01_snap", 0x1a37f98 "", 0x1a37f98 "", 0x0}
        argv = 0x7fff4ddf0980
        cmdcopy = 0x1a72290 "_memlock_inc"
        cmd = 0x1a3ae50
#5  0x00007f2f90e2db34 in dmeventd_lvm2_init () at dmeventd_lvm.c:117
        r = 0
#6  0x00007f2f9102fe6e in register_device (device=0x11cc510 "test--vg-data01_snap", uuid=<value optimized out>,
    major=<value optimized out>, minor=<value optimized out>, private=0x1a37f98) at dmeventd_snapshot.c:243
        percent_check = 0x1a37f98
        r = <value optimized out>
#7  0x0000000000403bc0 in _do_register_device (message_data=0x606f00) at dmeventd.c:689
No locals.
#8  _register_for_event (message_data=0x606f00) at dmeventd.c:1010
        ret = 0
        thread = <value optimized out>
        thread_new = 0x1a37f20
        dso_data = <value optimized out>
#9  0x00000000004045f1 in _handle_request (msg=0x7fff4ddf0e90) at dmeventd.c:1426
        requests = {{cmd = 2, f = 0x403720 <_register_for_event>}, {cmd = 3, f = 0x402fd0 <_unregister_for_event>}, {cmd = 4,
            f = 0x402f80 <_get_registered_device>}, {cmd = 5, f = 0x402f70 <_get_next_registered_device>}, {cmd = 6,
            f = 0x402dc0 <_set_timeout>}, {cmd = 7, f = 0x402d40 <_get_timeout>}, {cmd = 1, f = 0x402870 <_active>}, {cmd = 10,
            f = 0x402ad0 <_get_status>}}
        req = 0x606e00
#10 _do_process_request (msg=0x7fff4ddf0e90) at dmeventd.c:1457
        ret = <value optimized out>
        answer = <value optimized out>
        message_data = {id = 0x11cc580 "6008:3", dso_name = 0x11cc770 "libdevmapper-event-lvm2snapshot.so",
          device_uuid = 0x1a73c00 "LVM-XpiJnj24rpQoNi9vDihWFCfsCzh6JD4tM4HMZzzG4gill3AxggwJUROaoE2tPqLg", events = {
            str = 0x2ff00 <Address 0x2ff00 out of bounds>, field = 196352}, timeout = {str = 0xa <Address 0xa out of bounds>,
            secs = 10}, msg = 0x7fff4ddf0e90}
#11 0x0000000000404aec in _process_request (argc=<value optimized out>, argv=<value optimized out>) at dmeventd.c:1488
        die = 0
        msg = {cmd = 2, size = 0, data = 0x0}
#12 main (argc=<value optimized out>, argv=<value optimized out>) at dmeventd.c:1971
        opt = <value optimized out>
        fifos = {client = 5, server = 4, client_path = 0x405ac5 "/var/run/dmeventd-client",
          server_path = 0x405aac "/var/run/dmeventd-server"}
(gdb) fram 8
#8  _register_for_event (message_data=0x606f00) at dmeventd.c:1010
/usr/src/debug/LVM2.2.02.87/daemons/dmeventd/dmeventd.c:1010:24323:beg:0x403bc0
(gdb) print *thread_new
$6 = {list = {n = 0x0, p = 0x0}, thread = 0, dso_data = 0x1a73e20, device = {
    uuid = 0x1a37fb0 "LVM-XpiJnj24rpQoNi9vDihWFCfsCzh6JD4tM4HMZzzG4gill3AxggwJUROaoE2tPqLg",
    name = 0x11cc510 "test--vg-data01_snap", major = 253, minor = 0}, event_nr = 0, processing = 0, status = 0, events = 196352,
  current_events = 0, current_task = 0x0, next_time = 1391701558, timeout = 10, timeout_list = {n = 0x606e90, p = 0x606e90},
  dso_private = 0x0}

(gdb) print _thread_registry
$7 = {n = 0x606de0, p = 0x606de0}
(gdb) print &_thread_registry
$8 = (struct dm_list *) 0x606de0
(gdb) print _thread_registry_unused
$9 = {n = 0x606df0, p = 0x606df0}
(gdb) print &_thread_registry_unused
$10 = (struct dm_list *) 0x606df0

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

Thanks,

--
Chiyohiko Morita <morita valinux co jp>



