From: Eric Ren <zren@suse.com>
Date: Sun, 19 Feb 2017 00:46:02 +0800
Subject: Question about the fix "clvmd: Fix freeze if client dies holding locks"
In-Reply-To: <354d7d0a-70dc-69b2-3aed-9c60c7a1064d@redhat.com>
References: <58A836FB020000D40008F988@prv-mh.provo.novell.com>
	<354d7d0a-70dc-69b2-3aed-9c60c7a1064d@redhat.com>
Message-ID: <6ead33c0-a772-aaac-46e3-a0d6be278fc7@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

On 02/18/2017 05:45 PM, Zdenek Kabelac wrote:
> [snip]
>>
>> I still cannot find out what is the root cause after looking the code 
>> around, only to be confused with "lastfd" in your patch,
>> which is assigned at 3 times, but never used.
>
> Hi
>
> Could you please open regular community BZ about this issue ?
> https://bugzilla.redhat.com/enter_bug.cgi?product=LVM%20and%20device-mapper 
>
>
> Provide full backtrace of all threads of clmvd please.
Thanks for this advice. I'd be happy to do so if I can reproduce this 
issue with
the latest upstream version in my testing:)

But, in case you might be interested in seeing the back traces, I've 
attached 3 files in which all the
back traces are listed.

1. hang_without_this_fixes.txt     -  lvm2 command hang-up is the 
original problem;
2. hang_with_this_fixes.txt    - so I backported the 2 patches below, 
then it happens much less often, but
still occurred once:

- Upstream commit id: be662439331abf6ccb16dd996bfe15eb613b4e53 "clvmd: 
Fix freeze if client dies holding locks"
- upstream commit: 25bed9968155f43ef0b8832383ef711e7ae1685d "clvmd: 
Avoid a 3-way deadlock in dead-client cleanup"

3. segfault_with_this_fixes.txt - segfault happens rather often now.

And, our base-version is pretty old - lvm2-2.02.98.
>
> I'd some patches which were redoing some if this lasfd logic - but 
> there was not enough justification if it's fixing some bug or bring in 
> some new one.

Yes:)

Regards,
Eric
>
> Regards
>
> Zdenek
>
> -- 
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>

-------------- next part --------------
(gdb) info threads
  Id   Target Id         Frame 
  27   Thread 0x7fb37003b7a0 (LWP 11280) 0x00007fb36eddc324 in __lll_lock_wait () from /lib64/libpthread.so.0
  26   Thread 0x7fb36ca71700 (LWP 12200) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  25   Thread 0x7fb36c856700 (LWP 12199) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  24   Thread 0x7fb36c94b700 (LWP 12186) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  23   Thread 0x7fb36c9de700 (LWP 12185) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  22   Thread 0x7fb36c97c700 (LWP 12171) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  21   Thread 0x7fb36c825700 (LWP 12164) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  20   Thread 0x7fb36c91a700 (LWP 12163) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  19   Thread 0x7fb36c8b8700 (LWP 12150) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  18   Thread 0x7fb36c730700 (LWP 12149) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  17   Thread 0x7fb36cad3700 (LWP 12136) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  16   Thread 0x7fb36c792700 (LWP 12135) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  15   Thread 0x7fb36ca40700 (LWP 12122) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  14   Thread 0x7fb36fed8700 (LWP 12114) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  13   Thread 0x7fb36fea7700 (LWP 12094) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  12   Thread 0x7fb36ff09700 (LWP 12085) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  11   Thread 0x7fb36c887700 (LWP 12081) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  10   Thread 0x7fb36c9ad700 (LWP 12076) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  9    Thread 0x7fb36c7c3700 (LWP 12063) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  8    Thread 0x7fb36c7f4700 (LWP 12044) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  7    Thread 0x7fb36c761700 (LWP 12042) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  6    Thread 0x7fb36ca0f700 (LWP 12021) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  5    Thread 0x7fb36c6ff700 (LWP 12015) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  4    Thread 0x7fb36c8e9700 (LWP 12007) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  3    Thread 0x7fb36caa2700 (LWP 11946) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  2    Thread 0x7fb36ff3a700 (LWP 11291) 0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
* 1    Thread 0x7fb36d2d4700 (LWP 11290) 0x00007fb36eddc7fd in read () from /lib64/libpthread.so.0

=========

