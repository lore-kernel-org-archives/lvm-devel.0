From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 15 Aug 2010 14:03:36 +0100
Subject: [dm-devel] linux-2.6.35+ causes LVM to fail with " device-mapper: version ioctl failed: Inappropriate ioctl for device"
In-Reply-To: <AANLkTi=aJ7f5X9sMeA85KJxi+rzWhiZCZ2ZwriNEVFCT@mail.gmail.com>
References: <AANLkTime9NS3Bk-8ZpovRNy9iEGJxwYw=-aZ38JoRa_3@mail.gmail.com>
	<20100814155401.GJ26032@agk-dp.fab.redhat.com>
	<AANLkTi=aJ7f5X9sMeA85KJxi+rzWhiZCZ2ZwriNEVFCT@mail.gmail.com>
Message-ID: <20100815130336.GA24055@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> Just a vanilla linux. No udev.

So likely a userspace problem where udev is now assumed to be present.
 
> > Provide long listing of /dev/mapper and any dm/lvm devices in /dev.

You can do that by running:
  ls -l /dev/mapper /dev/vg01

Also:
  cat /proc/devices
  cat /proc/misc

Alasdair


