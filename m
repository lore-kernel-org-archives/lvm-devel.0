From: Oliver Rath <rath@mglug.de>
Date: Wed, 05 Feb 2014 10:44:50 +0100
Subject: naming problem on cached devices
Message-ID: <52F20812.8010305@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

i have a little problem here using (not only happen on lvm ;-) ) cached
devices:

I.e. i have a ssd named /dev/ssd and a standard disk /dev/sda1 to be
cached. If I now create i.e. a device /dev/mapper/cache0 (done by
dmsetup at the mom) and create there a pv, this pv exists twice (at ssd
and sda). If I then create a vg based on ssd, this vg exists twice, too.
This happens i.e. for flashcache device, too.

Is there a mechanism to avoid this doubling in an easy way? I know, you
can blind out devices with a filter argument in lvm.conf, but maybe
there are better possibilities.

There is another interesting case: If i want to cache an *existing* pv,
is it possiblie to change the *name* of this pv in a vg in a dynamic
way? I.e. if the vg "myvg" consists on /dev/sdc1, if now i create a
cache-device /dev/mapper/sdc1_cached, how can i transfer this name into
myvg instead of the original sdc1? Or is this the wrong question?

Tfh!
Oliver