(gdb) thread 1
[Switching to thread 1 (Thread 0x7fb36d2d4700 (LWP 11290))]
#0  0x00007fb36eddc7fd in read () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fb36eddc7fd in read () from /lib64/libpthread.so.0
#1  0x00007fb36efed4e5 in read (__nbytes=<optimized out>, __buf=<optimized out>, __fd=<optimized out>) at /usr/include/bits/unistd.h:45
#2  do_dlm_dispatch_v6 (fd=13) at libdlm.c:531
#3  0x00007fb36efed607 in dlm_recv_thread (lsinfo=0x6c9d70) at libdlm.c:1182
#4  0x00007fb36edd5806 in start_thread () from /lib64/libpthread.so.0
#5  0x00007fb36e92c67d in clone () from /lib64/libc.so.6
#6  0x0000000000000000 in ?? ()

==========

(gdb) thread 2
[Switching to thread 2 (Thread 0x7fb36ff3a700 (LWP 11291))]
#0  0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040dbab in lvm_thread_fn (arg=0x7fb368002c30) at clvmd.c:2085
#2  0x00007fb36edd5806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fb36e92c67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) list clvmd.c:2085
2080		pthread_mutex_lock(&lvm_thread_mutex);
2081	
2082		while (!quit) {
2083			if (dm_list_empty(&lvm_cmd_head)) {
2084				DEBUGLOG("LVM thread waiting for work\n");
2085				pthread_cond_wait(&lvm_thread_cond, &lvm_thread_mutex);
2086			} else {
2087				cmd = dm_list_item(dm_list_first(&lvm_cmd_head),
2088						   struct lvm_thread_cmd);
2089				dm_list_del(&cmd->list);

========= the same backtrace for thread 3-26 ========

(gdb) thread 3
[Switching to thread 3 (Thread 0x7fb36caa2700 (LWP 11946))]
#0  0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fb36edd966c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x00007fb36efed927 in sync_write_v6 (lsinfo=0x6c9d70, req=0x7fb36caa1a70, len=<optimized out>) at libdlm.c:640
#2  0x00007fb36efede7e in ls_lock_v6 (ls=0x6c9d70, mode=<optimized out>, lksb=0x7fb36caa1ce0, flags=2147483648, name=0x0, namelen=<optimized out>, 
    parent=0, astaddr=0x0, astarg=0x0, bastaddr=0x0, xid=0x0, timeout=0x0) at libdlm.c:824
#3  0x00007fb36efedf87 in ls_lock (ls=0x6c9d70, mode=128, lksb=0x7fb36caa1ce0, flags=2147483648, name=0x0, namelen=9, parent=0, astaddr=0x0, 
    astarg=0x0, bastaddr=0x246, range=0x0) at libdlm.c:867
#4  0x00007fb36efee18d in dlm_ls_lock_wait (ls=0x7fb36caa19c4, mode=128, lksb=0x1, flags=4294967295, name=0x7fb36caa1900, namelen=0, parent=0, 
    bastarg=0x0, bastaddr=0x0, range=0x0) at libdlm.c:929
#5  0x0000000000410b49 in _lock_resource (resource=0x6fd973 "P_#global", mode=4, flags=0, lockid=0x7fb36caa1d40) at clvmd-corosync.c:475
#6  0x0000000000409892 in lock_vg (client=<optimized out>) at clvmd-command.c:236
#7  do_pre_command (client=0x70e9a0) at clvmd-command.c:274
#8  0x000000000040d558 in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1720
#9  0x00007fb36edd5806 in start_thread () from /lib64/libpthread.so.0
#10 0x00007fb36e92c67d in clone () from /lib64/libc.so.6
#11 0x0000000000000000 in ?? ()

=========

