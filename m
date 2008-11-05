From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 05 Nov 2008 10:54:24 -0500
Subject: [PATCH] (2/11) various minor cleanups
In-Reply-To: <87wsfq3r91.fsf@eriador.mornfall.net>
References: <87wsfq3r91.fsf@eriador.mornfall.net>
Message-ID: <1225900465.11788.10.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 18:52 +0100, Petr Rockai wrote:
> diff -rN -p -u old-lvmlib-b/lib/device/dev-io.c
> new-lvmlib-b/lib/device/dev-io.c
> --- old-lvmlib-b/lib/device/dev-io.c    2008-10-30 17:43:21.097833255
> +0100
> +++ new-lvmlib-b/lib/device/dev-io.c    2008-10-30 17:43:21.161836711
> +0100
> @@ -622,6 +622,11 @@ int dev_write(struct device *dev, uint64
>         where.start = offset;
>         where.size = len;
>  
> +       if (!vg_write_lock_held()) {
> +               log_error("Attempted to write unlocked VG's device.");
> +               return_0;
> +       }
> +
>         dev->flags |= DEV_ACCESSED_W;
>  
> 

This looks a little strange here but as far as I can tell this is a
reasonable check.  The only command I could think of that might write to
a device without a write VG lock would be vgcfgbackup, but this actually
uses its own IO path (not dev_write()).

Probably want a WHATS_NEW comment like:
Do not allow dev_write() to proceed unless a VG write lock is held.


