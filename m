From: Anatoly Pugachev <matorola@gmail.com>
Date: Mon, 21 Aug 2017 13:26:55 +0300
Subject: [xfstests, sparc64] git kernel OOPS 4.13.0-rc5+
In-Reply-To: <CADxRZqykqGycgPh5O9C1F_Eq0J_rP-95zxesDkSDbkLD=04uYA@mail.gmail.com>
References: <CADxRZqykqGycgPh5O9C1F_Eq0J_rP-95zxesDkSDbkLD=04uYA@mail.gmail.com>
Message-ID: <CADxRZqz_m69YL214tiimqCQ-+pYAvc1UFO_HgvTdKKok0_LzXw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Aug 20, 2017 at 1:02 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
>  Hello!
>
> Running xfstests (git) suite , I'm getting git kernel OOPS :

Just tested on debian kernel

Linux ttip 4.12.0-1-sparc64-smp #1 SMP Debian 4.12.6-1 (2017-08-12)
sparc64 GNU/Linux

it does not trigger OOPS, but ends in other way:

# ./check generic/081
FSTYP         -- xfs (non-debug)
PLATFORM      -- Linux/sparc64 ttip 4.12.0-1-sparc64-smp
MKFS_OPTIONS  -- -f -bsize=4096 /dev/loop0
MOUNT_OPTIONS -- /dev/loop0 /1/scratch

generic/081 7s ... 4s
Ran: generic/081
Passed all 1 tests

and kernel/console logs:

[7594425.799817] run fstests generic/081 at 2017-08-21 13:20:52
[7594426.133141] XFS (loop0): Unmounting Filesystem
[7594427.098132] XFS (dm-4): Mounting V5 Filesystem
[7594427.105135] XFS (dm-4): Ending clean mount
[7594427.121110] device-mapper: snapshots: Invalidating snapshot:
Unable to allocate exception.
[7594427.127696] Buffer I/O error on dev dm-4, logical block 20, lost
async page write
[7594427.127714] Buffer I/O error on dev dm-4, logical block 21, lost
async page write
[7594427.127735] Buffer I/O error on dev dm-4, logical block 22, lost
async page write
[7594427.127742] Buffer I/O error on dev dm-4, logical block 23, lost
async page write
[7594427.127755] Buffer I/O error on dev dm-4, logical block 24, lost
async page write
[7594427.127765] Buffer I/O error on dev dm-4, logical block 25, lost
async page write
[7594427.127777] Buffer I/O error on dev dm-4, logical block 26, lost
async page write
[7594427.127787] Buffer I/O error on dev dm-4, logical block 27, lost
async page write
[7594427.127800] Buffer I/O error on dev dm-4, logical block 28, lost
async page write
[7594427.127809] Buffer I/O error on dev dm-4, logical block 29, lost
async page write
[7594427.215857] XFS (dm-4): metadata I/O error: block 0x4002a
("xlog_iodone") error 5 numblks 64
[7594427.215876] XFS (dm-4): xfs_do_force_shutdown(0x2) called from
line 1200 of file /build/linux-3KUWz1/linux-4.12.6/fs/xfs/xfs_log.c.
Return address = 0x0000000010af0640
[7594427.215922] XFS (dm-4): Log I/O Error Detected.  Shutting down filesystem
[7594427.215929] XFS (dm-4): Please umount the filesystem and rectify
the problem(s)
[7594427.248012] VFS:Filesystem freeze failed
[7594427.287516] VFS:Filesystem freeze failed
[7594427.455936] VFS:Filesystem freeze failed
[7594427.587978] VFS:Filesystem freeze failed
[7594427.759826] VFS:Filesystem freeze failed
[7594427.907975] VFS:Filesystem freeze failed
[7594428.079824] VFS:Filesystem freeze failed
[7594428.207978] VFS:Filesystem freeze failed
[7594428.379944] VFS:Filesystem freeze failed
[7594428.418514] VFS:Filesystem freeze failed
[7594429.178337] XFS (dm-4): Unmounting Filesystem
[7594429.749125] XFS (vdiskb1): Unmounting Filesystem
[7594429.923089] XFS (vdiskb1): Mounting V5 Filesystem
[7594429.933437] XFS (vdiskb1): Ending clean mount
[7594430.025109] XFS (vdiskb1): Unmounting Filesystem