(gdb) thread 27
[Switching to thread 27 (Thread 0x7fb37003b7a0 (LWP 11280))]
#0  0x00007fb36eddc324 in __lll_lock_wait () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fb36eddc324 in __lll_lock_wait () from /lib64/libpthread.so.0
#1  0x00007fb36edd7669 in _L_lock_1008 () from /lib64/libpthread.so.0
#2  0x00007fb36edd747e in pthread_mutex_lock () from /lib64/libpthread.so.0
#3  0x000000000040d03f in read_from_local_sock (thisfd=0x7fb368044610) at clvmd.c:1117
#4  0x000000000040b31b in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:904
#5  0x000000000040c09f in main (argc=<optimized out>, argv=<optimized out>) at clvmd.c:611
(gdb) list clvmd.c:1117
1112			thisfd->bits.localsock.finished = 1;
1113	
1114			/* If the client went away in mid command then tidy up */
1115			if (thisfd->bits.localsock.in_progress) {
1116				pthread_kill(thisfd->bits.localsock.threadid, SIGUSR2);
1117				pthread_mutex_lock(&thisfd->bits.localsock.mutex);
1118				thisfd->bits.localsock.state = POST_COMMAND;
1119				pthread_cond_signal(&thisfd->bits.localsock.cond);
1120				pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
1121	




-------------- next part --------------
(gdb) info threads 
  Id   Target Id         Frame 
  21   Thread 0x7fd1c705d7a0 (LWP 48137) 0x00007fd1c5dff324 in __lll_lock_wait () from /lib64/libpthread.so.0
  20   Thread 0x7fd1c362f700 (LWP 12159) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  19   Thread 0x7fd1c3660700 (LWP 11907) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  18   Thread 0x7fd1c3691700 (LWP 11902) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  17   Thread 0x7fd1c36c2700 (LWP 11517) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  16   Thread 0x7fd1c36f3700 (LWP 11516) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  15   Thread 0x7fd1c3724700 (LWP 10116) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  14   Thread 0x7fd1c3755700 (LWP 9996) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  13   Thread 0x7fd1c3786700 (LWP 9720) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  12   Thread 0x7fd1c37b7700 (LWP 7026) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  11   Thread 0x7fd1c37e8700 (LWP 7025) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  10   Thread 0x7fd1c3819700 (LWP 6993) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  9    Thread 0x7fd1c6efa700 (LWP 6988) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  8    Thread 0x7fd1c387b700 (LWP 6447) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  7    Thread 0x7fd1c6f2b700 (LWP 5200) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  6    Thread 0x7fd1c384a700 (LWP 2430) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  5    Thread 0x7fd1c3af6700 (LWP 2377) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  4    Thread 0x7fd1c6ec9700 (LWP 946) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  3    Thread 0x7fd1c38ac700 (LWP 47722) 0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  2    Thread 0x7fd1c6f5c700 (LWP 48149) 0x00007fd1c5dff324 in __lll_lock_wait () from /lib64/libpthread.so.0
* 1    Thread 0x7fd1c42f7700 (LWP 48148) 0x00007fd1c5dff7fd in read () from /lib64/libpthread.so.0

===========
(gdb) bt
#0  0x00007fd1c5dff7fd in read () from /lib64/libpthread.so.0
#1  0x00007fd1c60104e5 in ?? () from /usr/lib64/libdlm.so.3
#2  0x00007fd1c6010607 in ?? () from /usr/lib64/libdlm.so.3
#3  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#4  0x00007fd1c594f67d in clone () from /lib64/libc.so.6

===========
(gdb) thread 2
[Switching to thread 2 (Thread 0x7fd1c6f5c700 (LWP 48149))]
#0  0x00007fd1c5dff324 in __lll_lock_wait () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dff324 in __lll_lock_wait () from /lib64/libpthread.so.0
#1  0x00007fd1c5dfa669 in _L_lock_1008 () from /lib64/libpthread.so.0
#2  0x00007fd1c5dfa47e in pthread_mutex_lock () from /lib64/libpthread.so.0
#3  0x000000000040ac61 in add_reply_to_list (client=0x7fd1b40653d0, status=128, csid=0x0, 
    buf=0xffffffffffffffff <error: Cannot access memory@address 0xffffffffffffffff>, len=-1274653520) at clvmd.c:1678
#4  0x000000000040ded9 in process_local_command (xid=<optimized out>, client=<optimized out>, msglen=<optimized out>, msg=<optimized out>)
    at clvmd.c:1845
#5  process_work_item (cmd=<optimized out>) at clvmd.c:2076
#6  lvm_thread_fn (arg=<optimized out>) at clvmd.c:2123
#7  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#8  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#9  0x0000000000000000 in ?? ()

================
(gdb) thread 3
[Switching to thread 3 (Thread 0x7fd1c38ac700 (LWP 47722))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) list clvmd.c:1781
1776			DEBUGLOG("Waiting to do post command - state = %d\n",
1777				 client->bits.localsock.state);
1778	
1779			if (client->bits.localsock.state != POST_COMMAND &&
1780			    !client->bits.localsock.finished) {
1781				pthread_cond_wait(&client->bits.localsock.cond,
1782						  &client->bits.localsock.mutex);
1783			}
1784	
1785			DEBUGLOG("Got post command condition...\n");

