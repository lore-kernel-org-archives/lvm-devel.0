From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 05 Feb 2014 16:09:04 +0100
Subject: naming problem on cached devices
In-Reply-To: <52F20812.8010305@mglug.de>
References: <52F20812.8010305@mglug.de>
Message-ID: <52F25410.1020600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.2.2014 10:44, Oliver Rath napsal(a):
> Hi list,
>
> i have a little problem here using (not only happen on lvm ;-) ) cached
> devices:
>
> I.e. i have a ssd named /dev/ssd and a standard disk /dev/sda1 to be
> cached. If I now create i.e. a device /dev/mapper/cache0 (done by
> dmsetup at the mom) and create there a pv, this pv exists twice (at ssd
> and sda). If I then create a vg based on ssd, this vg exists twice, too.
> This happens i.e. for flashcache device, too.
>
> Is there a mechanism to avoid this doubling in an easy way? I know, you
> can blind out devices with a filter argument in lvm.conf, but maybe
> there are better possibilities.

It's quite tricky - and that's currently the main reason lvm2 insist on using 
only PVs for any use.

While everything has a PV header - LVM does the tricky job to handle
device hierarchy.

It's quite tricky to handle udev notification in way, udev has proper data 
which device is the master device and how we use such in stack.

One you start to create cached lower-lever devices - you get into troubles of 
activation and deactivation order during various system stages.

> There is another interesting case: If i want to cache an *existing* pv,
> is it possiblie to change the *name* of this pv in a vg in a dynamic
> way? I.e. if the vg "myvg" consists on /dev/sdc1, if now i create a
> cache-device /dev/mapper/sdc1_cached, how can i transfer this name into
> myvg instead of the original sdc1? Or is this the wrong question?

Again - this will be handled via lvm2 command for LVs. You'll be able to 
convert any live/active LV to cached LV and also back to uncached. All device 
renaming in metadata will happen in background together with change of table 
layout.

Regards

Zdenek


