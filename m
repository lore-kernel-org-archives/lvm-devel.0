From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 26 Jan 2022 18:41:07 +0530
Subject: Reg a deadlock specific to our environment
In-Reply-To: <20220113145226.GA436@redhat.com>
References: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
	<20220113145226.GA436@redhat.com>
Message-ID: <CAFe+wq1yJG-QymJg_uT6+yEU3f0Ua5MEXaKpSEZRmDcPTMXt5w@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

See inline

On Thu, Jan 13, 2022 at 8:22 PM David Teigland <teigland@redhat.com> wrote:

> On Wed, Jan 12, 2022 at 05:10:40PM +0530, Lakshmi Narasimhan Sundararajan
> wrote:
> > In such a scenario, when our user space storage application gets
> restarted,
> > there are calls to sanitize the storage backend. This involves reading
> the
> > thin pool information. This internally, does a vg open call, which ends
> up
> > READing to all dm devices, resulting in a deadlock during startup.
> > To overcome this situation, I extended a filter to ignore all devices
> that
> > have pxd naming part of it. This solves the problem for us.
> >
> > Is there a better way to handle our deadlock situation?
>
> Hi,
>
> We need more details to understand this.  Which command is run that gets
> stuck (any?), and can you send the output of that command with -vvvv?
> By deadlock do you mean the lvm command blocks reading it?  What are the
> details of this device?  Is it a dm device, and if so can you show how we
> could create one here using dmsetup, or is it using a custom dm target?
> Do you know why the command blocks, e.g. is the device suspended?
>

>From the code, all commands that internally does vg_open() gets stuck.
Attached output of lvs -vvv wherein the lvm2 call tries to read a
dmcrypt volume whose source is a pxd device which is serviced by a
userspace app.
When this app is restarted, lvm2 sanity calls are made which gets stuck
forever because a read on a virtual pxd device happens which cannot be
serviced during startup.
All logs attached below.


>
> > Is the below posted solution good to be merged back into master?
>
> I don't think that looks like the right solution.
>

Ok, the reason we pursued this approach was to stop lvm2 from building a
cache during vg_open by filtering out pxd devices.
This seems to work for us, will await your further analysis and inputs to
handle this correctly.


>
> Dave
>
>
[root at ip-70-0-159-14 ~]# pxctl status
Status: PX is operational
Telemetry: Disabled or Unhealthy
License: PX-Enterprise (floating) (lease renewal in 6h, 4m)
Node ID: 4ae973b1-d70b-4bda-b24b-8bd9b07f1722
        IP: 70.0.159.14
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS
 ZONE    REGION
        0       HIGH            raid0           380 GiB 39 MiB  Online
 default default
        Local Storage Devices: 3 devices
        Device  Path            Media Type              Size
 Last-Scan
        0:0     /dev/sdf        STORAGE_MEDIUM_SSD      128 GiB         26
Jan 22 12:35 UTC
        0:1     /dev/sdg        STORAGE_MEDIUM_SSD      128 GiB         26
Jan 22 12:35 UTC
        0:2     /dev/sde        STORAGE_MEDIUM_SSD      128 GiB         26
Jan 22 12:35 UTC
        total                   -                       384 GiB
        Cache Devices:
         * No cache devices
        Journal Device:
        1       /dev/sdc1       STORAGE_MEDIUM_SSD
Cluster Summary
        Cluster ID: PX-INT-C0-1_26_DEV/Porx-01-caching_703_725
        Cluster UUID: 7a0e5dc3-3893-41e7-b439-8114fae147be
        Scheduler: none
        Nodes: 5 node(s) with storage (5 online)
        IP              ID
 SchedulerNodeName       Auth            StorageNode     Used    Capacity
Status   StorageStatus   Version         Kernel                          OS
        70.0.82.56      b111cff1-af96-43ce-a5cb-26fd31150682    N/A
            Disabled        Yes             39 MiB  380 GiB    Online   Up
             3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7
(Core)
        70.0.82.58      893122a7-571e-48a3-a6dd-2b210976079d    N/A
            Disabled        Yes             39 MiB  380 GiB    Online   Up
             3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7
(Core)
        70.0.159.0      85b4ad2f-5d55-4c35-9368-db381cc2f273    N/A
            Disabled        Yes             39 MiB  380 GiB    Online   Up
             3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7
(Core)
        70.0.158.220    7d29c7f6-a948-43d0-b9c2-d86e02b12899    N/A
            Disabled        Yes             39 MiB  380 GiB    Online   Up
             3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7
(Core)
        70.0.159.14     4ae973b1-d70b-4bda-b24b-8bd9b07f1722    N/A
            Disabled        Yes             39 MiB  380 GiB    Online   Up
(This node)  3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7
(Core)
Global Storage Pool
        Total Used      :  194 MiB
        Total Capacity  :  1.9 TiB
[root at ip-70-0-159-14 ~]#
[root at ip-70-0-159-14 ~]#
[root at ip-70-0-159-14 ~]# pxctl v c -s 10 -r 1 --nodes LocalNode --secure
--secret_key secret securevol
Encrypted Volume successfully created: 405564132566284931
[root at ip-70-0-159-14 ~]# pxctl host attach --secret_key secret securevol
Volume successfully attached at: /dev/mapper/pxd-enc405564132566284931


/// Created a dmcrypt volume and have it attached on the node. This is a
new block device (/dev/mapper/pxd-enc405564132566284931)
/// whose parent virtual pxd device is (/dev/pxd/pxd/pxd405564132566284931)

[root at ip-70-0-159-14 ~]# lvs
  WARNING: Not using lvmetad because config setting use_lvmetad=0.
  WARNING: To avoid corruption, rescan devices to make changes visible
(pvscan --cache).
  LV                            VG             Attr       LSize    Pool
Origin             Data%  Meta%  Move Log Cpy%Sync Convert
  root                          centos_bazinga -wi-ao----   28.99g
  swap                          centos_bazinga -wi-a-----    2.00g
  405564132566284931            pwx0           Vwi-aot---   10.00g pxpool
                 0.68
  405564132566284931_empty_snap pwx0           Vwi-a-t---   10.00g pxpool
405564132566284931 0.00
  pxMetaFS                      pwx0           Vwi-aot---   64.00g pxpool
                 0.05
  pxpool                        pwx0           twi-aot--- <379.62g
                  0.03   0.87
  vmoptdisk                     vgoptdisk      -wi-ao----  <20.00g
  vmvardisk                     vgvardisk      -wi-ao----  <20.00g
[root at ip-70-0-159-14 ~]#
[root at ip-70-0-159-14 ~]# lsblk
NAME                                       MAJ:MIN RM   SIZE RO TYPE
 MOUNTPOINT
sdf                                          8:80   0   128G  0 disk
??md127                                      9:127  0 383.6G  0 raid0
  ??pwx0-pxpool_tmeta                      253:4    0     2G  0 lvm
  ? ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
  ?   ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
  ?   ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
  ?   ??pwx0-405564132566284931            253:9    0    10G  0 lvm
  ?   ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
  ??pwx0-pxpool_tdata                      253:5    0 379.6G  0 lvm
    ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
      ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
      ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
      ??pwx0-405564132566284931            253:9    0    10G  0 lvm
      ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
sdd                                          8:48   0    64G  0 disk
pxd!pxd405564132566284931                  252:1    0    10G  0 disk
??pxd-enc405564132566284931                253:11   0    10G  0 crypt
sdb                                          8:16   0    32G  0 disk
sdg                                          8:96   0   128G  0 disk
??md127                                      9:127  0 383.6G  0 raid0
  ??pwx0-pxpool_tmeta                      253:4    0     2G  0 lvm
  ? ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
  ?   ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
  ?   ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
  ?   ??pwx0-405564132566284931            253:9    0    10G  0 lvm
  ?   ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
  ??pwx0-pxpool_tdata                      253:5    0 379.6G  0 lvm
    ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
      ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
      ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
      ??pwx0-405564132566284931            253:9    0    10G  0 lvm
      ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
sde                                          8:64   0   128G  0 disk
??md127                                      9:127  0 383.6G  0 raid0
  ??pwx0-pxpool_tmeta                      253:4    0     2G  0 lvm
  ? ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
  ?   ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
  ?   ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
  ?   ??pwx0-405564132566284931            253:9    0    10G  0 lvm
  ?   ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
  ??pwx0-pxpool_tdata                      253:5    0 379.6G  0 lvm
    ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
      ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
      ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
      ??pwx0-405564132566284931            253:9    0    10G  0 lvm
      ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
sdc                                          8:32   0    25G  0 disk
??sdc1                                       8:33   0     3G  0 part
sda                                          8:0    0   128G  0 disk
??sda4                                       8:4    0    20G  0 part
? ??vgoptdisk-vmoptdisk                    253:2    0    20G  0 lvm   /opt
??sda2                                       8:2    0    31G  0 part
? ??centos_bazinga-swap                    253:1    0     2G  0 lvm
? ??centos_bazinga-root                    253:0    0    29G  0 lvm   /
??sda3                                       8:3    0    20G  0 part
? ??vgvardisk-vmvardisk                    253:3    0    20G  0 lvm   /var
??sda1                                       8:1    0     1G  0 part  /boot
[root at ip-70-0-159-14 ~]#

[root at ip-70-0-159-14 ~]# dmsetup ls --tree
pwx0-pxMetaFS (253:8)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
pwx0-pxpool (253:7)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
pwx0-405564132566284931_empty_snap (253:10)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
pxd-enc405564132566284931 (253:11)
 ?? (252:1)
pwx0-405564132566284931 (253:9)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
vgoptdisk-vmoptdisk (253:2)
 ?? (8:4)
centos_bazinga-swap (253:1)
 ?? (8:2)
centos_bazinga-root (253:0)
 ?? (8:2)
vgvardisk-vmvardisk (253:3)
 ?? (8:3)
[root at ip-70-0-159-14 ~]#

[root@ip-70-0-159-14 ~]# ls -al /dev/pxd/pxd405564132566284931
brw-rw---- 1 root disk 252, 1 Jan 26 12:36 /dev/pxd/pxd405564132566284931

//// Stop userspace IO application that services IO to /dev/pxd/pxd<>
devices.

//// Issue lvs -vvv it is stuck for disk IO to
/dev/pxd/pxd405564132566284931.

[root at ip-70-0-159-14 ~]# ps -lef | grep lvs
4 S root      9166  7342  0  80   0 - 18108 read_e 12:40 pts/2    00:00:00
lvs -vvv
4 S root      9167  7342  0  80   0 -  1944 pipe_w 12:40 pts/2    00:00:00
tee lvs.out
0 S root      9171 17043  0  80   0 -  3133 pipe_w 12:40 pts/0    00:00:00
grep --color=auto lvs
[root at ip-70-0-159-14 ~]# cat /proc/9166/fd
fd/     fdinfo/
[root at ip-70-0-159-14 ~]# cat /proc/9166/fd
fd/     fdinfo/
[root at ip-70-0-159-14 ~]# ls /proc/9166/fd
0  1  10  11  12  13  14  2  3  4  5  6  7  8  9
[root at ip-70-0-159-14 ~]# ls -al /proc/9166/fdinfo/
total 0
dr-x------ 2 root root 0 Jan 26 12:41 .
dr-xr-xr-x 9 root root 0 Jan 26 12:40 ..
-r-------- 1 root root 0 Jan 26 12:41 0
-r-------- 1 root root 0 Jan 26 12:41 1
-r-------- 1 root root 0 Jan 26 12:41 10
-r-------- 1 root root 0 Jan 26 12:41 11
-r-------- 1 root root 0 Jan 26 12:41 12
-r-------- 1 root root 0 Jan 26 12:41 13
-r-------- 1 root root 0 Jan 26 12:41 14
-r-------- 1 root root 0 Jan 26 12:41 2
-r-------- 1 root root 0 Jan 26 12:41 3
-r-------- 1 root root 0 Jan 26 12:41 4
-r-------- 1 root root 0 Jan 26 12:41 5
-r-------- 1 root root 0 Jan 26 12:41 6
-r-------- 1 root root 0 Jan 26 12:41 7
-r-------- 1 root root 0 Jan 26 12:41 8
-r-------- 1 root root 0 Jan 26 12:41 9
[root at ip-70-0-159-14 ~]# ls -al /proc/9166/fd
total 0
dr-x------ 2 root root  0 Jan 26 12:40 .
dr-xr-xr-x 9 root root  0 Jan 26 12:40 ..
lrwx------ 1 root root 64 Jan 26 12:40 0 -> /dev/pts/2
l-wx------ 1 root root 64 Jan 26 12:40 1 -> pipe:[943352]
lr-x------ 1 root root 64 Jan 26 12:41 10 -> /dev/sdb
lr-x------ 1 root root 64 Jan 26 12:41 11 -> /dev/sdc
lr-x------ 1 root root 64 Jan 26 12:41 12 -> /dev/sdc1
lr-x------ 1 root root 64 Jan 26 12:41 13 -> /dev/sdd
lr-x------ 1 root root 64 Jan 26 12:41 14 -> /dev/md127
lrwx------ 1 root root 64 Jan 26 12:40 2 -> /dev/pts/2
lrwx------ 1 root root 64 Jan 26 12:40 3 -> /dev/mapper/control
lr-x------ 1 root root 64 Jan 26 12:41 4 -> /dev/sda
lr-x------ 1 root root 64 Jan 26 12:41 5 -> /dev/sda1
lr-x------ 1 root root 64 Jan 26 12:41 6 -> /dev/sda2
lr-x------ 1 root root 64 Jan 26 12:41 7 -> /dev/sda3
lr-x------ 1 root root 64 Jan 26 12:41 8 -> /dev/sda4
lr-x------ 1 root root 64 Jan 26 12:41 9 -> /dev/dm-11
[root at ip-70-0-159-14 ~]# ls -al /dev/mapper/pwx0-405564132566284931
lrwxrwxrwx 1 root root 7 Jan 26 12:40 /dev/mapper/pwx0-405564132566284931
-> ../dm-9
[root at ip-70-0-159-14 ~]# ls -al /dev/mapper/
centos_bazinga-root                 pwx0-pxMetaFS
pxd-enc405564132566284931
centos_bazinga-swap                 pwx0-pxpool
vgoptdisk-vmoptdisk
control                             pwx0-pxpool_tdata
vgvardisk-vmvardisk
pwx0-405564132566284931             pwx0-pxpool_tmeta
pwx0-405564132566284931_empty_snap  pwx0-pxpool-tpool
[root at ip-70-0-159-14 ~]# ls -al /dev/mapper/pxd-enc405564132566284931
lrwxrwxrwx 1 root root 8 Jan 26 12:36 /dev/mapper/pxd-enc405564132566284931
-> ../dm-11
[root at ip-70-0-159-14 ~]# top -p 9166
top - 12:44:47 up  7:45,  2 users,  load average: 0.28, 0.11, 0.15
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.0 sy,  0.0 ni, 99.7 id,  0.0 wa,  0.0 hi,  0.1 si,
 0.0 st
KiB Mem :  8167916 total,   884304 free,   470124 used,  6813488 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  7034948 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 9166 root      20   0       0      0      0 D   0.0  0.0   0:00.00 lvs

[root at ip-70-0-159-14 ~]# cat /proc/9166/task/*/status
Name:   lvs
Umask:  0077
State:  D (disk sleep)
Tgid:   9166
Ngid:   0
Pid:    9166
PPid:   7342
TracerPid:      0
Uid:    0       0       0       0
Gid:    0       0       0       0
FDSize: 256
Groups: 0
NStgid: 9166
NSpid:  9166
NSpgid: 9166
NSsid:  7342
Threads:        1
SigQ:   4/31805
SigPnd: 0000000000000000
ShdPnd: 0000000000000002
SigBlk: 0000000000000000
SigIgn: 0000000000000000
SigCgt: 0000000180000000
CapInh: 0000000000000000
CapPrm: 0000003fffffffff
CapEff: 0000003fffffffff
CapBnd: 0000003fffffffff
CapAmb: 0000000000000000
NoNewPrivs:     0
Seccomp:        0
Speculation_Store_Bypass:       thread vulnerable
Cpus_allowed:   f
Cpus_allowed_list:      0-3
Mems_allowed:
00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,0000000

0,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,000
      00000,00000000,00000001
Mems_allowed_list:      0
voluntary_ctxt_switches:        5
nonvoluntary_ctxt_switches:     2
[root at ip-70-0-159-14 ~]# cat /proc/9166/status
Name:   lvs
Umask:  0077
State:  D (disk sleep)
Tgid:   9166
Ngid:   0
Pid:    9166
PPid:   7342
TracerPid:      0
Uid:    0       0       0       0
Gid:    0       0       0       0
FDSize: 256
Groups: 0
NStgid: 9166
NSpid:  9166
NSpgid: 9166
NSsid:  7342
Threads:        1
SigQ:   4/31805
SigPnd: 0000000000000000
ShdPnd: 0000000000000002
SigBlk: 0000000000000000
SigIgn: 0000000000000000
SigCgt: 0000000180000000
CapInh: 0000000000000000
CapPrm: 0000003fffffffff
CapEff: 0000003fffffffff
CapBnd: 0000003fffffffff
CapAmb: 0000000000000000
NoNewPrivs:     0
Seccomp:        0
Speculation_Store_Bypass:       thread vulnerable
Cpus_allowed:   f
Cpus_allowed_list:      0-3
Mems_allowed:
00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000001
Mems_allowed_list:      0
voluntary_ctxt_switches:        5
nonvoluntary_ctxt_switches:     2
[root at ip-70-0-159-14 ~]# ls -al /proc/9166/fd/
total 0
dr-x------ 2 root root  0 Jan 26 12:40 .
dr-xr-xr-x 9 root root  0 Jan 26 12:40 ..
lrwx------ 1 root root 64 Jan 26 12:40 0 -> /dev/pts/2
l-wx------ 1 root root 64 Jan 26 12:40 1 -> pipe:[943352]
lr-x------ 1 root root 64 Jan 26 12:41 10 -> /dev/sdb
lr-x------ 1 root root 64 Jan 26 12:41 11 -> /dev/sdc
lr-x------ 1 root root 64 Jan 26 12:41 12 -> /dev/sdc1
lr-x------ 1 root root 64 Jan 26 12:41 13 -> /dev/sdd
lr-x------ 1 root root 64 Jan 26 12:41 14 -> /dev/md127
lrwx------ 1 root root 64 Jan 26 12:40 2 -> /dev/pts/2
lrwx------ 1 root root 64 Jan 26 12:40 3 -> /dev/mapper/control
lr-x------ 1 root root 64 Jan 26 12:41 4 -> /dev/sda
lr-x------ 1 root root 64 Jan 26 12:41 5 -> /dev/sda1
lr-x------ 1 root root 64 Jan 26 12:41 6 -> /dev/sda2
lr-x------ 1 root root 64 Jan 26 12:41 7 -> /dev/sda3
lr-x------ 1 root root 64 Jan 26 12:41 8 -> /dev/sda4
lr-x------ 1 root root 64 Jan 26 12:41 9 -> /dev/dm-11 ///// This is
/dev/mapper/pxd-enc405564132566284931
[root at ip-70-0-159-14 ~]#



[root at ip-70-0-159-14 ~]# lvs -vvv
WARNING: Ignoring duplicate config value: global_filter
WARNING: Ignoring duplicate config value: thin_pool_zero
        Parsing: lvs -vvv
        Recognised command lvs_general (id 93 / enum 74).
      Setting devices/global_filter to global_filter = [ "r|/dev/pxd.*|",
"r|/dev/mapper/pxd.*|", "a|.*/|" ]
  WARNING: Not using lvmetad because config setting use_lvmetad=0.
  WARNING: To avoid corruption, rescan devices to make changes visible
(pvscan --cache).
        Sysfs filter initialised.
        Internal filter initialised.
        Regex filter initialised.
        LVM type filter initialised.
        Usable device filter initialised (scan_lvs 0).
        mpath filter initialised.
        Partitioned filter initialised.
        MD filter initialised.
        Composite filter initialised.
      devices/cache not found in config: defaulting to /etc/lvm/cache/.cache
        Persistent filter initialised.
      metadata/record_lvs_history not found in config: defaulting to 0
        DEGRADED MODE. Incomplete RAID LVs will be processed.
        Processing command: lvs -vvv
        Command pid: 9166
        System ID:
        O_DIRECT will be used
      File-based locking selected.
      report/output_format not found in config: defaulting to basic
      log/report_command_log not found in config: defaulting to 0
      report/aligned not found in config: defaulting to 1
      report/buffered not found in config: defaulting to 1
      report/headings not found in config: defaulting to 1
      report/separator not found in config: defaulting to
      report/prefixes not found in config: defaulting to 0
      report/quoted not found in config: defaulting to 1
      report/columns_as_rows not found in config: defaulting to 0
      report/lvs_sort not found in config: defaulting to vg_name,lv_name
      report/lvs_cols_verbose not found in config: defaulting to
lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile
      report/compact_output_cols not found in config: defaulting to
        Finding VG info
        Sysfs filter initialised.
        Internal filter initialised.
        Regex filter initialised.
        LVM type filter initialised.
        Usable device filter initialised (scan_lvs 0).
        mpath filter initialised.
        Partitioned filter initialised.
        MD filter initialised.
        Composite filter initialised.
      devices/cache not found in config: defaulting to /etc/lvm/cache/.cache
        Persistent filter initialised.
        Finding devices to scan
        Creating list of system devices.
        Found dev 8:0 /dev/sda - new.
        Found dev 8:0 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0 - new
alias.
        Found dev 8:1 /dev/sda1 - new.
        Found dev 8:1 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1
- new alias.
        Found dev 8:1
/dev/disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4 - new alias.
        Found dev 8:2 /dev/sda2 - new.
        Found dev 8:2
/dev/disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc - new
alias.
        Found dev 8:2 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2
- new alias.
        Found dev 8:3 /dev/sda3 - new.
        Found dev 8:3
/dev/disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD - new
alias.
        Found dev 8:3 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3
- new alias.
        Found dev 8:4 /dev/sda4 - new.
        Found dev 8:4
/dev/disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW - new
alias.
        Found dev 8:4 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4
- new alias.
        Found dev 8:16 /dev/sdb - new.
        Found dev 8:16 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0 -
new alias.
        Found dev 8:32 /dev/sdc - new.
        Found dev 8:32 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0 -
new alias.
        Found dev 8:33 /dev/sdc1 - new.
        Found dev 8:33 /dev/disk/by-partlabel/journal - new alias.
        Found dev 8:33
/dev/disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6 - new alias.
        Found dev 8:33
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0-part1 - new alias.
        Found dev 8:48 /dev/sdd - new.
        Found dev 8:48 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0 -
new alias.
        Found dev 8:64 /dev/sde - new.
        Found dev 8:64 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0 -
new alias.
        Found dev 8:80 /dev/sdf - new.
        Found dev 8:80 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0 -
new alias.
        Found dev 8:96 /dev/sdg - new.
        Found dev 8:96 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0 -
new alias.
        Found dev 252:1 /dev/pxd/pxd405564132566284931 - new.
        Found dev 253:9
/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - new.
        Found dev 253:0 /dev/dm-0 - new.
        Found dev 253:0 /dev/centos_bazinga/root - new alias.
        Found dev 253:0 /dev/disk/by-id/dm-name-centos_bazinga-root - new
alias.
        Found dev 253:0
/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv
- new alias.
        Found dev 253:0
/dev/disk/by-uuid/3476a32c-d5c2-49e1-9efb-85238af4bbe5 - new alias.
        Found dev 253:0 /dev/mapper/centos_bazinga-root - new alias.
        Found dev 253:1 /dev/dm-1 - new.
        Found dev 253:1 /dev/centos_bazinga/swap - new alias.
        Found dev 253:1 /dev/disk/by-id/dm-name-centos_bazinga-swap - new
alias.
        Found dev 253:1
/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs
- new alias.
        Found dev 253:1
/dev/disk/by-uuid/72214974-21d6-442e-b60a-e291f8a2bea3 - new alias.
        Found dev 253:1 /dev/mapper/centos_bazinga-swap - new alias.
        Found dev 253:10 /dev/dm-10 - new.
        Found dev 253:10
/dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap - new alias.
        Found dev 253:10
/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me
- new alias.
        Found dev 253:10 /dev/mapper/pwx0-405564132566284931_empty_snap -
new alias.
        Found dev 253:10 /dev/pwx0/405564132566284931_empty_snap - new
alias.
        Found dev 253:11 /dev/dm-11 - new.
        Found dev 253:11 /dev/disk/by-id/dm-name-pxd-enc405564132566284931
- new alias.
        Found dev 253:11
/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931
- new alias.
        Found dev 253:11
/dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c - new alias.
        Found dev 253:11 /dev/mapper/pxd-enc405564132566284931 - new alias.
        Found dev 253:2 /dev/dm-2 - new.
        Found dev 253:2 /dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk - new
alias.
        Found dev 253:2
/dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE
- new alias.
        Found dev 253:2
/dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186 - new alias.
        Found dev 253:2 /dev/mapper/vgoptdisk-vmoptdisk - new alias.
        Found dev 253:2 /dev/vgoptdisk/vmoptdisk - new alias.
        Found dev 253:3 /dev/dm-3 - new.
        Found dev 253:3 /dev/disk/by-id/dm-name-vgvardisk-vmvardisk - new
alias.
        Found dev 253:3
/dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt
- new alias.
        Found dev 253:3
/dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169 - new alias.
        Found dev 253:3 /dev/mapper/vgvardisk-vmvardisk - new alias.
        Found dev 253:3 /dev/vgvardisk/vmvardisk - new alias.
        Found dev 253:4 /dev/dm-4 - new.
        Found dev 253:4 /dev/mapper/pwx0-pxpool_tmeta - new alias.
        Found dev 253:5 /dev/dm-5 - new.
        Found dev 253:5 /dev/mapper/pwx0-pxpool_tdata - new alias.
        Found dev 253:6 /dev/dm-6 - new.
        Found dev 253:6 /dev/mapper/pwx0-pxpool-tpool - new alias.
        Found dev 253:7 /dev/dm-7 - new.
        Found dev 253:7 /dev/mapper/pwx0-pxpool - new alias.
        Found dev 253:8 /dev/dm-8 - new.
        Found dev 253:8 /dev/disk/by-id/dm-name-pwx0-pxMetaFS - new alias.
        Found dev 253:8
/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ
- new alias.
        Found dev 253:8
/dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43 - new alias.
        Found dev 253:8 /dev/mapper/pwx0-pxMetaFS - new alias.
        Found dev 253:8 /dev/pwx0/pxMetaFS - new alias.
        Found dev 253:9 /dev/dm-9 - new alias.
        Found dev 253:9 /dev/disk/by-id/dm-name-pwx0-405564132566284931 -
new alias.
        Found dev 253:9
/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue
- new alias.
        Found dev 253:9
/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - exists.
        Found dev 253:9 /dev/mapper/pwx0-405564132566284931 - new alias.
        Found dev 253:9 /dev/pwx0/405564132566284931 - new alias.
        Found dev 9:127 /dev/md127 - new.
        Found dev 9:127
/dev/disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT - new
alias.
        Found dev 9:127 /dev/disk/by-id/md-name-any:pwx0 - new alias.
        Found dev 9:127
/dev/disk/by-id/md-uuid-eb0177fc:8911b6f1:2bf4d8b2:877bdfe8 - new alias.
        Found dev 9:127 /dev/md/pwx0 - new alias.
        Opened /dev/sda RO O_DIRECT
      /dev/sda: size is 268435456 sectors
        Closed /dev/sda
        filter partitioned deferred /dev/sda
        filter md deferred /dev/sda
        filter cache deferred /dev/sda
        dm version   [ opencount flush ]   [16384] (*1)
        dm status   (253:0) [ noopencount noflush ]   [16384] (*1)
        /dev/centos_bazinga/root: Skipping unusable device.
        filter caching bad /dev/centos_bazinga/root
        Opened /dev/sda1 RO O_DIRECT
      /dev/sda1: size is 2097152 sectors
        Closed /dev/sda1
        /dev/sda1: Device is a partition, using primary device sda for
mpath component detection
        filter partitioned deferred /dev/sda1
        filter md deferred /dev/sda1
        filter cache deferred /dev/sda1
        /dev/pxd/pxd405564132566284931: Skipping (regex)
        filter caching bad /dev/pxd/pxd405564132566284931
        dm status   (253:1) [ noopencount noflush ]   [16384] (*1)
        /dev/centos_bazinga/swap: Skipping unusable device.
        filter caching bad /dev/centos_bazinga/swap
        Opened /dev/sda2 RO O_DIRECT
      /dev/sda2: size is 65009664 sectors
        Closed /dev/sda2
        /dev/sda2: Device is a partition, using primary device sda for
mpath component detection
        filter partitioned deferred /dev/sda2
        filter md deferred /dev/sda2
        filter cache deferred /dev/sda2
        dm status   (253:2) [ noopencount noflush ]   [16384] (*1)
        /dev/vgoptdisk/vmoptdisk: Skipping unusable device.
        filter caching bad /dev/vgoptdisk/vmoptdisk
        Opened /dev/sda3 RO O_DIRECT
      /dev/sda3: size is 41943041 sectors
        Closed /dev/sda3
        /dev/sda3: Device is a partition, using primary device sda for
mpath component detection
        filter partitioned deferred /dev/sda3
        filter md deferred /dev/sda3
        filter cache deferred /dev/sda3
        dm status   (253:3) [ noopencount noflush ]   [16384] (*1)
        /dev/vgvardisk/vmvardisk: Skipping unusable device.
        filter caching bad /dev/vgvardisk/vmvardisk
        Opened /dev/sda4 RO O_DIRECT
      /dev/sda4: size is 41943041 sectors
        Closed /dev/sda4
        /dev/sda4: Device is a partition, using primary device sda for
mpath component detection
        filter partitioned deferred /dev/sda4
        filter md deferred /dev/sda4
        filter cache deferred /dev/sda4
        dm status   (253:4) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool_tmeta: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta
on internal LV device pwx0-pxpool_tmeta not usable.
        /dev/mapper/pwx0-pxpool_tmeta: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool_tmeta
        dm status   (253:5) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool_tdata: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata
on internal LV device pwx0-pxpool_tdata not usable.
        /dev/mapper/pwx0-pxpool_tdata: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool_tdata
        dm status   (253:6) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool-tpool: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool
on internal LV device pwx0-pxpool-tpool not usable.
        /dev/mapper/pwx0-pxpool-tpool: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool-tpool
        dm status   (253:7) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool
on internal LV device pwx0-pxpool not usable.
        /dev/mapper/pwx0-pxpool: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool
        dm status   (253:8) [ noopencount noflush ]   [16384] (*1)
        /dev/pwx0/pxMetaFS: Skipping unusable device.
        filter caching bad /dev/pwx0/pxMetaFS
        dm status   (253:9) [ noopencount noflush ]   [16384] (*1)
        /dev/pwx0/405564132566284931: Skipping unusable device.
        filter caching bad /dev/pwx0/405564132566284931
        dm status   (253:10) [ noopencount noflush ]   [16384] (*1)
        /dev/pwx0/405564132566284931_empty_snap: Skipping unusable device.
        filter caching bad /dev/pwx0/405564132566284931_empty_snap
        dm status   (253:11) [ noopencount noflush ]   [16384] (*1)
        Opened /dev/mapper/pxd-enc405564132566284931 RO O_DIRECT
      /dev/mapper/pxd-enc405564132566284931: size is 20967424 sectors
        Closed /dev/mapper/pxd-enc405564132566284931
        filter partitioned deferred /dev/mapper/pxd-enc405564132566284931
        filter md deferred /dev/mapper/pxd-enc405564132566284931
        filter cache deferred /dev/mapper/pxd-enc405564132566284931
        Opened /dev/sdb RO O_DIRECT
      /dev/sdb: size is 67108864 sectors
        Closed /dev/sdb
        filter partitioned deferred /dev/sdb
        filter md deferred /dev/sdb
        filter cache deferred /dev/sdb
        Opened /dev/sdc RO O_DIRECT
      /dev/sdc: size is 52428800 sectors
        Closed /dev/sdc
        filter partitioned deferred /dev/sdc
        filter md deferred /dev/sdc
        filter cache deferred /dev/sdc
        Opened /dev/sdc1 RO O_DIRECT
      /dev/sdc1: size is 6287360 sectors
        Closed /dev/sdc1
        /dev/sdc1: Device is a partition, using primary device sdc for
mpath component detection
        filter partitioned deferred /dev/sdc1
        filter md deferred /dev/sdc1
        filter cache deferred /dev/sdc1
        Opened /dev/sdd RO O_DIRECT
      /dev/sdd: size is 134217728 sectors
        Closed /dev/sdd
        filter partitioned deferred /dev/sdd
        filter md deferred /dev/sdd
        filter cache deferred /dev/sdd
        Opened /dev/sde RO O_DIRECT
      /dev/sde: size is 268435456 sectors
        Closed /dev/sde
        filter partitioned deferred /dev/sde
        Device /dev/sde is md raid component based on blkid variable in
