From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 15:39:07 -0500
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <87y6ypcn7l.fsf@eriador.mornfall.net>
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
Message-ID: <1229027947.20795.16.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Tue, 2008-12-09 at 17:44 +0100, Petr Rockai wrote:
> diff -rN -p -u old-lvmlib/lib/device/dev-io.c
> new-lvmlib/lib/device/dev-io.c
> --- old-lvmlib/lib/device/dev-io.c      2008-12-09 17:44:06.638398136
> +0100
> +++ new-lvmlib/lib/device/dev-io.c      2008-12-09 17:44:06.930396980
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
>         return _aligned_io(&where, buffer, 1);
> 

Should this be its own patch?  It seems unrelated to the vg_read()
library changes.


