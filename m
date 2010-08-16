From: Jeff Chua <jeff.chua.linux@gmail.com>
Date: Mon, 16 Aug 2010 15:32:34 -0000
Subject: [dm-devel] linux-2.6.35+ causes LVM to fail with " device-mapper: version ioctl failed: Inappropriate ioctl for device"
In-Reply-To: <20100816142246.GA11907@agk-dp.fab.redhat.com>
References: <AANLkTime9NS3Bk-8ZpovRNy9iEGJxwYw=-aZ38JoRa_3@mail.gmail.com>
	<20100814155401.GJ26032@agk-dp.fab.redhat.com>
	<AANLkTi=aJ7f5X9sMeA85KJxi+rzWhiZCZ2ZwriNEVFCT@mail.gmail.com>
	<20100815130336.GA24055@agk-dp.fab.redhat.com>
	<AANLkTinUuphqozgrSMNnrKxJrPWFp77y2TzdEwtuMD42@mail.gmail.com>
	<4C6943A0.9030708@redhat.com>
	<20100816142246.GA11907@agk-dp.fab.redhat.com>
Message-ID: <AANLkTik0naaXsicwLgLeBUA0u2+BQQbww-44Fs_cHXHH@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 16, 2010 at 10:22 PM, Alasdair G Kergon <agk@redhat.com> wrote:
> On Mon, Aug 16, 2010 at 03:56:48PM +0200, Zdenek Kabelac wrote:
>> Dne 15.8.2010 16:13, Jeff Chua napsal(a):
>> > With 2.6.35++, /dev/mapper/control has moved from 60 to 236!
>
> The latest LVM package made an assumption that it would be set up
> correctly by udev (or manually in your case). ?We are updating
> the userspace libdevmapper code to handle your circumstances
> automatically.

It'll be nice if lvm returns a more meanful message like "ioctl
failed. Check /proc/misc to ensure the device is mapped correctly."

To take care of it automatically with udev, I'm doing this in rc.S

if [ -f /sys/devices/virtual/misc/device-mapper/dev ]
then
        NODE=$(</sys/devices/virtual/misc/device-mapper/dev)
        rm -f /dev/mapper/control
        mknod /dev/mapper/control c ${NODE/:/ }
fi


>> > # vgchange -a n vg01
>> > ? Internal error: Maps lock 14217216 < unlock 14221312
>> > ? Internal error: Maps lock 14221312 < unlock 14225408
>> > ? Internal error: Maps lock 14225408 < unlock 14229504
>> > ? Internal error: Maps lock 14229504 < unlock 14233600
>> > ? Internal error: Maps lock 14233600 < unlock 14237696
>> > ? Internal error: Maps lock 14237696 < unlock 14241792
>> > ? 0 logical volume(s) in volume group "vg01" now active
>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d7824370e26325c881b665350ce64fb0a4fde24a
>
> For those interested, originally we used mlockall() but in non-C locales
> on some distributions glibc is configured to map 80MB+ of locale data
> into memory without offering any way to unmap it. ?We don't need
> that data locked and it increased the minimum memory required to install
> a distribution as well as slowing down the LVM tools! ?So we had to
> write a customised version that tries to skip locking unnecessary pages
> like those.

I see that now it's fixed with that commit.

Thanks,
Jeff