udev db (ID_FS_TYPE="linux_raid_member").
        md filter full 0 excluding md component /dev/sde
        /dev/sde: Skipping md component device
        filter caching bad /dev/sde
        Opened /dev/sdf RO O_DIRECT
      /dev/sdf: size is 268435456 sectors
        Closed /dev/sdf
        filter partitioned deferred /dev/sdf
        Device /dev/sdf is md raid component based on blkid variable in
udev db (ID_FS_TYPE="linux_raid_member").
        md filter full 0 excluding md component /dev/sdf
        /dev/sdf: Skipping md component device
        filter caching bad /dev/sdf
        Opened /dev/sdg RO O_DIRECT
      /dev/sdg: size is 268435456 sectors
        Closed /dev/sdg
        filter partitioned deferred /dev/sdg
        Device /dev/sdg is md raid component based on blkid variable in
udev db (ID_FS_TYPE="linux_raid_member").
        md filter full 0 excluding md component /dev/sdg
        /dev/sdg: Skipping md component device
        filter caching bad /dev/sdg
        Opened /dev/md127 RO O_DIRECT
      /dev/md127: size is 804513792 sectors
        Closed /dev/md127
        filter partitioned deferred /dev/md127
        filter md deferred /dev/md127
        filter cache deferred /dev/md127
      Device /dev/md127 metadata_version is 1.2.
        Found 11 devices to scan
        Scanning 11 devices for VG info
        Scanning submitted 11 reads
        Processing data from device /dev/sda 8:0 fd 4 block 0x564490886010
        Scan filtering /dev/sda
      /dev/sda: using cached size 268435456 sectors
        /dev/sda: Skipping: Partition table signature found
        filter caching bad /dev/sda
      /dev/sda: Not processing filtered
^C^C^C^C^C^C
<<<<<<< Stuck here for disk IO - waiting for read from dmcrypt
volume(/dev/mapper/pwx0-405564132566284931)
whose parent device /dev/pxd/pxd/pxd405564132566284931, which is not going
to be serviced since
the application is down.

//// dmesg logs during this point.
[Wed Jan 26 12:40:03 2022] pxd_control_release: pxd-control-0(3) close OK
[Wed Jan 26 12:48:23 2022] INFO: task lvs:9166 blocked for more than 120
seconds.
[Wed Jan 26 12:48:23 2022]       Tainted: G           O
 4.20.13-1.el7.elrepo.x86_64 #1
[Wed Jan 26 12:48:23 2022] "echo 0 >
/proc/sys/kernel/hung_task_timeout_secs" disables this message.
[Wed Jan 26 12:48:23 2022] lvs             D    0  9166   7342 0x80000084
[Wed Jan 26 12:48:23 2022] Call Trace:
[Wed Jan 26 12:48:23 2022]  __schedule+0x2ab/0x880
[Wed Jan 26 12:48:23 2022]  schedule+0x36/0x80
[Wed Jan 26 12:48:23 2022]  schedule_timeout+0x1dc/0x300
[Wed Jan 26 12:48:23 2022]  ? call_rcu+0x15/0x20
[Wed Jan 26 12:48:23 2022]  ? __percpu_ref_switch_mode+0xdf/0x180
[Wed Jan 26 12:48:23 2022]  wait_for_completion+0x121/0x180
[Wed Jan 26 12:48:23 2022]  ? wake_up_q+0x80/0x80
[Wed Jan 26 12:48:23 2022]  exit_aio+0xbc/0xf0
[Wed Jan 26 12:48:23 2022]  mmput+0x2f/0x130
[Wed Jan 26 12:48:23 2022]  do_exit+0x273/0xbf0
[Wed Jan 26 12:48:23 2022]  ? __switch_to_asm+0x40/0x70
[Wed Jan 26 12:48:23 2022]  ? __switch_to+0x130/0x450
[Wed Jan 26 12:48:23 2022]  ? __switch_to_asm+0x40/0x70
[Wed Jan 26 12:48:23 2022]  do_group_exit+0x3f/0xb0
[Wed Jan 26 12:48:23 2022]  get_signal+0x166/0x780
[Wed Jan 26 12:48:23 2022]  ? read_events+0x178/0x1a0
[Wed Jan 26 12:48:23 2022]  do_signal+0x37/0x690
[Wed Jan 26 12:48:23 2022]  ? hrtimer_init+0x1b0/0x1b0
[Wed Jan 26 12:48:23 2022]  ? __audit_syscall_exit+0x21c/0x350
[Wed Jan 26 12:48:23 2022]  exit_to_usermode_loop+0x4f/0xb9
[Wed Jan 26 12:48:23 2022]  do_syscall_64+0x162/0x190
[Wed Jan 26 12:48:23 2022]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[Wed Jan 26 12:48:23 2022] RIP: 0033:0x7f71a031e644
[Wed Jan 26 12:48:23 2022] Code: Bad RIP value.
[Wed Jan 26 12:48:23 2022] RSP: 002b:00007fffce23dec0 EFLAGS: 00000246
ORIG_RAX: 00000000000000d0
[Wed Jan 26 12:48:23 2022] RAX: fffffffffffffffc RBX: 0000000000000000 RCX:
00007f71a031e644
[Wed Jan 26 12:48:23 2022] RDX: 0000000000000040 RSI: 0000000000000001 RDI:
00007f71a11dd000
[Wed Jan 26 12:48:23 2022] RBP: 000056449005a1e0 R08: 0000000000000000 R09:
00007fffce23ded0
[Wed Jan 26 12:48:23 2022] R10: 00007fffce23ded0 R11: 0000000000000246 R12:
000056449005a170
[Wed Jan 26 12:48:23 2022] R13: 000056448de8b9b0 R14: 0000000000000000 R15:
0000000000000004


//// Now doing strace output for the same scenario.

10331 open("/dev/mapper/pxd-enc405564132566284931",
O_RDONLY|O_DIRECT|O_NOATIME) = 9</dev/dm-11>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=9</dev/dm-11>, aio_buf=0x555bdebb2000, aio_nbytes=131072,
aio_offset=0}]) = 1

^^^^^ The above is the trouble, where the lvs (or any vg open call from
code) will read all dm devices that includes dm-crypt volumes too whose
source
is not ready now, thereby waiting forever.

