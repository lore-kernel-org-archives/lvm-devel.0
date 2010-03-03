From: Theodore Ts'o <tytso@mit.edu>
Date: Wed, 03 Mar 2010 09:46:02 -0500
Subject: [REGRESSION] Can't boot lvm on root (Ubuntu 9.10 userspace) with 2.6.33
Message-ID: <E1Nmppq-0000sA-E1@closure.thunk.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The last kernel I could boot was 2.6.33-rc4, so this might be a
regression.   As near as I can tell, this udev rule isn't firing:

SUBSYSTEM=="block", ACTION=="add|change", ENV{ID_FS_TYPE}=="lvm*|LVM*", \
	RUN+="watershed sh -c '/sbin/lvm vgscan; /sbin/lvm vgchange -a y'"

So nothing is showing up in /dev/mapper, and so the root can't be
mounted.  After 45 seconds, it drops me into the initramfs shell, and if
I manually run "lvm vgscan" and "lvm vgscange -ay", everything is back,
but then I can't figure out how to restart the boot process from inside
a failed initramfs.   And of course, the initramfs environment is so
crappy that there are no debugging aids --- not even a working pager.

Did I mention how much I hate the whole initramfs with dynamic udev
rules as a design?

I'll probably kludge some kind of "sleep 10; lvm vgscan ; lvm vgchange
-ay" into some local initramfs script, but it would be nice to know what
happened and what the real right fix should be.  Did anything change
recently that might have caused this to fail?

						- Ted


