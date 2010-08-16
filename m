From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Aug 2010 16:55:16 +0100
Subject: [dm-devel] linux-2.6.35+ causes LVM to fail with " device-mapper: version ioctl failed: Inappropriate ioctl for device"
In-Reply-To: <AANLkTik0naaXsicwLgLeBUA0u2+BQQbww-44Fs_cHXHH@mail.gmail.com>
References: <AANLkTime9NS3Bk-8ZpovRNy9iEGJxwYw=-aZ38JoRa_3@mail.gmail.com>
	<20100814155401.GJ26032@agk-dp.fab.redhat.com>
	<AANLkTi=aJ7f5X9sMeA85KJxi+rzWhiZCZ2ZwriNEVFCT@mail.gmail.com>
	<20100815130336.GA24055@agk-dp.fab.redhat.com>
	<AANLkTinUuphqozgrSMNnrKxJrPWFp77y2TzdEwtuMD42@mail.gmail.com>
	<4C6943A0.9030708@redhat.com>
	<20100816142246.GA11907@agk-dp.fab.redhat.com>
	<AANLkTik0naaXsicwLgLeBUA0u2+BQQbww-44Fs_cHXHH@mail.gmail.com>
Message-ID: <20100816155516.GD11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 16, 2010 at 11:32:15PM +0800, Jeff Chua wrote:
> It'll be nice if lvm returns a more meanful message like "ioctl
> failed. Check /proc/misc to ensure the device is mapped correctly."
 
No need - LVM should be quite capable of detecting/dealing with the problem.

> To take care of it automatically with udev, I'm doing this in rc.S
> if [ -f /sys/devices/virtual/misc/device-mapper/dev ]
> then
>         NODE=$(</sys/devices/virtual/misc/device-mapper/dev)
>         rm -f /dev/mapper/control
>         mknod /dev/mapper/control c ${NODE/:/ }

The whole point of this change was to trigger the loading of dm-mod
automatically for people using it as a module, based on using a known
major/minor number instead of a dynamic one only known after the module
has been loaded.  That needs to happen regardless of whether someone is
using udev or not.  

This can all be fixed easily enough in userspace.

Alasdair


