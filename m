From: Anatoly Pugachev <matorola@gmail.com>
Date: Mon, 21 Aug 2017 15:03:13 +0300
Subject: [xfstests, sparc64] git kernel OOPS 4.13.0-rc5+
In-Reply-To: <CADxRZqyHkwT+HVTQopDZYiAwkCAkBDvPM0eY-Cqw6e5XuzcZ5Q@mail.gmail.com>
References: <CADxRZqykqGycgPh5O9C1F_Eq0J_rP-95zxesDkSDbkLD=04uYA@mail.gmail.com>
	<CADxRZqz_m69YL214tiimqCQ-+pYAvc1UFO_HgvTdKKok0_LzXw@mail.gmail.com>
	<CADxRZqyHkwT+HVTQopDZYiAwkCAkBDvPM0eY-Cqw6e5XuzcZ5Q@mail.gmail.com>
Message-ID: <CADxRZqwe71WZ2=9Xecash65zdk2HmaRffoiCWjwQCHzub3tdvQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 21, 2017 at 1:52 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
> On Mon, Aug 21, 2017 at 1:26 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
>> On Sun, Aug 20, 2017 at 1:02 PM, Anatoly Pugachev <matorola@gmail.com> wrote:
>>>  Hello!
>>>
>>> Running xfstests (git) suite , I'm getting git kernel OOPS :
>>
>> Just tested on debian kernel
>>
>> Linux ttip 4.12.0-1-sparc64-smp #1 SMP Debian 4.12.6-1 (2017-08-12)
>> sparc64 GNU/Linux
>>
>> it does not trigger OOPS, but ends in other way:
>
> well, just compiled v4.12 with gcc-7, it triggers OOPS... going to
> check with gcc-6 now...

git kernel (4.13.0-rc6), compiled with debian gcc-6.4.0 , no kernel OOPS:

xfstests-dev# ./check generic/082
FSTYP         -- xfs (non-debug)
PLATFORM      -- Linux/sparc64 ttip 4.13.0-rc6
MKFS_OPTIONS  -- -f -bsize=4096 /dev/loop0
MOUNT_OPTIONS -- /dev/loop0 /1/scratch

generic/082 2s ... 1s
Ran: generic/082
Passed all 1 tests

kernel/console logs:

[   66.022438] XFS (vdiskb1): Mounting V5 Filesystem
[   66.105236] XFS (vdiskb1): Ending clean mount
[   69.862294] XFS (loop0): Mounting V5 Filesystem
[   69.869785] XFS (loop0): Ending clean mount
[   69.954562] XFS (vdiskb1): Unmounting Filesystem
[   70.243985] XFS (vdiskb1): Mounting V5 Filesystem
[   70.266297] XFS (vdiskb1): Ending clean mount
[   70.381947] run fstests generic/082 at 2017-08-21 14:58:27
[   71.162403] XFS (loop0): Unmounting Filesystem
[   71.409342] XFS (loop0): Mounting V5 Filesystem
[   71.416942] XFS (loop0): Ending clean mount
[   71.418462] XFS (loop0): Quotacheck needed: Please wait.
[   71.423380] XFS (loop0): Quotacheck: Done.
[   71.525841] XFS (loop0): unknown mount option [nosuchopt].
[   71.734429] XFS (vdiskb1): Unmounting Filesystem
[   72.017664] XFS (vdiskb1): Mounting V5 Filesystem
[   72.035156] XFS (vdiskb1): Ending clean mount
[   72.154335] XFS (loop0): Unmounting Filesystem
[   72.525197] XFS (loop0): Mounting V5 Filesystem
[   72.533368] XFS (loop0): resetting quota flags
[   72.533486] XFS (loop0): Ending clean mount
[   72.698356] XFS (vdiskb1): Unmounting Filesystem
[   72.770753] XFS (loop0): Unmounting Filesystem


I wonder how safe to compile kernel with gcc-7, since it is second bug
I found in the kernel, when it's compiled with gcc-7.2.0...


