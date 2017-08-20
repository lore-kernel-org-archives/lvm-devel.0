From: Anatoly Pugachev <matorola@gmail.com>
Date: Sun, 20 Aug 2017 13:02:09 +0300
Subject: [xfstests, sparc64] git kernel OOPS 4.13.0-rc5+
Message-ID: <CADxRZqykqGycgPh5O9C1F_Eq0J_rP-95zxesDkSDbkLD=04uYA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 Hello!

Running xfstests (git) suite , I'm getting git kernel OOPS :

Debian GNU/Linux buster/sid ttip console

ttip login: [   32.181114] loop: module loaded
[   73.785279] XFS (vdiskb1): Mounting V5 Filesystem
[   73.800044] XFS (vdiskb1): Starting recovery (logdev: internal)
[   73.804064] XFS (vdiskb1): Ending recovery (logdev: internal)
[   77.527548] XFS (loop0): Mounting V5 Filesystem
[   77.535114] XFS (loop0): Ending clean mount
[   77.644657] XFS (vdiskb1): Unmounting Filesystem
[   77.933610] XFS (vdiskb1): Mounting V5 Filesystem
[   77.948151] XFS (vdiskb1): Ending clean mount
[   78.040921] run fstests generic/081 at 2017-08-20 12:46:15
[   78.780493] XFS (loop0): Unmounting Filesystem
[   80.192977] Unable to handle kernel NULL pointer dereference
[   80.193072] tsk->{mm,active_mm}->context = 00000000000006ce
[   80.193116] tsk->{mm,active_mm}->pgd = fff80040964b8000
[   80.193152]               \|/ ____ \|/
[   80.193152]               "@'/ .. \`@"
[   80.193152]               /_| \__/ |_\
[   80.193152]                  \__U_/
[   80.193232] lvm(1595): Oops [#1]
[   80.193259] CPU: 5 PID: 1595 Comm: lvm Not tainted
4.13.0-rc5-00173-g58d4e450a490 #420
[   80.193307] task: fff800409f410c40 task.stack: fff8004097e4c000
[   80.193346] TSTATE: 0000004411001602 TPC: 00000000004d06e4 TNPC:
00000000004d06e8 Y: 0000016b    Not tainted
[   80.193412] TPC: <lockdep_trace_alloc+0x4/0x140>
[   80.193444] g0: 0000000000c61800 g1: 00000000014000c0 g2:
0000000000000000 g3: 0000000000000000
[   80.193496] g4: 0000000000000000 g5: 0000000000000000 g6:
fff8004097e4c000 g7: 0000000000000000
[   80.193550] o0: 000000010b788020 o1: 0000000000000400 o2:
fff8004096936898 o3: 00000000105ff260
[   80.193603] o4: fff8004096936800 o5: 0000000000000001 sp:
fff8004097e4eae1 ret_pc: 00000000008a1f98
[   80.193664] RPC: <dm_table_add_target+0x298/0x360>
[   80.193697] l0: fff800409f410c40 l1: 00000000010d2ea0 l2:
0000000001555c00 l3: fff800409f4114d0
[   80.193749] l4: 0000000000c61800 l5: 00000000010aaea0 l6:
0000000000db3bf0 l7: 0000000000000050
[   80.193802] i0: 00000000014080c0 i1: 0000000000000100 i2:
0000000000000100 i3: 0000000000000000
[   80.193855] i4: 0000000000000001 i5: 0000000000c61800 i6:
fff8004097e4eb91 i7: 000000000063841c
[   80.193911] I7: <kmem_cache_alloc_trace+0x1c/0x3e0>
[   80.193944] Call Trace:
[   80.193968]  [000000000063841c] kmem_cache_alloc_trace+0x1c/0x3e0
[   80.194011]  [000000000061b318] __get_vm_area_node.isra.5+0x1b8/0x260
[   80.194052]  [000000000061bc98] __vmalloc_node_range+0x58/0x2c0
[   80.194092]  [000000000061c0c0] vzalloc+0x40/0x60
[   80.194125]  [00000000008a0b28] dm_vcalloc+0x28/0x40
[   80.194164]  [00000000105fae58] dm_exception_table_init+0x18/0x80
[dm_snapshot]
[   80.194214]  [00000000105fba78] snapshot_ctr+0x2b8/0x720 [dm_snapshot]
[   80.194255]  [00000000008a1f98] dm_table_add_target+0x298/0x360
[   80.194294]  [00000000008a6448] table_load+0x2c8/0x360
[   80.194330]  [00000000008a70c8] ctl_ioctl+0x348/0x440
[   80.194364]  [00000000008a71d4] dm_ctl_ioctl+0x14/0x40
[   80.194401]  [00000000006754e4] do_vfs_ioctl+0x644/0x6a0
[   80.194437]  [0000000000675590] SyS_ioctl+0x50/0x80
[   80.194473]  [0000000000406234] linux_sparc_syscall+0x34/0x44
[   80.194510] Disabling lock debugging due to kernel taint
[   80.194533] Caller[000000000063841c]: kmem_cache_alloc_trace+0x1c/0x3e0
[   80.194557] Caller[000000000061b318]: __get_vm_area_node.isra.5+0x1b8/0x260
[   80.194581] Caller[000000000061bc98]: __vmalloc_node_range+0x58/0x2c0
[   80.194605] Caller[000000000061c0c0]: vzalloc+0x40/0x60
[   80.194625] Caller[00000000008a0b28]: dm_vcalloc+0x28/0x40
[   80.194647] Caller[00000000105fae58]:
dm_exception_table_init+0x18/0x80 [dm_snapshot]
[   80.194677] Caller[00000000105fba78]: snapshot_ctr+0x2b8/0x720 [dm_snapshot]
[   80.194701] Caller[00000000008a1f98]: dm_table_add_target+0x298/0x360
[   80.194724] Caller[00000000008a6448]: table_load+0x2c8/0x360
[   80.194786] Caller[00000000008a70c8]: ctl_ioctl+0x348/0x440
[   80.194813] Caller[00000000008a71d4]: dm_ctl_ioctl+0x14/0x40
[   80.194839] Caller[00000000006754e4]: do_vfs_ioctl+0x644/0x6a0
[   80.194865] Caller[0000000000675590]: SyS_ioctl+0x50/0x80
[   80.194890] Caller[0000000000406234]: linux_sparc_syscall+0x34/0x44
[   80.194916] Caller[fff80001005e2484]: 0xfff80001005e2484
[   80.194938] Instruction DUMP:
[   80.194942]  01000000
[   80.194958]  01000000
[   80.194972]  9de3bf50
[   80.194986] <c20128b4>
[   80.195000]  80a06000
[   80.195014]  12400048
[   80.195029]  01000000
[   80.195044]  bb520000
[   80.195059]  8217600e
[   80.195073]


steps to reproduce:

git clone https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git
configure && make && make install

xfstests-dev$ cat local.config
export TEST_DIR=/testvol
export TEST_DEV=/dev/vdiskb1
export SCRATCH_DEV_POOL="/dev/loop0 /dev/loop1 /dev/loop2"
export SCRATCH_MNT=/1/scratch

loop devices are in tmpfs:

$ mount tmpfs -t tmpfs -o size=30G /ramdisk
$ for i in 1 2 3; do  fallocate -l 10G /ramdisk/$i; losetup --find
/ramdisk/$i; done

vdiskb1 is xfs filesystem.

kernel OOPS test is generic/081 :

xfstests-dev# ./check generic/081
FSTYP         -- xfs (non-debug)
PLATFORM      -- Linux/sparc64 ttip 4.13.0-rc5-00173-g58d4e450a490
MKFS_OPTIONS  -- -f -bsize=4096 /dev/loop0
MOUNT_OPTIONS -- /dev/loop0 /1/scratch

generic/081 7s ...
(never ends, hangs on kernel OOPS)


