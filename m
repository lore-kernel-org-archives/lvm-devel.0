From: tytso@mit.edu <tytso@mit.edu>
Date: Thu, 4 Mar 2010 23:43:05 -0500
Subject: [2.6.33 REGRESSION BUG] Can't boot lvm on root (Ubuntu 9.10 userspace) with 2.6.33
In-Reply-To: <E1Nmppq-0000sA-E1@closure.thunk.org>
References: <E1Nmppq-0000sA-E1@closure.thunk.org>
Message-ID: <20100305044305.GC5747@thunk.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 03, 2010 at 09:46:02AM -0500, Theodore Ts'o wrote:
> 
> The last kernel I could boot was 2.6.33-rc4, so this might be a
> regression.   As near as I can tell, this udev rule isn't firing:
> 
> SUBSYSTEM=="block", ACTION=="add|change", ENV{ID_FS_TYPE}=="lvm*|LVM*", \
> 	RUN+="watershed sh -c '/sbin/lvm vgscan; /sbin/lvm vgchange -a y'"
> 
> So nothing is showing up in /dev/mapper, and so the root can't be
> mounted.  After 45 seconds, it drops me into the initramfs shell, and if
> I manually run "lvm vgscan" and "lvm vgscange -ay", everything is back,
> but then I can't figure out how to restart the boot process from inside
> a failed initramfs.   And of course, the initramfs environment is so
> crappy that there are no debugging aids --- not even a working pager.
> 
> Did I mention how much I hate the whole initramfs with dynamic udev
> rules as a design?

So the workaround I've found for this is to use the magic boot command
line option: 

     break=premount

And then at the initramfs prompt, enter the command "lvm2 vgchange
-ay", followed by control-D.  

Then you'll run into the hal/X11 regression, where I've documented the
workaround I had to use for that.

So I can at least test during the merge window, but it would be nice
if these regressions could get fixed in a real way.

   	 	      	    	      	   - Ted


