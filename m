From: Paul B. Henson <henson@acm.org>
Date: Wed, 5 Feb 2014 12:12:06 -0800
Subject: cache support
In-Reply-To: <52F1E9DC.60809@mglug.de>
References: <096101cf2214$d241ed60$76c5c820$@acm.org> <52F1E9DC.60809@mglug.de>
Message-ID: <0a3601cf22ae$8cdd4900$a697db00$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Oliver Rath
> Sent: Tuesday, February 04, 2014 11:36 PM
>
> you can create a cache-device with dm-cache, i.e. /dev/mapper/cache0,
> which consists your underlying disks cached by your ssd.

I investigated that, although I never prototyped it. Using dm-cache directly
involves size calculations and an annoying number of messy manual
operations, I was hoping lvm would hide most of that from the user level and
make it easier to do :).

> cache0, getting the right name for this. As result you get the disk ids
> twice, so you have to filter the ids by lvm.conf.
> 
> @list: Is there a solution for this "doubling" case?

I've deployed lvm on mdraid in the past, specifically on mirrors using the
older metadata format such that each half of the mirror appears to be a pv
on its own. I never fiddled with filters, but somehow lvm figured out that
it should use the /dev/md device for the pv and not the raw /dev/sd
components.

> Alternativly you can use bcache, which needs a "superblock" on both

I looked at bcache, which is relatively easy to use and does match my use
case. However, after hanging out on the mailing list for a while, the
developers didn't seem to reliably respond to postings of crashes or data
corruption or other issues, which made me somewhat leery of deployment in
production. On the device mapper mailing list, the developers seem to
respond to pretty much every question or problem report about dm-cache,
which gives one a little bit more of a warm fuzzy ;).

> enhanceIO (not in standard kernel yet), which caches your device

I took a look at that too, but I'd really prefer something in the mainline
kernel for production deployment.

Thanks much.


