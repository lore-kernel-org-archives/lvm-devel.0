From: Chiyohiko Morita <morita@valinux.co.jp>
Date: Wed, 12 Feb 2014 17:18:06 +0900
Subject: dmeventd generates segfault when creating snapshots
In-Reply-To: <52F9FC6D.6090708@redhat.com>
References: <20140210203415.7529.DDAE3F33@valinux.co.jp>
	<52F9FC6D.6090708@redhat.com>
Message-ID: <20140212171805.02AE.DDAE3F33@valinux.co.jp>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> Dne 10.2.2014 12:34, Chiyohiko Morita napsal(a):
> > 
> > (I'm not on this list; please Cc me)
> > 
> > With a high load, the dmeventd daemon sometimes generates
> > a segmentation violation when createing a lvm-snapshot.
> > 
> > In _register_for_event(), it may take 10 or more seconds between
> > calling _register_for_timeout() and _create_thread().
> > (Please refer to the following _register_for_timeout().)
> > 
> > If the _timeout_thread thread calls pthread_kill() before
> > _create_thread() is called, dmeventd will generate segfault.
> > This is because the value of thread->thread is still NULL.
> > (Please refer to the following _timeout_thread().)
> > 
> > A related source code and coredump are shown below.
> > 
> 
> Could you please open regular  lvm2 bugzilla
> (at   http://bugzilla.redhat.com/   - use Fedora Rawhide in case you don't
> have match for your distro)
> 
> Attach all your information provided here in your email.
> 
> Add info from 'vgs, lvs -a, pvs' and your in-use lvm.conf
> version of your lvm2 package,
> how many volumes are active.

I am using LVM2 version lvm2-2.02.87-6.el6.x86_64.
Please refer to the following for package information 
and 'vgs, lvs -a, pvs' command output. 

# rpm -qa | grep kernel-2
kernel-2.6.32-220.23.1.el6.x86_64
kernel-2.6.32-220.el6.x86_64
(RHEL/CentOS 6.2)

# rpm -qa | grep lvm2
lvm2-libs-2.02.87-6.el6.x86_64
lvm2-2.02.87-6.el6.x86_64
lvm2-debuginfo-2.02.87-6.el6.x86_64

# vgs
  VG      #PV #LV #SN Attr   VSize VFree
  test-vg   2   5   2 wz--n- 7.99g 4.98g

# lvs -a
  LV          VG      Attr   LSize Origin Snap%  Move Log Copy%  Convert
  data01      test-vg owi-a- 1.00g
  data01_snap test-vg swi-a- 4.00m data01   0.00
  data02      test-vg owi-a- 1.00g
  data02_snap test-vg swi-a- 4.00m data02   0.00
  data03      test-vg -wi-a- 1.00g

# pvs
  PV         VG      Fmt  Attr PSize PFree
  /dev/vdb1  test-vg lvm2 a--  4.00g 1012.00m
  /dev/vdb2  test-vg lvm2 a--  4.00g    4.00g

# diff -upN /etc/lvm/lvm.conf.org /etc/lvm/lvm.conf
--- lvm.conf.org        2011-12-08 07:48:23.000000000 +0900
+++ /etc/lvm/lvm.conf   2014-02-12 07:35:34.000000000 +0900
@@ -63,7 +63,7 @@ devices {


     # By default we accept every block device:
-    filter = [ "a/.*/" ]
+    filter = [ "a|/dev/vdb*|", "r|.*|" ]

     # Exclude the cdrom drive
     # filter = [ "r|/dev/cdrom|" ]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Additional info:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# ls /etc/lvm/archive | wc -l
121510

#  ls -al /etc/lvm/archive | head
total 493076
drwxr-xr-x. 2 root root 6377472 Feb 12  2014 .
drwxr-xr-x. 9 root root    4096 Feb 12 06:28 ..
-rw-------. 1 root root    1109 Jan 29 11:59 test-vg_00000-2082297108.vg
-rw-------. 1 root root    1442 Jan 29 12:00 test-vg_00001-190015709.vg
-rw-------. 1 root root    1771 Jan 29 12:01 test-vg_00002-1842787566.vg
-rw-------. 1 root root    2372 Jan 29 12:01 test-vg_00003-1994250619.vg
-rw-------. 1 root root    1773 Jan 29 12:01 test-vg_00004-2042082134.vg
-rw-------. 1 root root    2390 Jan 29 12:01 test-vg_00005-1068639300.vg
-rw-------. 1 root root    2993 Jan 29 12:01 test-vg_00006-364657598.vg

#  ls -al /etc/lvm/archive | tail -n3
-rw-------. 1 root root    3322 Jan 31 02:14 test-vg_99997-1786673524.vg
-rw-------. 1 root root    3925 Jan 31 02:14 test-vg_99998-1284671590.vg
-rw-------. 1 root root    3306 Jan 31 02:14 test-vg_99999-1949909947.vg

# ls -alrt /etc/lvm/archive | tail -n5
-rw-------. 1 root root    2402 Feb  9 13:54 test-vg_121507-196968836.vg
-rw-------. 1 root root    3007 Feb  9 13:55 test-vg_121508-1062447752.vg
-rw-------. 1 root root    2402 Feb  9 13:55 test-vg_121509-1916506465.vg
drwxr-xr-x. 9 root root    4096 Feb 12 06:28 ..
drwxr-xr-x. 2 root root 6377472 Feb 12  2014 .


<lvcreate/lvremove command execution with no load>

# ls /etc/lvm/archive | wc -l
121510

# ls /etc/lvm/archive | head -n3
test-vg_00000-2082297108.vg
test-vg_00001-190015709.vg
test-vg_00002-1842787566.vg

# ls /etc/lvm/archive | tail -n3
test-vg_99997-1786673524.vg
test-vg_99998-1284671590.vg
test-vg_99999-1949909947.vg

# ls -rt /etc/lvm/archive | tail -n3
test-vg_121507-196968836.vg
test-vg_121508-1062447752.vg
test-vg_121509-1916506465.vg

# time lvcreate -s -L 1M -n data01_snap /dev/test-vg/data01
  Rounding up size to full physical extent 4.00 MiB
  Logical volume "data01_snap" created

real    0m11.666s
user    0m10.377s
sys     0m0.184s

--<top>---
top - 07:07:48 up 5 days,  5:02, 11 users,  load average: 0.38, 0.74, 0.74
Tasks: 155 total,   2 running, 153 sleeping,   0 stopped,   0 zombie
Cpu(s): 29.9%us,  5.3%sy,  0.0%ni, 61.3%id,  3.5%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   3923192k total,  3795744k used,   127448k free,   475752k buffers
Swap:  4194296k total,    49272k used,  4145024k free,  2213304k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
20102 root      20   0 46356  24m 1472 R 100.0  0.6   0:03.70 lvcreate
    1 root      20   0 19328  956  736 S  0.0  0.0   0:01.16 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:02.32 kthreadd
    3 root      RT   0     0    0    0 S  0.0  0.0   0:14.32 migration/0
    4 root      20   0     0    0    0 S  0.0  0.0   4:21.86 ksoftirqd/0
    5 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0
	:
---

# time lvremove -f /dev/test-vg/data01_snap
  Logical volume "data01_snap" successfully removed

real    0m11.255s
user    0m10.361s
sys     0m0.174s

--<top>---
top - 07:09:32 up 5 days,  5:03, 11 users,  load average: 0.22, 0.59, 0.69
Tasks: 161 total,   2 running, 159 sleeping,   0 stopped,   0 zombie
Cpu(s): 50.0%us,  0.2%sy,  0.0%ni, 49.8%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   3923192k total,  3797244k used,   125948k free,   475748k buffers
Swap:  4194296k total,    49272k used,  4145024k free,  2211404k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
20147 root      20   0 48124  26m 1452 R 100.0  0.7   0:03.78 lvremove
    9 root      20   0     0    0    0 S  3.3  0.0   5:50.75 ksoftirqd/1
    4 root      20   0     0    0    0 S  3.0  0.0   4:22.21 ksoftirqd/0
20146 root      20   0 15020 1208  888 R  0.3  0.0   0:00.02 top
    1 root      20   0 19328  956  736 S  0.0  0.0   0:01.16 init
	:
----------

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

Thank you

--
Chiyohiko Morita <morita valinux co jp>