The whole strace output is as below.
[root at ip-70-0-159-14 ~]# cat lvm.strace
10331 execve("/usr/sbin/lvs", ["lvs", "-vvv"], 0x7ffd78b022f8 /* 21 vars
*/) = 0
10331 brk(NULL)                         = 0x555bdea9c000
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064563000
10331 access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or
directory)
10331 open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3</etc/ld.so.cache>
10331 fstat(3</etc/ld.so.cache>, {st_mode=S_IFREG|0644, st_size=29284,
...}) = 0
10331 mmap(NULL, 29284, PROT_READ, MAP_PRIVATE, 3</etc/ld.so.cache>, 0) =
0x7fb06455b000
10331 close(3</etc/ld.so.cache>)        = 0
10331 open("/lib64/libdevmapper-event.so.1.02", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libdevmapper-event.so.1.02>
10331 read(3</usr/lib64/libdevmapper-event.so.1.02>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\35\0\0\0\0\0\0@
\0\0\0\0\0\0\0\0W\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\35\0\34\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\214M\0\0\0\0\0\0\214M\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdevmapper-event.so.1.02>,
{st_mode=S_IFREG|0555, st_size=24128, ...}) = 0
10331 mmap(NULL, 2118264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libdevmapper-event.so.1.02>, 0) = 0x7fb06413d000
10331 mprotect(0x7fb064142000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb064341000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE,
3</usr/lib64/libdevmapper-event.so.1.02>, 0x4000) = 0x7fb064341000
10331 close(3</usr/lib64/libdevmapper-event.so.1.02>) = 0
10331 open("/lib64/libudev.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libudev.so.1.6.2>
10331 read(3</usr/lib64/libudev.so.1.6.2>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 :\0\0\0\0\0\0@
\0\0\0\0\0\0\0\270\\\1\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\24B\1\0\0\0\0\0\24B\1\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libudev.so.1.6.2>, {st_mode=S_IFREG|0755,
st_size=91256, ...}) = 0
10331 mmap(NULL, 2185456, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libudev.so.1.6.2>, 0) = 0x7fb063f27000
10331 mprotect(0x7fb063f3c000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb06413b000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libudev.so.1.6.2>,
0x14000) = 0x7fb06413b000
10331 close(3</usr/lib64/libudev.so.1.6.2>) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455a000
10331 open("/lib64/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
libdl-2.17.so>
10331 read(3</usr/lib64/libdl-2.17.so>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\16\0\0\0\0\0\0@
\0\0\0\0\0\0\0\0E\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0!\0
\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\330\37\0\0\0\0\0\0\330\37\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdl-2.17.so>, {st_mode=S_IFREG|0755,
st_size=19776, ...}) = 0
10331 mmap(NULL, 2109744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libdl-2.17.so>, 0) = 0x7fb063d23000
10331 mprotect(0x7fb063d25000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb063f25000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdl-2.17.so>, 0x2000) =
0x7fb063f25000
10331 close(3</usr/lib64/libdl-2.17.so>) = 0
10331 open("/lib64/libblkid.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libblkid.so.1.1.0>
10331 read(3</usr/lib64/libblkid.so.1.1.0>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\203\0\0\0\0\0\0@
\0\0\0\0\0\0\0\220\365\3\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|\244\3\0\0\0\0\0|\244\3\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libblkid.so.1.1.0>, {st_mode=S_IFREG|0755,
st_size=261456, ...}) = 0
10331 mmap(NULL, 2354056, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libblkid.so.1.1.0>, 0) = 0x7fb063ae4000
10331 mprotect(0x7fb063b1f000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb063d1e000, 16384, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libblkid.so.1.1.0>,
0x3a000) = 0x7fb063d1e000
10331 mmap(0x7fb063d22000, 2952, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063d22000
10331 close(3</usr/lib64/libblkid.so.1.1.0>) = 0
10331 open("/lib64/libdevmapper.so.1.02", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libdevmapper.so.1.02>
10331 read(3</usr/lib64/libdevmapper.so.1.02>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\270\0\0\0\0\0\0@
\0\0\0\0\0\0\0\0x\5\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\35\0\34\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\224\35\5\0\0\0\0\0\224\35\5\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdevmapper.so.1.02>, {st_mode=S_IFREG|0555,
st_size=360256, ...}) = 0
10331 mmap(NULL, 2453968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libdevmapper.so.1.02>, 0) = 0x7fb06388c000
10331 mprotect(0x7fb0638de000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb063ade000, 20480, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdevmapper.so.1.02>,
0x52000) = 0x7fb063ade000
10331 mmap(0x7fb063ae3000, 464, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063ae3000
10331 close(3</usr/lib64/libdevmapper.so.1.02>) = 0
10331 open("/lib64/libaio.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libaio.so.1.0.1>
10331 read(3</usr/lib64/libaio.so.1.0.1>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\5\0\0\0\0\0\0@
\0\0\0\0\0\0\0\370\23\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\22\0\21\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\240\t\0\0\0\0\0\0\240\t\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libaio.so.1.0.1>, {st_mode=S_IFREG|0755,
st_size=6264, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064559000
10331 mmap(NULL, 2101328, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libaio.so.1.0.1>, 0) = 0x7fb06368a000
10331 mprotect(0x7fb06368b000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb06388a000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libaio.so.1.0.1>, 0) =
0x7fb06388a000
10331 close(3</usr/lib64/libaio.so.1.0.1>) = 0
10331 open("/lib64/libreadline.so.6", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libreadline.so.6.2>
10331 read(3</usr/lib64/libreadline.so.6.2>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0PO\1\0\0\0\0\0@
\0\0\0\0\0\0\08S\4\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\214\271\3\0\0\0\0\0\214\271\3\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libreadline.so.6.2>, {st_mode=S_IFREG|0755,
st_size=285240, ...}) = 0
10331 mmap(NULL, 2380744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libreadline.so.6.2>, 0) = 0x7fb063444000
10331 mprotect(0x7fb063480000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb063680000, 32768, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libreadline.so.6.2>,
0x3c000) = 0x7fb063680000
10331 mmap(0x7fb063688000, 5064, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063688000
10331 close(3</usr/lib64/libreadline.so.6.2>) = 0
10331 open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
libc-2.17.so>
10331 read(3</usr/lib64/libc-2.17.so>,
"\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P%\2\0\0\0\0\0@
\0\0\0\0\0\0\0H\27!\0\0\0\0\0\0\0\0\0@\08\0\n\0@\0L\0K\0\6\0\0\0\5\0\0\0@
\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0000\2\0\0\0\0\0\0000\2\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0"...,
832) = 832
10331 fstat(3</usr/lib64/libc-2.17.so>, {st_mode=S_IFREG|0755,
st_size=2173512, ...}) = 0
10331 mmap(NULL, 3981792, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libc-2.17.so>, 0) = 0x7fb063077000
10331 mprotect(0x7fb06323a000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb063439000, 24576, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libc-2.17.so>, 0x1c2000)
= 0x7fb063439000
10331 mmap(0x7fb06343f000, 16864, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb06343f000
10331 close(3</usr/lib64/libc-2.17.so>) = 0
10331 open("/lib64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
libpthread-2.17.so>
10331 read(3</usr/lib64/libpthread-2.17.so>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0m\0\0\0\0\0\0@
\0\0\0\0\0\0\0X+\2\0\0\0\0\0\0\0\0\0@\08\0\t\0@\0)\0(\0\6\0\0\0\5\0\0\0@
\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0\370\1\0\0\0\0\0\0\370\1\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0"...,
832) = 832
10331 fstat(3</usr/lib64/libpthread-2.17.so>, {st_mode=S_IFREG|0755,
st_size=144792, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064558000
10331 mmap(NULL, 2208904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libpthread-2.17.so>, 0) = 0x7fb062e5b000
10331 mprotect(0x7fb062e72000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb063071000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libpthread-2.17.so>,
0x16000) = 0x7fb063071000
10331 mmap(0x7fb063073000, 13448, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063073000
10331 close(3</usr/lib64/libpthread-2.17.so>) = 0
10331 open("/lib64/librt.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
librt-2.17.so>
10331 read(3</usr/lib64/librt-2.17.so>,
"\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\"\0\0\0\0\0\0@
\0\0\0\0\0\0\0\340\243\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0'\0&\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\08e\0\0\0\0\0\08e\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/librt-2.17.so>, {st_mode=S_IFREG|0755,
st_size=44448, ...}) = 0
10331 mmap(NULL, 2128952, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/librt-2.17.so>, 0) = 0x7fb062c53000
10331 mprotect(0x7fb062c5a000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062e59000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/librt-2.17.so>, 0x6000) =
0x7fb062e59000
10331 close(3</usr/lib64/librt-2.17.so>) = 0
10331 open("/lib64/libcap.so.2", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libcap.so.2.22>
10331 read(3</usr/lib64/libcap.so.2.22>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \26\0\0\0\0\0\0@
\0\0\0\0\0\0\0 at G\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\3247\0\0\0\0\0\0\3247\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libcap.so.2.22>, {st_mode=S_IFREG|0755,
st_size=20032, ...}) = 0
10331 mmap(NULL, 2114112, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libcap.so.2.22>, 0) = 0x7fb062a4e000
10331 mprotect(0x7fb062a52000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062c51000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libcap.so.2.22>, 0x3000)
= 0x7fb062c51000
10331 close(3</usr/lib64/libcap.so.2.22>) = 0
10331 open("/lib64/libm.so.6", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
libm-2.17.so>
10331 read(3</usr/lib64/libm-2.17.so>,
"\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0pS\0\0\0\0\0\0@
\0\0\0\0\0\0\0\340Z\21\0\0\0\0\0\0\0\0\0@\08\0\7\0@
\0$\0#\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0@
\10\20\0\0\0\0\0@\10\20\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832)
= 832
10331 fstat(3</usr/lib64/libm-2.17.so>, {st_mode=S_IFREG|0755,
st_size=1139680, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064557000
10331 mmap(NULL, 3150136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libm-2.17.so>, 0) = 0x7fb06274c000
10331 mprotect(0x7fb06284d000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062a4c000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libm-2.17.so>, 0x100000)
= 0x7fb062a4c000
10331 close(3</usr/lib64/libm-2.17.so>) = 0
10331 open("/lib64/libdw.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
libdw-0.170.so>
10331 read(3</usr/lib64/libdw-0.170.so>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\230\0\0\0\0\0\0@
\0\0\0\0\0\0\0\20\202\4\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\234>\4\0\0\0\0\0\234>\4\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdw-0.170.so>, {st_mode=S_IFREG|0755,
st_size=297360, ...}) = 0
10331 mmap(NULL, 2386096, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libdw-0.170.so>, 0) = 0x7fb062505000
10331 mprotect(0x7fb062549000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb062749000, 12288, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdw-0.170.so>, 0x44000)
= 0x7fb062749000
10331 close(3</usr/lib64/libdw-0.170.so>) = 0
10331 open("/lib64/libgcc_s.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>
10331 read(3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220*\0\0\0\0\0\0@
\0\0\0\0\0\0\0\10S\1\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0TL\1\0\0\0\0\0TL\1\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>,
{st_mode=S_IFREG|0755, st_size=88776, ...}) = 0
10331 mmap(NULL, 2184192, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>, 0) = 0x7fb0622ef000
10331 mprotect(0x7fb062304000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062503000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE,
3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>, 0x14000) = 0x7fb062503000
10331 close(3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>) = 0
10331 open("/lib64/libuuid.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libuuid.so.1.3.0>
10331 read(3</usr/lib64/libuuid.so.1.3.0>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\24\0\0\0\0\0\0@
\0\0\0\0\0\0\0\320F\0\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0D1\0\0\0\0\0\0D1\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libuuid.so.1.3.0>, {st_mode=S_IFREG|0755,
st_size=20112, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064556000
10331 mmap(NULL, 2113904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libuuid.so.1.3.0>, 0) = 0x7fb0620ea000
10331 mprotect(0x7fb0620ee000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0622ed000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libuuid.so.1.3.0>,
0x3000) = 0x7fb0622ed000
10331 close(3</usr/lib64/libuuid.so.1.3.0>) = 0
10331 open("/lib64/libselinux.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libselinux.so.1>
10331 read(3</usr/lib64/libselinux.so.1>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220j\0\0\0\0\0\0@
\0\0\0\0\0\0\0\340X\2\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\3740\2\0\0\0\0\0\3740\2\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libselinux.so.1>, {st_mode=S_IFREG|0755,
st_size=155744, ...}) = 0
10331 mmap(NULL, 2255216, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libselinux.so.1>, 0) = 0x7fb061ec3000
10331 mprotect(0x7fb061ee7000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0620e6000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libselinux.so.1>,
0x23000) = 0x7fb0620e6000
10331 mmap(0x7fb0620e8000, 6512, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb0620e8000
10331 close(3</usr/lib64/libselinux.so.1>) = 0
10331 open("/lib64/libsepol.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libsepol.so.1>
10331 read(3</usr/lib64/libsepol.so.1>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 at a\0\0\0\0\0\0@
\0\0\0\0\0\0\0p\v\n\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\324\265\t\0\0\0\0\0\324\265\t\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libsepol.so.1>, {st_mode=S_IFREG|0755,
st_size=660208, ...}) = 0
10331 mmap(NULL, 2744248, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libsepol.so.1>, 0) = 0x7fb061c25000
10331 mprotect(0x7fb061cc1000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb061ec0000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libsepol.so.1>, 0x9b000)
= 0x7fb061ec0000
10331 mmap(0x7fb061ec2000, 4024, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb061ec2000
10331 close(3</usr/lib64/libsepol.so.1>) = 0
10331 open("/lib64/libtinfo.so.5", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libtinfo.so.5.9>
10331 read(3</usr/lib64/libtinfo.so.5.9>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\316\0\0\0\0\0\0@
\0\0\0\0\0\0\0\360\242\2\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\O\2\0\0\0\0\0\\O\2\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libtinfo.so.5.9>, {st_mode=S_IFREG|0755,
st_size=174576, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064555000
10331 mmap(NULL, 2268928, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libtinfo.so.5.9>, 0) = 0x7fb0619fb000
10331 mprotect(0x7fb061a20000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb061c20000, 20480, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libtinfo.so.5.9>,
0x25000) = 0x7fb061c20000
10331 close(3</usr/lib64/libtinfo.so.5.9>) = 0
10331 open("/lib64/libattr.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libattr.so.1.1.0>
10331 read(3</usr/lib64/libattr.so.1.1.0>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\23\0\0\0\0\0\0@
\0\0\0\0\0\0\0\270F\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\344;\0\0\0\0\0\0\344;\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libattr.so.1.1.0>, {st_mode=S_IFREG|0755,
st_size=19896, ...}) = 0
10331 mmap(NULL, 2113904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libattr.so.1.1.0>, 0) = 0x7fb0617f6000
10331 mprotect(0x7fb0617fa000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0619f9000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libattr.so.1.1.0>,
0x3000) = 0x7fb0619f9000
10331 close(3</usr/lib64/libattr.so.1.1.0>) = 0
10331 open("/usr/lib64/elfutils/tls/x86_64/libelf.so.1",
O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils/tls/x86_64", 0x7ffd7d8fc690) = -1 ENOENT
(No such file or directory)
10331 open("/usr/lib64/elfutils/tls/libelf.so.1", O_RDONLY|O_CLOEXEC) = -1
ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils/tls", 0x7ffd7d8fc690) = -1 ENOENT (No such
file or directory)
10331 open("/usr/lib64/elfutils/x86_64/libelf.so.1", O_RDONLY|O_CLOEXEC) =
-1 ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils/x86_64", 0x7ffd7d8fc690) = -1 ENOENT (No
such file or directory)
10331 open("/usr/lib64/elfutils/libelf.so.1", O_RDONLY|O_CLOEXEC) = -1
ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils", {st_mode=S_IFDIR|0755, st_size=4096,
...}) = 0
10331 open("/lib64/libelf.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/
libelf-0.170.so>
10331 read(3</usr/lib64/libelf-0.170.so>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0200\0\0\0\0\0\0@
\0\0\0\0\0\0\0\350~\1\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\304d\1\0\0\0\0\0\304d\1\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libelf-0.170.so>, {st_mode=S_IFREG|0755,
st_size=99944, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064554000
10331 mmap(NULL, 2191824, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libelf-0.170.so>, 0) = 0x7fb0615de000
10331 mprotect(0x7fb0615f5000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0617f4000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libelf-0.170.so>,
0x16000) = 0x7fb0617f4000
10331 close(3</usr/lib64/libelf-0.170.so>) = 0
10331 open("/usr/lib64/elfutils/libz.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT
(No such file or directory)
10331 open("/lib64/libz.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libz.so.1.2.7>
10331 read(3</usr/lib64/libz.so.1.2.7>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p!\0\0\0\0\0\0@
\0\0\0\0\0\0\0\350Z\1\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\35\0\34\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\254D\1\0\0\0\0\0\254D\1\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libz.so.1.2.7>, {st_mode=S_IFREG|0755,
st_size=90664, ...}) = 0
10331 mmap(NULL, 2183688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libz.so.1.2.7>, 0) = 0x7fb0613c8000
10331 mprotect(0x7fb0613dd000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0615dc000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libz.so.1.2.7>, 0x14000)
= 0x7fb0615dc000
10331 close(3</usr/lib64/libz.so.1.2.7>) = 0
10331 open("/usr/lib64/elfutils/liblzma.so.5", O_RDONLY|O_CLOEXEC) = -1
ENOENT (No such file or directory)
10331 open("/lib64/liblzma.so.5", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/liblzma.so.5.2.2>
10331 read(3</usr/lib64/liblzma.so.5.2.2>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2000\0\0\0\0\0\0@
\0\0\0\0\0\0\0\360_\2\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0<@\2\0\0\0\0\0<@\2\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/liblzma.so.5.2.2>, {st_mode=S_IFREG|0755,
st_size=157424, ...}) = 0
10331 mmap(NULL, 2249352, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/liblzma.so.5.2.2>, 0) = 0x7fb0611a2000
10331 mprotect(0x7fb0611c7000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0613c6000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/liblzma.so.5.2.2>,
0x24000) = 0x7fb0613c6000
10331 close(3</usr/lib64/liblzma.so.5.2.2>) = 0
10331 open("/usr/lib64/elfutils/libbz2.so.1", O_RDONLY|O_CLOEXEC) = -1
ENOENT (No such file or directory)
10331 open("/lib64/libbz2.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libbz2.so.1.0.6>
10331 read(3</usr/lib64/libbz2.so.1.0.6>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\27\0\0\0\0\0\0@
\0\0\0\0\0\0\0`\3\1\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|\353\0\0\0\0\0\0|\353\0\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libbz2.so.1.0.6>, {st_mode=S_IFREG|0755,
st_size=68192, ...}) = 0
10331 mmap(NULL, 2162024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libbz2.so.1.0.6>, 0) = 0x7fb060f92000
10331 mprotect(0x7fb060fa1000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0611a0000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libbz2.so.1.0.6>, 0xe000)
= 0x7fb0611a0000
10331 close(3</usr/lib64/libbz2.so.1.0.6>) = 0
10331 open("/lib64/libpcre.so.1", O_RDONLY|O_CLOEXEC) =
3</usr/lib64/libpcre.so.1.2.0>
10331 read(3</usr/lib64/libpcre.so.1.2.0>,
"\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\25\0\0\0\0\0\0@
\0\0\0\0\0\0\0\320\34\6\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0004\377\5\0\0\0\0\0004\377\5\0\0\0\0\0\0\0
\0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libpcre.so.1.2.0>, {st_mode=S_IFREG|0755,
st_size=402384, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064553000
10331 mmap(NULL, 2494984, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE,
3</usr/lib64/libpcre.so.1.2.0>, 0) = 0x7fb060d30000
10331 mprotect(0x7fb060d90000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb060f90000, 8192, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libpcre.so.1.2.0>,
0x60000) = 0x7fb060f90000
10331 close(3</usr/lib64/libpcre.so.1.2.0>) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064552000
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064551000
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064550000
10331 mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06454e000
10331 arch_prctl(ARCH_SET_FS, 0x7fb06454e880) = 0
10331 mprotect(0x7fb063439000, 16384, PROT_READ) = 0
10331 mprotect(0x7fb063071000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb060f90000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0611a0000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0613c6000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0615dc000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0617f4000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0619f9000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb061c20000, 16384, PROT_READ) = 0
10331 mprotect(0x7fb061ec0000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063f25000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0620e6000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0622ed000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062503000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062749000, 8192, PROT_READ) = 0
10331 mprotect(0x7fb062a4c000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062c51000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062e59000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063680000, 8192, PROT_READ) = 0
10331 mprotect(0x7fb06388a000, 4096, PROT_READ) = 0
10331 stat("/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned",
0x7ffd7d8fd260) = -1 ENOENT (No such file or directory)
10331 mprotect(0x7fb06413b000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063ade000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063d1e000, 12288, PROT_READ) = 0
10331 mprotect(0x7fb064341000, 4096, PROT_READ) = 0
10331 stat("/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned",
0x7ffd7d8fd260) = -1 ENOENT (No such file or directory)
10331 mprotect(0x555bdcbf6000, 40960, PROT_READ) = 0
10331 mprotect(0x7fb064564000, 4096, PROT_READ) = 0
10331 munmap(0x7fb06455b000, 29284)     = 0
10331 set_tid_address(0x7fb06454eb50)   = 10331
10331 set_robust_list(0x7fb06454eb60, 24) = 0
10331 rt_sigaction(SIGRTMIN, {sa_handler=0x7fb062e617e0, sa_mask=[],
sa_flags=SA_RESTORER|SA_SIGINFO, sa_restorer=0x7fb062e6a6d0}, NULL, 8) = 0
10331 rt_sigaction(SIGRT_1, {sa_handler=0x7fb062e61870, sa_mask=[],
sa_flags=SA_RESTORER|SA_RESTART|SA_SIGINFO, sa_restorer=0x7fb062e6a6d0},
NULL, 8) = 0
10331 rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
10331 getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024,
rlim_max=RLIM64_INFINITY}) = 0
10331 statfs("/sys/fs/selinux", 0x7ffd7d8fe4c0) = -1 ENOENT (No such file
or directory)
10331 statfs("/selinux", 0x7ffd7d8fe4c0) = -1 ENOENT (No such file or
directory)
10331 brk(NULL)                         = 0x555bdea9c000
10331 brk(0x555bdeabd000)               = 0x555bdeabd000
10331 open("/proc/filesystems", O_RDONLY) = 3</proc/filesystems>
10331 fstat(3</proc/filesystems>, {st_mode=S_IFREG|0444, st_size=0, ...}) =
0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064562000
10331 read(3</proc/filesystems>,
"nodev\tsysfs\nnodev\trootfs\nnodev\tramfs\nnodev\tbdev\nnodev\tproc\nnodev\tcpuset\nnodev\tcgroup\nnodev\tcgroup2\nnodev\ttmpfs\nnodev\tdevtmpfs\nno"...,
1024) = 427
10331 stat("/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned",
0x7ffd7d8fd9f0) = -1 ENOENT (No such file or directory)
10331 read(3</proc/filesystems>, "", 1024) = 0
10331 close(3</proc/filesystems>)       = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 access("/etc/selinux/config", F_OK) = 0
10331 fcntl(2</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(0</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(1</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(2</dev/pts/2>, F_GETFD)     = 0
10331 getppid()                         = 10329
10331 open("/proc/10329/cmdline", O_RDONLY) = 3</proc/10329/cmdline>
10331 read(3</proc/10329/cmdline>,
"strace\0-o\0lvm.strace\0-f\0-s\000128\0", 31) = 31
10331 close(3</proc/10329/cmdline>)     = 0
10331 openat(AT_FDCWD, "/proc/self/fd",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</proc/10331/fd>
10331 getdents(3</proc/10331/fd>, /* 6 entries */, 32768) = 144
10331 getdents(3</proc/10331/fd>, /* 0 entries */, 32768) = 0
10331 close(3</proc/10331/fd>)          = 0
10331 open("/etc/udev/udev.conf", O_RDONLY|O_CLOEXEC) =
3</etc/udev/udev.conf>
10331 fstat(3</etc/udev/udev.conf>, {st_mode=S_IFREG|0644, st_size=49,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064562000
10331 read(3</etc/udev/udev.conf>, "# see udev.conf(5) for
details\n\n#udev_log=\"info\"\n", 4096) = 49
10331 read(3</etc/udev/udev.conf>, "", 4096) = 0
10331 close(3</etc/udev/udev.conf>)     = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) =
3</usr/lib/locale/locale-archive>
10331 fstat(3</usr/lib/locale/locale-archive>, {st_mode=S_IFREG|0644,
st_size=3485296, ...}) = 0
10331 mmap(NULL, 3485296, PROT_READ, MAP_PRIVATE,
3</usr/lib/locale/locale-archive>, 0) = 0x7fb0609dd000
10331 close(3</usr/lib/locale/locale-archive>) = 0
10331 gettid()                          = 10331
10331 fcntl(0</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(0</dev/pts/2>, F_GETFL)     = 0x8402 (flags
O_RDWR|O_APPEND|O_LARGEFILE)
10331 dup(0</dev/pts/2>)                = 3</dev/pts/2>
10331 close(0</dev/pts/2>)              = 0
10331 dup2(3</dev/pts/2>, 0)            = 0</dev/pts/2>
10331 close(3</dev/pts/2>)              = 0
10331 fcntl(0</dev/pts/2>, F_GETFL)     = 0x8402 (flags
O_RDWR|O_APPEND|O_LARGEFILE)
10331 fcntl(1</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(1</dev/pts/2>, F_GETFL)     = 0x8402 (flags
O_RDWR|O_APPEND|O_LARGEFILE)
10331 dup(1</dev/pts/2>)                = 3</dev/pts/2>
10331 close(1</dev/pts/2>)              = 0
10331 dup2(3</dev/pts/2>, 1)            = 1</dev/pts/2>
10331 close(3</dev/pts/2>)              = 0
10331 fcntl(1</dev/pts/2>, F_GETFL)     = 0x8402 (flags
O_RDWR|O_APPEND|O_LARGEFILE)
10331 stat("/etc/lvm", {st_mode=S_IFDIR|0755, st_size=131, ...}) = 0
10331 stat("/etc/lvm/lvm.conf", {st_mode=S_IFREG|0644, st_size=96015, ...})
= 0
10331 stat("/etc/lvm/lvm.conf", {st_mode=S_IFREG|0644, st_size=96015, ...})
= 0
10331 open("/etc/lvm/lvm.conf", O_RDONLY) = 3</etc/lvm/lvm.conf>
10331 brk(NULL)                         = 0x555bdeabd000
10331 brk(0x555bdeae1000)               = 0x555bdeae1000
10331 read(3</etc/lvm/lvm.conf>, "# This is an example configuration file
for the LVM2 system.\n# It contains the default settings that would be used
if there was "..., 96015) = 96015
10331 write(2</dev/pts/2>, "WARNING: Ignoring duplicate config value:
global_filter", 55) = 55
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "WARNING: Ignoring duplicate config value:
thin_pool_zero", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(3</etc/lvm/lvm.conf>)       = 0
10331 open("/etc/localtime", O_RDONLY|O_CLOEXEC) =
3</usr/share/zoneinfo/UTC>
10331 fstat(3</usr/share/zoneinfo/UTC>, {st_mode=S_IFREG|0644, st_size=118,
...}) = 0
10331 fstat(3</usr/share/zoneinfo/UTC>, {st_mode=S_IFREG|0644, st_size=118,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064562000
10331 read(3</usr/share/zoneinfo/UTC>,
"TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0UTC\0\0\0TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0UTC\0\0\0\nUTC0\n",
4096) = 118
10331 lseek(3</usr/share/zoneinfo/UTC>, -62, SEEK_CUR) = 56
10331 read(3</usr/share/zoneinfo/UTC>,
"TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0UTC\0\0\0\nUTC0\n",
4096) = 62
10331 close(3</usr/share/zoneinfo/UTC>) = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 uname({sysname="Linux", nodename="ip-70-0-159-14.brbnca.spcsdns.net",
...}) = 0
10331 stat("/etc/lvm/lvmlocal.conf", {st_mode=S_IFREG|0644, st_size=2301,
...}) = 0
10331 stat("/etc/lvm/lvmlocal.conf", {st_mode=S_IFREG|0644, st_size=2301,
...}) = 0
10331 open("/etc/lvm/lvmlocal.conf", O_RDONLY) = 3</etc/lvm/lvmlocal.conf>
10331 read(3</etc/lvm/lvmlocal.conf>, "# This is a local configuration file
template for the LVM2 system\n# which should be installed as
/etc/lvm/lvmlocal.conf .\n#\n# Re"..., 2301) = 2301
10331 close(3</etc/lvm/lvmlocal.conf>)  = 0
10331 umask(077)                        = 022
10331 stat("/proc", {st_mode=S_IFDIR|0555, st_size=0, ...}) = 0
10331 open("/proc/mounts", O_RDONLY)    = 3</proc/10331/mounts>
10331 fstat(3</proc/10331/mounts>, {st_mode=S_IFREG|0444, st_size=0, ...})
= 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064562000
10331 read(3</proc/10331/mounts>, "sysfs /sys sysfs
rw,nosuid,nodev,noexec,relatime 0 0\nproc /proc proc
rw,nosuid,nodev,noexec,relatime 0 0\ndevtmpfs /dev devtmpfs "..., 1024) =
1024
10331 close(3</proc/10331/mounts>)      = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 open("/proc/devices", O_RDONLY)   = 3</proc/devices>
10331 fstat(3</proc/devices>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064562000
10331 read(3</proc/devices>, "Character devices:\n  1 mem\n  4 /dev/vc/0\n
 4 tty\n  4 ttyS\n  5 /dev/tty\n  5 /dev/console\n  5 /dev/ptmx\n  7 vcs\n
10 misc\n 13 input"..., 1024) = 534
10331 read(3</proc/devices>, "", 1024)  = 0
10331 close(3</proc/devices>)           = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 access("/run/udev/control", F_OK) = 0
10331 stat("/dev", {st_mode=S_IFDIR|0755, st_size=3840, ...}) = 0
10331 open("/dev/urandom", O_RDONLY)    = 3</dev/urandom>
10331 read(3</dev/urandom>, "\267zF\f", 4) = 4
10331 close(3</dev/urandom>)            = 0
10331 open("/proc/meminfo", O_RDONLY|O_CLOEXEC) = 3</proc/meminfo>
10331 fstat(3</proc/meminfo>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb064562000
10331 read(3</proc/meminfo>, "MemTotal:        8167916 kB\nMemFree:
 856504 kB\nMemAvailable:    7023536 kB\nBuffers:           72760
kB\nCached:         "..., 1024) = 1024
10331 close(3</proc/meminfo>)           = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 getuid()                          = 0
10331 geteuid()                         = 0
10331 brk(NULL)                         = 0x555bdeae1000
10331 brk(0x555bdeb02000)               = 0x555bdeb02000
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Parsing: lvs -vvv", 17) = 17
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Recognised command lvs_general (id 93 / enum
74).", 49) = 49
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/lvm.conf", {st_mode=S_IFREG|0644, st_size=96015, ...})
= 0
10331 stat("/etc/lvm/lvmlocal.conf", {st_mode=S_IFREG|0644, st_size=2301,
...}) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "Setting devices/global_filter to global_filter
= [ \"r|/dev/pxd.*|\", \"r|/dev/mapper/pxd.*|\", \"a|.*/|\" ]", 102) = 102
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 access("/run/lvmetad.pid", F_OK)  = 0
10331 write(2</dev/pts/2>, "  ", 2)     = 2
10331 write(2</dev/pts/2>, "WARNING: Not using lvmetad because config
setting use_lvmetad=0.", 64) = 64
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "  ", 2)     = 2
10331 write(2</dev/pts/2>, "WARNING: To avoid corruption, rescan devices to
make changes visible (pvscan --cache).", 86) = 86
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys/subsystem/block/devices", 0x7ffd7d8fd0c0) = -1 ENOENT (No
such file or directory)
10331 stat("/sys/class/block", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Sysfs filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Internal filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Regex filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "LVM type filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Usable device filter initialised (scan_lvs
0).", 46) = 46
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "mpath filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Partitioned filter initialised.", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "MD filter initialised.", 22) = 22
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Composite filter initialised.", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "devices/cache not found in config: defaulting
to /etc/lvm/cache/.cache", 70) = 70
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/cache/.cache", 0x7ffd7d8fe0c0) = -1 ENOENT (No such
file or directory)
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Persistent filter initialised.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/cache/.cache", 0x7ffd7d8fe1b0) = -1 ENOENT (No such
file or directory)
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "metadata/record_lvs_history not found in
config: defaulting to 0", 64) = 64
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "DEGRADED MODE. Incomplete RAID LVs will be
processed.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Processing command: lvs -vvv", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Command pid: 10331", 18) = 18
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "System ID: ", 11) = 11
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "O_DIRECT will be used", 21) = 21
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "File-based locking selected.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/run/lock/lvm", {st_mode=S_IFDIR|0700, st_size=40, ...}) = 0
10331 access("/run/lock/lvm", R_OK|W_OK|X_OK) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/output_format not found in config:
defaulting to basic", 61) = 61
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "log/report_command_log not found in config:
defaulting to 0", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/aligned not found in config: defaulting
to 1", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/buffered not found in config: defaulting
to 1", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/headings not found in config: defaulting
to 1", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/separator not found in config:
defaulting to  ", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/prefixes not found in config: defaulting
to 0", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/quoted not found in config: defaulting
to 1", 50) = 50
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/columns_as_rows not found in config:
defaulting to 0", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/lvs_sort not found in config: defaulting
to vg_name,lv_name", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/lvs_cols_verbose not found in config:
defaulting to
lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel"...,
257) = 257
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/compact_output_cols not found in config:
defaulting to ", 62) = 62
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Finding VG info", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys/subsystem/block/devices", 0x7ffd7d8fc900) = -1 ENOENT (No
such file or directory)
10331 stat("/sys/class/block", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Sysfs filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Internal filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Regex filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "LVM type filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Usable device filter initialised (scan_lvs
0).", 46) = 46
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "mpath filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Partitioned filter initialised.", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "MD filter initialised.", 22) = 22
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Composite filter initialised.", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "devices/cache not found in config: defaulting
to /etc/lvm/cache/.cache", 70) = 70
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/cache/.cache", 0x7ffd7d8fd900) = -1 ENOENT (No such
file or directory)
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Persistent filter initialised.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Finding devices to scan", 23) = 23
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Creating list of system devices.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys/subsystem", 0x7ffd7d8fd8d0) = -1 ENOENT (No such file or
directory)
10331 openat(AT_FDCWD, "/sys/bus",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/bus>
10331 getdents(3</sys/bus>, /* 33 entries */, 32768) = 912
10331 open("/usr/lib64/gconv/gconv-modules.cache", O_RDONLY) =
4</usr/lib64/gconv/gconv-modules.cache>
10331 fstat(4</usr/lib64/gconv/gconv-modules.cache>, {st_mode=S_IFREG|0644,
st_size=26254, ...}) = 0
10331 mmap(NULL, 26254, PROT_READ, MAP_SHARED,
4</usr/lib64/gconv/gconv-modules.cache>, 0) = 0x7fb06455c000
10331 close(4</usr/lib64/gconv/gconv-modules.cache>) = 0
10331 futex(0x7fb06343ea80, FUTEX_WAKE_PRIVATE, 2147483647) = 0
10331 getdents(3</sys/bus>, /* 0 entries */, 32768) = 0
10331 close(3</sys/bus>)                = 0
10331 openat(AT_FDCWD, "/sys/class",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/class>
10331 getdents(3</sys/class>, /* 56 entries */, 32768) = 1656
10331 openat(AT_FDCWD, "/sys/class/block",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/class/block>
10331 brk(NULL)                         = 0x555bdeb02000
10331 brk(0x555bdeb24000)               = 0x555bdeb24000
10331 getdents(4</sys/class/block>, /* 28 entries */, 32768) = 720
10331 readlink("/sys/class/block/dm-1", "../../devices/virtual/block/dm-1",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-1/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdf",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-10",
"../../devices/virtual/block/dm-10", 1024) = 33
10331 stat("/sys/devices/virtual/block/dm-10/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda4",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdd",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/pxd!pxd405564132566284931",
"../../devices/virtual/block/pxd!pxd405564132566284931", 1024) = 53
10331 stat("/sys/devices/virtual/block/pxd!pxd405564132566284931/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda2",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/md127",
"../../devices/virtual/block/md127", 1024) = 33
10331 stat("/sys/devices/virtual/block/md127/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-8", "../../devices/virtual/block/dm-8",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-8/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdb",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-6", "../../devices/virtual/block/dm-6",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-6/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-4", "../../devices/virtual/block/dm-4",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-4/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-2", "../../devices/virtual/block/dm-2",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-2/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdg",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-11",
"../../devices/virtual/block/dm-11", 1024) = 33
10331 stat("/sys/devices/virtual/block/dm-11/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-0", "../../devices/virtual/block/dm-0",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-0/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sde",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda3",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdc1",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-9", "../../devices/virtual/block/dm-9",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-9/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdc",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda1",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-7", "../../devices/virtual/block/dm-7",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-7/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-5", "../../devices/virtual/block/dm-5",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-5/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-3", "../../devices/virtual/block/dm-3",
1024) = 32
10331 stat("/sys/devices/virtual/block/dm-3/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 getdents(4</sys/class/block>, /* 0 entries */, 32768) = 0
10331 close(4</sys/class/block>)        = 0
10331 getdents(3</sys/class>, /* 0 entries */, 32768) = 0
10331 close(3</sys/class>)              = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>,
"MAJOR=8\nMINOR=0\nDEVNAME=sda\nDEVTYPE=disk\n", 4096) = 41
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:0 /dev/sda - new.", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:0", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:0>
10331 fstat(3</run/udev/data/b8:0>, {st_mode=S_IFREG|0644, st_size=371,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:0>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0\nW:512\nI:1504\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 371
10331 read(3</run/udev/data/b8:0>, "", 4096) = 0
10331 close(3</run/udev/data/b8:0>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:0
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0 - new alias.", 74) = 74
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>,
"MAJOR=8\nMINOR=1\nDEVNAME=sda1\nDEVTYPE=partition\nPARTN=1\n", 4096) = 55
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:1 /dev/sda1 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:1", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:1>
10331 fstat(3</run/udev/data/b8:1>, {st_mode=S_IFREG|0644, st_size=748,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:1>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1\nS:disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4\nW:500\nI:1617\nE:ID_BUS=scs"...,
4096) = 748
10331 read(3</run/udev/data/b8:1>, "", 4096) = 0
10331 close(3</run/udev/data/b8:1>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:1
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1 - new alias.", 80) =
80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:1
/dev/disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4 - new alias.", 81) =
81
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>,
"MAJOR=8\nMINOR=2\nDEVNAME=sda2\nDEVTYPE=partition\nPARTN=2\n", 4096) = 55
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda2", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:2 /dev/sda2 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:2", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:2>
10331 fstat(3</run/udev/data/b8:2>, {st_mode=S_IFREG|0644, st_size=857,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:2>,
"S:disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2\nW:499\nI:1810\n"...,
4096) = 857
10331 read(3</run/udev/data/b8:2>, "", 4096) = 0
10331 close(3</run/udev/data/b8:2>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
stat("/dev/disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:2
/dev/disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc - new
alias.", 93) = 93
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:2
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2 - new alias.", 80) =
80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>,
"MAJOR=8\nMINOR=3\nDEVNAME=sda3\nDEVTYPE=partition\nPARTN=3\n", 4096) = 55
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda3", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:3 /dev/sda3 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:3", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:3>
10331 fstat(3</run/udev/data/b8:3>, {st_mode=S_IFREG|0644, st_size=858,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:3>,
"S:disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3\nW:501\nI:2019\n"...,
4096) = 858
10331 read(3</run/udev/data/b8:3>, "", 4096) = 0
10331 close(3</run/udev/data/b8:3>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
stat("/dev/disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:3
/dev/disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD - new
alias.", 93) = 93
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:3
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3 - new alias.", 80) =
80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>,
"MAJOR=8\nMINOR=4\nDEVNAME=sda4\nDEVTYPE=partition\nPARTN=4\n", 4096) = 55
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda4", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:4 /dev/sda4 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:4", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:4>
10331 fstat(3</run/udev/data/b8:4>, {st_mode=S_IFREG|0644, st_size=859,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:4>,
"S:disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4\nW:502\nI:2187\n"...,
4096) = 859
10331 read(3</run/udev/data/b8:4>, "", 4096) = 0
10331 close(3</run/udev/data/b8:4>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
stat("/dev/disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:4
/dev/disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW - new
alias.", 93) = 93
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:4
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4 - new alias.", 80) =
80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>,
"MAJOR=8\nMINOR=16\nDEVNAME=sdb\nDEVTYPE=disk\n", 4096) = 42
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdb", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:16 /dev/sdb - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:16", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:16>
10331 fstat(3</run/udev/data/b8:16>, {st_mode=S_IFREG|0644, st_size=346,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:16>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0\nW:520\nI:3038\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 346
10331 read(3</run/udev/data/b8:16>, "", 4096) = 0
10331 close(3</run/udev/data/b8:16>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:16
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>,
"MAJOR=8\nMINOR=32\nDEVNAME=sdc\nDEVTYPE=disk\n", 4096) = 42
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdc", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:32 /dev/sdc - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:32", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:32>
10331 fstat(3</run/udev/data/b8:32>, {st_mode=S_IFREG|0644, st_size=371,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:32>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0\nW:513\nI:3870\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 371
10331 read(3</run/udev/data/b8:32>, "", 4096) = 0
10331 close(3</run/udev/data/b8:32>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:32
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>,
"MAJOR=8\nMINOR=33\nDEVNAME=sdc1\nDEVTYPE=partition\nPARTN=1\nPARTNAME=journal\n",
4096) = 73
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdc1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33 /dev/sdc1 - new.", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:33", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:33>
10331 fstat(3</run/udev/data/b8:33>, {st_mode=S_IFREG|0644, st_size=744,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:33>,
"S:disk/by-partlabel/journal\nS:disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0"...,
4096) = 744
10331 read(3</run/udev/data/b8:33>, "", 4096) = 0
10331 close(3</run/udev/data/b8:33>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-partlabel/journal", {st_mode=S_IFBLK|0660,
st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33 /dev/disk/by-partlabel/journal -
new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33
/dev/disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6 - new alias.",
86) = 86
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0-part1",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0-part1 - new alias.", 81) =
81
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>,
"MAJOR=8\nMINOR=48\nDEVNAME=sdd\nDEVTYPE=disk\n", 4096) = 42
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdd", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:48 /dev/sdd - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:48", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:48>
10331 fstat(3</run/udev/data/b8:48>, {st_mode=S_IFREG|0644, st_size=346,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:48>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0\nW:519\nI:4512\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 346
10331 read(3</run/udev/data/b8:48>, "", 4096) = 0
10331 close(3</run/udev/data/b8:48>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:48
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>,
"MAJOR=8\nMINOR=64\nDEVNAME=sde\nDEVTYPE=disk\n", 4096) = 42
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sde", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:64 /dev/sde - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:64", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:64>
10331 fstat(3</run/udev/data/b8:64>, {st_mode=S_IFREG|0644, st_size=668,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:64>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0\nW:511\nI:5158\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"...,
4096) = 668
10331 read(3</run/udev/data/b8:64>, "", 4096) = 0
10331 close(3</run/udev/data/b8:64>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:64
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>,
"MAJOR=8\nMINOR=80\nDEVNAME=sdf\nDEVTYPE=disk\n", 4096) = 42
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdf", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:80 /dev/sdf - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:80", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:80>
10331 fstat(3</run/udev/data/b8:80>, {st_mode=S_IFREG|0644, st_size=668,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:80>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0\nW:516\nI:5664\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"...,
4096) = 668
10331 read(3</run/udev/data/b8:80>, "", 4096) = 0
10331 close(3</run/udev/data/b8:80>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:80
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>,
"MAJOR=8\nMINOR=96\nDEVNAME=sdg\nDEVTYPE=disk\n", 4096) = 42
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdg", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...})
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:96 /dev/sdg - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:96", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:96>
10331 fstat(3</run/udev/data/b8:96>, {st_mode=S_IFREG|0644, st_size=668,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:96>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0\nW:514\nI:6230\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"...,
4096) = 668
10331 read(3</run/udev/data/b8:96>, "", 4096) = 0
10331 close(3</run/udev/data/b8:96>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0",
{st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:96
/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/pxd!pxd405564132566284931",
0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/pxd!pxd405564132566284931/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/pxd!pxd405564132566284931/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>
10331 fstat(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>,
"MAJOR=252\nMINOR=1\nDEVNAME=pxd/pxd405564132566284931\nDEVTYPE=disk\n",
4096) = 65
10331 read(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>,
"", 4096) = 0
10331 close(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/pxd/pxd405564132566284931", {st_mode=S_IFBLK|0660,
st_rdev=makedev(252, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 252:1 /dev/pxd/pxd405564132566284931
- new.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
readlink("/sys/devices/virtual/block/pxd!pxd405564132566284931/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b252:1", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b252:1>
10331 fstat(3</run/udev/data/b252:1>, {st_mode=S_IFREG|0644, st_size=250,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b252:1>,
"S:disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8\nW:525\nI:28394815651\nE:ID_FS_TYPE=crypto_LUKS\nE:ID_FS_USAGE=crypto\nE:ID_FS_UU"...,
4096) = 250
10331 read(3</run/udev/data/b252:1>, "", 4096) = 0
10331 close(3</run/udev/data/b252:1>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9
/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - new.", 77) = 77
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-0", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-0/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-0/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-0/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-0/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-0/uevent>,
"MAJOR=253\nMINOR=0\nDEVNAME=dm-0\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-0/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-0/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-0", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/dm-0 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-0/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:0", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:0>
10331 fstat(3</run/udev/data/b253:0>, {st_mode=S_IFREG|0644, st_size=687,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:0>,
"S:centos_bazinga/root\nS:disk/by-id/dm-name-centos_bazinga-root\nS:disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD"...,
4096) = 687
10331 read(3</run/udev/data/b253:0>, "", 4096) = 0
10331 close(3</run/udev/data/b253:0>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/centos_bazinga/root", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/centos_bazinga/root - new
alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-name-centos_bazinga-root",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0
/dev/disk/by-id/dm-name-centos_bazinga-root - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0
/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv
- new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-uuid/3476a32c-d5c2-49e1-9efb-85238af4bbe5",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0
/dev/disk/by-uuid/3476a32c-d5c2-49e1-9efb-85238af4bbe5 - new alias.", 83) =
83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/centos_bazinga-root", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/mapper/centos_bazinga-root
- new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-1", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-1/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-1/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-1/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-1/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-1/uevent>,
"MAJOR=253\nMINOR=1\nDEVNAME=dm-1\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-1/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-1/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-1", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/dm-1 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-1/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:1", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:1>
10331 fstat(3</run/udev/data/b253:1>, {st_mode=S_IFREG|0644, st_size=701,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:1>,
"S:centos_bazinga/swap\nS:disk/by-id/dm-name-centos_bazinga-swap\nS:disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdg"...,
4096) = 701
10331 read(3</run/udev/data/b253:1>, "", 4096) = 0
10331 close(3</run/udev/data/b253:1>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/centos_bazinga/swap", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/centos_bazinga/swap - new
alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-name-centos_bazinga-swap",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1
/dev/disk/by-id/dm-name-centos_bazinga-swap - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1
/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs
- new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-uuid/72214974-21d6-442e-b60a-e291f8a2bea3",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1
/dev/disk/by-uuid/72214974-21d6-442e-b60a-e291f8a2bea3 - new alias.", 83) =
83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/centos_bazinga-swap", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/mapper/centos_bazinga-swap
- new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-10", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-10/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-10/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-10/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-10/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-10/uevent>,
"MAJOR=253\nMINOR=10\nDEVNAME=dm-10\nDEVTYPE=disk\n", 4096) = 46
10331 read(3</sys/devices/virtual/block/dm-10/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-10/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-10", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10 /dev/dm-10 - new.", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-10/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:10", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:10>
10331 fstat(3</run/udev/data/b253:10>, {st_mode=S_IFREG|0644, st_size=582,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:10>,
"S:disk/by-id/dm-name-pwx0-405564132566284931_empty_snap\nS:disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4C"...,
4096) = 582
10331 read(3</run/udev/data/b253:10>, "", 4096) = 0
10331 close(3</run/udev/data/b253:10>)  = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10
/dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap - new alias.",
88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10
/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me
- new alias.", 122) = 122
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
lstat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me",
{st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap",
{st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 stat("/dev/mapper/pwx0-405564132566284931_empty_snap",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10
/dev/mapper/pwx0-405564132566284931_empty_snap - new alias.", 76) = 76
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/pwx0/405564132566284931_empty_snap",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10
/dev/pwx0/405564132566284931_empty_snap - new alias.", 69) = 69
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-11", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-11/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-11/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-11/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-11/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-11/uevent>,
"MAJOR=253\nMINOR=11\nDEVNAME=dm-11\nDEVTYPE=disk\n", 4096) = 46
10331 read(3</sys/devices/virtual/block/dm-11/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-11/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-11", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11 /dev/dm-11 - new.", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-11/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:11", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:11>
10331 fstat(3</run/udev/data/b253:11>, {st_mode=S_IFREG|0644, st_size=669,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:11>,
"S:disk/by-id/dm-name-pxd-enc405564132566284931\nS:disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc40556413"...,
4096) = 669
10331 read(3</run/udev/data/b253:11>, "", 4096) = 0
10331 close(3</run/udev/data/b253:11>)  = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pxd-enc405564132566284931",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11
/dev/disk/by-id/dm-name-pxd-enc405564132566284931 - new alias.", 79) = 79
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11
/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931
- new alias.", 124) = 124
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
lstat("/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931",
{st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pxd-enc405564132566284931",
{st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 stat("/dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11
/dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c - new alias.", 84) =
84
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...})
= 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c",
{st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pxd-enc405564132566284931",
{st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 stat("/dev/mapper/pxd-enc405564132566284931", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11
/dev/mapper/pxd-enc405564132566284931 - new alias.", 67) = 67
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-2", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-2/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-2/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-2/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-2/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-2/uevent>,
"MAJOR=253\nMINOR=2\nDEVNAME=dm-2\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-2/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-2/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-2", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/dm-2 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-2/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:2", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:2>
10331 fstat(3</run/udev/data/b253:2>, {st_mode=S_IFREG|0644, st_size=708,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:2>,
"S:disk/by-id/dm-name-vgoptdisk-vmoptdisk\nS:disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjI"...,
4096) = 708
10331 read(3</run/udev/data/b253:2>, "", 4096) = 0
10331 close(3</run/udev/data/b253:2>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2
/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2
/dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE
- new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
lstat("/dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2
/dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186 - new alias.", 83) =
83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...})
= 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/mapper/vgoptdisk-vmoptdisk", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/mapper/vgoptdisk-vmoptdisk
- new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/vgoptdisk/vmoptdisk", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/vgoptdisk/vmoptdisk - new
alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-3", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-3/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-3/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-3/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-3/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-3/uevent>,
"MAJOR=253\nMINOR=3\nDEVNAME=dm-3\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-3/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-3/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-3", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/dm-3 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-3/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:3", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:3>
10331 fstat(3</run/udev/data/b253:3>, {st_mode=S_IFREG|0644, st_size=708,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:3>,
"S:disk/by-id/dm-name-vgvardisk-vmvardisk\nS:disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5"...,
4096) = 708
10331 read(3</run/udev/data/b253:3>, "", 4096) = 0
10331 close(3</run/udev/data/b253:3>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-vgvardisk-vmvardisk",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3
/dev/disk/by-id/dm-name-vgvardisk-vmvardisk - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3
/dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt
- new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
lstat("/dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgvardisk-vmvardisk",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3
/dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169 - new alias.", 83) =
83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...})
= 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgvardisk-vmvardisk",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/mapper/vgvardisk-vmvardisk", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/mapper/vgvardisk-vmvardisk
- new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/vgvardisk/vmvardisk", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/vgvardisk/vmvardisk - new
alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-4", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-4/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-4/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-4/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-4/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-4/uevent>,
"MAJOR=253\nMINOR=4\nDEVNAME=dm-4\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-4/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-4/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-4", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 4),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:4 /dev/dm-4 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-4/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:4", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:4>
10331 fstat(3</run/udev/data/b253:4>, {st_mode=S_IFREG|0644, st_size=446,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:4>,
"S:mapper/pwx0-pxpool_tmeta\nI:1253249\nE:DM_LV_LAYER=\nE:DM_LV_NAME=pxpool_tmeta\nE:DM_NAME=pwx0-pxpool_tmeta\nE:DM_SUSPENDED=0\nE:DM_"...,
4096) = 446
10331 read(3</run/udev/data/b253:4>, "", 4096) = 0
10331 close(3</run/udev/data/b253:4>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool_tmeta", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:4 /dev/mapper/pwx0-pxpool_tmeta -
new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-5", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-5/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-5/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-5/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-5/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-5/uevent>,
"MAJOR=253\nMINOR=5\nDEVNAME=dm-5\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-5/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-5/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-5", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 5),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:5 /dev/dm-5 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-5/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:5", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:5>
10331 fstat(3</run/udev/data/b253:5>, {st_mode=S_IFREG|0644, st_size=446,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:5>,
"S:mapper/pwx0-pxpool_tdata\nI:1254463\nE:DM_LV_LAYER=\nE:DM_LV_NAME=pxpool_tdata\nE:DM_NAME=pwx0-pxpool_tdata\nE:DM_SUSPENDED=0\nE:DM_"...,
4096) = 446
10331 read(3</run/udev/data/b253:5>, "", 4096) = 0
10331 close(3</run/udev/data/b253:5>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool_tdata", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 5), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:5 /dev/mapper/pwx0-pxpool_tdata -
new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-6", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-6/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-6/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-6/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-6/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-6/uevent>,
"MAJOR=253\nMINOR=6\nDEVNAME=dm-6\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-6/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-6/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-6", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 6),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:6 /dev/dm-6 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-6/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:6", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:6>
10331 fstat(3</run/udev/data/b253:6>, {st_mode=S_IFREG|0644, st_size=445,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:6>,
"S:mapper/pwx0-pxpool-tpool\nI:1393315\nE:DM_LV_LAYER=tpool\nE:DM_LV_NAME=pxpool\nE:DM_NAME=pwx0-pxpool-tpool\nE:DM_SUSPENDED=0\nE:DM_U"...,
4096) = 445
10331 read(3</run/udev/data/b253:6>, "", 4096) = 0
10331 close(3</run/udev/data/b253:6>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool-tpool", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 6), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:6 /dev/mapper/pwx0-pxpool-tpool -
new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-7", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-7/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-7/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-7/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-7/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-7/uevent>,
"MAJOR=253\nMINOR=7\nDEVNAME=dm-7\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-7/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-7/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-7", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 7),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:7 /dev/dm-7 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-7/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:7", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:7>
10331 fstat(3</run/udev/data/b253:7>, {st_mode=S_IFREG|0644, st_size=427,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:7>,
"S:mapper/pwx0-pxpool\nI:1394152\nE:DM_LV_LAYER=\nE:DM_LV_NAME=pxpool\nE:DM_NAME=pwx0-pxpool\nE:DM_SUSPENDED=0\nE:DM_UDEV_DISABLE_DISK_"...,
4096) = 427
10331 read(3</run/udev/data/b253:7>, "", 4096) = 0
10331 close(3</run/udev/data/b253:7>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 7), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:7 /dev/mapper/pwx0-pxpool - new
alias.", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-8", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-8/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-8/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-8/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-8/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-8/uevent>,
"MAJOR=253\nMINOR=8\nDEVNAME=dm-8\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-8/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-8/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-8", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/dm-8 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-8/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:8", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:8>
10331 fstat(3</run/udev/data/b253:8>, {st_mode=S_IFREG|0644, st_size=659,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:8>,
"S:disk/by-id/dm-name-pwx0-pxMetaFS\nS:disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ\nS:d"...,
4096) = 659
10331 read(3</run/udev/data/b253:8>, "", 4096) = 0
10331 close(3</run/udev/data/b253:8>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pwx0-pxMetaFS", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8
/dev/disk/by-id/dm-name-pwx0-pxMetaFS - new alias.", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
stat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8
/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ
- new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
lstat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-pxMetaFS", {st_mode=S_IFLNK|0777,
st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8
/dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43 - new alias.", 83) =
83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...})
= 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-pxMetaFS", {st_mode=S_IFLNK|0777,
st_size=10, ...}) = 0
10331 stat("/dev/mapper/pwx0-pxMetaFS", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/mapper/pwx0-pxMetaFS - new
alias.", 54) = 54
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/pwx0/pxMetaFS", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/pwx0/pxMetaFS - new
alias.", 47) = 47
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-9", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-9/uevent", {st_mode=S_IFREG|0644,
st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-9/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/dm-9/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-9/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-9/uevent>,
"MAJOR=253\nMINOR=9\nDEVNAME=dm-9\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-9/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-9/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-9", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/dm-9 - new alias.", 38) =
38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-9/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:9", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b253:9>
10331 fstat(3</run/udev/data/b253:9>, {st_mode=S_IFREG|0644, st_size=735,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:9>,
"S:disk/by-id/dm-name-pwx0-405564132566284931\nS:disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0f"...,
4096) = 735
10331 read(3</run/udev/data/b253:9>, "", 4096) = 0
10331 close(3</run/udev/data/b253:9>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pwx0-405564132566284931",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9
/dev/disk/by-id/dm-name-pwx0-405564132566284931 - new alias.", 76) = 76
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...})
= 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-405564132566284931",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331
stat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9
/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue
- new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331
lstat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-405564132566284931",
{st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8",
{st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9
/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - exists. ", 81) = 81
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/pwx0-405564132566284931", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9
/dev/mapper/pwx0-405564132566284931 - new alias.", 64) = 64
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/pwx0/405564132566284931", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/pwx0/405564132566284931 -
new alias.", 57) = 57
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/md127", 0x7ffd7d8fcc80, 1024) =
-1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/md127/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/md127/uevent", O_RDONLY|O_CLOEXEC) =
3</sys/devices/virtual/block/md127/uevent>
10331 fstat(3</sys/devices/virtual/block/md127/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/md127/uevent>,
"MAJOR=9\nMINOR=127\nDEVNAME=md127\nDEVTYPE=disk\n", 4096) = 45
10331 read(3</sys/devices/virtual/block/md127/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/md127/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/md127", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/md127 - new.", 33) = 33
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/md127/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b9:127", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b9:127>
10331 fstat(3</run/udev/data/b9:127>, {st_mode=S_IFREG|0644, st_size=529,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b9:127>,
"S:disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT\nS:disk/by-id/md-name-any:pwx0\nS:disk/by-id/md-uuid-eb0177fc:8911"...,
4096) = 529
10331 read(3</run/udev/data/b9:127>, "", 4096) = 0
10331 close(3</run/udev/data/b9:127>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
stat("/dev/disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT",
{st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127
/dev/disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT - new
alias.", 95) = 95
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/md-name-any:pwx0", {st_mode=S_IFBLK|0660,
st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127
/dev/disk/by-id/md-name-any:pwx0 - new alias.", 61) = 61
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/md-uuid-eb0177fc:8911b6f1:2bf4d8b2:877bdfe8",
{st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127
/dev/disk/by-id/md-uuid-eb0177fc:8911b6f1:2bf4d8b2:877bdfe8 - new alias.",
88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/md/pwx0", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/md/pwx0 - new alias.", 41)
= 41
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 brk(NULL)                         = 0x555bdeb24000
10331 brk(NULL)                         = 0x555bdeb24000
10331 brk(0x555bdeb21000)               = 0x555bdeb21000
10331 brk(NULL)                         = 0x555bdeb21000
10331 stat("/sys/dev/block", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:0/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:0/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-0/holders>
10331 getdents(3</sys/devices/virtual/block/dm-0/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-0/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-0/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:1/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/252:1/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>
10331
getdents(3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>,
/* 3 entries */, 32768) = 80
10331 uname({sysname="Linux", nodename="ip-70-0-159-14.brbnca.spcsdns.net",
...}) = 0
10331 open("/proc/devices", O_RDONLY)   = 4</proc/devices>
10331 fstat(4</proc/devices>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</proc/devices>, "Character devices:\n  1 mem\n  4 /dev/vc/0\n
 4 tty\n  4 ttyS\n  5 /dev/tty\n  5 /dev/console\n  5 /dev/ptmx\n  7 vcs\n
10 misc\n 13 input"..., 1024) = 534
10331 close(4</proc/devices>)           = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:11/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-11/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-11/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-11/dm/uuid>,
"CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931\n",
4096) = 71
10331 close(4</sys/devices/virtual/block/dm-11/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
getdents(3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:1/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-1/holders>
10331 getdents(3</sys/devices/virtual/block/dm-1/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-1/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-1/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:2/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>,
/* 4 entries */, 32768) = 96
10331 open("/sys/dev/block/253:1/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-1/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-1/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-1/dm/uuid>,
"LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-1/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:0/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-0/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-0/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-0/dm/uuid>,
"LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-0/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:2/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-2/holders>
10331 getdents(3</sys/devices/virtual/block/dm-2/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-2/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-2/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:3/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>,
/* 3 entries */, 32768) = 72
10331 open("/sys/dev/block/253:3/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-3/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-3/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-3/dm/uuid>,
"LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-3/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:3/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-3/holders>
10331 getdents(3</sys/devices/virtual/block/dm-3/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-3/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-3/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:4/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>,
/* 3 entries */, 32768) = 72
10331 open("/sys/dev/block/253:2/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-2/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-2/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-2/dm/uuid>,
"LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-2/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:4/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-4/holders>
10331 getdents(3</sys/devices/virtual/block/dm-4/holders>, /* 3 entries */,
32768) = 72
10331 open("/sys/dev/block/253:6/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-6/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-6/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-6/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool\n",
4096) = 75
10331 close(4</sys/devices/virtual/block/dm-6/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:4/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-4/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-4/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-4/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta\n",
4096) = 75
10331 close(4</sys/devices/virtual/block/dm-4/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/dm-4/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-4/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:5/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-5/holders>
10331 getdents(3</sys/devices/virtual/block/dm-5/holders>, /* 3 entries */,
32768) = 72
10331 open("/sys/dev/block/253:5/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-5/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-5/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-5/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata\n",
4096) = 75
10331 close(4</sys/devices/virtual/block/dm-5/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/dm-5/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-5/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:6/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-6/holders>
10331 getdents(3</sys/devices/virtual/block/dm-6/holders>, /* 6 entries */,
32768) = 152
10331 open("/sys/dev/block/253:10/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-10/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-10/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-10/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-10/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:8/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-8/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-8/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-8/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-8/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:9/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-9/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-9/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-9/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue\n",
4096) = 69
10331 close(4</sys/devices/virtual/block/dm-9/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:7/dm/uuid", O_RDONLY) =
4</sys/devices/virtual/block/dm-7/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-7/dm/uuid>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-7/dm/uuid>,
"LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool\n",
4096) = 74
10331 close(4</sys/devices/virtual/block/dm-7/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/dm-6/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-6/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:7/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-7/holders>
10331 getdents(3</sys/devices/virtual/block/dm-7/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-7/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-7/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:8/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-8/holders>
10331 getdents(3</sys/devices/virtual/block/dm-8/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-8/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-8/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:9/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-9/holders>
10331 getdents(3</sys/devices/virtual/block/dm-9/holders>, /* 2 entries */,
32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-9/holders>, /* 0 entries */,
32768) = 0
10331 close(3</sys/devices/virtual/block/dm-9/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:10/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-10/holders>
10331 getdents(3</sys/devices/virtual/block/dm-10/holders>, /* 2 entries
*/, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-10/holders>, /* 0 entries
*/, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-10/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:11/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/dm-11/holders>
10331 getdents(3</sys/devices/virtual/block/dm-11/holders>, /* 2 entries
*/, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-11/holders>, /* 0 entries
*/, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-11/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:16/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:32/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:33/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:48/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:64/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>,
/* 3 entries */, 32768) = 80
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:80/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>,
/* 3 entries */, 32768) = 80
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:96/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>,
/* 3 entries */, 32768) = 80
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>)
= 0
10331 openat(AT_FDCWD, "/sys/dev/block/9:127/holders/",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/virtual/block/md127/holders>
10331 getdents(3</sys/devices/virtual/block/md127/holders>, /* 4 entries
*/, 32768) = 96
10331 getdents(3</sys/devices/virtual/block/md127/holders>, /* 0 entries
*/, 32768) = 0
10331 close(3</sys/devices/virtual/block/md127/holders>) = 0
10331 openat(AT_FDCWD, "/sys/class/block",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/class/block>
10331 getdents(3</sys/class/block>, /* 28 entries */, 32768) = 720
10331 stat("/sys/class/block/dm-1/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-1/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-1/dev>
10331 fstat(4</sys/devices/virtual/block/dm-1/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-1/dev>, "253:1\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-1/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdf/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sdf/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>,
"8:80\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-10/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-10/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-10/dev>
10331 fstat(4</sys/devices/virtual/block/dm-10/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-10/dev>, "253:10\n", 4096) = 7
10331 close(4</sys/devices/virtual/block/dm-10/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda4/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda4/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>,
"8:4\n", 4096) = 4
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdd/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sdd/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>,
"8:48\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/pxd!pxd405564132566284931/dev",
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/pxd!pxd405564132566284931/dev", O_RDONLY) =
4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>
10331 fstat(4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>,
"252:1\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda2/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda2/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>,
"8:2\n", 4096) = 4
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/md127/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/md127/dev", O_RDONLY) =
4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-8/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-8/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-8/dev>
10331 fstat(4</sys/devices/virtual/block/dm-8/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-8/dev>, "253:8\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-8/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdb/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sdb/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>,
"8:16\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-6/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-6/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-6/dev>
10331 fstat(4</sys/devices/virtual/block/dm-6/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-6/dev>, "253:6\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-6/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-4/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-4/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-4/dev>
10331 fstat(4</sys/devices/virtual/block/dm-4/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-4/dev>, "253:4\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-4/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-2/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-2/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-2/dev>
10331 fstat(4</sys/devices/virtual/block/dm-2/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-2/dev>, "253:2\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-2/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdg/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sdg/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>,
"8:96\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-11/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-11/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-11/dev>
10331 fstat(4</sys/devices/virtual/block/dm-11/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-11/dev>, "253:11\n", 4096) = 7
10331 close(4</sys/devices/virtual/block/dm-11/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-0/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-0/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-0/dev>
10331 fstat(4</sys/devices/virtual/block/dm-0/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-0/dev>, "253:0\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-0/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sde/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sde/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>,
"8:64\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda3/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda3/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>,
"8:3\n", 4096) = 4
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdc1/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdc1/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>,
"8:33\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-9/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-9/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-9/dev>
10331 fstat(4</sys/devices/virtual/block/dm-9/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-9/dev>, "253:9\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-9/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdc/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sdc/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>,
"8:32\n", 4096) = 5
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda1/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda1/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>,
"8:1\n", 4096) = 4
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-7/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-7/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-7/dev>
10331 fstat(4</sys/devices/virtual/block/dm-7/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-7/dev>, "253:7\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-7/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda/dev", {st_mode=S_IFREG|0444, st_size=4096,
...}) = 0
10331 open("/sys/class/block/sda/dev", O_RDONLY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>,
{st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>,
"8:0\n", 4096) = 4
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-5/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-5/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-5/dev>
10331 fstat(4</sys/devices/virtual/block/dm-5/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-5/dev>, "253:5\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-5/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-3/dev", {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-3/dev", O_RDONLY) =
4</sys/devices/virtual/block/dm-3/dev>
10331 fstat(4</sys/devices/virtual/block/dm-3/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-3/dev>, "253:3\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-3/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/class/block>, /* 0 entries */, 32768) = 0
10331 close(3</sys/class/block>)        = 0
10331 stat("/dev/sda", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...})
= 0
10331 open("/dev/sda", O_RDONLY|O_DIRECT|O_NOATIME) = 3</dev/sda>
10331 fstat(3</dev/sda>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/sda>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(3</dev/sda>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:0",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent",
O_RDONLY|O_CLOEXEC) =
3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>
10331
fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>,
"MAJOR=8\nMINOR=0\nDEVNAME=sda\nDEVTYPE=disk\n", 4096) = 41
10331
read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>,
"", 4096) = 0
10331
close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:0", O_RDONLY|O_CLOEXEC) =
3</run/udev/data/b8:0>
10331 fstat(3</run/udev/data/b8:0>, {st_mode=S_IFREG|0644, st_size=371,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:0>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0\nW:512\nI:1504\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 371
10331 read(3</run/udev/data/b8:0>, "", 4096) = 0
10331 close(3</run/udev/data/b8:0>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/control", {st_mode=S_IFCHR|0600,
st_rdev=makedev(10, 236), ...}) = 0
10331 open("/dev/mapper/control", O_RDWR) = 3</dev/mapper/control>
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm version   [ opencount flush ]   [16384]
(*1)", 47) = 47
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_VERSION, {version=4.0.0,
data_size=16384, flags=DM_EXISTS_FLAG} => {version=4.39.0, data_size=16384,
flags=DM_EXISTS_FLAG}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:0) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 0),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 0),
name="centos_bazinga-root",
uuid="LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv",
target_count=1, open_count=1, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/centos_bazinga/root: Skipping unusable
device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/centos_bazinga/root",
43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...})
= 0
10331 open("/dev/sda1", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda1>
10331 fstat(4</dev/sda1>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda1 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda1>, BLKGETSIZE64, [1073741824]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda1: size is 2097152 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda1>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda1", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda1: Device is a partition, using primary
device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda1", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:1",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>,
"MAJOR=8\nMINOR=1\nDEVNAME=sda1\nDEVTYPE=partition\nPARTN=1\n", 4096) = 55
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:1", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:1>
10331 fstat(4</run/udev/data/b8:1>, {st_mode=S_IFREG|0644, st_size=748,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:1>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1\nS:disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4\nW:500\nI:1617\nE:ID_BUS=scs"...,
4096) = 748
10331 read(4</run/udev/data/b8:1>, "", 4096) = 0
10331 close(4</run/udev/data/b8:1>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda1", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda1", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pxd/pxd405564132566284931: Skipping
(regex)", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad
/dev/pxd/pxd405564132566284931", 49) = 49
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:1) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 1),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 1),
name="centos_bazinga-swap",
uuid="LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs",
target_count=1, open_count=0, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/centos_bazinga/swap: Skipping unusable
device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/centos_bazinga/swap",
43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda2", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...})
= 0
10331 open("/dev/sda2", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda2>
10331 fstat(4</dev/sda2>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda2 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda2>, BLKGETSIZE64, [33284947968]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda2: size is 65009664 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda2>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda2", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda2: Device is a partition, using primary
device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda2", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:2",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>,
"MAJOR=8\nMINOR=2\nDEVNAME=sda2\nDEVTYPE=partition\nPARTN=2\n", 4096) = 55
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:2", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:2>
10331 fstat(4</run/udev/data/b8:2>, {st_mode=S_IFREG|0644, st_size=857,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:2>,
"S:disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2\nW:499\nI:1810\n"...,
4096) = 857
10331 read(4</run/udev/data/b8:2>, "", 4096) = 0
10331 close(4</run/udev/data/b8:2>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda2", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda2", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:2) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 2),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 2),
name="vgoptdisk-vmoptdisk",
uuid="LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE",
target_count=1, open_count=1, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/vgoptdisk/vmoptdisk: Skipping unusable
device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/vgoptdisk/vmoptdisk",
43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda3", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...})
= 0
10331 open("/dev/sda3", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda3>
10331 fstat(4</dev/sda3>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda3 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda3>, BLKGETSIZE64, [21474836992]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda3: size is 41943041 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda3>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda3", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda3: Device is a partition, using primary
device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda3", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:3",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>,
"MAJOR=8\nMINOR=3\nDEVNAME=sda3\nDEVTYPE=partition\nPARTN=3\n", 4096) = 55
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:3", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:3>
10331 fstat(4</run/udev/data/b8:3>, {st_mode=S_IFREG|0644, st_size=858,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:3>,
"S:disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3\nW:501\nI:2019\n"...,
4096) = 858
10331 read(4</run/udev/data/b8:3>, "", 4096) = 0
10331 close(4</run/udev/data/b8:3>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda3", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda3", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:3) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 3),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 3),
name="vgvardisk-vmvardisk",
uuid="LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt",
target_count=1, open_count=1, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/vgvardisk/vmvardisk: Skipping unusable
device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/vgvardisk/vmvardisk",
43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda4", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...})
= 0
10331 open("/dev/sda4", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda4>
10331 fstat(4</dev/sda4>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda4 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda4>, BLKGETSIZE64, [21474836992]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda4: size is 41943041 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda4>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda4", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda",
4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda4: Device is a partition, using primary
device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda4", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:4",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>,
"MAJOR=8\nMINOR=4\nDEVNAME=sda4\nDEVTYPE=partition\nPARTN=4\n", 4096) = 55
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:4", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:4>
10331 fstat(4</run/udev/data/b8:4>, {st_mode=S_IFREG|0644, st_size=859,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:4>,
"S:disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4\nW:502\nI:2187\n"...,
4096) = 859
10331 read(4</run/udev/data/b8:4>, "", 4096) = 0
10331 close(4</run/udev/data/b8:4>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda4", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda4", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:4) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 4),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 4),
name="pwx0-pxpool_tmeta",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta",
target_count=1, open_count=1, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tmeta: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta
on inter"..., 171) = 171
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tmeta: Skipping
unusable device.", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad
/dev/mapper/pwx0-pxpool_tmeta", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:5) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 5),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 5),
name="pwx0-pxpool_tdata",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata",
target_count=1, open_count=1, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tdata: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata
on inter"..., 171) = 171
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tdata: Skipping
unusable device.", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad
/dev/mapper/pwx0-pxpool_tdata", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:6) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 6),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=431, data_start=312, dev=makedev(253, 6),
name="pwx0-pxpool-tpool",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool",
target_count=1, open_count=4, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool-tpool: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool
on inter"..., 171) = 171
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool-tpool: Skipping
unusable device.", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad
/dev/mapper/pwx0-pxpool-tpool", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:7) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 7),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 7),
name="pwx0-pxpool",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool",
target_count=1, open_count=0, event_nr=0,
flags=DM_READONLY_FLAG|DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool: Reserved uuid
LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool
on internal LV "..., 158) = 158
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool: Skipping unusable
device.", 50) = 50
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/mapper/pwx0-pxpool",
42) = 42
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:8) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 8),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=368, data_start=312, dev=makedev(253, 8),
name="pwx0-pxMetaFS",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ",
target_count=1, open_count=1, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pwx0/pxMetaFS: Skipping unusable device.",
45) = 45
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/pwx0/pxMetaFS", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:9) [ noopencount noflush ]
[16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 9),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=368, data_start=312, dev=makedev(253, 9),
name="pwx0-405564132566284931",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue",
target_count=1, open_count=0, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pwx0/405564132566284931: Skipping unusable
device.", 55) = 55
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad
/dev/pwx0/405564132566284931", 47) = 47
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:10) [ noopencount noflush ]
[16384] (*1)", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 10),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=356, data_start=312, dev=makedev(253, 10),
name="pwx0-405564132566284931_empty_snap",
uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me",
target_count=1, open_count=0, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pwx0/405564132566284931_empty_snap:
Skipping unusable device.", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad
/dev/pwx0/405564132566284931_empty_snap", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:11) [ noopencount noflush ]
[16384] (*1)", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0,
data_size=16384, data_start=312, dev=makedev(253, 11),
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG}
=> {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 11),
name="pxd-enc405564132566284931",
uuid="CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931",
target_count=1, open_count=0, event_nr=0,
flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG,
...}) = 0
10331 stat("/dev/mapper/pxd-enc405564132566284931", {st_mode=S_IFBLK|0660,
st_rdev=makedev(253, 11), ...}) = 0
10331 open("/dev/mapper/pxd-enc405564132566284931",
O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/dm-11>
10331 fstat(4</dev/dm-11>, {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/mapper/pxd-enc405564132566284931 RO
O_DIRECT", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/dm-11>, BLKGETSIZE64, [10735321088]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/mapper/pxd-enc405564132566284931: size is
20967424 sectors", 63) = 63
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/dm-11>)              = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/mapper/pxd-enc405564132566284931",
44) = 44
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred
/dev/mapper/pxd-enc405564132566284931", 65) = 65
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/253:11",
"../../devices/virtual/block/dm-11", 1024) = 33
10331 stat("/sys/devices/virtual/block/dm-11/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/virtual/block/dm-11/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/sys/devices/virtual/block/dm-11/uevent", O_RDONLY|O_CLOEXEC) =
4</sys/devices/virtual/block/dm-11/uevent>
10331 fstat(4</sys/devices/virtual/block/dm-11/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-11/uevent>,
"MAJOR=253\nMINOR=11\nDEVNAME=dm-11\nDEVTYPE=disk\n", 4096) = 46
10331 read(4</sys/devices/virtual/block/dm-11/uevent>, "", 4096) = 0
10331 close(4</sys/devices/virtual/block/dm-11/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b253:11", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b253:11>
10331 fstat(4</run/udev/data/b253:11>, {st_mode=S_IFREG|0644, st_size=669,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b253:11>,
"S:disk/by-id/dm-name-pxd-enc405564132566284931\nS:disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc40556413"...,
4096) = 669
10331 read(4</run/udev/data/b253:11>, "", 4096) = 0
10331 close(4</run/udev/data/b253:11>)  = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred
/dev/mapper/pxd-enc405564132566284931", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred
/dev/mapper/pxd-enc405564132566284931", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdb", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...})
= 0
10331 open("/dev/sdb", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdb>
10331 fstat(4</dev/sdb>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdb RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdb>, BLKGETSIZE64, [34359738368]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdb: size is 67108864 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdb>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdb", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdb/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdb/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdb", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:16",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>,
"MAJOR=8\nMINOR=16\nDEVNAME=sdb\nDEVTYPE=disk\n", 4096) = 42
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:16", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:16>
10331 fstat(4</run/udev/data/b8:16>, {st_mode=S_IFREG|0644, st_size=346,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:16>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0\nW:520\nI:3038\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 346
10331 read(4</run/udev/data/b8:16>, "", 4096) = 0
10331 close(4</run/udev/data/b8:16>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdb", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdb", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdc", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...})
= 0
10331 open("/dev/sdc", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdc>
10331 fstat(4</dev/sdc>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdc RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdc>, BLKGETSIZE64, [26843545600]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdc: size is 52428800 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdc>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdc", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdc/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdc/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdc", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:32",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>,
"MAJOR=8\nMINOR=32\nDEVNAME=sdc\nDEVTYPE=disk\n", 4096) = 42
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:32", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:32>
10331 fstat(4</run/udev/data/b8:32>, {st_mode=S_IFREG|0644, st_size=371,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:32>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0\nW:513\nI:3870\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 371
10331 read(4</run/udev/data/b8:32>, "", 4096) = 0
10331 close(4</run/udev/data/b8:32>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdc", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdc", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdc1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33),
...}) = 0
10331 open("/dev/sdc1", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdc1>
10331 fstat(4</dev/sdc1>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdc1 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdc1>, BLKGETSIZE64, [3219128320]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdc1: size is 6287360 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdc1>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdc1", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:32",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc",
4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sdc1: Device is a partition, using primary
device sdc for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdc/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdc/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdc1", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:33",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1",
1024) = 78
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/subsystem",
"../../../../../../../../../class/block", 1024) = 38
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>,
"MAJOR=8\nMINOR=33\nDEVNAME=sdc1\nDEVTYPE=partition\nPARTN=1\nPARTNAME=journal\n",
4096) = 73
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:33", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:33>
10331 fstat(4</run/udev/data/b8:33>, {st_mode=S_IFREG|0644, st_size=744,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:33>,
"S:disk/by-partlabel/journal\nS:disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0"...,
4096) = 744
10331 read(4</run/udev/data/b8:33>, "", 4096) = 0
10331 close(4</run/udev/data/b8:33>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdc1", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdc1", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdd", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...})
= 0
10331 open("/dev/sdd", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdd>
10331 fstat(4</dev/sdd>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdd RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdd>, BLKGETSIZE64, [68719476736]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdd: size is 134217728 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdd>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdd", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdd/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdd/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdd", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:48",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>,
"MAJOR=8\nMINOR=48\nDEVNAME=sdd\nDEVTYPE=disk\n", 4096) = 42
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:48", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:48>
10331 fstat(4</run/udev/data/b8:48>, {st_mode=S_IFREG|0644, st_size=346,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:48>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0\nW:519\nI:4512\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"...,
4096) = 346
10331 read(4</run/udev/data/b8:48>, "", 4096) = 0
10331 close(4</run/udev/data/b8:48>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdd", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdd", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sde", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...})
= 0
10331 open("/dev/sde", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sde>
10331 fstat(4</dev/sde>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sde RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sde>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sde: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sde>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sde", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sde/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sde/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>,
/* 3 entries */, 32768) = 80
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>)
= 0
10331 open("/sys//block/md127/dev", O_RDONLY) =
4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sde", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:64",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>,
"MAJOR=8\nMINOR=64\nDEVNAME=sde\nDEVTYPE=disk\n", 4096) = 42
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:64", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:64>
10331 fstat(4</run/udev/data/b8:64>, {st_mode=S_IFREG|0644, st_size=668,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:64>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0\nW:511\nI:5158\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"...,
4096) = 668
10331 read(4</run/udev/data/b8:64>, "", 4096) = 0
10331 close(4</run/udev/data/b8:64>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Device /dev/sde is md raid component based on
blkid variable in udev db (ID_FS_TYPE=\"linux_raid_member\").", 105) = 105
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "md filter full 0 excluding md component
/dev/sde", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sde: Skipping md component device", 38) =
38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sde", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdf", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...})
= 0
10331 open("/dev/sdf", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdf>
10331 fstat(4</dev/sdf>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdf RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdf>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdf: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdf>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdf", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdf/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdf/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>,
/* 3 entries */, 32768) = 80
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>)
= 0
10331 open("/sys//block/md127/dev", O_RDONLY) =
4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdf", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:80",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>,
"MAJOR=8\nMINOR=80\nDEVNAME=sdf\nDEVTYPE=disk\n", 4096) = 42
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:80", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:80>
10331 fstat(4</run/udev/data/b8:80>, {st_mode=S_IFREG|0644, st_size=668,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:80>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0\nW:516\nI:5664\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"...,
4096) = 668
10331 read(4</run/udev/data/b8:80>, "", 4096) = 0
10331 close(4</run/udev/data/b8:80>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Device /dev/sdf is md raid component based on
blkid variable in udev db (ID_FS_TYPE=\"linux_raid_member\").", 105) = 105
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "md filter full 0 excluding md component
/dev/sdf", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sdf: Skipping md component device", 38) =
38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sdf", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdg", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...})
= 0
10331 open("/dev/sdg", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdg>
10331 fstat(4</dev/sdg>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdg RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdg>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdg: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdg>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdg", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdg/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdg/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>,
/* 3 entries */, 32768) = 80
10331
getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>,
/* 0 entries */, 32768) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>)
= 0
10331 open("/sys//block/md127/dev", O_RDONLY) =
4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444,
st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdg", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:96",
"../../devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg",
1024) = 73
10331
stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331
readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/subsystem",
"../../../../../../../../class/block", 1024) = 35
10331
open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent",
O_RDONLY|O_CLOEXEC) =
4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>
10331
fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>,
"MAJOR=8\nMINOR=96\nDEVNAME=sdg\nDEVTYPE=disk\n", 4096) = 42
10331
read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>,
"", 4096) = 0
10331
close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>)
= 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:96", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b8:96>
10331 fstat(4</run/udev/data/b8:96>, {st_mode=S_IFREG|0644, st_size=668,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:96>,
"S:disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0\nW:514\nI:6230\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"...,
4096) = 668
10331 read(4</run/udev/data/b8:96>, "", 4096) = 0
10331 close(4</run/udev/data/b8:96>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Device /dev/sdg is md raid component based on
blkid variable in udev db (ID_FS_TYPE=\"linux_raid_member\").", 105) = 105
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "md filter full 0 excluding md component
/dev/sdg", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sdg: Skipping md component device", 38) =
38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sdg", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/md127", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127),
...}) = 0
10331 open("/dev/md127", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/md127>
10331 fstat(4</dev/md127>, {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127),
...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/md127 RO O_DIRECT", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/md127>, BLKGETSIZE64, [411911061504]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/md127: size is 804513792 sectors", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/md127>)              = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/md127", 17) = 17
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/md127", 38) =
38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/9:127", "../../devices/virtual/block/md127",
1024) = 33
10331 stat("/sys/devices/virtual/block/md127/uevent",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/virtual/block/md127/subsystem",
"../../../../class/block", 1024) = 23
10331 open("/sys/devices/virtual/block/md127/uevent", O_RDONLY|O_CLOEXEC) =
4</sys/devices/virtual/block/md127/uevent>
10331 fstat(4</sys/devices/virtual/block/md127/uevent>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/uevent>,
"MAJOR=9\nMINOR=127\nDEVNAME=md127\nDEVTYPE=disk\n", 4096) = 45
10331 read(4</sys/devices/virtual/block/md127/uevent>, "", 4096) = 0
10331 close(4</sys/devices/virtual/block/md127/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b9:127", O_RDONLY|O_CLOEXEC) =
4</run/udev/data/b9:127>
10331 fstat(4</run/udev/data/b9:127>, {st_mode=S_IFREG|0644, st_size=529,
...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</run/udev/data/b9:127>,
"S:disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT\nS:disk/by-id/md-name-any:pwx0\nS:disk/by-id/md-uuid-eb0177fc:8911"...,
4096) = 529
10331 read(4</run/udev/data/b9:127>, "", 4096) = 0
10331 close(4</run/udev/data/b9:127>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/md127", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/md127", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//dev/block/9:127/md/metadata_version",
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys//dev/block/9:127/md/metadata_version", O_RDONLY) =
4</sys/devices/virtual/block/md127/md/metadata_version>
10331 fstat(4</sys/devices/virtual/block/md127/md/metadata_version>,
{st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/md/metadata_version>,
"1.2\n", 4096) = 4
10331 close(4</sys/devices/virtual/block/md127/md/metadata_version>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "Device /dev/md127 metadata_version is 1.2.",
42) = 42
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found 11 devices to scan", 24) = 24
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 io_setup(256, [0x7fb064549000])   = 0
10331 brk(NULL)                         = 0x555bdeb21000
10331 brk(0x555bdf333000)               = 0x555bdf333000
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Scanning 11 devices for VG info", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 open("/dev/sda", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=4</dev/sda>, aio_buf=0x555bdeb12000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sda1", O_RDONLY|O_DIRECT|O_NOATIME) = 5</dev/sda1>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=5</dev/sda1>, aio_buf=0x555bdeb32000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sda2", O_RDONLY|O_DIRECT|O_NOATIME) = 6</dev/sda2>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=6</dev/sda2>, aio_buf=0x555bdeb52000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sda3", O_RDONLY|O_DIRECT|O_NOATIME) = 7</dev/sda3>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=7</dev/sda3>, aio_buf=0x555bdeb72000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sda4", O_RDONLY|O_DIRECT|O_NOATIME) = 8</dev/sda4>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=8</dev/sda4>, aio_buf=0x555bdeb92000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/mapper/pxd-enc405564132566284931",
O_RDONLY|O_DIRECT|O_NOATIME) = 9</dev/dm-11> <<<<< HERE IS THE TROUBLE!!!!!
OPEN TO READ
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=9</dev/dm-11>, aio_buf=0x555bdebb2000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sdb", O_RDONLY|O_DIRECT|O_NOATIME) = 10</dev/sdb>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=10</dev/sdb>, aio_buf=0x555bdebd2000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sdc", O_RDONLY|O_DIRECT|O_NOATIME) = 11</dev/sdc>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=11</dev/sdc>, aio_buf=0x555bdebf2000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sdc1", O_RDONLY|O_DIRECT|O_NOATIME) = 12</dev/sdc1>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=12</dev/sdc1>, aio_buf=0x555bdec12000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/sdd", O_RDONLY|O_DIRECT|O_NOATIME) = 13</dev/sdd>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=13</dev/sdd>, aio_buf=0x555bdec32000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 open("/dev/md127", O_RDONLY|O_DIRECT|O_NOATIME) = 14</dev/md127>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD,
aio_fildes=14</dev/md127>, aio_buf=0x555bdec52000, aio_nbytes=131072,
aio_offset=0}]) = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Scanning submitted 11 reads", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 io_getevents(0x7fb064549000, 1, 64, [{data=0, obj=0x555bdeb0c588,
res=131072, res2=0}, {data=0, obj=0x555bdeb0c5e0, res=131072, res2=0},
{data=0, obj=0x555bdeb0c638, res=131072, res2=0}, {data=0,
obj=0x555bdeb0c690, res=131072, res2=0}, {data=0, obj=0x555bdeb0c6e8,
res=131072, res2=0}, {data=0, obj=0x555bdeb0c798, res=131072, res2=0},
{data=0, obj=0x555bdeb0c7f0, res=131072, res2=0}, {data=0,
obj=0x555bdeb0c8a0, res=131072, res2=0}, {data=0, obj=0x555bdeb0c848,
res=131072, res2=0}], NULL) = 9
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Processing data from device /dev/sda 8:0 fd 4
block 0x555bdf312010", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Scan filtering /dev/sda", 23) = 23
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda: using cached size 268435456 sectors",
45) = 45
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0,
...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders",
O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) =
15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331
getdents(15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 2 entries */, 32768) = 48
10331
getdents(15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>,
/* 0 entries */, 32768) = 0
10331
close(15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>)
= 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda: Skipping: Partition table signature
found", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sda", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda: Not processing filtered", 33) = 33
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 io_getevents(0x7fb064549000, 1, 64, [{data=0, obj=0x555bdeb0c8f8,
res=131072, res2=0}], NULL) = 1
10331 io_getevents(0x7fb064549000, 1, 64, 0x7ffd7d8fd000, NULL) = -1 EINTR
(Interrupted system call)
10331 --- SIGINT {si_signo=SIGINT, si_code=SI_KERNEL} ---


Thanks
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220126/1f30689b/attachment.htm>
-------------- next part --------------
[root at ip-70-0-159-14 ~]# pxctl status
Status: PX is operational
Telemetry: Disabled or Unhealthy
License: PX-Enterprise (floating) (lease renewal in 6h, 4m)
Node ID: 4ae973b1-d70b-4bda-b24b-8bd9b07f1722
        IP: 70.0.159.14
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       HIGH            raid0           380 GiB 39 MiB  Online  default default
        Local Storage Devices: 3 devices
        Device  Path            Media Type              Size            Last-Scan
        0:0     /dev/sdf        STORAGE_MEDIUM_SSD      128 GiB         26 Jan 22 12:35 UTC
        0:1     /dev/sdg        STORAGE_MEDIUM_SSD      128 GiB         26 Jan 22 12:35 UTC
        0:2     /dev/sde        STORAGE_MEDIUM_SSD      128 GiB         26 Jan 22 12:35 UTC
        total                   -                       384 GiB
        Cache Devices:
         * No cache devices
        Journal Device:
        1       /dev/sdc1       STORAGE_MEDIUM_SSD
Cluster Summary
        Cluster ID: PX-INT-C0-1_26_DEV/Porx-01-caching_703_725
        Cluster UUID: 7a0e5dc3-3893-41e7-b439-8114fae147be
        Scheduler: none
        Nodes: 5 node(s) with storage (5 online)
        IP              ID                                      SchedulerNodeName       Auth            StorageNode     Used    Capacity   Status   StorageStatus   Version         Kernel                          OS
        70.0.82.56      b111cff1-af96-43ce-a5cb-26fd31150682    N/A                     Disabled        Yes             39 MiB  380 GiB    Online   Up              3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7 (Core)
        70.0.82.58      893122a7-571e-48a3-a6dd-2b210976079d    N/A                     Disabled        Yes             39 MiB  380 GiB    Online   Up              3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7 (Core)
        70.0.159.0      85b4ad2f-5d55-4c35-9368-db381cc2f273    N/A                     Disabled        Yes             39 MiB  380 GiB    Online   Up              3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7 (Core)
        70.0.158.220    7d29c7f6-a948-43d0-b9c2-d86e02b12899    N/A                     Disabled        Yes             39 MiB  380 GiB    Online   Up              3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7 (Core)
        70.0.159.14     4ae973b1-d70b-4bda-b24b-8bd9b07f1722    N/A                     Disabled        Yes             39 MiB  380 GiB    Online   Up (This node)  3.0.0.0-c4bd95f 4.20.13-1.el7.elrepo.x86_64     CentOS Linux 7 (Core)
Global Storage Pool
        Total Used      :  194 MiB
        Total Capacity  :  1.9 TiB
[root at ip-70-0-159-14 ~]#
[root at ip-70-0-159-14 ~]#
[root at ip-70-0-159-14 ~]# pxctl v c -s 10 -r 1 --nodes LocalNode --secure --secret_key secret securevol
Encrypted Volume successfully created: 405564132566284931
[root at ip-70-0-159-14 ~]# pxctl host attach --secret_key secret securevol
Volume successfully attached at: /dev/mapper/pxd-enc405564132566284931


/// Created a dmcrypt volume and have it attached on the node. This is a new block device (/dev/mapper/pxd-enc405564132566284931)
/// whose parent virtual pxd device is (/dev/pxd/pxd/pxd405564132566284931)

[root at ip-70-0-159-14 ~]# lvs
  WARNING: Not using lvmetad because config setting use_lvmetad=0.
  WARNING: To avoid corruption, rescan devices to make changes visible (pvscan --cache).
  LV                            VG             Attr       LSize    Pool   Origin             Data%  Meta%  Move Log Cpy%Sync Convert
  root                          centos_bazinga -wi-ao----   28.99g
  swap                          centos_bazinga -wi-a-----    2.00g
  405564132566284931            pwx0           Vwi-aot---   10.00g pxpool                    0.68
  405564132566284931_empty_snap pwx0           Vwi-a-t---   10.00g pxpool 405564132566284931 0.00
  pxMetaFS                      pwx0           Vwi-aot---   64.00g pxpool                    0.05
  pxpool                        pwx0           twi-aot--- <379.62g                           0.03   0.87
  vmoptdisk                     vgoptdisk      -wi-ao----  <20.00g
  vmvardisk                     vgvardisk      -wi-ao----  <20.00g
[root at ip-70-0-159-14 ~]#
[root at ip-70-0-159-14 ~]# lsblk
NAME                                       MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sdf                                          8:80   0   128G  0 disk
??md127                                      9:127  0 383.6G  0 raid0
  ??pwx0-pxpool_tmeta                      253:4    0     2G  0 lvm
  ? ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
  ?   ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
  ?   ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
  ?   ??pwx0-405564132566284931            253:9    0    10G  0 lvm
  ?   ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
  ??pwx0-pxpool_tdata                      253:5    0 379.6G  0 lvm
    ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
      ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
      ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
      ??pwx0-405564132566284931            253:9    0    10G  0 lvm
      ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
sdd                                          8:48   0    64G  0 disk
pxd!pxd405564132566284931                  252:1    0    10G  0 disk
??pxd-enc405564132566284931                253:11   0    10G  0 crypt
sdb                                          8:16   0    32G  0 disk
sdg                                          8:96   0   128G  0 disk
??md127                                      9:127  0 383.6G  0 raid0
  ??pwx0-pxpool_tmeta                      253:4    0     2G  0 lvm
  ? ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
  ?   ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
  ?   ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
  ?   ??pwx0-405564132566284931            253:9    0    10G  0 lvm
  ?   ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
  ??pwx0-pxpool_tdata                      253:5    0 379.6G  0 lvm
    ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
      ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
      ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
      ??pwx0-405564132566284931            253:9    0    10G  0 lvm
      ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
sde                                          8:64   0   128G  0 disk
??md127                                      9:127  0 383.6G  0 raid0
  ??pwx0-pxpool_tmeta                      253:4    0     2G  0 lvm
  ? ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
  ?   ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
  ?   ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
  ?   ??pwx0-405564132566284931            253:9    0    10G  0 lvm
  ?   ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
  ??pwx0-pxpool_tdata                      253:5    0 379.6G  0 lvm
    ??pwx0-pxpool-tpool                    253:6    0 379.6G  0 lvm
      ??pwx0-405564132566284931_empty_snap 253:10   0    10G  0 lvm
      ??pwx0-pxMetaFS                      253:8    0    64G  0 lvm
      ??pwx0-405564132566284931            253:9    0    10G  0 lvm
      ??pwx0-pxpool                        253:7    0 379.6G  1 lvm
sdc                                          8:32   0    25G  0 disk
??sdc1                                       8:33   0     3G  0 part
sda                                          8:0    0   128G  0 disk
??sda4                                       8:4    0    20G  0 part
? ??vgoptdisk-vmoptdisk                    253:2    0    20G  0 lvm   /opt
??sda2                                       8:2    0    31G  0 part
? ??centos_bazinga-swap                    253:1    0     2G  0 lvm
? ??centos_bazinga-root                    253:0    0    29G  0 lvm   /
??sda3                                       8:3    0    20G  0 part
? ??vgvardisk-vmvardisk                    253:3    0    20G  0 lvm   /var
??sda1                                       8:1    0     1G  0 part  /boot
[root at ip-70-0-159-14 ~]#

[root at ip-70-0-159-14 ~]# dmsetup ls --tree
pwx0-pxMetaFS (253:8)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
pwx0-pxpool (253:7)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
pwx0-405564132566284931_empty_snap (253:10)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
pxd-enc405564132566284931 (253:11)
 ?? (252:1)
pwx0-405564132566284931 (253:9)
 ??pwx0-pxpool-tpool (253:6)
    ??pwx0-pxpool_tdata (253:5)
    ?  ?? (9:127)
    ??pwx0-pxpool_tmeta (253:4)
       ?? (9:127)
vgoptdisk-vmoptdisk (253:2)
 ?? (8:4)
centos_bazinga-swap (253:1)
 ?? (8:2)
centos_bazinga-root (253:0)
 ?? (8:2)
vgvardisk-vmvardisk (253:3)
 ?? (8:3)
[root at ip-70-0-159-14 ~]#

[root@ip-70-0-159-14 ~]# ls -al /dev/pxd/pxd405564132566284931
brw-rw---- 1 root disk 252, 1 Jan 26 12:36 /dev/pxd/pxd405564132566284931

//// Stop userspace IO application that services IO to /dev/pxd/pxd<> devices.

//// Issue lvs -vvv it is stuck for disk IO to /dev/pxd/pxd405564132566284931.

[root at ip-70-0-159-14 ~]# ps -lef | grep lvs
4 S root      9166  7342  0  80   0 - 18108 read_e 12:40 pts/2    00:00:00 lvs -vvv
4 S root      9167  7342  0  80   0 -  1944 pipe_w 12:40 pts/2    00:00:00 tee lvs.out
0 S root      9171 17043  0  80   0 -  3133 pipe_w 12:40 pts/0    00:00:00 grep --color=auto lvs
[root at ip-70-0-159-14 ~]# cat /proc/9166/fd
fd/     fdinfo/
[root at ip-70-0-159-14 ~]# cat /proc/9166/fd
fd/     fdinfo/
[root at ip-70-0-159-14 ~]# ls /proc/9166/fd
0  1  10  11  12  13  14  2  3  4  5  6  7  8  9
[root at ip-70-0-159-14 ~]# ls -al /proc/9166/fdinfo/
total 0
dr-x------ 2 root root 0 Jan 26 12:41 .
dr-xr-xr-x 9 root root 0 Jan 26 12:40 ..
-r-------- 1 root root 0 Jan 26 12:41 0
-r-------- 1 root root 0 Jan 26 12:41 1
-r-------- 1 root root 0 Jan 26 12:41 10
-r-------- 1 root root 0 Jan 26 12:41 11
-r-------- 1 root root 0 Jan 26 12:41 12
-r-------- 1 root root 0 Jan 26 12:41 13
-r-------- 1 root root 0 Jan 26 12:41 14
-r-------- 1 root root 0 Jan 26 12:41 2
-r-------- 1 root root 0 Jan 26 12:41 3
-r-------- 1 root root 0 Jan 26 12:41 4
-r-------- 1 root root 0 Jan 26 12:41 5
-r-------- 1 root root 0 Jan 26 12:41 6
-r-------- 1 root root 0 Jan 26 12:41 7
-r-------- 1 root root 0 Jan 26 12:41 8
-r-------- 1 root root 0 Jan 26 12:41 9
[root at ip-70-0-159-14 ~]# ls -al /proc/9166/fd
total 0
dr-x------ 2 root root  0 Jan 26 12:40 .
dr-xr-xr-x 9 root root  0 Jan 26 12:40 ..
lrwx------ 1 root root 64 Jan 26 12:40 0 -> /dev/pts/2
l-wx------ 1 root root 64 Jan 26 12:40 1 -> pipe:[943352]
lr-x------ 1 root root 64 Jan 26 12:41 10 -> /dev/sdb
lr-x------ 1 root root 64 Jan 26 12:41 11 -> /dev/sdc
lr-x------ 1 root root 64 Jan 26 12:41 12 -> /dev/sdc1
lr-x------ 1 root root 64 Jan 26 12:41 13 -> /dev/sdd
lr-x------ 1 root root 64 Jan 26 12:41 14 -> /dev/md127
lrwx------ 1 root root 64 Jan 26 12:40 2 -> /dev/pts/2
lrwx------ 1 root root 64 Jan 26 12:40 3 -> /dev/mapper/control
lr-x------ 1 root root 64 Jan 26 12:41 4 -> /dev/sda
lr-x------ 1 root root 64 Jan 26 12:41 5 -> /dev/sda1
lr-x------ 1 root root 64 Jan 26 12:41 6 -> /dev/sda2
lr-x------ 1 root root 64 Jan 26 12:41 7 -> /dev/sda3
lr-x------ 1 root root 64 Jan 26 12:41 8 -> /dev/sda4
lr-x------ 1 root root 64 Jan 26 12:41 9 -> /dev/dm-11
[root at ip-70-0-159-14 ~]# ls -al /dev/mapper/pwx0-405564132566284931
lrwxrwxrwx 1 root root 7 Jan 26 12:40 /dev/mapper/pwx0-405564132566284931 -> ../dm-9
[root at ip-70-0-159-14 ~]# ls -al /dev/mapper/
centos_bazinga-root                 pwx0-pxMetaFS                       pxd-enc405564132566284931
centos_bazinga-swap                 pwx0-pxpool                         vgoptdisk-vmoptdisk
control                             pwx0-pxpool_tdata                   vgvardisk-vmvardisk
pwx0-405564132566284931             pwx0-pxpool_tmeta
pwx0-405564132566284931_empty_snap  pwx0-pxpool-tpool
[root at ip-70-0-159-14 ~]# ls -al /dev/mapper/pxd-enc405564132566284931
lrwxrwxrwx 1 root root 8 Jan 26 12:36 /dev/mapper/pxd-enc405564132566284931 -> ../dm-11
[root at ip-70-0-159-14 ~]# top -p 9166
top - 12:44:47 up  7:45,  2 users,  load average: 0.28, 0.11, 0.15
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.0 sy,  0.0 ni, 99.7 id,  0.0 wa,  0.0 hi,  0.1 si,  0.0 st
KiB Mem :  8167916 total,   884304 free,   470124 used,  6813488 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  7034948 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 9166 root      20   0       0      0      0 D   0.0  0.0   0:00.00 lvs

[root at ip-70-0-159-14 ~]# cat /proc/9166/task/*/status
Name:   lvs
Umask:  0077
State:  D (disk sleep)
Tgid:   9166
Ngid:   0
Pid:    9166
PPid:   7342
TracerPid:      0
Uid:    0       0       0       0
Gid:    0       0       0       0
FDSize: 256
Groups: 0
NStgid: 9166
NSpid:  9166
NSpgid: 9166
NSsid:  7342
Threads:        1
SigQ:   4/31805
SigPnd: 0000000000000000
ShdPnd: 0000000000000002
SigBlk: 0000000000000000
SigIgn: 0000000000000000
SigCgt: 0000000180000000
CapInh: 0000000000000000
CapPrm: 0000003fffffffff
CapEff: 0000003fffffffff
CapBnd: 0000003fffffffff
CapAmb: 0000000000000000
NoNewPrivs:     0
Seccomp:        0
Speculation_Store_Bypass:       thread vulnerable
Cpus_allowed:   f
Cpus_allowed_list:      0-3
Mems_allowed:   00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,0000000       0,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,000       00000,00000000,00000001
Mems_allowed_list:      0
voluntary_ctxt_switches:        5
nonvoluntary_ctxt_switches:     2
[root at ip-70-0-159-14 ~]# cat /proc/9166/status
Name:   lvs
Umask:  0077
State:  D (disk sleep)
Tgid:   9166
Ngid:   0
Pid:    9166
PPid:   7342
TracerPid:      0
Uid:    0       0       0       0
Gid:    0       0       0       0
FDSize: 256
Groups: 0
NStgid: 9166
NSpid:  9166
NSpgid: 9166
NSsid:  7342
Threads:        1
SigQ:   4/31805
SigPnd: 0000000000000000
ShdPnd: 0000000000000002
SigBlk: 0000000000000000
SigIgn: 0000000000000000
SigCgt: 0000000180000000
CapInh: 0000000000000000
CapPrm: 0000003fffffffff
CapEff: 0000003fffffffff
CapBnd: 0000003fffffffff
CapAmb: 0000000000000000
NoNewPrivs:     0
Seccomp:        0
Speculation_Store_Bypass:       thread vulnerable
Cpus_allowed:   f
Cpus_allowed_list:      0-3
Mems_allowed:   00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000001
Mems_allowed_list:      0
voluntary_ctxt_switches:        5
nonvoluntary_ctxt_switches:     2
[root at ip-70-0-159-14 ~]# ls -al /proc/9166/fd/
total 0
dr-x------ 2 root root  0 Jan 26 12:40 .
dr-xr-xr-x 9 root root  0 Jan 26 12:40 ..
lrwx------ 1 root root 64 Jan 26 12:40 0 -> /dev/pts/2
l-wx------ 1 root root 64 Jan 26 12:40 1 -> pipe:[943352]
lr-x------ 1 root root 64 Jan 26 12:41 10 -> /dev/sdb
lr-x------ 1 root root 64 Jan 26 12:41 11 -> /dev/sdc
lr-x------ 1 root root 64 Jan 26 12:41 12 -> /dev/sdc1
lr-x------ 1 root root 64 Jan 26 12:41 13 -> /dev/sdd
lr-x------ 1 root root 64 Jan 26 12:41 14 -> /dev/md127
lrwx------ 1 root root 64 Jan 26 12:40 2 -> /dev/pts/2
lrwx------ 1 root root 64 Jan 26 12:40 3 -> /dev/mapper/control
lr-x------ 1 root root 64 Jan 26 12:41 4 -> /dev/sda
lr-x------ 1 root root 64 Jan 26 12:41 5 -> /dev/sda1
lr-x------ 1 root root 64 Jan 26 12:41 6 -> /dev/sda2
lr-x------ 1 root root 64 Jan 26 12:41 7 -> /dev/sda3
lr-x------ 1 root root 64 Jan 26 12:41 8 -> /dev/sda4
lr-x------ 1 root root 64 Jan 26 12:41 9 -> /dev/dm-11 ///// This is /dev/mapper/pxd-enc405564132566284931
[root at ip-70-0-159-14 ~]#



[root at ip-70-0-159-14 ~]# lvs -vvv 
WARNING: Ignoring duplicate config value: global_filter
WARNING: Ignoring duplicate config value: thin_pool_zero
        Parsing: lvs -vvv
        Recognised command lvs_general (id 93 / enum 74).
      Setting devices/global_filter to global_filter = [ "r|/dev/pxd.*|", "r|/dev/mapper/pxd.*|", "a|.*/|" ]
  WARNING: Not using lvmetad because config setting use_lvmetad=0.
  WARNING: To avoid corruption, rescan devices to make changes visible (pvscan --cache).
        Sysfs filter initialised.
        Internal filter initialised.
        Regex filter initialised.
        LVM type filter initialised.
        Usable device filter initialised (scan_lvs 0).
        mpath filter initialised.
        Partitioned filter initialised.
        MD filter initialised.
        Composite filter initialised.
      devices/cache not found in config: defaulting to /etc/lvm/cache/.cache
        Persistent filter initialised.
      metadata/record_lvs_history not found in config: defaulting to 0
        DEGRADED MODE. Incomplete RAID LVs will be processed.
        Processing command: lvs -vvv
        Command pid: 9166
        System ID:
        O_DIRECT will be used
      File-based locking selected.
      report/output_format not found in config: defaulting to basic
      log/report_command_log not found in config: defaulting to 0
      report/aligned not found in config: defaulting to 1
      report/buffered not found in config: defaulting to 1
      report/headings not found in config: defaulting to 1
      report/separator not found in config: defaulting to
      report/prefixes not found in config: defaulting to 0
      report/quoted not found in config: defaulting to 1
      report/columns_as_rows not found in config: defaulting to 0
      report/lvs_sort not found in config: defaulting to vg_name,lv_name
      report/lvs_cols_verbose not found in config: defaulting to lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile
      report/compact_output_cols not found in config: defaulting to
        Finding VG info
        Sysfs filter initialised.
        Internal filter initialised.
        Regex filter initialised.
        LVM type filter initialised.
        Usable device filter initialised (scan_lvs 0).
        mpath filter initialised.
        Partitioned filter initialised.
        MD filter initialised.
        Composite filter initialised.
      devices/cache not found in config: defaulting to /etc/lvm/cache/.cache
        Persistent filter initialised.
        Finding devices to scan
        Creating list of system devices.
        Found dev 8:0 /dev/sda - new.
        Found dev 8:0 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0 - new alias.
        Found dev 8:1 /dev/sda1 - new.
        Found dev 8:1 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1 - new alias.
        Found dev 8:1 /dev/disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4 - new alias.
        Found dev 8:2 /dev/sda2 - new.
        Found dev 8:2 /dev/disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc - new alias.
        Found dev 8:2 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2 - new alias.
        Found dev 8:3 /dev/sda3 - new.
        Found dev 8:3 /dev/disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD - new alias.
        Found dev 8:3 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3 - new alias.
        Found dev 8:4 /dev/sda4 - new.
        Found dev 8:4 /dev/disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW - new alias.
        Found dev 8:4 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4 - new alias.
        Found dev 8:16 /dev/sdb - new.
        Found dev 8:16 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0 - new alias.
        Found dev 8:32 /dev/sdc - new.
        Found dev 8:32 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0 - new alias.
        Found dev 8:33 /dev/sdc1 - new.
        Found dev 8:33 /dev/disk/by-partlabel/journal - new alias.
        Found dev 8:33 /dev/disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6 - new alias.
        Found dev 8:33 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0-part1 - new alias.
        Found dev 8:48 /dev/sdd - new.
        Found dev 8:48 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0 - new alias.
        Found dev 8:64 /dev/sde - new.
        Found dev 8:64 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0 - new alias.
        Found dev 8:80 /dev/sdf - new.
        Found dev 8:80 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0 - new alias.
        Found dev 8:96 /dev/sdg - new.
        Found dev 8:96 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0 - new alias.
        Found dev 252:1 /dev/pxd/pxd405564132566284931 - new.
        Found dev 253:9 /dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - new.
        Found dev 253:0 /dev/dm-0 - new.
        Found dev 253:0 /dev/centos_bazinga/root - new alias.
        Found dev 253:0 /dev/disk/by-id/dm-name-centos_bazinga-root - new alias.
        Found dev 253:0 /dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv - new alias.
        Found dev 253:0 /dev/disk/by-uuid/3476a32c-d5c2-49e1-9efb-85238af4bbe5 - new alias.
        Found dev 253:0 /dev/mapper/centos_bazinga-root - new alias.
        Found dev 253:1 /dev/dm-1 - new.
        Found dev 253:1 /dev/centos_bazinga/swap - new alias.
        Found dev 253:1 /dev/disk/by-id/dm-name-centos_bazinga-swap - new alias.
        Found dev 253:1 /dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs - new alias.
        Found dev 253:1 /dev/disk/by-uuid/72214974-21d6-442e-b60a-e291f8a2bea3 - new alias.
        Found dev 253:1 /dev/mapper/centos_bazinga-swap - new alias.
        Found dev 253:10 /dev/dm-10 - new.
        Found dev 253:10 /dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap - new alias.
        Found dev 253:10 /dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me - new alias.
        Found dev 253:10 /dev/mapper/pwx0-405564132566284931_empty_snap - new alias.
        Found dev 253:10 /dev/pwx0/405564132566284931_empty_snap - new alias.
        Found dev 253:11 /dev/dm-11 - new.
        Found dev 253:11 /dev/disk/by-id/dm-name-pxd-enc405564132566284931 - new alias.
        Found dev 253:11 /dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931 - new alias.
        Found dev 253:11 /dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c - new alias.
        Found dev 253:11 /dev/mapper/pxd-enc405564132566284931 - new alias.
        Found dev 253:2 /dev/dm-2 - new.
        Found dev 253:2 /dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk - new alias.
        Found dev 253:2 /dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE - new alias.
        Found dev 253:2 /dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186 - new alias.
        Found dev 253:2 /dev/mapper/vgoptdisk-vmoptdisk - new alias.
        Found dev 253:2 /dev/vgoptdisk/vmoptdisk - new alias.
        Found dev 253:3 /dev/dm-3 - new.
        Found dev 253:3 /dev/disk/by-id/dm-name-vgvardisk-vmvardisk - new alias.
        Found dev 253:3 /dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt - new alias.
        Found dev 253:3 /dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169 - new alias.
        Found dev 253:3 /dev/mapper/vgvardisk-vmvardisk - new alias.
        Found dev 253:3 /dev/vgvardisk/vmvardisk - new alias.
        Found dev 253:4 /dev/dm-4 - new.
        Found dev 253:4 /dev/mapper/pwx0-pxpool_tmeta - new alias.
        Found dev 253:5 /dev/dm-5 - new.
        Found dev 253:5 /dev/mapper/pwx0-pxpool_tdata - new alias.
        Found dev 253:6 /dev/dm-6 - new.
        Found dev 253:6 /dev/mapper/pwx0-pxpool-tpool - new alias.
        Found dev 253:7 /dev/dm-7 - new.
        Found dev 253:7 /dev/mapper/pwx0-pxpool - new alias.
        Found dev 253:8 /dev/dm-8 - new.
        Found dev 253:8 /dev/disk/by-id/dm-name-pwx0-pxMetaFS - new alias.
        Found dev 253:8 /dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ - new alias.
        Found dev 253:8 /dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43 - new alias.
        Found dev 253:8 /dev/mapper/pwx0-pxMetaFS - new alias.
        Found dev 253:8 /dev/pwx0/pxMetaFS - new alias.
        Found dev 253:9 /dev/dm-9 - new alias.
        Found dev 253:9 /dev/disk/by-id/dm-name-pwx0-405564132566284931 - new alias.
        Found dev 253:9 /dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue - new alias.
        Found dev 253:9 /dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - exists.
        Found dev 253:9 /dev/mapper/pwx0-405564132566284931 - new alias.
        Found dev 253:9 /dev/pwx0/405564132566284931 - new alias.
        Found dev 9:127 /dev/md127 - new.
        Found dev 9:127 /dev/disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT - new alias.
        Found dev 9:127 /dev/disk/by-id/md-name-any:pwx0 - new alias.
        Found dev 9:127 /dev/disk/by-id/md-uuid-eb0177fc:8911b6f1:2bf4d8b2:877bdfe8 - new alias.
        Found dev 9:127 /dev/md/pwx0 - new alias.
        Opened /dev/sda RO O_DIRECT
      /dev/sda: size is 268435456 sectors
        Closed /dev/sda
        filter partitioned deferred /dev/sda
        filter md deferred /dev/sda
        filter cache deferred /dev/sda
        dm version   [ opencount flush ]   [16384] (*1)
        dm status   (253:0) [ noopencount noflush ]   [16384] (*1)
        /dev/centos_bazinga/root: Skipping unusable device.
        filter caching bad /dev/centos_bazinga/root
        Opened /dev/sda1 RO O_DIRECT
      /dev/sda1: size is 2097152 sectors
        Closed /dev/sda1
        /dev/sda1: Device is a partition, using primary device sda for mpath component detection
        filter partitioned deferred /dev/sda1
        filter md deferred /dev/sda1
        filter cache deferred /dev/sda1
        /dev/pxd/pxd405564132566284931: Skipping (regex)
        filter caching bad /dev/pxd/pxd405564132566284931
        dm status   (253:1) [ noopencount noflush ]   [16384] (*1)
        /dev/centos_bazinga/swap: Skipping unusable device.
        filter caching bad /dev/centos_bazinga/swap
        Opened /dev/sda2 RO O_DIRECT
      /dev/sda2: size is 65009664 sectors
        Closed /dev/sda2
        /dev/sda2: Device is a partition, using primary device sda for mpath component detection
        filter partitioned deferred /dev/sda2
        filter md deferred /dev/sda2
        filter cache deferred /dev/sda2
        dm status   (253:2) [ noopencount noflush ]   [16384] (*1)
        /dev/vgoptdisk/vmoptdisk: Skipping unusable device.
        filter caching bad /dev/vgoptdisk/vmoptdisk
        Opened /dev/sda3 RO O_DIRECT
      /dev/sda3: size is 41943041 sectors
        Closed /dev/sda3
        /dev/sda3: Device is a partition, using primary device sda for mpath component detection
        filter partitioned deferred /dev/sda3
        filter md deferred /dev/sda3
        filter cache deferred /dev/sda3
        dm status   (253:3) [ noopencount noflush ]   [16384] (*1)
        /dev/vgvardisk/vmvardisk: Skipping unusable device.
        filter caching bad /dev/vgvardisk/vmvardisk
        Opened /dev/sda4 RO O_DIRECT
      /dev/sda4: size is 41943041 sectors
        Closed /dev/sda4
        /dev/sda4: Device is a partition, using primary device sda for mpath component detection
        filter partitioned deferred /dev/sda4
        filter md deferred /dev/sda4
        filter cache deferred /dev/sda4
        dm status   (253:4) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool_tmeta: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta on internal LV device pwx0-pxpool_tmeta not usable.
        /dev/mapper/pwx0-pxpool_tmeta: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool_tmeta
        dm status   (253:5) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool_tdata: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata on internal LV device pwx0-pxpool_tdata not usable.
        /dev/mapper/pwx0-pxpool_tdata: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool_tdata
        dm status   (253:6) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool-tpool: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool on internal LV device pwx0-pxpool-tpool not usable.
        /dev/mapper/pwx0-pxpool-tpool: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool-tpool
        dm status   (253:7) [ noopencount noflush ]   [16384] (*1)
        /dev/mapper/pwx0-pxpool: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool on internal LV device pwx0-pxpool not usable.
        /dev/mapper/pwx0-pxpool: Skipping unusable device.
        filter caching bad /dev/mapper/pwx0-pxpool
        dm status   (253:8) [ noopencount noflush ]   [16384] (*1)
        /dev/pwx0/pxMetaFS: Skipping unusable device.
        filter caching bad /dev/pwx0/pxMetaFS
        dm status   (253:9) [ noopencount noflush ]   [16384] (*1)
        /dev/pwx0/405564132566284931: Skipping unusable device.
        filter caching bad /dev/pwx0/405564132566284931
        dm status   (253:10) [ noopencount noflush ]   [16384] (*1)
        /dev/pwx0/405564132566284931_empty_snap: Skipping unusable device.
        filter caching bad /dev/pwx0/405564132566284931_empty_snap
        dm status   (253:11) [ noopencount noflush ]   [16384] (*1)
        Opened /dev/mapper/pxd-enc405564132566284931 RO O_DIRECT
      /dev/mapper/pxd-enc405564132566284931: size is 20967424 sectors
        Closed /dev/mapper/pxd-enc405564132566284931
        filter partitioned deferred /dev/mapper/pxd-enc405564132566284931
        filter md deferred /dev/mapper/pxd-enc405564132566284931
        filter cache deferred /dev/mapper/pxd-enc405564132566284931
        Opened /dev/sdb RO O_DIRECT
      /dev/sdb: size is 67108864 sectors
        Closed /dev/sdb
        filter partitioned deferred /dev/sdb
        filter md deferred /dev/sdb
        filter cache deferred /dev/sdb
        Opened /dev/sdc RO O_DIRECT
      /dev/sdc: size is 52428800 sectors
        Closed /dev/sdc
        filter partitioned deferred /dev/sdc
        filter md deferred /dev/sdc
        filter cache deferred /dev/sdc
        Opened /dev/sdc1 RO O_DIRECT
      /dev/sdc1: size is 6287360 sectors
        Closed /dev/sdc1
        /dev/sdc1: Device is a partition, using primary device sdc for mpath component detection
        filter partitioned deferred /dev/sdc1
        filter md deferred /dev/sdc1
        filter cache deferred /dev/sdc1
        Opened /dev/sdd RO O_DIRECT
      /dev/sdd: size is 134217728 sectors
        Closed /dev/sdd
        filter partitioned deferred /dev/sdd
        filter md deferred /dev/sdd
        filter cache deferred /dev/sdd
        Opened /dev/sde RO O_DIRECT
      /dev/sde: size is 268435456 sectors
        Closed /dev/sde
        filter partitioned deferred /dev/sde
        Device /dev/sde is md raid component based on blkid variable in udev db (ID_FS_TYPE="linux_raid_member").
        md filter full 0 excluding md component /dev/sde
        /dev/sde: Skipping md component device
        filter caching bad /dev/sde
        Opened /dev/sdf RO O_DIRECT
      /dev/sdf: size is 268435456 sectors
        Closed /dev/sdf
        filter partitioned deferred /dev/sdf
        Device /dev/sdf is md raid component based on blkid variable in udev db (ID_FS_TYPE="linux_raid_member").
        md filter full 0 excluding md component /dev/sdf
        /dev/sdf: Skipping md component device
        filter caching bad /dev/sdf
        Opened /dev/sdg RO O_DIRECT
      /dev/sdg: size is 268435456 sectors
        Closed /dev/sdg
        filter partitioned deferred /dev/sdg
        Device /dev/sdg is md raid component based on blkid variable in udev db (ID_FS_TYPE="linux_raid_member").
        md filter full 0 excluding md component /dev/sdg
        /dev/sdg: Skipping md component device
        filter caching bad /dev/sdg
        Opened /dev/md127 RO O_DIRECT
      /dev/md127: size is 804513792 sectors
        Closed /dev/md127
        filter partitioned deferred /dev/md127
        filter md deferred /dev/md127
        filter cache deferred /dev/md127
      Device /dev/md127 metadata_version is 1.2.
        Found 11 devices to scan
        Scanning 11 devices for VG info
        Scanning submitted 11 reads
        Processing data from device /dev/sda 8:0 fd 4 block 0x564490886010
        Scan filtering /dev/sda
      /dev/sda: using cached size 268435456 sectors
        /dev/sda: Skipping: Partition table signature found
        filter caching bad /dev/sda
      /dev/sda: Not processing filtered
^C^C^C^C^C^C
<<<<<<< Stuck here for disk IO - waiting for read from dmcrypt volume(/dev/mapper/pwx0-405564132566284931)
whose parent device /dev/pxd/pxd/pxd405564132566284931, which is not going to be serviced since
the application is down.

//// dmesg logs during this point.
[Wed Jan 26 12:40:03 2022] pxd_control_release: pxd-control-0(3) close OK
[Wed Jan 26 12:48:23 2022] INFO: task lvs:9166 blocked for more than 120 seconds.
[Wed Jan 26 12:48:23 2022]       Tainted: G           O      4.20.13-1.el7.elrepo.x86_64 #1
[Wed Jan 26 12:48:23 2022] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[Wed Jan 26 12:48:23 2022] lvs             D    0  9166   7342 0x80000084
[Wed Jan 26 12:48:23 2022] Call Trace:
[Wed Jan 26 12:48:23 2022]  __schedule+0x2ab/0x880
[Wed Jan 26 12:48:23 2022]  schedule+0x36/0x80
[Wed Jan 26 12:48:23 2022]  schedule_timeout+0x1dc/0x300
[Wed Jan 26 12:48:23 2022]  ? call_rcu+0x15/0x20
[Wed Jan 26 12:48:23 2022]  ? __percpu_ref_switch_mode+0xdf/0x180
[Wed Jan 26 12:48:23 2022]  wait_for_completion+0x121/0x180
[Wed Jan 26 12:48:23 2022]  ? wake_up_q+0x80/0x80
[Wed Jan 26 12:48:23 2022]  exit_aio+0xbc/0xf0
[Wed Jan 26 12:48:23 2022]  mmput+0x2f/0x130
[Wed Jan 26 12:48:23 2022]  do_exit+0x273/0xbf0
[Wed Jan 26 12:48:23 2022]  ? __switch_to_asm+0x40/0x70
[Wed Jan 26 12:48:23 2022]  ? __switch_to+0x130/0x450
[Wed Jan 26 12:48:23 2022]  ? __switch_to_asm+0x40/0x70
[Wed Jan 26 12:48:23 2022]  do_group_exit+0x3f/0xb0
[Wed Jan 26 12:48:23 2022]  get_signal+0x166/0x780
[Wed Jan 26 12:48:23 2022]  ? read_events+0x178/0x1a0
[Wed Jan 26 12:48:23 2022]  do_signal+0x37/0x690
[Wed Jan 26 12:48:23 2022]  ? hrtimer_init+0x1b0/0x1b0
[Wed Jan 26 12:48:23 2022]  ? __audit_syscall_exit+0x21c/0x350
[Wed Jan 26 12:48:23 2022]  exit_to_usermode_loop+0x4f/0xb9
[Wed Jan 26 12:48:23 2022]  do_syscall_64+0x162/0x190
[Wed Jan 26 12:48:23 2022]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[Wed Jan 26 12:48:23 2022] RIP: 0033:0x7f71a031e644
[Wed Jan 26 12:48:23 2022] Code: Bad RIP value.
[Wed Jan 26 12:48:23 2022] RSP: 002b:00007fffce23dec0 EFLAGS: 00000246 ORIG_RAX: 00000000000000d0
[Wed Jan 26 12:48:23 2022] RAX: fffffffffffffffc RBX: 0000000000000000 RCX: 00007f71a031e644
[Wed Jan 26 12:48:23 2022] RDX: 0000000000000040 RSI: 0000000000000001 RDI: 00007f71a11dd000
[Wed Jan 26 12:48:23 2022] RBP: 000056449005a1e0 R08: 0000000000000000 R09: 00007fffce23ded0
[Wed Jan 26 12:48:23 2022] R10: 00007fffce23ded0 R11: 0000000000000246 R12: 000056449005a170
[Wed Jan 26 12:48:23 2022] R13: 000056448de8b9b0 R14: 0000000000000000 R15: 0000000000000004


//// Now doing strace output for the same scenario.

10331 open("/dev/mapper/pxd-enc405564132566284931", O_RDONLY|O_DIRECT|O_NOATIME) = 9</dev/dm-11>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=9</dev/dm-11>, aio_buf=0x555bdebb2000, aio_nbytes=131072, aio_offset=0}]) = 1

^^^^^ The above is the trouble, where the lvs (or any vg open call from code) will read all dm devices that includes dm-crypt volumes too whose source
is not ready now, thereby waiting forever.

The whole strace output is as below.
[root at ip-70-0-159-14 ~]# cat lvm.strace
10331 execve("/usr/sbin/lvs", ["lvs", "-vvv"], 0x7ffd78b022f8 /* 21 vars */) = 0
10331 brk(NULL)                         = 0x555bdea9c000
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064563000
10331 access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
10331 open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3</etc/ld.so.cache>
10331 fstat(3</etc/ld.so.cache>, {st_mode=S_IFREG|0644, st_size=29284, ...}) = 0
10331 mmap(NULL, 29284, PROT_READ, MAP_PRIVATE, 3</etc/ld.so.cache>, 0) = 0x7fb06455b000
10331 close(3</etc/ld.so.cache>)        = 0
10331 open("/lib64/libdevmapper-event.so.1.02", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libdevmapper-event.so.1.02>
10331 read(3</usr/lib64/libdevmapper-event.so.1.02>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\35\0\0\0\0\0\0@\0\0\0\0\0\0\0\0W\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\35\0\34\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\214M\0\0\0\0\0\0\214M\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdevmapper-event.so.1.02>, {st_mode=S_IFREG|0555, st_size=24128, ...}) = 0
10331 mmap(NULL, 2118264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libdevmapper-event.so.1.02>, 0) = 0x7fb06413d000
10331 mprotect(0x7fb064142000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb064341000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdevmapper-event.so.1.02>, 0x4000) = 0x7fb064341000
10331 close(3</usr/lib64/libdevmapper-event.so.1.02>) = 0
10331 open("/lib64/libudev.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libudev.so.1.6.2>
10331 read(3</usr/lib64/libudev.so.1.6.2>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 :\0\0\0\0\0\0@\0\0\0\0\0\0\0\270\\\1\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\24B\1\0\0\0\0\0\24B\1\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libudev.so.1.6.2>, {st_mode=S_IFREG|0755, st_size=91256, ...}) = 0
10331 mmap(NULL, 2185456, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libudev.so.1.6.2>, 0) = 0x7fb063f27000
10331 mprotect(0x7fb063f3c000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb06413b000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libudev.so.1.6.2>, 0x14000) = 0x7fb06413b000
10331 close(3</usr/lib64/libudev.so.1.6.2>) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455a000
10331 open("/lib64/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libdl-2.17.so>
10331 read(3</usr/lib64/libdl-2.17.so>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\16\0\0\0\0\0\0@\0\0\0\0\0\0\0\0E\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0!\0 \0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\330\37\0\0\0\0\0\0\330\37\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdl-2.17.so>, {st_mode=S_IFREG|0755, st_size=19776, ...}) = 0
10331 mmap(NULL, 2109744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libdl-2.17.so>, 0) = 0x7fb063d23000
10331 mprotect(0x7fb063d25000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb063f25000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdl-2.17.so>, 0x2000) = 0x7fb063f25000
10331 close(3</usr/lib64/libdl-2.17.so>) = 0
10331 open("/lib64/libblkid.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libblkid.so.1.1.0>
10331 read(3</usr/lib64/libblkid.so.1.1.0>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\203\0\0\0\0\0\0@\0\0\0\0\0\0\0\220\365\3\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|\244\3\0\0\0\0\0|\244\3\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libblkid.so.1.1.0>, {st_mode=S_IFREG|0755, st_size=261456, ...}) = 0
10331 mmap(NULL, 2354056, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libblkid.so.1.1.0>, 0) = 0x7fb063ae4000
10331 mprotect(0x7fb063b1f000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb063d1e000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libblkid.so.1.1.0>, 0x3a000) = 0x7fb063d1e000
10331 mmap(0x7fb063d22000, 2952, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063d22000
10331 close(3</usr/lib64/libblkid.so.1.1.0>) = 0
10331 open("/lib64/libdevmapper.so.1.02", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libdevmapper.so.1.02>
10331 read(3</usr/lib64/libdevmapper.so.1.02>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\270\0\0\0\0\0\0@\0\0\0\0\0\0\0\0x\5\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\35\0\34\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\224\35\5\0\0\0\0\0\224\35\5\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdevmapper.so.1.02>, {st_mode=S_IFREG|0555, st_size=360256, ...}) = 0
10331 mmap(NULL, 2453968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libdevmapper.so.1.02>, 0) = 0x7fb06388c000
10331 mprotect(0x7fb0638de000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb063ade000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdevmapper.so.1.02>, 0x52000) = 0x7fb063ade000
10331 mmap(0x7fb063ae3000, 464, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063ae3000
10331 close(3</usr/lib64/libdevmapper.so.1.02>) = 0
10331 open("/lib64/libaio.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libaio.so.1.0.1>
10331 read(3</usr/lib64/libaio.so.1.0.1>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\5\0\0\0\0\0\0@\0\0\0\0\0\0\0\370\23\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\22\0\21\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\240\t\0\0\0\0\0\0\240\t\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libaio.so.1.0.1>, {st_mode=S_IFREG|0755, st_size=6264, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064559000
10331 mmap(NULL, 2101328, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libaio.so.1.0.1>, 0) = 0x7fb06368a000
10331 mprotect(0x7fb06368b000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb06388a000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libaio.so.1.0.1>, 0) = 0x7fb06388a000
10331 close(3</usr/lib64/libaio.so.1.0.1>) = 0
10331 open("/lib64/libreadline.so.6", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libreadline.so.6.2>
10331 read(3</usr/lib64/libreadline.so.6.2>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0PO\1\0\0\0\0\0@\0\0\0\0\0\0\08S\4\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\214\271\3\0\0\0\0\0\214\271\3\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libreadline.so.6.2>, {st_mode=S_IFREG|0755, st_size=285240, ...}) = 0
10331 mmap(NULL, 2380744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libreadline.so.6.2>, 0) = 0x7fb063444000
10331 mprotect(0x7fb063480000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb063680000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libreadline.so.6.2>, 0x3c000) = 0x7fb063680000
10331 mmap(0x7fb063688000, 5064, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063688000
10331 close(3</usr/lib64/libreadline.so.6.2>) = 0
10331 open("/lib64/libc.so.6", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libc-2.17.so>
10331 read(3</usr/lib64/libc-2.17.so>, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P%\2\0\0\0\0\0@\0\0\0\0\0\0\0H\27!\0\0\0\0\0\0\0\0\0@\08\0\n\0@\0L\0K\0\6\0\0\0\5\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0000\2\0\0\0\0\0\0000\2\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libc-2.17.so>, {st_mode=S_IFREG|0755, st_size=2173512, ...}) = 0
10331 mmap(NULL, 3981792, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libc-2.17.so>, 0) = 0x7fb063077000
10331 mprotect(0x7fb06323a000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb063439000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libc-2.17.so>, 0x1c2000) = 0x7fb063439000
10331 mmap(0x7fb06343f000, 16864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb06343f000
10331 close(3</usr/lib64/libc-2.17.so>) = 0
10331 open("/lib64/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libpthread-2.17.so>
10331 read(3</usr/lib64/libpthread-2.17.so>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0m\0\0\0\0\0\0@\0\0\0\0\0\0\0X+\2\0\0\0\0\0\0\0\0\0@\08\0\t\0@\0)\0(\0\6\0\0\0\5\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0\370\1\0\0\0\0\0\0\370\1\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libpthread-2.17.so>, {st_mode=S_IFREG|0755, st_size=144792, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064558000
10331 mmap(NULL, 2208904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libpthread-2.17.so>, 0) = 0x7fb062e5b000
10331 mprotect(0x7fb062e72000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb063071000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libpthread-2.17.so>, 0x16000) = 0x7fb063071000
10331 mmap(0x7fb063073000, 13448, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb063073000
10331 close(3</usr/lib64/libpthread-2.17.so>) = 0
10331 open("/lib64/librt.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/librt-2.17.so>
10331 read(3</usr/lib64/librt-2.17.so>, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\"\0\0\0\0\0\0@\0\0\0\0\0\0\0\340\243\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0'\0&\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\08e\0\0\0\0\0\08e\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/librt-2.17.so>, {st_mode=S_IFREG|0755, st_size=44448, ...}) = 0
10331 mmap(NULL, 2128952, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/librt-2.17.so>, 0) = 0x7fb062c53000
10331 mprotect(0x7fb062c5a000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062e59000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/librt-2.17.so>, 0x6000) = 0x7fb062e59000
10331 close(3</usr/lib64/librt-2.17.so>) = 0
10331 open("/lib64/libcap.so.2", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libcap.so.2.22>
10331 read(3</usr/lib64/libcap.so.2.22>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \26\0\0\0\0\0\0@\0\0\0\0\0\0\0 at G\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\3247\0\0\0\0\0\0\3247\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libcap.so.2.22>, {st_mode=S_IFREG|0755, st_size=20032, ...}) = 0
10331 mmap(NULL, 2114112, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libcap.so.2.22>, 0) = 0x7fb062a4e000
10331 mprotect(0x7fb062a52000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062c51000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libcap.so.2.22>, 0x3000) = 0x7fb062c51000
10331 close(3</usr/lib64/libcap.so.2.22>) = 0
10331 open("/lib64/libm.so.6", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libm-2.17.so>
10331 read(3</usr/lib64/libm-2.17.so>, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0pS\0\0\0\0\0\0@\0\0\0\0\0\0\0\340Z\21\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0$\0#\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0@\10\20\0\0\0\0\0@\10\20\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libm-2.17.so>, {st_mode=S_IFREG|0755, st_size=1139680, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064557000
10331 mmap(NULL, 3150136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libm-2.17.so>, 0) = 0x7fb06274c000
10331 mprotect(0x7fb06284d000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062a4c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libm-2.17.so>, 0x100000) = 0x7fb062a4c000
10331 close(3</usr/lib64/libm-2.17.so>) = 0
10331 open("/lib64/libdw.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libdw-0.170.so>
10331 read(3</usr/lib64/libdw-0.170.so>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\230\0\0\0\0\0\0@\0\0\0\0\0\0\0\20\202\4\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\234>\4\0\0\0\0\0\234>\4\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libdw-0.170.so>, {st_mode=S_IFREG|0755, st_size=297360, ...}) = 0
10331 mmap(NULL, 2386096, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libdw-0.170.so>, 0) = 0x7fb062505000
10331 mprotect(0x7fb062549000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb062749000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libdw-0.170.so>, 0x44000) = 0x7fb062749000
10331 close(3</usr/lib64/libdw-0.170.so>) = 0
10331 open("/lib64/libgcc_s.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>
10331 read(3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220*\0\0\0\0\0\0@\0\0\0\0\0\0\0\10S\1\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0TL\1\0\0\0\0\0TL\1\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>, {st_mode=S_IFREG|0755, st_size=88776, ...}) = 0
10331 mmap(NULL, 2184192, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>, 0) = 0x7fb0622ef000
10331 mprotect(0x7fb062304000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb062503000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>, 0x14000) = 0x7fb062503000
10331 close(3</usr/lib64/libgcc_s-4.8.5-20150702.so.1>) = 0
10331 open("/lib64/libuuid.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libuuid.so.1.3.0>
10331 read(3</usr/lib64/libuuid.so.1.3.0>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\24\0\0\0\0\0\0@\0\0\0\0\0\0\0\320F\0\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\37\0\36\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0D1\0\0\0\0\0\0D1\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libuuid.so.1.3.0>, {st_mode=S_IFREG|0755, st_size=20112, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064556000
10331 mmap(NULL, 2113904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libuuid.so.1.3.0>, 0) = 0x7fb0620ea000
10331 mprotect(0x7fb0620ee000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0622ed000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libuuid.so.1.3.0>, 0x3000) = 0x7fb0622ed000
10331 close(3</usr/lib64/libuuid.so.1.3.0>) = 0
10331 open("/lib64/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libselinux.so.1>
10331 read(3</usr/lib64/libselinux.so.1>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220j\0\0\0\0\0\0@\0\0\0\0\0\0\0\340X\2\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\3740\2\0\0\0\0\0\3740\2\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libselinux.so.1>, {st_mode=S_IFREG|0755, st_size=155744, ...}) = 0
10331 mmap(NULL, 2255216, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libselinux.so.1>, 0) = 0x7fb061ec3000
10331 mprotect(0x7fb061ee7000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0620e6000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libselinux.so.1>, 0x23000) = 0x7fb0620e6000
10331 mmap(0x7fb0620e8000, 6512, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb0620e8000
10331 close(3</usr/lib64/libselinux.so.1>) = 0
10331 open("/lib64/libsepol.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libsepol.so.1>
10331 read(3</usr/lib64/libsepol.so.1>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 at a\0\0\0\0\0\0@\0\0\0\0\0\0\0p\v\n\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\324\265\t\0\0\0\0\0\324\265\t\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libsepol.so.1>, {st_mode=S_IFREG|0755, st_size=660208, ...}) = 0
10331 mmap(NULL, 2744248, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libsepol.so.1>, 0) = 0x7fb061c25000
10331 mprotect(0x7fb061cc1000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb061ec0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libsepol.so.1>, 0x9b000) = 0x7fb061ec0000
10331 mmap(0x7fb061ec2000, 4024, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fb061ec2000
10331 close(3</usr/lib64/libsepol.so.1>) = 0
10331 open("/lib64/libtinfo.so.5", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libtinfo.so.5.9>
10331 read(3</usr/lib64/libtinfo.so.5.9>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\316\0\0\0\0\0\0@\0\0\0\0\0\0\0\360\242\2\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\O\2\0\0\0\0\0\\O\2\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libtinfo.so.5.9>, {st_mode=S_IFREG|0755, st_size=174576, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064555000
10331 mmap(NULL, 2268928, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libtinfo.so.5.9>, 0) = 0x7fb0619fb000
10331 mprotect(0x7fb061a20000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb061c20000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libtinfo.so.5.9>, 0x25000) = 0x7fb061c20000
10331 close(3</usr/lib64/libtinfo.so.5.9>) = 0
10331 open("/lib64/libattr.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libattr.so.1.1.0>
10331 read(3</usr/lib64/libattr.so.1.1.0>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\23\0\0\0\0\0\0@\0\0\0\0\0\0\0\270F\0\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\344;\0\0\0\0\0\0\344;\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libattr.so.1.1.0>, {st_mode=S_IFREG|0755, st_size=19896, ...}) = 0
10331 mmap(NULL, 2113904, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libattr.so.1.1.0>, 0) = 0x7fb0617f6000
10331 mprotect(0x7fb0617fa000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0619f9000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libattr.so.1.1.0>, 0x3000) = 0x7fb0619f9000
10331 close(3</usr/lib64/libattr.so.1.1.0>) = 0
10331 open("/usr/lib64/elfutils/tls/x86_64/libelf.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils/tls/x86_64", 0x7ffd7d8fc690) = -1 ENOENT (No such file or directory)
10331 open("/usr/lib64/elfutils/tls/libelf.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils/tls", 0x7ffd7d8fc690) = -1 ENOENT (No such file or directory)
10331 open("/usr/lib64/elfutils/x86_64/libelf.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils/x86_64", 0x7ffd7d8fc690) = -1 ENOENT (No such file or directory)
10331 open("/usr/lib64/elfutils/libelf.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 stat("/usr/lib64/elfutils", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
10331 open("/lib64/libelf.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libelf-0.170.so>
10331 read(3</usr/lib64/libelf-0.170.so>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0200\0\0\0\0\0\0@\0\0\0\0\0\0\0\350~\1\0\0\0\0\0\0\0\0\0@\08\0\10\0@\0\36\0\35\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\304d\1\0\0\0\0\0\304d\1\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libelf-0.170.so>, {st_mode=S_IFREG|0755, st_size=99944, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064554000
10331 mmap(NULL, 2191824, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libelf-0.170.so>, 0) = 0x7fb0615de000
10331 mprotect(0x7fb0615f5000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0617f4000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libelf-0.170.so>, 0x16000) = 0x7fb0617f4000
10331 close(3</usr/lib64/libelf-0.170.so>) = 0
10331 open("/usr/lib64/elfutils/libz.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 open("/lib64/libz.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libz.so.1.2.7>
10331 read(3</usr/lib64/libz.so.1.2.7>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p!\0\0\0\0\0\0@\0\0\0\0\0\0\0\350Z\1\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\35\0\34\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\254D\1\0\0\0\0\0\254D\1\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libz.so.1.2.7>, {st_mode=S_IFREG|0755, st_size=90664, ...}) = 0
10331 mmap(NULL, 2183688, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libz.so.1.2.7>, 0) = 0x7fb0613c8000
10331 mprotect(0x7fb0613dd000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0615dc000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libz.so.1.2.7>, 0x14000) = 0x7fb0615dc000
10331 close(3</usr/lib64/libz.so.1.2.7>) = 0
10331 open("/usr/lib64/elfutils/liblzma.so.5", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 open("/lib64/liblzma.so.5", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/liblzma.so.5.2.2>
10331 read(3</usr/lib64/liblzma.so.5.2.2>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\2000\0\0\0\0\0\0@\0\0\0\0\0\0\0\360_\2\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0<@\2\0\0\0\0\0<@\2\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/liblzma.so.5.2.2>, {st_mode=S_IFREG|0755, st_size=157424, ...}) = 0
10331 mmap(NULL, 2249352, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/liblzma.so.5.2.2>, 0) = 0x7fb0611a2000
10331 mprotect(0x7fb0611c7000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0613c6000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/liblzma.so.5.2.2>, 0x24000) = 0x7fb0613c6000
10331 close(3</usr/lib64/liblzma.so.5.2.2>) = 0
10331 open("/usr/lib64/elfutils/libbz2.so.1", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
10331 open("/lib64/libbz2.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libbz2.so.1.0.6>
10331 read(3</usr/lib64/libbz2.so.1.0.6>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\27\0\0\0\0\0\0@\0\0\0\0\0\0\0`\3\1\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|\353\0\0\0\0\0\0|\353\0\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libbz2.so.1.0.6>, {st_mode=S_IFREG|0755, st_size=68192, ...}) = 0
10331 mmap(NULL, 2162024, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libbz2.so.1.0.6>, 0) = 0x7fb060f92000
10331 mprotect(0x7fb060fa1000, 2093056, PROT_NONE) = 0
10331 mmap(0x7fb0611a0000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libbz2.so.1.0.6>, 0xe000) = 0x7fb0611a0000
10331 close(3</usr/lib64/libbz2.so.1.0.6>) = 0
10331 open("/lib64/libpcre.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib64/libpcre.so.1.2.0>
10331 read(3</usr/lib64/libpcre.so.1.2.0>, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\25\0\0\0\0\0\0@\0\0\0\0\0\0\0\320\34\6\0\0\0\0\0\0\0\0\0@\08\0\7\0@\0\34\0\33\0\1\0\0\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0004\377\5\0\0\0\0\0004\377\5\0\0\0\0\0\0\0 \0\0\0\0\0\1\0\0\0\6\0\0\0"..., 832) = 832
10331 fstat(3</usr/lib64/libpcre.so.1.2.0>, {st_mode=S_IFREG|0755, st_size=402384, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064553000
10331 mmap(NULL, 2494984, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3</usr/lib64/libpcre.so.1.2.0>, 0) = 0x7fb060d30000
10331 mprotect(0x7fb060d90000, 2097152, PROT_NONE) = 0
10331 mmap(0x7fb060f90000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3</usr/lib64/libpcre.so.1.2.0>, 0x60000) = 0x7fb060f90000
10331 close(3</usr/lib64/libpcre.so.1.2.0>) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064552000
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064551000
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064550000
10331 mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06454e000
10331 arch_prctl(ARCH_SET_FS, 0x7fb06454e880) = 0
10331 mprotect(0x7fb063439000, 16384, PROT_READ) = 0
10331 mprotect(0x7fb063071000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb060f90000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0611a0000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0613c6000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0615dc000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0617f4000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0619f9000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb061c20000, 16384, PROT_READ) = 0
10331 mprotect(0x7fb061ec0000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063f25000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0620e6000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb0622ed000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062503000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062749000, 8192, PROT_READ) = 0
10331 mprotect(0x7fb062a4c000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062c51000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb062e59000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063680000, 8192, PROT_READ) = 0
10331 mprotect(0x7fb06388a000, 4096, PROT_READ) = 0
10331 stat("/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned", 0x7ffd7d8fd260) = -1 ENOENT (No such file or directory)
10331 mprotect(0x7fb06413b000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063ade000, 4096, PROT_READ) = 0
10331 mprotect(0x7fb063d1e000, 12288, PROT_READ) = 0
10331 mprotect(0x7fb064341000, 4096, PROT_READ) = 0
10331 stat("/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned", 0x7ffd7d8fd260) = -1 ENOENT (No such file or directory)
10331 mprotect(0x555bdcbf6000, 40960, PROT_READ) = 0
10331 mprotect(0x7fb064564000, 4096, PROT_READ) = 0
10331 munmap(0x7fb06455b000, 29284)     = 0
10331 set_tid_address(0x7fb06454eb50)   = 10331
10331 set_robust_list(0x7fb06454eb60, 24) = 0
10331 rt_sigaction(SIGRTMIN, {sa_handler=0x7fb062e617e0, sa_mask=[], sa_flags=SA_RESTORER|SA_SIGINFO, sa_restorer=0x7fb062e6a6d0}, NULL, 8) = 0
10331 rt_sigaction(SIGRT_1, {sa_handler=0x7fb062e61870, sa_mask=[], sa_flags=SA_RESTORER|SA_RESTART|SA_SIGINFO, sa_restorer=0x7fb062e6a6d0}, NULL, 8) = 0
10331 rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
10331 getrlimit(RLIMIT_STACK, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
10331 statfs("/sys/fs/selinux", 0x7ffd7d8fe4c0) = -1 ENOENT (No such file or directory)
10331 statfs("/selinux", 0x7ffd7d8fe4c0) = -1 ENOENT (No such file or directory)
10331 brk(NULL)                         = 0x555bdea9c000
10331 brk(0x555bdeabd000)               = 0x555bdeabd000
10331 open("/proc/filesystems", O_RDONLY) = 3</proc/filesystems>
10331 fstat(3</proc/filesystems>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064562000
10331 read(3</proc/filesystems>, "nodev\tsysfs\nnodev\trootfs\nnodev\tramfs\nnodev\tbdev\nnodev\tproc\nnodev\tcpuset\nnodev\tcgroup\nnodev\tcgroup2\nnodev\ttmpfs\nnodev\tdevtmpfs\nno"..., 1024) = 427
10331 stat("/etc/sysconfig/64bit_strstr_via_64bit_strstr_sse2_unaligned", 0x7ffd7d8fd9f0) = -1 ENOENT (No such file or directory)
10331 read(3</proc/filesystems>, "", 1024) = 0
10331 close(3</proc/filesystems>)       = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 access("/etc/selinux/config", F_OK) = 0
10331 fcntl(2</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(0</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(1</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(2</dev/pts/2>, F_GETFD)     = 0
10331 getppid()                         = 10329
10331 open("/proc/10329/cmdline", O_RDONLY) = 3</proc/10329/cmdline>
10331 read(3</proc/10329/cmdline>, "strace\0-o\0lvm.strace\0-f\0-s\000128\0", 31) = 31
10331 close(3</proc/10329/cmdline>)     = 0
10331 openat(AT_FDCWD, "/proc/self/fd", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</proc/10331/fd>
10331 getdents(3</proc/10331/fd>, /* 6 entries */, 32768) = 144
10331 getdents(3</proc/10331/fd>, /* 0 entries */, 32768) = 0
10331 close(3</proc/10331/fd>)          = 0
10331 open("/etc/udev/udev.conf", O_RDONLY|O_CLOEXEC) = 3</etc/udev/udev.conf>
10331 fstat(3</etc/udev/udev.conf>, {st_mode=S_IFREG|0644, st_size=49, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064562000
10331 read(3</etc/udev/udev.conf>, "# see udev.conf(5) for details\n\n#udev_log=\"info\"\n", 4096) = 49
10331 read(3</etc/udev/udev.conf>, "", 4096) = 0
10331 close(3</etc/udev/udev.conf>)     = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3</usr/lib/locale/locale-archive>
10331 fstat(3</usr/lib/locale/locale-archive>, {st_mode=S_IFREG|0644, st_size=3485296, ...}) = 0
10331 mmap(NULL, 3485296, PROT_READ, MAP_PRIVATE, 3</usr/lib/locale/locale-archive>, 0) = 0x7fb0609dd000
10331 close(3</usr/lib/locale/locale-archive>) = 0
10331 gettid()                          = 10331
10331 fcntl(0</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(0</dev/pts/2>, F_GETFL)     = 0x8402 (flags O_RDWR|O_APPEND|O_LARGEFILE)
10331 dup(0</dev/pts/2>)                = 3</dev/pts/2>
10331 close(0</dev/pts/2>)              = 0
10331 dup2(3</dev/pts/2>, 0)            = 0</dev/pts/2>
10331 close(3</dev/pts/2>)              = 0
10331 fcntl(0</dev/pts/2>, F_GETFL)     = 0x8402 (flags O_RDWR|O_APPEND|O_LARGEFILE)
10331 fcntl(1</dev/pts/2>, F_GETFD)     = 0
10331 fcntl(1</dev/pts/2>, F_GETFL)     = 0x8402 (flags O_RDWR|O_APPEND|O_LARGEFILE)
10331 dup(1</dev/pts/2>)                = 3</dev/pts/2>
10331 close(1</dev/pts/2>)              = 0
10331 dup2(3</dev/pts/2>, 1)            = 1</dev/pts/2>
10331 close(3</dev/pts/2>)              = 0
10331 fcntl(1</dev/pts/2>, F_GETFL)     = 0x8402 (flags O_RDWR|O_APPEND|O_LARGEFILE)
10331 stat("/etc/lvm", {st_mode=S_IFDIR|0755, st_size=131, ...}) = 0
10331 stat("/etc/lvm/lvm.conf", {st_mode=S_IFREG|0644, st_size=96015, ...}) = 0
10331 stat("/etc/lvm/lvm.conf", {st_mode=S_IFREG|0644, st_size=96015, ...}) = 0
10331 open("/etc/lvm/lvm.conf", O_RDONLY) = 3</etc/lvm/lvm.conf>
10331 brk(NULL)                         = 0x555bdeabd000
10331 brk(0x555bdeae1000)               = 0x555bdeae1000
10331 read(3</etc/lvm/lvm.conf>, "# This is an example configuration file for the LVM2 system.\n# It contains the default settings that would be used if there was "..., 96015) = 96015
10331 write(2</dev/pts/2>, "WARNING: Ignoring duplicate config value: global_filter", 55) = 55
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "WARNING: Ignoring duplicate config value: thin_pool_zero", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(3</etc/lvm/lvm.conf>)       = 0
10331 open("/etc/localtime", O_RDONLY|O_CLOEXEC) = 3</usr/share/zoneinfo/UTC>
10331 fstat(3</usr/share/zoneinfo/UTC>, {st_mode=S_IFREG|0644, st_size=118, ...}) = 0
10331 fstat(3</usr/share/zoneinfo/UTC>, {st_mode=S_IFREG|0644, st_size=118, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064562000
10331 read(3</usr/share/zoneinfo/UTC>, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0UTC\0\0\0TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0UTC\0\0\0\nUTC0\n", 4096) = 118
10331 lseek(3</usr/share/zoneinfo/UTC>, -62, SEEK_CUR) = 56
10331 read(3</usr/share/zoneinfo/UTC>, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0UTC\0\0\0\nUTC0\n", 4096) = 62
10331 close(3</usr/share/zoneinfo/UTC>) = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 uname({sysname="Linux", nodename="ip-70-0-159-14.brbnca.spcsdns.net", ...}) = 0
10331 stat("/etc/lvm/lvmlocal.conf", {st_mode=S_IFREG|0644, st_size=2301, ...}) = 0
10331 stat("/etc/lvm/lvmlocal.conf", {st_mode=S_IFREG|0644, st_size=2301, ...}) = 0
10331 open("/etc/lvm/lvmlocal.conf", O_RDONLY) = 3</etc/lvm/lvmlocal.conf>
10331 read(3</etc/lvm/lvmlocal.conf>, "# This is a local configuration file template for the LVM2 system\n# which should be installed as /etc/lvm/lvmlocal.conf .\n#\n# Re"..., 2301) = 2301
10331 close(3</etc/lvm/lvmlocal.conf>)  = 0
10331 umask(077)                        = 022
10331 stat("/proc", {st_mode=S_IFDIR|0555, st_size=0, ...}) = 0
10331 open("/proc/mounts", O_RDONLY)    = 3</proc/10331/mounts>
10331 fstat(3</proc/10331/mounts>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064562000
10331 read(3</proc/10331/mounts>, "sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0\nproc /proc proc rw,nosuid,nodev,noexec,relatime 0 0\ndevtmpfs /dev devtmpfs "..., 1024) = 1024
10331 close(3</proc/10331/mounts>)      = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 open("/proc/devices", O_RDONLY)   = 3</proc/devices>
10331 fstat(3</proc/devices>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064562000
10331 read(3</proc/devices>, "Character devices:\n  1 mem\n  4 /dev/vc/0\n  4 tty\n  4 ttyS\n  5 /dev/tty\n  5 /dev/console\n  5 /dev/ptmx\n  7 vcs\n 10 misc\n 13 input"..., 1024) = 534
10331 read(3</proc/devices>, "", 1024)  = 0
10331 close(3</proc/devices>)           = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 access("/run/udev/control", F_OK) = 0
10331 stat("/dev", {st_mode=S_IFDIR|0755, st_size=3840, ...}) = 0
10331 open("/dev/urandom", O_RDONLY)    = 3</dev/urandom>
10331 read(3</dev/urandom>, "\267zF\f", 4) = 4
10331 close(3</dev/urandom>)            = 0
10331 open("/proc/meminfo", O_RDONLY|O_CLOEXEC) = 3</proc/meminfo>
10331 fstat(3</proc/meminfo>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb064562000
10331 read(3</proc/meminfo>, "MemTotal:        8167916 kB\nMemFree:          856504 kB\nMemAvailable:    7023536 kB\nBuffers:           72760 kB\nCached:         "..., 1024) = 1024
10331 close(3</proc/meminfo>)           = 0
10331 munmap(0x7fb064562000, 4096)      = 0
10331 getuid()                          = 0
10331 geteuid()                         = 0
10331 brk(NULL)                         = 0x555bdeae1000
10331 brk(0x555bdeb02000)               = 0x555bdeb02000
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Parsing: lvs -vvv", 17) = 17
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Recognised command lvs_general (id 93 / enum 74).", 49) = 49
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/lvm.conf", {st_mode=S_IFREG|0644, st_size=96015, ...}) = 0
10331 stat("/etc/lvm/lvmlocal.conf", {st_mode=S_IFREG|0644, st_size=2301, ...}) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "Setting devices/global_filter to global_filter = [ \"r|/dev/pxd.*|\", \"r|/dev/mapper/pxd.*|\", \"a|.*/|\" ]", 102) = 102
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 access("/run/lvmetad.pid", F_OK)  = 0
10331 write(2</dev/pts/2>, "  ", 2)     = 2
10331 write(2</dev/pts/2>, "WARNING: Not using lvmetad because config setting use_lvmetad=0.", 64) = 64
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "  ", 2)     = 2
10331 write(2</dev/pts/2>, "WARNING: To avoid corruption, rescan devices to make changes visible (pvscan --cache).", 86) = 86
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys/subsystem/block/devices", 0x7ffd7d8fd0c0) = -1 ENOENT (No such file or directory)
10331 stat("/sys/class/block", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Sysfs filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Internal filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Regex filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "LVM type filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Usable device filter initialised (scan_lvs 0).", 46) = 46
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "mpath filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Partitioned filter initialised.", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "MD filter initialised.", 22) = 22
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Composite filter initialised.", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "devices/cache not found in config: defaulting to /etc/lvm/cache/.cache", 70) = 70
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/cache/.cache", 0x7ffd7d8fe0c0) = -1 ENOENT (No such file or directory)
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Persistent filter initialised.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/cache/.cache", 0x7ffd7d8fe1b0) = -1 ENOENT (No such file or directory)
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "metadata/record_lvs_history not found in config: defaulting to 0", 64) = 64
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "DEGRADED MODE. Incomplete RAID LVs will be processed.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Processing command: lvs -vvv", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Command pid: 10331", 18) = 18
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "System ID: ", 11) = 11
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "O_DIRECT will be used", 21) = 21
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "File-based locking selected.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/run/lock/lvm", {st_mode=S_IFDIR|0700, st_size=40, ...}) = 0
10331 access("/run/lock/lvm", R_OK|W_OK|X_OK) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/output_format not found in config: defaulting to basic", 61) = 61
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "log/report_command_log not found in config: defaulting to 0", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/aligned not found in config: defaulting to 1", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/buffered not found in config: defaulting to 1", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/headings not found in config: defaulting to 1", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/separator not found in config: defaulting to  ", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/prefixes not found in config: defaulting to 0", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/quoted not found in config: defaulting to 1", 50) = 50
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/columns_as_rows not found in config: defaulting to 0", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/lvs_sort not found in config: defaulting to vg_name,lv_name", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/lvs_cols_verbose not found in config: defaulting to lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel"..., 257) = 257
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "report/compact_output_cols not found in config: defaulting to ", 62) = 62
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Finding VG info", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys/subsystem/block/devices", 0x7ffd7d8fc900) = -1 ENOENT (No such file or directory)
10331 stat("/sys/class/block", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Sysfs filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Internal filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Regex filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "LVM type filter initialised.", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Usable device filter initialised (scan_lvs 0).", 46) = 46
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "mpath filter initialised.", 25) = 25
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Partitioned filter initialised.", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "MD filter initialised.", 22) = 22
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Composite filter initialised.", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "devices/cache not found in config: defaulting to /etc/lvm/cache/.cache", 70) = 70
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/etc/lvm/cache/.cache", 0x7ffd7d8fd900) = -1 ENOENT (No such file or directory)
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Persistent filter initialised.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Finding devices to scan", 23) = 23
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Creating list of system devices.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys/subsystem", 0x7ffd7d8fd8d0) = -1 ENOENT (No such file or directory)
10331 openat(AT_FDCWD, "/sys/bus", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/bus>
10331 getdents(3</sys/bus>, /* 33 entries */, 32768) = 912
10331 open("/usr/lib64/gconv/gconv-modules.cache", O_RDONLY) = 4</usr/lib64/gconv/gconv-modules.cache>
10331 fstat(4</usr/lib64/gconv/gconv-modules.cache>, {st_mode=S_IFREG|0644, st_size=26254, ...}) = 0
10331 mmap(NULL, 26254, PROT_READ, MAP_SHARED, 4</usr/lib64/gconv/gconv-modules.cache>, 0) = 0x7fb06455c000
10331 close(4</usr/lib64/gconv/gconv-modules.cache>) = 0
10331 futex(0x7fb06343ea80, FUTEX_WAKE_PRIVATE, 2147483647) = 0
10331 getdents(3</sys/bus>, /* 0 entries */, 32768) = 0
10331 close(3</sys/bus>)                = 0
10331 openat(AT_FDCWD, "/sys/class", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/class>
10331 getdents(3</sys/class>, /* 56 entries */, 32768) = 1656
10331 openat(AT_FDCWD, "/sys/class/block", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/class/block>
10331 brk(NULL)                         = 0x555bdeb02000
10331 brk(0x555bdeb24000)               = 0x555bdeb24000
10331 getdents(4</sys/class/block>, /* 28 entries */, 32768) = 720
10331 readlink("/sys/class/block/dm-1", "../../devices/virtual/block/dm-1", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdf", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-10", "../../devices/virtual/block/dm-10", 1024) = 33
10331 stat("/sys/devices/virtual/block/dm-10/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda4", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdd", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/pxd!pxd405564132566284931", "../../devices/virtual/block/pxd!pxd405564132566284931", 1024) = 53
10331 stat("/sys/devices/virtual/block/pxd!pxd405564132566284931/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda2", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/md127", "../../devices/virtual/block/md127", 1024) = 33
10331 stat("/sys/devices/virtual/block/md127/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-8", "../../devices/virtual/block/dm-8", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-8/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdb", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-6", "../../devices/virtual/block/dm-6", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-6/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-4", "../../devices/virtual/block/dm-4", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-4/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-2", "../../devices/virtual/block/dm-2", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-2/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdg", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-11", "../../devices/virtual/block/dm-11", 1024) = 33
10331 stat("/sys/devices/virtual/block/dm-11/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-0", "../../devices/virtual/block/dm-0", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-0/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sde", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda3", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdc1", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-9", "../../devices/virtual/block/dm-9", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-9/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sdc", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda1", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-7", "../../devices/virtual/block/dm-7", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-7/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/sda", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-5", "../../devices/virtual/block/dm-5", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-5/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/class/block/dm-3", "../../devices/virtual/block/dm-3", 1024) = 32
10331 stat("/sys/devices/virtual/block/dm-3/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 getdents(4</sys/class/block>, /* 0 entries */, 32768) = 0
10331 close(4</sys/class/block>)        = 0
10331 getdents(3</sys/class>, /* 0 entries */, 32768) = 0
10331 close(3</sys/class>)              = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>, "MAJOR=8\nMINOR=0\nDEVNAME=sda\nDEVTYPE=disk\n", 4096) = 41
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:0 /dev/sda - new.", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:0", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:0>
10331 fstat(3</run/udev/data/b8:0>, {st_mode=S_IFREG|0644, st_size=371, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:0>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0\nW:512\nI:1504\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 371
10331 read(3</run/udev/data/b8:0>, "", 4096) = 0
10331 close(3</run/udev/data/b8:0>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:0 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0 - new alias.", 74) = 74
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>, "MAJOR=8\nMINOR=1\nDEVNAME=sda1\nDEVTYPE=partition\nPARTN=1\n", 4096) = 55
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:1 /dev/sda1 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:1", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:1>
10331 fstat(3</run/udev/data/b8:1>, {st_mode=S_IFREG|0644, st_size=748, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:1>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1\nS:disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4\nW:500\nI:1617\nE:ID_BUS=scs"..., 4096) = 748
10331 read(3</run/udev/data/b8:1>, "", 4096) = 0
10331 close(3</run/udev/data/b8:1>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:1 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1 - new alias.", 80) = 80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:1 /dev/disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4 - new alias.", 81) = 81
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>, "MAJOR=8\nMINOR=2\nDEVNAME=sda2\nDEVTYPE=partition\nPARTN=2\n", 4096) = 55
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda2", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:2 /dev/sda2 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:2", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:2>
10331 fstat(3</run/udev/data/b8:2>, {st_mode=S_IFREG|0644, st_size=857, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:2>, "S:disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2\nW:499\nI:1810\n"..., 4096) = 857
10331 read(3</run/udev/data/b8:2>, "", 4096) = 0
10331 close(3</run/udev/data/b8:2>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:2 /dev/disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc - new alias.", 93) = 93
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:2 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2 - new alias.", 80) = 80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>, "MAJOR=8\nMINOR=3\nDEVNAME=sda3\nDEVTYPE=partition\nPARTN=3\n", 4096) = 55
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda3", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:3 /dev/sda3 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:3", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:3>
10331 fstat(3</run/udev/data/b8:3>, {st_mode=S_IFREG|0644, st_size=858, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:3>, "S:disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3\nW:501\nI:2019\n"..., 4096) = 858
10331 read(3</run/udev/data/b8:3>, "", 4096) = 0
10331 close(3</run/udev/data/b8:3>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:3 /dev/disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD - new alias.", 93) = 93
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:3 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3 - new alias.", 80) = 80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>, "MAJOR=8\nMINOR=4\nDEVNAME=sda4\nDEVTYPE=partition\nPARTN=4\n", 4096) = 55
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sda4", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:4 /dev/sda4 - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:4", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:4>
10331 fstat(3</run/udev/data/b8:4>, {st_mode=S_IFREG|0644, st_size=859, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:4>, "S:disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4\nW:502\nI:2187\n"..., 4096) = 859
10331 read(3</run/udev/data/b8:4>, "", 4096) = 0
10331 close(3</run/udev/data/b8:4>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:4 /dev/disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW - new alias.", 93) = 93
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:4 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4 - new alias.", 80) = 80
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>, "MAJOR=8\nMINOR=16\nDEVNAME=sdb\nDEVTYPE=disk\n", 4096) = 42
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdb", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:16 /dev/sdb - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:16", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:16>
10331 fstat(3</run/udev/data/b8:16>, {st_mode=S_IFREG|0644, st_size=346, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:16>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0\nW:520\nI:3038\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 346
10331 read(3</run/udev/data/b8:16>, "", 4096) = 0
10331 close(3</run/udev/data/b8:16>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:16 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>, "MAJOR=8\nMINOR=32\nDEVNAME=sdc\nDEVTYPE=disk\n", 4096) = 42
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdc", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:32 /dev/sdc - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:32", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:32>
10331 fstat(3</run/udev/data/b8:32>, {st_mode=S_IFREG|0644, st_size=371, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:32>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0\nW:513\nI:3870\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 371
10331 read(3</run/udev/data/b8:32>, "", 4096) = 0
10331 close(3</run/udev/data/b8:32>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:32 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>, "MAJOR=8\nMINOR=33\nDEVNAME=sdc1\nDEVTYPE=partition\nPARTN=1\nPARTNAME=journal\n", 4096) = 73
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdc1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33 /dev/sdc1 - new.", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/run/udev/data/b8:33", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:33>
10331 fstat(3</run/udev/data/b8:33>, {st_mode=S_IFREG|0644, st_size=744, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:33>, "S:disk/by-partlabel/journal\nS:disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0"..., 4096) = 744
10331 read(3</run/udev/data/b8:33>, "", 4096) = 0
10331 close(3</run/udev/data/b8:33>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-partlabel/journal", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33 /dev/disk/by-partlabel/journal - new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33 /dev/disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6 - new alias.", 86) = 86
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0-part1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:33 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0-part1 - new alias.", 81) = 81
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>, "MAJOR=8\nMINOR=48\nDEVNAME=sdd\nDEVTYPE=disk\n", 4096) = 42
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdd", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:48 /dev/sdd - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:48", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:48>
10331 fstat(3</run/udev/data/b8:48>, {st_mode=S_IFREG|0644, st_size=346, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:48>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0\nW:519\nI:4512\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 346
10331 read(3</run/udev/data/b8:48>, "", 4096) = 0
10331 close(3</run/udev/data/b8:48>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:48 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>, "MAJOR=8\nMINOR=64\nDEVNAME=sde\nDEVTYPE=disk\n", 4096) = 42
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sde", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:64 /dev/sde - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:64", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:64>
10331 fstat(3</run/udev/data/b8:64>, {st_mode=S_IFREG|0644, st_size=668, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:64>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0\nW:511\nI:5158\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"..., 4096) = 668
10331 read(3</run/udev/data/b8:64>, "", 4096) = 0
10331 close(3</run/udev/data/b8:64>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:64 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>, "MAJOR=8\nMINOR=80\nDEVNAME=sdf\nDEVTYPE=disk\n", 4096) = 42
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdf", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:80 /dev/sdf - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:80", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:80>
10331 fstat(3</run/udev/data/b8:80>, {st_mode=S_IFREG|0644, st_size=668, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:80>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0\nW:516\nI:5664\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"..., 4096) = 668
10331 read(3</run/udev/data/b8:80>, "", 4096) = 0
10331 close(3</run/udev/data/b8:80>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:80 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>, "MAJOR=8\nMINOR=96\nDEVNAME=sdg\nDEVTYPE=disk\n", 4096) = 42
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/sdg", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:96 /dev/sdg - new.", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/run/udev/data/b8:96", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:96>
10331 fstat(3</run/udev/data/b8:96>, {st_mode=S_IFREG|0644, st_size=668, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:96>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0\nW:514\nI:6230\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"..., 4096) = 668
10331 read(3</run/udev/data/b8:96>, "", 4096) = 0
10331 close(3</run/udev/data/b8:96>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 8:96 /dev/disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0 - new alias.", 75) = 75
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/pxd!pxd405564132566284931", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/pxd!pxd405564132566284931/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/pxd!pxd405564132566284931/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>
10331 fstat(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>, "MAJOR=252\nMINOR=1\nDEVNAME=pxd/pxd405564132566284931\nDEVTYPE=disk\n", 4096) = 65
10331 read(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/pxd!pxd405564132566284931/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/pxd/pxd405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(252, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 252:1 /dev/pxd/pxd405564132566284931 - new.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/pxd!pxd405564132566284931/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b252:1", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b252:1>
10331 fstat(3</run/udev/data/b252:1>, {st_mode=S_IFREG|0644, st_size=250, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b252:1>, "S:disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8\nW:525\nI:28394815651\nE:ID_FS_TYPE=crypto_LUKS\nE:ID_FS_USAGE=crypto\nE:ID_FS_UU"..., 4096) = 250
10331 read(3</run/udev/data/b252:1>, "", 4096) = 0
10331 close(3</run/udev/data/b252:1>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - new.", 77) = 77
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-0", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-0/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-0/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-0/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-0/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-0/uevent>, "MAJOR=253\nMINOR=0\nDEVNAME=dm-0\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-0/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-0/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-0", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/dm-0 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-0/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:0", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:0>
10331 fstat(3</run/udev/data/b253:0>, {st_mode=S_IFREG|0644, st_size=687, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:0>, "S:centos_bazinga/root\nS:disk/by-id/dm-name-centos_bazinga-root\nS:disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD"..., 4096) = 687
10331 read(3</run/udev/data/b253:0>, "", 4096) = 0
10331 close(3</run/udev/data/b253:0>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/centos_bazinga/root", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/centos_bazinga/root - new alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-name-centos_bazinga-root", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/disk/by-id/dm-name-centos_bazinga-root - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv - new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-uuid/3476a32c-d5c2-49e1-9efb-85238af4bbe5", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/disk/by-uuid/3476a32c-d5c2-49e1-9efb-85238af4bbe5 - new alias.", 83) = 83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/centos_bazinga-root", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:0 /dev/mapper/centos_bazinga-root - new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-1", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-1/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-1/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-1/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-1/uevent>, "MAJOR=253\nMINOR=1\nDEVNAME=dm-1\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-1/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-1/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-1", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/dm-1 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-1/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:1", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:1>
10331 fstat(3</run/udev/data/b253:1>, {st_mode=S_IFREG|0644, st_size=701, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:1>, "S:centos_bazinga/swap\nS:disk/by-id/dm-name-centos_bazinga-swap\nS:disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdg"..., 4096) = 701
10331 read(3</run/udev/data/b253:1>, "", 4096) = 0
10331 close(3</run/udev/data/b253:1>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/centos_bazinga/swap", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/centos_bazinga/swap - new alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-name-centos_bazinga-swap", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/disk/by-id/dm-name-centos_bazinga-swap - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/disk/by-id/dm-uuid-LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs - new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-uuid/72214974-21d6-442e-b60a-e291f8a2bea3", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/disk/by-uuid/72214974-21d6-442e-b60a-e291f8a2bea3 - new alias.", 83) = 83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/centos_bazinga-swap", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:1 /dev/mapper/centos_bazinga-swap - new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-10", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-10/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-10/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-10/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-10/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-10/uevent>, "MAJOR=253\nMINOR=10\nDEVNAME=dm-10\nDEVTYPE=disk\n", 4096) = 46
10331 read(3</sys/devices/virtual/block/dm-10/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-10/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-10", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10 /dev/dm-10 - new.", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-10/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:10", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:10>
10331 fstat(3</run/udev/data/b253:10>, {st_mode=S_IFREG|0644, st_size=582, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:10>, "S:disk/by-id/dm-name-pwx0-405564132566284931_empty_snap\nS:disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4C"..., 4096) = 582
10331 read(3</run/udev/data/b253:10>, "", 4096) = 0
10331 close(3</run/udev/data/b253:10>)  = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10 /dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap - new alias.", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10 /dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me - new alias.", 122) = 122
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me", {st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-405564132566284931_empty_snap", {st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 stat("/dev/mapper/pwx0-405564132566284931_empty_snap", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10 /dev/mapper/pwx0-405564132566284931_empty_snap - new alias.", 76) = 76
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/pwx0/405564132566284931_empty_snap", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 10), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:10 /dev/pwx0/405564132566284931_empty_snap - new alias.", 69) = 69
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-11", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-11/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-11/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-11/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-11/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-11/uevent>, "MAJOR=253\nMINOR=11\nDEVNAME=dm-11\nDEVTYPE=disk\n", 4096) = 46
10331 read(3</sys/devices/virtual/block/dm-11/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-11/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-11", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11 /dev/dm-11 - new.", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-11/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:11", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:11>
10331 fstat(3</run/udev/data/b253:11>, {st_mode=S_IFREG|0644, st_size=669, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:11>, "S:disk/by-id/dm-name-pxd-enc405564132566284931\nS:disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc40556413"..., 4096) = 669
10331 read(3</run/udev/data/b253:11>, "", 4096) = 0
10331 close(3</run/udev/data/b253:11>)  = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pxd-enc405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11 /dev/disk/by-id/dm-name-pxd-enc405564132566284931 - new alias.", 79) = 79
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11 /dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931 - new alias.", 124) = 124
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931", {st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pxd-enc405564132566284931", {st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 stat("/dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11 /dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c - new alias.", 84) = 84
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...}) = 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/632025b7-1cd8-4dc5-91c9-f6f94d51379c", {st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pxd-enc405564132566284931", {st_mode=S_IFLNK|0777, st_size=11, ...}) = 0
10331 stat("/dev/mapper/pxd-enc405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:11 /dev/mapper/pxd-enc405564132566284931 - new alias.", 67) = 67
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-2", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-2/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-2/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-2/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-2/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-2/uevent>, "MAJOR=253\nMINOR=2\nDEVNAME=dm-2\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-2/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-2/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-2", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/dm-2 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-2/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:2", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:2>
10331 fstat(3</run/udev/data/b253:2>, {st_mode=S_IFREG|0644, st_size=708, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:2>, "S:disk/by-id/dm-name-vgoptdisk-vmoptdisk\nS:disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjI"..., 4096) = 708
10331 read(3</run/udev/data/b253:2>, "", 4096) = 0
10331 close(3</run/udev/data/b253:2>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE - new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id/dm-uuid-LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186 - new alias.", 83) = 83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...}) = 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/f584da8c-5a37-490a-83eb-711fb1401186", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgoptdisk-vmoptdisk", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/mapper/vgoptdisk-vmoptdisk", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/mapper/vgoptdisk-vmoptdisk - new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/vgoptdisk/vmoptdisk", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:2 /dev/vgoptdisk/vmoptdisk - new alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-3", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-3/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-3/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-3/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-3/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-3/uevent>, "MAJOR=253\nMINOR=3\nDEVNAME=dm-3\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-3/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-3/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-3", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/dm-3 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-3/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:3", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:3>
10331 fstat(3</run/udev/data/b253:3>, {st_mode=S_IFREG|0644, st_size=708, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:3>, "S:disk/by-id/dm-name-vgvardisk-vmvardisk\nS:disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5"..., 4096) = 708
10331 read(3</run/udev/data/b253:3>, "", 4096) = 0
10331 close(3</run/udev/data/b253:3>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-vgvardisk-vmvardisk", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/disk/by-id/dm-name-vgvardisk-vmvardisk - new alias.", 72) = 72
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt - new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id/dm-uuid-LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgvardisk-vmvardisk", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169 - new alias.", 83) = 83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...}) = 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/fddf0ed9-b974-4d69-ab95-8225c0d62169", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-vgvardisk-vmvardisk", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/mapper/vgvardisk-vmvardisk", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/mapper/vgvardisk-vmvardisk - new alias.", 60) = 60
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/vgvardisk/vmvardisk", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:3 /dev/vgvardisk/vmvardisk - new alias.", 53) = 53
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-4", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-4/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-4/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-4/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-4/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-4/uevent>, "MAJOR=253\nMINOR=4\nDEVNAME=dm-4\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-4/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-4/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-4", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:4 /dev/dm-4 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-4/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:4", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:4>
10331 fstat(3</run/udev/data/b253:4>, {st_mode=S_IFREG|0644, st_size=446, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:4>, "S:mapper/pwx0-pxpool_tmeta\nI:1253249\nE:DM_LV_LAYER=\nE:DM_LV_NAME=pxpool_tmeta\nE:DM_NAME=pwx0-pxpool_tmeta\nE:DM_SUSPENDED=0\nE:DM_"..., 4096) = 446
10331 read(3</run/udev/data/b253:4>, "", 4096) = 0
10331 close(3</run/udev/data/b253:4>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool_tmeta", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:4 /dev/mapper/pwx0-pxpool_tmeta - new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-5", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-5/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-5/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-5/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-5/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-5/uevent>, "MAJOR=253\nMINOR=5\nDEVNAME=dm-5\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-5/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-5/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-5", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 5), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:5 /dev/dm-5 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-5/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:5", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:5>
10331 fstat(3</run/udev/data/b253:5>, {st_mode=S_IFREG|0644, st_size=446, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:5>, "S:mapper/pwx0-pxpool_tdata\nI:1254463\nE:DM_LV_LAYER=\nE:DM_LV_NAME=pxpool_tdata\nE:DM_NAME=pwx0-pxpool_tdata\nE:DM_SUSPENDED=0\nE:DM_"..., 4096) = 446
10331 read(3</run/udev/data/b253:5>, "", 4096) = 0
10331 close(3</run/udev/data/b253:5>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool_tdata", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 5), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:5 /dev/mapper/pwx0-pxpool_tdata - new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-6", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-6/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-6/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-6/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-6/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-6/uevent>, "MAJOR=253\nMINOR=6\nDEVNAME=dm-6\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-6/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-6/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-6", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 6), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:6 /dev/dm-6 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-6/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:6", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:6>
10331 fstat(3</run/udev/data/b253:6>, {st_mode=S_IFREG|0644, st_size=445, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:6>, "S:mapper/pwx0-pxpool-tpool\nI:1393315\nE:DM_LV_LAYER=tpool\nE:DM_LV_NAME=pxpool\nE:DM_NAME=pwx0-pxpool-tpool\nE:DM_SUSPENDED=0\nE:DM_U"..., 4096) = 445
10331 read(3</run/udev/data/b253:6>, "", 4096) = 0
10331 close(3</run/udev/data/b253:6>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool-tpool", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 6), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:6 /dev/mapper/pwx0-pxpool-tpool - new alias.", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-7", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-7/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-7/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-7/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-7/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-7/uevent>, "MAJOR=253\nMINOR=7\nDEVNAME=dm-7\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-7/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-7/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-7", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 7), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:7 /dev/dm-7 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-7/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:7", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:7>
10331 fstat(3</run/udev/data/b253:7>, {st_mode=S_IFREG|0644, st_size=427, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:7>, "S:mapper/pwx0-pxpool\nI:1394152\nE:DM_LV_LAYER=\nE:DM_LV_NAME=pxpool\nE:DM_NAME=pwx0-pxpool\nE:DM_SUSPENDED=0\nE:DM_UDEV_DISABLE_DISK_"..., 4096) = 427
10331 read(3</run/udev/data/b253:7>, "", 4096) = 0
10331 close(3</run/udev/data/b253:7>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/mapper/pwx0-pxpool", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 7), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:7 /dev/mapper/pwx0-pxpool - new alias.", 52) = 52
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-8", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-8/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-8/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-8/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-8/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-8/uevent>, "MAJOR=253\nMINOR=8\nDEVNAME=dm-8\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-8/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-8/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-8", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/dm-8 - new.", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-8/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:8", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:8>
10331 fstat(3</run/udev/data/b253:8>, {st_mode=S_IFREG|0644, st_size=659, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:8>, "S:disk/by-id/dm-name-pwx0-pxMetaFS\nS:disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ\nS:d"..., 4096) = 659
10331 read(3</run/udev/data/b253:8>, "", 4096) = 0
10331 close(3</run/udev/data/b253:8>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pwx0-pxMetaFS", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/disk/by-id/dm-name-pwx0-pxMetaFS - new alias.", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ - new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-pxMetaFS", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43 - new alias.", 83) = 83
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...}) = 0
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid/464d0ce4-474d-413b-b520-92cae6a7dd43", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-pxMetaFS", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/mapper/pwx0-pxMetaFS", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/mapper/pwx0-pxMetaFS - new alias.", 54) = 54
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/pwx0/pxMetaFS", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 8), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:8 /dev/pwx0/pxMetaFS - new alias.", 47) = 47
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-9", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/dm-9/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/dm-9/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/dm-9/uevent>
10331 fstat(3</sys/devices/virtual/block/dm-9/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/dm-9/uevent>, "MAJOR=253\nMINOR=9\nDEVNAME=dm-9\nDEVTYPE=disk\n", 4096) = 44
10331 read(3</sys/devices/virtual/block/dm-9/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/dm-9/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/dm-9", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/dm-9 - new alias.", 38) = 38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/dm-9/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b253:9", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b253:9>
10331 fstat(3</run/udev/data/b253:9>, {st_mode=S_IFREG|0644, st_size=735, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b253:9>, "S:disk/by-id/dm-name-pwx0-405564132566284931\nS:disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0f"..., 4096) = 735
10331 read(3</run/udev/data/b253:9>, "", 4096) = 0
10331 close(3</run/udev/data/b253:9>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/dm-name-pwx0-405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/disk/by-id/dm-name-pwx0-405564132566284931 - new alias.", 76) = 76
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id", {st_mode=S_IFDIR|0755, st_size=480, ...}) = 0
10331 lstat("/dev/disk/by-uuid", {st_mode=S_IFDIR|0755, st_size=200, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-405564132566284931", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue - new alias.", 121) = 121
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 lstat("/dev/disk/by-id/dm-uuid-LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 lstat("/dev/disk/by-id/dm-name-pwx0-405564132566284931", {st_mode=S_IFLNK|0777, st_size=10, ...}) = 0
10331 stat("/dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/disk/by-uuid/8fc0fea8-73f7-451d-b757-b3088f4160b8 - exists. ", 81) = 81
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/pwx0-405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/mapper/pwx0-405564132566284931 - new alias.", 64) = 64
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/pwx0/405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 9), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 253:9 /dev/pwx0/405564132566284931 - new alias.", 57) = 57
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/md127", 0x7ffd7d8fcc80, 1024) = -1 EINVAL (Invalid argument)
10331 stat("/sys/devices/virtual/block/md127/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys/devices/virtual/block/md127/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/virtual/block/md127/uevent>
10331 fstat(3</sys/devices/virtual/block/md127/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/virtual/block/md127/uevent>, "MAJOR=9\nMINOR=127\nDEVNAME=md127\nDEVTYPE=disk\n", 4096) = 45
10331 read(3</sys/devices/virtual/block/md127/uevent>, "", 4096) = 0
10331 close(3</sys/devices/virtual/block/md127/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/md127", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/md127 - new.", 33) = 33
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/devices/virtual/block/md127/subsystem", "../../../../class/block", 1024) = 23
10331 open("/run/udev/data/b9:127", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b9:127>
10331 fstat(3</run/udev/data/b9:127>, {st_mode=S_IFREG|0644, st_size=529, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b9:127>, "S:disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT\nS:disk/by-id/md-name-any:pwx0\nS:disk/by-id/md-uuid-eb0177fc:8911"..., 4096) = 529
10331 read(3</run/udev/data/b9:127>, "", 4096) = 0
10331 close(3</run/udev/data/b9:127>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/dev/disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT - new alias.", 95) = 95
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/md-name-any:pwx0", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/disk/by-id/md-name-any:pwx0 - new alias.", 61) = 61
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/disk/by-id/md-uuid-eb0177fc:8911b6f1:2bf4d8b2:877bdfe8", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/disk/by-id/md-uuid-eb0177fc:8911b6f1:2bf4d8b2:877bdfe8 - new alias.", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/md/pwx0", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found dev 9:127 /dev/md/pwx0 - new alias.", 41) = 41
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 brk(NULL)                         = 0x555bdeb24000
10331 brk(NULL)                         = 0x555bdeb24000
10331 brk(0x555bdeb21000)               = 0x555bdeb21000
10331 brk(NULL)                         = 0x555bdeb21000
10331 stat("/sys/dev/block", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:0/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:0/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-0/holders>
10331 getdents(3</sys/devices/virtual/block/dm-0/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-0/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-0/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:1/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/252:1/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>
10331 getdents(3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>, /* 3 entries */, 32768) = 80
10331 uname({sysname="Linux", nodename="ip-70-0-159-14.brbnca.spcsdns.net", ...}) = 0
10331 open("/proc/devices", O_RDONLY)   = 4</proc/devices>
10331 fstat(4</proc/devices>, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</proc/devices>, "Character devices:\n  1 mem\n  4 /dev/vc/0\n  4 tty\n  4 ttyS\n  5 /dev/tty\n  5 /dev/console\n  5 /dev/ptmx\n  7 vcs\n 10 misc\n 13 input"..., 1024) = 534
10331 close(4</proc/devices>)           = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:11/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-11/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-11/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-11/dm/uuid>, "CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931\n", 4096) = 71
10331 close(4</sys/devices/virtual/block/dm-11/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/pxd!pxd405564132566284931/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:1/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-1/holders>
10331 getdents(3</sys/devices/virtual/block/dm-1/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-1/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-1/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:2/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>, /* 4 entries */, 32768) = 96
10331 open("/sys/dev/block/253:1/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-1/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-1/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-1/dm/uuid>, "LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-1/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:0/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-0/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-0/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-0/dm/uuid>, "LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-0/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:2/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-2/holders>
10331 getdents(3</sys/devices/virtual/block/dm-2/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-2/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-2/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:3/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>, /* 3 entries */, 32768) = 72
10331 open("/sys/dev/block/253:3/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-3/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-3/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-3/dm/uuid>, "LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-3/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:3/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-3/holders>
10331 getdents(3</sys/devices/virtual/block/dm-3/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-3/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-3/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:4/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>, /* 3 entries */, 32768) = 72
10331 open("/sys/dev/block/253:2/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-2/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-2/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-2/dm/uuid>, "LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-2/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:4/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-4/holders>
10331 getdents(3</sys/devices/virtual/block/dm-4/holders>, /* 3 entries */, 32768) = 72
10331 open("/sys/dev/block/253:6/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-6/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-6/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-6/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool\n", 4096) = 75
10331 close(4</sys/devices/virtual/block/dm-6/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:4/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-4/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-4/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-4/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta\n", 4096) = 75
10331 close(4</sys/devices/virtual/block/dm-4/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/dm-4/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-4/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:5/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-5/holders>
10331 getdents(3</sys/devices/virtual/block/dm-5/holders>, /* 3 entries */, 32768) = 72
10331 open("/sys/dev/block/253:5/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-5/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-5/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-5/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata\n", 4096) = 75
10331 close(4</sys/devices/virtual/block/dm-5/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/dm-5/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-5/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:6/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-6/holders>
10331 getdents(3</sys/devices/virtual/block/dm-6/holders>, /* 6 entries */, 32768) = 152
10331 open("/sys/dev/block/253:10/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-10/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-10/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-10/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-10/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:8/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-8/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-8/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-8/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-8/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:9/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-9/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-9/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-9/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue\n", 4096) = 69
10331 close(4</sys/devices/virtual/block/dm-9/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/sys/dev/block/253:7/dm/uuid", O_RDONLY) = 4</sys/devices/virtual/block/dm-7/dm/uuid>
10331 fstat(4</sys/devices/virtual/block/dm-7/dm/uuid>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-7/dm/uuid>, "LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool\n", 4096) = 74
10331 close(4</sys/devices/virtual/block/dm-7/dm/uuid>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/devices/virtual/block/dm-6/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-6/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:7/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-7/holders>
10331 getdents(3</sys/devices/virtual/block/dm-7/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-7/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-7/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:8/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-8/holders>
10331 getdents(3</sys/devices/virtual/block/dm-8/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-8/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-8/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:9/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-9/holders>
10331 getdents(3</sys/devices/virtual/block/dm-9/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-9/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-9/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:10/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-10/holders>
10331 getdents(3</sys/devices/virtual/block/dm-10/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-10/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-10/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/253:11/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/dm-11/holders>
10331 getdents(3</sys/devices/virtual/block/dm-11/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/virtual/block/dm-11/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/dm-11/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:16/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:32/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:33/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:48/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:64/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>, /* 3 entries */, 32768) = 80
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:80/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>, /* 3 entries */, 32768) = 80
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/8:96/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>, /* 3 entries */, 32768) = 80
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>) = 0
10331 openat(AT_FDCWD, "/sys/dev/block/9:127/holders/", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/virtual/block/md127/holders>
10331 getdents(3</sys/devices/virtual/block/md127/holders>, /* 4 entries */, 32768) = 96
10331 getdents(3</sys/devices/virtual/block/md127/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/virtual/block/md127/holders>) = 0
10331 openat(AT_FDCWD, "/sys/class/block", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/class/block>
10331 getdents(3</sys/class/block>, /* 28 entries */, 32768) = 720
10331 stat("/sys/class/block/dm-1/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-1/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-1/dev>
10331 fstat(4</sys/devices/virtual/block/dm-1/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-1/dev>, "253:1\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-1/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdf/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdf/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>, "8:80\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-10/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-10/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-10/dev>
10331 fstat(4</sys/devices/virtual/block/dm-10/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-10/dev>, "253:10\n", 4096) = 7
10331 close(4</sys/devices/virtual/block/dm-10/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda4/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda4/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>, "8:4\n", 4096) = 4
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdd/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdd/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>, "8:48\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/pxd!pxd405564132566284931/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/pxd!pxd405564132566284931/dev", O_RDONLY) = 4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>
10331 fstat(4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>, "252:1\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/pxd!pxd405564132566284931/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda2/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda2/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>, "8:2\n", 4096) = 4
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/md127/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/md127/dev", O_RDONLY) = 4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-8/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-8/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-8/dev>
10331 fstat(4</sys/devices/virtual/block/dm-8/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-8/dev>, "253:8\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-8/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdb/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdb/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>, "8:16\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-6/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-6/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-6/dev>
10331 fstat(4</sys/devices/virtual/block/dm-6/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-6/dev>, "253:6\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-6/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-4/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-4/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-4/dev>
10331 fstat(4</sys/devices/virtual/block/dm-4/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-4/dev>, "253:4\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-4/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-2/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-2/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-2/dev>
10331 fstat(4</sys/devices/virtual/block/dm-2/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-2/dev>, "253:2\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-2/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdg/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdg/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>, "8:96\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-11/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-11/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-11/dev>
10331 fstat(4</sys/devices/virtual/block/dm-11/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-11/dev>, "253:11\n", 4096) = 7
10331 close(4</sys/devices/virtual/block/dm-11/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-0/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-0/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-0/dev>
10331 fstat(4</sys/devices/virtual/block/dm-0/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-0/dev>, "253:0\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-0/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sde/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sde/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>, "8:64\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda3/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda3/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>, "8:3\n", 4096) = 4
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdc1/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdc1/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>, "8:33\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-9/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-9/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-9/dev>
10331 fstat(4</sys/devices/virtual/block/dm-9/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-9/dev>, "253:9\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-9/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sdc/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sdc/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>, "8:32\n", 4096) = 5
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda1/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda1/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>, "8:1\n", 4096) = 4
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-7/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-7/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-7/dev>
10331 fstat(4</sys/devices/virtual/block/dm-7/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-7/dev>, "253:7\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-7/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/sda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/sda/dev", O_RDONLY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>, "8:0\n", 4096) = 4
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-5/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-5/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-5/dev>
10331 fstat(4</sys/devices/virtual/block/dm-5/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-5/dev>, "253:5\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-5/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 stat("/sys/class/block/dm-3/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 open("/sys/class/block/dm-3/dev", O_RDONLY) = 4</sys/devices/virtual/block/dm-3/dev>
10331 fstat(4</sys/devices/virtual/block/dm-3/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-3/dev>, "253:3\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/dm-3/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 getdents(3</sys/class/block>, /* 0 entries */, 32768) = 0
10331 close(3</sys/class/block>)        = 0
10331 stat("/dev/sda", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...}) = 0
10331 open("/dev/sda", O_RDONLY|O_DIRECT|O_NOATIME) = 3</dev/sda>
10331 fstat(3</dev/sda>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 0), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/sda>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(3</dev/sda>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:0", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent", O_RDONLY|O_CLOEXEC) = 3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>
10331 fstat(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>, "MAJOR=8\nMINOR=0\nDEVNAME=sda\nDEVTYPE=disk\n", 4096) = 41
10331 read(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>, "", 4096) = 0
10331 close(3</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:0", O_RDONLY|O_CLOEXEC) = 3</run/udev/data/b8:0>
10331 fstat(3</run/udev/data/b8:0>, {st_mode=S_IFREG|0644, st_size=371, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(3</run/udev/data/b8:0>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0\nW:512\nI:1504\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 371
10331 read(3</run/udev/data/b8:0>, "", 4096) = 0
10331 close(3</run/udev/data/b8:0>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/mapper/control", {st_mode=S_IFCHR|0600, st_rdev=makedev(10, 236), ...}) = 0
10331 open("/dev/mapper/control", O_RDWR) = 3</dev/mapper/control>
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm version   [ opencount flush ]   [16384] (*1)", 47) = 47
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_VERSION, {version=4.0.0, data_size=16384, flags=DM_EXISTS_FLAG} => {version=4.39.0, data_size=16384, flags=DM_EXISTS_FLAG}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:0) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 0), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 0), name="centos_bazinga-root", uuid="LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4xUiU5XpD7rVkixiBGoBuPX3dF7DW6dfv", target_count=1, open_count=1, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/centos_bazinga/root: Skipping unusable device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/centos_bazinga/root", 43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 open("/dev/sda1", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda1>
10331 fstat(4</dev/sda1>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 1), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda1 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda1>, BLKGETSIZE64, [1073741824]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda1: size is 2097152 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda1>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda1", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda1: Device is a partition, using primary device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda1", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:1", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>, "MAJOR=8\nMINOR=1\nDEVNAME=sda1\nDEVTYPE=partition\nPARTN=1\n", 4096) = 55
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda1/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:1", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:1>
10331 fstat(4</run/udev/data/b8:1>, {st_mode=S_IFREG|0644, st_size=748, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:1>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part1\nS:disk/by-uuid/7da5e5e1-c59f-4e54-bad8-8b58823917c4\nW:500\nI:1617\nE:ID_BUS=scs"..., 4096) = 748
10331 read(4</run/udev/data/b8:1>, "", 4096) = 0
10331 close(4</run/udev/data/b8:1>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda1", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda1", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pxd/pxd405564132566284931: Skipping (regex)", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/pxd/pxd405564132566284931", 49) = 49
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:1) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 1), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 1), name="centos_bazinga-swap", uuid="LVM-wIL52Hy5cGdro6NBoxEU2cyHuMlLy6I4em1YySdgi2HRzc8FRRewOM5R27Ysk4Cs", target_count=1, open_count=0, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/centos_bazinga/swap: Skipping unusable device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/centos_bazinga/swap", 43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda2", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 open("/dev/sda2", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda2>
10331 fstat(4</dev/sda2>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 2), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda2 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda2>, BLKGETSIZE64, [33284947968]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda2: size is 65009664 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda2>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda2", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda2: Device is a partition, using primary device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda2", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:2", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>, "MAJOR=8\nMINOR=2\nDEVNAME=sda2\nDEVTYPE=partition\nPARTN=2\n", 4096) = 55
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda2/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:2", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:2>
10331 fstat(4</run/udev/data/b8:2>, {st_mode=S_IFREG|0644, st_size=857, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:2>, "S:disk/by-id/lvm-pv-uuid-7uXo7v-X0e4-pPyC-WEwd-fMWr-fvdC-frOPpc\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part2\nW:499\nI:1810\n"..., 4096) = 857
10331 read(4</run/udev/data/b8:2>, "", 4096) = 0
10331 close(4</run/udev/data/b8:2>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda2", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda2", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:2) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 2), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 2), name="vgoptdisk-vmoptdisk", uuid="LVM-9hFnv13mzYrVLHk8wT0gAwofoFXAIuTu0LrNOFMgVKfWfOuE4WrtYDRiYfUUjIqE", target_count=1, open_count=1, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/vgoptdisk/vmoptdisk: Skipping unusable device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/vgoptdisk/vmoptdisk", 43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda3", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 open("/dev/sda3", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda3>
10331 fstat(4</dev/sda3>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 3), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda3 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda3>, BLKGETSIZE64, [21474836992]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda3: size is 41943041 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda3>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda3", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda3: Device is a partition, using primary device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda3", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:3", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>, "MAJOR=8\nMINOR=3\nDEVNAME=sda3\nDEVTYPE=partition\nPARTN=3\n", 4096) = 55
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda3/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:3", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:3>
10331 fstat(4</run/udev/data/b8:3>, {st_mode=S_IFREG|0644, st_size=858, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:3>, "S:disk/by-id/lvm-pv-uuid-YDoDZv-ZbF3-bo3V-CUrB-IjyM-ZRQv-McfMSD\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part3\nW:501\nI:2019\n"..., 4096) = 858
10331 read(4</run/udev/data/b8:3>, "", 4096) = 0
10331 close(4</run/udev/data/b8:3>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda3", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda3", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:3) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 3), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 3), name="vgvardisk-vmvardisk", uuid="LVM-dBeWrO9rCnwbt0TZ2yWofgogWDjrW1ovuvvNFkj6bLoxhhgz1jZcnbkb24G1u5pt", target_count=1, open_count=1, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/vgvardisk/vmvardisk: Skipping unusable device.", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/vgvardisk/vmvardisk", 43) = 43
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sda4", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 open("/dev/sda4", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda4>
10331 fstat(4</dev/sda4>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 4), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sda4 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sda4>, BLKGETSIZE64, [21474836992]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda4: size is 41943041 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sda4>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sda4", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:0", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda", 4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda4: Device is a partition, using primary device sda for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sda4", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:4", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>, "MAJOR=8\nMINOR=4\nDEVNAME=sda4\nDEVTYPE=partition\nPARTN=4\n", 4096) = 55
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/sda4/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:4", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:4>
10331 fstat(4</run/udev/data/b8:4>, {st_mode=S_IFREG|0644, st_size=859, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:4>, "S:disk/by-id/lvm-pv-uuid-a0lFIm-sDIB-VQFz-VWm6-woEd-UWD4-iTxNxW\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:0:0-part4\nW:502\nI:2187\n"..., 4096) = 859
10331 read(4</run/udev/data/b8:4>, "", 4096) = 0
10331 close(4</run/udev/data/b8:4>)     = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sda4", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sda4", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:4) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 4), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 4), name="pwx0-pxpool_tmeta", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta", target_count=1, open_count=1, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tmeta: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dFaBULLJWNHDUAlju20jc24j6Z6e53BIm-tmeta on inter"..., 171) = 171
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tmeta: Skipping unusable device.", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/mapper/pwx0-pxpool_tmeta", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:5) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 5), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 5), name="pwx0-pxpool_tdata", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata", target_count=1, open_count=1, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tdata: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dgo6J7bQkqpMU9sKS9izMjIxxyDIhOUes-tdata on inter"..., 171) = 171
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool_tdata: Skipping unusable device.", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/mapper/pwx0-pxpool_tdata", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:6) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 6), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=431, data_start=312, dev=makedev(253, 6), name="pwx0-pxpool-tpool", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool", target_count=1, open_count=4, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool-tpool: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-tpool on inter"..., 171) = 171
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool-tpool: Skipping unusable device.", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/mapper/pwx0-pxpool-tpool", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:7) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 7), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 7), name="pwx0-pxpool", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool", target_count=1, open_count=0, event_nr=0, flags=DM_READONLY_FLAG|DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool: Reserved uuid LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3debZrrf8qYL9pcdy5yffmGgSUqUvo0n1D-pool on internal LV "..., 158) = 158
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/mapper/pwx0-pxpool: Skipping unusable device.", 50) = 50
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/mapper/pwx0-pxpool", 42) = 42
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:8) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 8), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=368, data_start=312, dev=makedev(253, 8), name="pwx0-pxMetaFS", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3dH04sRLD3EffmVZ1OuyxICQuCJ6A5VqgZ", target_count=1, open_count=1, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pwx0/pxMetaFS: Skipping unusable device.", 45) = 45
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/pwx0/pxMetaFS", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:9) [ noopencount noflush ]   [16384] (*1)", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 9), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=368, data_start=312, dev=makedev(253, 9), name="pwx0-405564132566284931", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3d39rXtL1w72zY3pqjn346I1LS0fqafxue", target_count=1, open_count=0, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pwx0/405564132566284931: Skipping unusable device.", 55) = 55
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/pwx0/405564132566284931", 47) = 47
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:10) [ noopencount noflush ]   [16384] (*1)", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 10), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=356, data_start=312, dev=makedev(253, 10), name="pwx0-405564132566284931_empty_snap", uuid="LVM-6wvEBdqYjJdyto5ttwuLGM1Dggr2Js3da8acDfYaHXUYl4CeIanK10k0vFfOa3Me", target_count=1, open_count=0, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/pwx0/405564132566284931_empty_snap: Skipping unusable device.", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/pwx0/405564132566284931_empty_snap", 58) = 58
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "dm status   (253:11) [ noopencount noflush ]   [16384] (*1)", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(3</dev/mapper/control>, DM_TABLE_STATUS, {version=4.0.0, data_size=16384, data_start=312, dev=makedev(253, 11), flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG} => {version=4.39.0, data_size=353, data_start=312, dev=makedev(253, 11), name="pxd-enc405564132566284931", uuid="CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc405564132566284931", target_count=1, open_count=0, event_nr=0, flags=DM_EXISTS_FLAG|DM_PERSISTENT_DEV_FLAG|DM_ACTIVE_PRESENT_FLAG|DM_SKIP_BDGET_FLAG|DM_NOFLUSH_FLAG, ...}) = 0
10331 stat("/dev/mapper/pxd-enc405564132566284931", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 open("/dev/mapper/pxd-enc405564132566284931", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/dm-11>
10331 fstat(4</dev/dm-11>, {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 11), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/mapper/pxd-enc405564132566284931 RO O_DIRECT", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/dm-11>, BLKGETSIZE64, [10735321088]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/mapper/pxd-enc405564132566284931: size is 20967424 sectors", 63) = 63
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/dm-11>)              = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/mapper/pxd-enc405564132566284931", 44) = 44
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/mapper/pxd-enc405564132566284931", 65) = 65
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/253:11", "../../devices/virtual/block/dm-11", 1024) = 33
10331 stat("/sys/devices/virtual/block/dm-11/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/virtual/block/dm-11/subsystem", "../../../../class/block", 1024) = 23
10331 open("/sys/devices/virtual/block/dm-11/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/virtual/block/dm-11/uevent>
10331 fstat(4</sys/devices/virtual/block/dm-11/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/dm-11/uevent>, "MAJOR=253\nMINOR=11\nDEVNAME=dm-11\nDEVTYPE=disk\n", 4096) = 46
10331 read(4</sys/devices/virtual/block/dm-11/uevent>, "", 4096) = 0
10331 close(4</sys/devices/virtual/block/dm-11/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b253:11", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b253:11>
10331 fstat(4</run/udev/data/b253:11>, {st_mode=S_IFREG|0644, st_size=669, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b253:11>, "S:disk/by-id/dm-name-pxd-enc405564132566284931\nS:disk/by-id/dm-uuid-CRYPT-LUKS1-8fc0fea873f7451db757b3088f4160b8-pxd-enc40556413"..., 4096) = 669
10331 read(4</run/udev/data/b253:11>, "", 4096) = 0
10331 close(4</run/udev/data/b253:11>)  = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/mapper/pxd-enc405564132566284931", 56) = 56
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/mapper/pxd-enc405564132566284931", 59) = 59
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdb", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...}) = 0
10331 open("/dev/sdb", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdb>
10331 fstat(4</dev/sdb>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 16), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdb RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdb>, BLKGETSIZE64, [34359738368]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdb: size is 67108864 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdb>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdb", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdb/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdb/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdb", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:16", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>, "MAJOR=8\nMINOR=16\nDEVNAME=sdb\nDEVTYPE=disk\n", 4096) = 42
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:1/2:0:1:0/block/sdb/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:16", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:16>
10331 fstat(4</run/udev/data/b8:16>, {st_mode=S_IFREG|0644, st_size=346, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:16>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:1:0\nW:520\nI:3038\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 346
10331 read(4</run/udev/data/b8:16>, "", 4096) = 0
10331 close(4</run/udev/data/b8:16>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdb", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdb", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdc", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...}) = 0
10331 open("/dev/sdc", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdc>
10331 fstat(4</dev/sdc>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 32), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdc RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdc>, BLKGETSIZE64, [26843545600]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdc: size is 52428800 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdc>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdc", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdc/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdc/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdc", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:32", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>, "MAJOR=8\nMINOR=32\nDEVNAME=sdc\nDEVTYPE=disk\n", 4096) = 42
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:32", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:32>
10331 fstat(4</run/udev/data/b8:32>, {st_mode=S_IFREG|0644, st_size=371, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:32>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0\nW:513\nI:3870\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 371
10331 read(4</run/udev/data/b8:32>, "", 4096) = 0
10331 close(4</run/udev/data/b8:32>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdc", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdc", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdc1", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 open("/dev/sdc1", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdc1>
10331 fstat(4</dev/sdc1>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 33), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdc1 RO O_DIRECT", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdc1>, BLKGETSIZE64, [3219128320]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdc1: size is 6287360 sectors", 34) = 34
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdc1>)               = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdc1", 16) = 16
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys//dev/block/8:32", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc", 4095) = 73
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sdc1: Device is a partition, using primary device sdc for mpath component detection", 88) = 88
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdc/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdc/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdc1", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:33", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1", 1024) = 78
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/subsystem", "../../../../../../../../../class/block", 1024) = 38
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>, "MAJOR=8\nMINOR=33\nDEVNAME=sdc1\nDEVTYPE=partition\nPARTN=1\nPARTNAME=journal\n", 4096) = 73
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:2/2:0:2:0/block/sdc/sdc1/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:33", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:33>
10331 fstat(4</run/udev/data/b8:33>, {st_mode=S_IFREG|0644, st_size=744, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:33>, "S:disk/by-partlabel/journal\nS:disk/by-partuuid/189951a5-f3f2-4d17-b3e5-032b0e5cb8d6\nS:disk/by-path/pci-0000:00:10.0-scsi-0:0:2:0"..., 4096) = 744
10331 read(4</run/udev/data/b8:33>, "", 4096) = 0
10331 close(4</run/udev/data/b8:33>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdc1", 28) = 28
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdc1", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdd", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...}) = 0
10331 open("/dev/sdd", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdd>
10331 fstat(4</dev/sdd>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 48), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdd RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdd>, BLKGETSIZE64, [68719476736]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdd: size is 134217728 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdd>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdd", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdd/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdd/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>, /* 2 entries */, 32768) = 48
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdd", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:48", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>, "MAJOR=8\nMINOR=48\nDEVNAME=sdd\nDEVTYPE=disk\n", 4096) = 42
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:3/2:0:3:0/block/sdd/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:48", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:48>
10331 fstat(4</run/udev/data/b8:48>, {st_mode=S_IFREG|0644, st_size=346, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:48>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:3:0\nW:519\nI:4512\nE:ID_BUS=scsi\nE:ID_FS_TYPE=\nE:ID_MODEL=Virtual_disk\nE:ID_MODEL_ENC=Vir"..., 4096) = 346
10331 read(4</run/udev/data/b8:48>, "", 4096) = 0
10331 close(4</run/udev/data/b8:48>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/sdd", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/sdd", 30) = 30
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sde", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...}) = 0
10331 open("/dev/sde", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sde>
10331 fstat(4</dev/sde>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 64), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sde RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sde>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sde: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sde>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sde", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sde/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sde/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>, /* 3 entries */, 32768) = 80
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/holders>) = 0
10331 open("/sys//block/md127/dev", O_RDONLY) = 4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sde", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:64", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>, "MAJOR=8\nMINOR=64\nDEVNAME=sde\nDEVTYPE=disk\n", 4096) = 42
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:4/2:0:4:0/block/sde/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:64", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:64>
10331 fstat(4</run/udev/data/b8:64>, {st_mode=S_IFREG|0644, st_size=668, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:64>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:4:0\nW:511\nI:5158\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"..., 4096) = 668
10331 read(4</run/udev/data/b8:64>, "", 4096) = 0
10331 close(4</run/udev/data/b8:64>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Device /dev/sde is md raid component based on blkid variable in udev db (ID_FS_TYPE=\"linux_raid_member\").", 105) = 105
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "md filter full 0 excluding md component /dev/sde", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sde: Skipping md component device", 38) = 38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sde", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdf", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...}) = 0
10331 open("/dev/sdf", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdf>
10331 fstat(4</dev/sdf>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 80), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdf RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdf>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdf: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdf>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdf", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdf/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdf/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>, /* 3 entries */, 32768) = 80
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/holders>) = 0
10331 open("/sys//block/md127/dev", O_RDONLY) = 4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdf", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:80", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>, "MAJOR=8\nMINOR=80\nDEVNAME=sdf\nDEVTYPE=disk\n", 4096) = 42
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:5/2:0:5:0/block/sdf/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:80", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:80>
10331 fstat(4</run/udev/data/b8:80>, {st_mode=S_IFREG|0644, st_size=668, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:80>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:5:0\nW:516\nI:5664\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"..., 4096) = 668
10331 read(4</run/udev/data/b8:80>, "", 4096) = 0
10331 close(4</run/udev/data/b8:80>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Device /dev/sdf is md raid component based on blkid variable in udev db (ID_FS_TYPE=\"linux_raid_member\").", 105) = 105
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "md filter full 0 excluding md component /dev/sdf", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sdf: Skipping md component device", 38) = 38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sdf", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/sdg", {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...}) = 0
10331 open("/dev/sdg", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sdg>
10331 fstat(4</dev/sdg>, {st_mode=S_IFBLK|0660, st_rdev=makedev(8, 96), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/sdg RO O_DIRECT", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/sdg>, BLKGETSIZE64, [137438953472]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sdg: size is 268435456 sectors", 35) = 35
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/sdg>)                = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/sdg", 15) = 15
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sdg/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sdg/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>, /* 3 entries */, 32768) = 80
10331 getdents(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>, /* 0 entries */, 32768) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/holders>) = 0
10331 open("/sys//block/md127/dev", O_RDONLY) = 4</sys/devices/virtual/block/md127/dev>
10331 fstat(4</sys/devices/virtual/block/md127/dev>, {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/dev>, "9:127\n", 4096) = 6
10331 close(4</sys/devices/virtual/block/md127/dev>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/sdg", 36) = 36
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/8:96", "../../devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg", 1024) = 73
10331 stat("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/subsystem", "../../../../../../../../class/block", 1024) = 35
10331 open("/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>
10331 fstat(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>, "MAJOR=8\nMINOR=96\nDEVNAME=sdg\nDEVTYPE=disk\n", 4096) = 42
10331 read(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>, "", 4096) = 0
10331 close(4</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:6/2:0:6:0/block/sdg/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b8:96", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b8:96>
10331 fstat(4</run/udev/data/b8:96>, {st_mode=S_IFREG|0644, st_size=668, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b8:96>, "S:disk/by-path/pci-0000:00:10.0-scsi-0:0:6:0\nW:514\nI:6230\nE:ID_BUS=scsi\nE:ID_FS_LABEL=any:pwx0\nE:ID_FS_LABEL_ENC=any:pwx0\nE:ID_F"..., 4096) = 668
10331 read(4</run/udev/data/b8:96>, "", 4096) = 0
10331 close(4</run/udev/data/b8:96>)    = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Device /dev/sdg is md raid component based on blkid variable in udev db (ID_FS_TYPE=\"linux_raid_member\").", 105) = 105
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "md filter full 0 excluding md component /dev/sdg", 48) = 48
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sdg: Skipping md component device", 38) = 38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sdg", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/dev/md127", {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 open("/dev/md127", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/md127>
10331 fstat(4</dev/md127>, {st_mode=S_IFBLK|0660, st_rdev=makedev(9, 127), ...}) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Opened /dev/md127 RO O_DIRECT", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 ioctl(4</dev/md127>, BLKGETSIZE64, [411911061504]) = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/md127: size is 804513792 sectors", 37) = 37
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 close(4</dev/md127>)              = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Closed /dev/md127", 17) = 17
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter partitioned deferred /dev/md127", 38) = 38
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 readlink("/sys/dev/block/9:127", "../../devices/virtual/block/md127", 1024) = 33
10331 stat("/sys/devices/virtual/block/md127/uevent", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 readlink("/sys/devices/virtual/block/md127/subsystem", "../../../../class/block", 1024) = 23
10331 open("/sys/devices/virtual/block/md127/uevent", O_RDONLY|O_CLOEXEC) = 4</sys/devices/virtual/block/md127/uevent>
10331 fstat(4</sys/devices/virtual/block/md127/uevent>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/uevent>, "MAJOR=9\nMINOR=127\nDEVNAME=md127\nDEVTYPE=disk\n", 4096) = 45
10331 read(4</sys/devices/virtual/block/md127/uevent>, "", 4096) = 0
10331 close(4</sys/devices/virtual/block/md127/uevent>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 open("/run/udev/data/b9:127", O_RDONLY|O_CLOEXEC) = 4</run/udev/data/b9:127>
10331 fstat(4</run/udev/data/b9:127>, {st_mode=S_IFREG|0644, st_size=529, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</run/udev/data/b9:127>, "S:disk/by-id/lvm-pv-uuid-yVNxXj-s2Bj-7utj-v0R1-6vKP-pxQJ-d9cMOT\nS:disk/by-id/md-name-any:pwx0\nS:disk/by-id/md-uuid-eb0177fc:8911"..., 4096) = 529
10331 read(4</run/udev/data/b9:127>, "", 4096) = 0
10331 close(4</run/udev/data/b9:127>)   = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter md deferred /dev/md127", 29) = 29
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter cache deferred /dev/md127", 32) = 32
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//dev/block/9:127/md/metadata_version", {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 open("/sys//dev/block/9:127/md/metadata_version", O_RDONLY) = 4</sys/devices/virtual/block/md127/md/metadata_version>
10331 fstat(4</sys/devices/virtual/block/md127/md/metadata_version>, {st_mode=S_IFREG|0644, st_size=4096, ...}) = 0
10331 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb06455b000
10331 read(4</sys/devices/virtual/block/md127/md/metadata_version>, "1.2\n", 4096) = 4
10331 close(4</sys/devices/virtual/block/md127/md/metadata_version>) = 0
10331 munmap(0x7fb06455b000, 4096)      = 0
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "Device /dev/md127 metadata_version is 1.2.", 42) = 42
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Found 11 devices to scan", 24) = 24
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 io_setup(256, [0x7fb064549000])   = 0
10331 brk(NULL)                         = 0x555bdeb21000
10331 brk(0x555bdf333000)               = 0x555bdf333000
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Scanning 11 devices for VG info", 31) = 31
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 open("/dev/sda", O_RDONLY|O_DIRECT|O_NOATIME) = 4</dev/sda>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=4</dev/sda>, aio_buf=0x555bdeb12000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sda1", O_RDONLY|O_DIRECT|O_NOATIME) = 5</dev/sda1>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=5</dev/sda1>, aio_buf=0x555bdeb32000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sda2", O_RDONLY|O_DIRECT|O_NOATIME) = 6</dev/sda2>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=6</dev/sda2>, aio_buf=0x555bdeb52000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sda3", O_RDONLY|O_DIRECT|O_NOATIME) = 7</dev/sda3>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=7</dev/sda3>, aio_buf=0x555bdeb72000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sda4", O_RDONLY|O_DIRECT|O_NOATIME) = 8</dev/sda4>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=8</dev/sda4>, aio_buf=0x555bdeb92000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/mapper/pxd-enc405564132566284931", O_RDONLY|O_DIRECT|O_NOATIME) = 9</dev/dm-11> <<<<< HERE IS THE TROUBLE!!!!! OPEN TO READ
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=9</dev/dm-11>, aio_buf=0x555bdebb2000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sdb", O_RDONLY|O_DIRECT|O_NOATIME) = 10</dev/sdb>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=10</dev/sdb>, aio_buf=0x555bdebd2000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sdc", O_RDONLY|O_DIRECT|O_NOATIME) = 11</dev/sdc>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=11</dev/sdc>, aio_buf=0x555bdebf2000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sdc1", O_RDONLY|O_DIRECT|O_NOATIME) = 12</dev/sdc1>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=12</dev/sdc1>, aio_buf=0x555bdec12000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/sdd", O_RDONLY|O_DIRECT|O_NOATIME) = 13</dev/sdd>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=13</dev/sdd>, aio_buf=0x555bdec32000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 open("/dev/md127", O_RDONLY|O_DIRECT|O_NOATIME) = 14</dev/md127>
10331 io_submit(0x7fb064549000, 1, [{aio_lio_opcode=IOCB_CMD_PREAD, aio_fildes=14</dev/md127>, aio_buf=0x555bdec52000, aio_nbytes=131072, aio_offset=0}]) = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Scanning submitted 11 reads", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 io_getevents(0x7fb064549000, 1, 64, [{data=0, obj=0x555bdeb0c588, res=131072, res2=0}, {data=0, obj=0x555bdeb0c5e0, res=131072, res2=0}, {data=0, obj=0x555bdeb0c638, res=131072, res2=0}, {data=0, obj=0x555bdeb0c690, res=131072, res2=0}, {data=0, obj=0x555bdeb0c6e8, res=131072, res2=0}, {data=0, obj=0x555bdeb0c798, res=131072, res2=0}, {data=0, obj=0x555bdeb0c7f0, res=131072, res2=0}, {data=0, obj=0x555bdeb0c8a0, res=131072, res2=0}, {data=0, obj=0x555bdeb0c848, res=131072, res2=0}], NULL) = 9
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Processing data from device /dev/sda 8:0 fd 4 block 0x555bdf312010", 66) = 66
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "Scan filtering /dev/sda", 23) = 23
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda: using cached size 268435456 sectors", 45) = 45
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 stat("/sys//block/sda/holders", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
10331 openat(AT_FDCWD, "/sys//block/sda/holders", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>
10331 getdents(15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 2 entries */, 32768) = 48
10331 getdents(15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>, /* 0 entries */, 32768) = 0
10331 close(15</sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/block/sda/holders>) = 0
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "/dev/sda: Skipping: Partition table signature found", 51) = 51
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "        ", 8) = 8
10331 write(2</dev/pts/2>, "filter caching bad /dev/sda", 27) = 27
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 write(2</dev/pts/2>, "      ", 6) = 6
10331 write(2</dev/pts/2>, "/dev/sda: Not processing filtered", 33) = 33
10331 write(2</dev/pts/2>, "\n", 1)     = 1
10331 io_getevents(0x7fb064549000, 1, 64, [{data=0, obj=0x555bdeb0c8f8, res=131072, res2=0}], NULL) = 1
10331 io_getevents(0x7fb064549000, 1, 64, 0x7ffd7d8fd000, NULL) = -1 EINTR (Interrupted system call)
10331 --- SIGINT {si_signo=SIGINT, si_code=SI_KERNEL} ---