============
(gdb) thread 4
[Switching to thread 4 (Thread 0x7fd1c6ec9700 (LWP 946))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d813 in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1806
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) list clvmd.c:1806
1801	next_pre:
1802			DEBUGLOG("Waiting for next pre command\n");
1803	
1804			if (client->bits.localsock.state != PRE_COMMAND &&
1805			    !client->bits.localsock.finished) {
1806				pthread_cond_wait(&client->bits.localsock.cond,
1807						  &client->bits.localsock.mutex);
1808			}
1809	
1810			DEBUGLOG("Got pre command condition...\n");

(gdb) thread  5
[Switching to thread 5 (Thread 0x7fd1c3af6700 (LWP 2377))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread  6
[Switching to thread 6 (Thread 0x7fd1c384a700 (LWP 2430))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread  7
[Switching to thread 7 (Thread 0x7fd1c6f2b700 (LWP 5200))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread  8
[Switching to thread 8 (Thread 0x7fd1c387b700 (LWP 6447))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread  9
[Switching to thread 9 (Thread 0x7fd1c6efa700 (LWP 6988))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 10
[Switching to thread 10 (Thread 0x7fd1c3819700 (LWP 6993))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 11
[Switching to thread 11 (Thread 0x7fd1c37e8700 (LWP 7025))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 12
[Switching to thread 12 (Thread 0x7fd1c37b7700 (LWP 7026))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 13
[Switching to thread 13 (Thread 0x7fd1c3786700 (LWP 9720))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 14
[Switching to thread 14 (Thread 0x7fd1c3755700 (LWP 9996))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 15
[Switching to thread 15 (Thread 0x7fd1c3724700 (LWP 10116))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) thread 16
[Switching to thread 16 (Thread 0x7fd1c36f3700 (LWP 11516))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 17
[Switching to thread 17 (Thread 0x7fd1c36c2700 (LWP 11517))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 18
[Switching to thread 18 (Thread 0x7fd1c3691700 (LWP 11902))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 19
[Switching to thread 19 (Thread 0x7fd1c3660700 (LWP 11907))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()
(gdb) thread 20
[Switching to thread 20 (Thread 0x7fd1c362f700 (LWP 12159))]
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dfc66c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000040d84b in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1781
#2  0x00007fd1c5df8806 in start_thread () from /lib64/libpthread.so.0
#3  0x00007fd1c594f67d in clone () from /lib64/libc.so.6
#4  0x0000000000000000 in ?? ()

================================

(gdb) thread 21
[Switching to thread 21 (Thread 0x7fd1c705d7a0 (LWP 48137))]
#0  0x00007fd1c5dff324 in __lll_lock_wait () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fd1c5dff324 in __lll_lock_wait () from /lib64/libpthread.so.0
#1  0x00007fd1c5dfa669 in _L_lock_1008 () from /lib64/libpthread.so.0
#2  0x00007fd1c5dfa47e in pthread_mutex_lock () from /lib64/libpthread.so.0
#3  0x000000000040ccb5 in timedout_callback (client=0x7fd1b40653d0, csid=0x7ffe0b999150 "!\017\250@", node_up=<optimized out>) at clvmd.c:798
#4  0x0000000000411192 in _cluster_do_node_callback (master_client=0x7fd1b40653d0, callback=0x40cc00 <timedout_callback>) at clvmd-corosync.c:459
#5  0x000000000040b8b0 in request_timed_out (client=<optimized out>) at clvmd.c:825
#6  main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:978
#7  0x000000000040c454 in main (argc=<optimized out>, argv=<optimized out>) at clvmd.c:615
(gdb) list clvmd.c:825
820	   number of replies that triggers the post command so we need to do it here
821	*/
822	static void request_timed_out(struct local_client *client)
823	{
824		DEBUGLOG("Request timed-out. padding\n");
825		clops->cluster_do_node_callback(client, timedout_callback);
826	
827		if (client->bits.localsock.num_replies !=
828		    client->bits.localsock.expected_replies) {
829			/* Post-process the command */
(gdb) list clvmd-corosync.c:459
454	
455			DEBUGLOG("down_callback. node %d, state = %d\n", ninfo->nodeid,
456				 ninfo->state);
457	
458			if (ninfo->state != NODE_DOWN)
459				callback(master_client, csid, ninfo->state == NODE_CLVMD);
460		}
461		return 0;
462	}
463	
(gdb) list  clvmd.c:798
793			struct node_reply *reply;
794			char nodename[max_cluster_member_name_len];
795	
796			clops->name_from_csid(csid, nodename);
797			DEBUGLOG("Checking for a reply from %s\n", nodename);
798			pthread_mutex_lock(&client->bits.localsock.reply_mutex);
799	
800			reply = client->bits.localsock.replies;
801			while (reply && strcmp(reply->node, nodename) != 0) {
802				reply = reply->next;



-------------- next part --------------
Core was generated by `/usr/sbin/clvmd -d2'.
Program terminated with signal SIGBUS, Bus error.
#0  0x000000000040b56f in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:898
898						FD_SET(thisfd->fd, &in);
(gdb) info threads 
  Id   Target Id         Frame 
  6    Thread 0x7fab9b702700 (LWP 9828) 0x00007fab9d20a7fd in read () from /lib64/libpthread.so.0
  5    Thread 0x7fab9ace6700 (LWP 10412) 0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  4    Thread 0x7fab9e2d5700 (LWP 10419) 0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  3    Thread 0x7fab9aed0700 (LWP 10405) 0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  2    Thread 0x7fab9e368700 (LWP 9829) 0x00007fab9ccf6552 in _int_free () from /lib64/libc.so.6
* 1    Thread 0x7fab9e4697a0 (LWP 9819) 0x000000000040b56f in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:898
(gdb) bt
#0  0x000000000040b56f in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:898
#1  0x000000000040c454 in main (argc=<optimized out>, argv=<optimized out>) at clvmd.c:615
(gdb) list clvmd.c:898
893	
894				/* if the cluster is not quorate then don't listen for new requests */
895				if ((thisfd->type != LOCAL_RENDEZVOUS &&
896				     thisfd->type != LOCAL_SOCK) || quorate)
897					if (thisfd->fd < FD_SETSIZE)
898						FD_SET(thisfd->fd, &in);
899			}
900	
901			select_status = select(FD_SETSIZE, &in, NULL, NULL, &tv);
902	
(gdb) frame 0
#0  0x000000000040b56f in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:898
898						FD_SET(thisfd->fd, &in);
(gdb) p *thisfd
$1 = {fd = -1660992632, type = 32683, next = 0x7fab9cff4388 <main_arena+1288>, xid = 37792, callback = 0x6c93a0, removeme = 0 '\000', bits = {
    localsock = {replies = 0x6c92a0, num_replies = 0, expected_replies = 0, sent_time = 0, in_progress = 7354112, sent_out = 0, private = 0x0, 
      cmd = 0x0, cmd_len = 0, pipe = 0, finished = 0, all_success = 0, cleanup_needed = 0, pipe_client = 0x0, threadid = 0, state = PRE_COMMAND, 
      mutex = {__data = {__lock = 7115952, __count = 0, __owner = 0, __nusers = 0, __kind = 7115968, __spins = 0, __list = {__prev = 0x0, 
            __next = 0x0}}, __size = "\260\224l", '\000' <repeats 13 times>, "\300\224l", '\000' <repeats 20 times>, __align = 7115952}, cond = {
        __data = {__lock = 1104, __futex = 0, __total_seq = 0, __wakeup_seq = 4294967295, __woken_seq = 4345488, __mutex = 0xffffffff, 
          __nwaiters = 2633962400, __broadcast_seq = 32683}, 
        __size = "P\004", '\000' <repeats 14 times>, "\377\377\377\377\000\000\000\000\220NB\000\000\000\000\000\377\377\377\377\000\000\000\000\240\023\377\234\253\177\000", __align = 1104}, reply_mutex = {__data = {__lock = -1664114304, __count = 32683, __owner = -1664114528, __nusers = 32683, 
          __kind = -133950800, __spins = 32766, __list = {__prev = 0x7ffef80412a8, __next = 0x0}}, 
        __size = "\200\241?\253\177\000\000\240\240?\253\177\000\000\260\022\004\370\376\177\000\000\250\022\004\370\376\177\000\000\000\000\000\000\000\000\000", __align = 140375046988160}}, pipe = {client = 0x6c92a0, threadid = 0}, net = {private = 0x6c92a0, flags = 0}}}
(gdb) p in
$2 = {fds_bits = {2533283380331136, 0 <repeats 15 times>}}

============== this segfault might be caused by "free NULL pointer" =================
(gdb) thread 2
[Switching to thread 2 (Thread 0x7fab9e368700 (LWP 9829))]
#0  0x00007fab9ccf6552 in _int_free () from /lib64/libc.so.6
(gdb) bt
#0  0x00007fab9ccf6552 in _int_free () from /lib64/libc.so.6
#1  0x00007fab9ccfa10c in free () from /lib64/libc.so.6
#2  0x00007fab9da3a9a0 in dm_hash_destroy () from /lib64/libdevmapper.so.1.02
#3  0x0000000000424edc in _persistent_destroy (f=0x7fab94050810) at filters/filter-persistent.c:325
#4  0x000000000041c276 in refresh_toolcontext (cmd=0x6c9f20) at commands/toolcontext.c:1591
#5  0x000000000040eceb in do_refresh_cache () at lvm-functions.c:655
#6  0x0000000000409e23 in do_command (client=0x6c92a0, msg=<optimized out>, msglen=<optimized out>, buf=0x7fab9e367df0, buflen=65516, 
    retlen=0x7fab9e367dfc) at clvmd-command.c:117
#7  0x000000000040dea3 in process_local_command (xid=<optimized out>, client=<optimized out>, msglen=<optimized out>, msg=<optimized out>)
    at clvmd.c:1838
#8  process_work_item (cmd=<optimized out>) at clvmd.c:2076
#9  lvm_thread_fn (arg=<optimized out>) at clvmd.c:2123
#10 0x00007fab9d203806 in start_thread () from /lib64/libpthread.so.0
#11 0x00007fab9cd5a67d in clone () from /lib64/libc.so.

======================
(gdb) thread 3
[Switching to thread 3 (Thread 0x7fab9aed0700 (LWP 10405))]
#0  0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x00007fab9d41b927 in sync_write_v6 (lsinfo=0x6c9d70, req=0x7fab9aecfa70, len=<optimized out>) at libdlm.c:640
#2  0x00007fab9d41be7e in ls_lock_v6 (ls=0x6c9d70, mode=<optimized out>, lksb=0x7fab9aecfce0, flags=2147483648, name=0x0, namelen=<optimized out>, 
    parent=0, astaddr=0x0, astarg=0x0, bastaddr=0x0, xid=0x0, timeout=0x0) at libdlm.c:824
#3  0x00007fab9d41bf87 in ls_lock (ls=0x6c9d70, mode=128, lksb=0x7fab9aecfce0, flags=2147483648, name=0x0, namelen=9, parent=0, astaddr=0x0, 
    astarg=0x0, bastaddr=0x246, range=0x0) at libdlm.c:867
#4  0x00007fab9d41c18d in dlm_ls_lock_wait (ls=0x7fab9aecf9c4, mode=128, lksb=0x1, flags=4294967295, name=0x7fab9aecf900, namelen=0, parent=0, 
    bastarg=0x0, bastaddr=0x0, range=0x0) at libdlm.c:929
#5  0x0000000000410cc9 in _lock_resource (resource=0x7fab94000d73 "P_#global", mode=4, flags=0, lockid=0x7fab9aecfd40) at clvmd-corosync.c:475
#6  0x0000000000409912 in lock_vg (client=<optimized out>) at clvmd-command.c:236
#7  do_pre_command (client=0x7fab94002bc0) at clvmd-command.c:274
#8  0x000000000040d6ce in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1750
#9  0x00007fab9d203806 in start_thread () from /lib64/libpthread.so.0
#10 0x00007fab9cd5a67d in clone () from /lib64/libc.so.6
#11 0x0000000000000000 in ?? ()
(gdb) thread 4
[Switching to thread 4 (Thread 0x7fab9e2d5700 (LWP 10419))]
#0  0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x00007fab9d41b927 in sync_write_v6 (lsinfo=0x6c9d70, req=0x7fab9e2d4a70, len=<optimized out>) at libdlm.c:640
#2  0x00007fab9d41be7e in ls_lock_v6 (ls=0x6c9d70, mode=<optimized out>, lksb=0x7fab9e2d4ce0, flags=2147483648, name=0x0, namelen=<optimized out>, 
    parent=0, astaddr=0x0, astarg=0x0, bastaddr=0x0, xid=0x0, timeout=0x0) at libdlm.c:824
#3  0x00007fab9d41bf87 in ls_lock (ls=0x6c9d70, mode=128, lksb=0x7fab9e2d4ce0, flags=2147483648, name=0x0, namelen=9, parent=0, astaddr=0x0, 
    astarg=0x0, bastaddr=0x246, range=0x0) at libdlm.c:867
#4  0x00007fab9d41c18d in dlm_ls_lock_wait (ls=0x7fab9e2d49c4, mode=128, lksb=0x1, flags=4294967295, name=0x7fab9e2d4900, namelen=0, parent=0, 
    bastarg=0x0, bastaddr=0x0, range=0x0) at libdlm.c:929
#5  0x0000000000410cc9 in _lock_resource (resource=0x7fab94019d93 "P_#global", mode=4, flags=0, lockid=0x7fab9e2d4d40) at clvmd-corosync.c:475
#6  0x0000000000409912 in lock_vg (client=<optimized out>) at clvmd-command.c:236
#7  do_pre_command (client=0x7fab940029e0) at clvmd-command.c:274
#8  0x000000000040d6ce in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1750
#9  0x00007fab9d203806 in start_thread () from /lib64/libpthread.so.0
#10 0x00007fab9cd5a67d in clone () from /lib64/libc.so.6
#11 0x0000000000000000 in ?? ()
(gdb) thread 5
[Switching to thread 5 (Thread 0x7fab9ace6700 (LWP 10412))]
#0  0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007fab9d20766c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x00007fab9d41b927 in sync_write_v6 (lsinfo=0x6c9d70, req=0x7fab9ace5a70, len=<optimized out>) at libdlm.c:640
#2  0x00007fab9d41be7e in ls_lock_v6 (ls=0x6c9d70, mode=<optimized out>, lksb=0x7fab9ace5ce0, flags=2147483648, name=0x0, namelen=<optimized out>, 
    parent=0, astaddr=0x0, astarg=0x0, bastaddr=0x0, xid=0x0, timeout=0x0) at libdlm.c:824
#3  0x00007fab9d41bf87 in ls_lock (ls=0x6c9d70, mode=128, lksb=0x7fab9ace5ce0, flags=2147483648, name=0x0, namelen=9, parent=0, astaddr=0x0, 
    astarg=0x0, bastaddr=0x246, range=0x0) at libdlm.c:867
#4  0x00007fab9d41c18d in dlm_ls_lock_wait (ls=0x7fab9ace59c4, mode=128, lksb=0x1, flags=4294967295, name=0x7fab9ace5900, namelen=0, parent=0, 
    bastarg=0x0, bastaddr=0x0, range=0x0) at libdlm.c:929
#5  0x0000000000410cc9 in _lock_resource (resource=0x7fab940021b3 "P_#global", mode=4, flags=0, lockid=0x7fab9ace5d40) at clvmd-corosync.c:475
#6  0x0000000000409912 in lock_vg (client=<optimized out>) at clvmd-command.c:236
#7  do_pre_command (client=0x7fab94002090) at clvmd-command.c:274
#8  0x000000000040d6ce in pre_and_post_thread (arg=<optimized out>) at clvmd.c:1750
#9  0x00007fab9d203806 in start_thread () from /lib64/libpthread.so.0
#10 0x00007fab9cd5a67d in clone () from /lib64/libc.so.6
#11 0x0000000000000000 in ?? ()
(gdb) thread 6
[Switching to thread 6 (Thread 0x7fab9b702700 (LWP 9828))]
#0  0x00007fab9d20a7fd in read () from /lib64/libpthread.so.0

=======================
(gdb) bt
#0  0x00007fab9d20a7fd in read () from /lib64/libpthread.so.0
#1  0x00007fab9d41b4e5 in read (__nbytes=<optimized out>, __buf=<optimized out>, __fd=<optimized out>) at /usr/include/bits/unistd.h:45
#2  do_dlm_dispatch_v6 (fd=13) at libdlm.c:531
#3  0x00007fab9d41b607 in dlm_recv_thread (lsinfo=0x6c9d70) at libdlm.c:1182
#4  0x00007fab9d203806 in start_thread () from /lib64/libpthread.so.0
#5  0x00007fab9cd5a67d in clone () from /lib64/libc.so.6
#6  0x0000000000000000 in ?? ()


