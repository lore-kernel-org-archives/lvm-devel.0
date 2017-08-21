From: Anatoly Pugachev <matorola@gmail.com>
Date: Mon, 21 Aug 2017 15:05:58 +0300
Subject: [xfstests, sparc64] git kernel OOPS 4.13.0-rc5+
In-Reply-To: <CADxRZqwe71WZ2=9Xecash65zdk2HmaRffoiCWjwQCHzub3tdvQ@mail.gmail.com>
References: <CADxRZqykqGycgPh5O9C1F_Eq0J_rP-95zxesDkSDbkLD=04uYA@mail.gmail.com>
	<CADxRZqz_m69YL214tiimqCQ-+pYAvc1UFO_HgvTdKKok0_LzXw@mail.gmail.com>
	<CADxRZqyHkwT+HVTQopDZYiAwkCAkBDvPM0eY-Cqw6e5XuzcZ5Q@mail.gmail.com>
	<CADxRZqwe71WZ2=9Xecash65zdk2HmaRffoiCWjwQCHzub3tdvQ@mail.gmail.com>
Message-ID: <CADxRZqyTse068Pt8xsAyehEJoHA7jQ6vPH4WCVyxrzEjYjpA1Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 21, 2017 at 3:03 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
> On Mon, Aug 21, 2017 at 1:52 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
>> On Mon, Aug 21, 2017 at 1:26 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
>>> On Sun, Aug 20, 2017 at 1:02 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
>>>>  Hello!
>>>>
>>>> Running xfstests (git) suite , I'm getting git kernel OOPS :
>>>
>>> Just tested on debian kernel
>>>
>>> Linux ttip 4.12.0-1-sparc64-smp #1 SMP Debian 4.12.6-1 (2017-08-12)
>>> sparc64 GNU/Linux
>>>
>>> it does not trigger OOPS, but ends in other way:
>>
>> well, just compiled v4.12 with gcc-7, it triggers OOPS... going to
>> check with gcc-6 now...
>
> git kernel (4.13.0-rc6), compiled with debian gcc-6.4.0 , no kernel OOPS:
>
> xfstests-dev# ./check generic/082
> FSTYP         -- xfs (non-debug)
> PLATFORM      -- Linux/sparc64 ttip 4.13.0-rc6
> MKFS_OPTIONS  -- -f -bsize=4096 /dev/loop0
> MOUNT_OPTIONS -- /dev/loop0 /1/scratch
>
> generic/082 2s ... 1s
> Ran: generic/082
> Passed all 1 tests
>
> kernel/console logs:
>
> [   66.022438] XFS (vdiskb1): Mounting V5 Filesystem
> [   66.105236] XFS (vdiskb1): Ending clean mount
> [   69.862294] XFS (loop0): Mounting V5 Filesystem
> [   69.869785] XFS (loop0): Ending clean mount
> [   69.954562] XFS (vdiskb1): Unmounting Filesystem
> [   70.243985] XFS (vdiskb1): Mounting V5 Filesystem
> [   70.266297] XFS (vdiskb1): Ending clean mount
> [   70.381947] run fstests generic/082 at 2017-08-21 14:58:27
> [   71.162403] XFS (loop0): Unmounting Filesystem
> [   71.409342] XFS (loop0): Mounting V5 Filesystem
> [   71.416942] XFS (loop0): Ending clean mount
> [   71.418462] XFS (loop0): Quotacheck needed: Please wait.
> [   71.423380] XFS (loop0): Quotacheck: Done.
> [   71.525841] XFS (loop0): unknown mount option [nosuchopt].
> [   71.734429] XFS (vdiskb1): Unmounting Filesystem
> [   72.017664] XFS (vdiskb1): Mounting V5 Filesystem
> [   72.035156] XFS (vdiskb1): Ending clean mount
> [   72.154335] XFS (loop0): Unmounting Filesystem
> [   72.525197] XFS (loop0): Mounting V5 Filesystem
> [   72.533368] XFS (loop0): resetting quota flags
> [   72.533486] XFS (loop0): Ending clean mount
> [   72.698356] XFS (vdiskb1): Unmounting Filesystem
> [   72.770753] XFS (loop0): Unmounting Filesystem
>
>
> I wonder how safe to compile kernel with gcc-7, since it is second bug
> I found in the kernel, when it's compiled with gcc-7.2.0...


OOPS, should be running generic/081 instead of 082 in my previous
message, but anyway, no OOPS with generic/081:

xfstests-dev# ./check generic/081
FSTYP         -- xfs (non-debug)
PLATFORM      -- Linux/sparc64 ttip 4.13.0-rc6
MKFS_OPTIONS  -- -f -bsize=4096 /dev/loop0
MOUNT_OPTIONS -- /dev/loop0 /1/scratch

generic/081 4s ... 5s
Ran: generic/081
Passed all 1 tests

kernel logs:

[  417.447478] XFS (vdiskb1): Ending clean mount
[  417.535416] run fstests generic/081 at 2017-08-21 15:04:14
[  418.274997] XFS (loop0): Unmounting Filesystem
[  419.929533] XFS (dm-4): Mounting V5 Filesystem
[  419.965193] XFS (dm-4): Ending clean mount
[  420.030845] device-mapper: snapshots: Invalidating snapshot: Unable
to allocate exception.
[  420.062800] Buffer I/O error on dev dm-4, logical block 20, lost
async page write
[  420.062887] Buffer I/O error on dev dm-4, logical block 21, lost
async page write
[  420.063566] Buffer I/O error on dev dm-4, logical block 22, lost
async page write
[  420.063619] Buffer I/O error on dev dm-4, logical block 23, lost
async page write
[  420.063684] Buffer I/O error on dev dm-4, logical block 24, lost
async page write
[  420.063737] Buffer I/O error on dev dm-4, logical block 25, lost
async page write
[  420.063801] Buffer I/O error on dev dm-4, logical block 26, lost
async page write
[  420.063853] Buffer I/O error on dev dm-4, logical block 27, lost
async page write
[  420.063916] Buffer I/O error on dev dm-4, logical block 28, lost
async page write
[  420.063967] Buffer I/O error on dev dm-4, logical block 29, lost
async page write
[  420.074043] XFS (dm-4): metadata I/O error: block 0x4002a
("xlog_iodone") error 5 numblks 64
[  420.074165] XFS (dm-4): xfs_do_force_shutdown(0x2) called from line
1210 of file fs/xfs/xfs_log.c.  Return address = 0x00000000103ee854
[  420.074623] XFS (dm-4): Log I/O Error Detected.  Shutting down filesystem
[  420.074682] XFS (dm-4): Please umount the filesystem and rectify
the problem(s)
[  420.080113] XFS (dm-4): Unmounting Filesystem
[  422.943129] XFS (vdiskb1): Unmounting Filesystem
[  423.227362] XFS (vdiskb1): Mounting V5 Filesystem
[  423.248418] XFS (vdiskb1): Ending clean mount
[  423.394854] XFS (vdiskb1): Unmounting Filesystem


