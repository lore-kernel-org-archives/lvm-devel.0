From: Petr Rockai <prockai@redhat.com>
Date: Fri, 02 Jul 2010 11:03:49 +0200
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/comma ...
In-Reply-To: <20100702020959.8357.qmail@sourceware.org> (agk@sourceware.org's
	message of "2 Jul 2010 02:09:59 -0000")
References: <20100702020959.8357.qmail@sourceware.org>
Message-ID: <87aaqai7be.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

agk at sourceware.org writes:
> --- LVM2/lib/commands/toolcontext.c	2010/06/01 21:47:57	1.100
> +++ LVM2/lib/commands/toolcontext.c	2010/07/02 02:09:57	1.101
> @@ -24,6 +24,7 @@
>  #include "filter-md.h"
>  #include "filter-persistent.h"
>  #include "filter-regex.h"
> +#include "filter-suspended.h"
>  #include "filter-sysfs.h"
>  #include "label.h"
>  #include "lvm-file.h"
Have you forgotten to cvs add filter-suspended.[hc]?

> --- LVM2/lib/filters/filter-persistent.c	2010/06/01 19:02:12	1.42
> +++ LVM2/lib/filters/filter-persistent.c	2010/07/02 02:09:57	1.43
> @@ -16,9 +16,11 @@
>  #include "lib.h"
>  #include "config.h"
>  #include "dev-cache.h"
> +#include "filter.h"
>  #include "filter-persistent.h"
>  #include "lvm-file.h"
>  #include "lvm-string.h"
> +#include "activate.h"
>  
>  #include <sys/stat.h>
>  #include <fcntl.h>
> @@ -266,15 +268,31 @@
>  	void *l = dm_hash_lookup(pf->devices, dev_name(dev));
>  	struct str_list *sl;
>  
> +	/* Cached BAD? */
> +	if (l == PF_BAD_DEVICE) {
> +		log_debug("%s: Skipping (cached)", dev_name(dev));
> +		return 0;
> +	}
> +
> +        /* Test dm devices every time, so cache them as GOOD. */
> +	if (MAJOR(dev->dev) == dm_major()) {
> +		if (!l)
> +			dm_list_iterate_items(sl, &dev->aliases)
> +				dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE);
> +		if (ignore_suspended_devices() && !device_is_usable(dev)) {
> +                	log_debug("%s: Skipping (suspended/internal)", dev_name(dev));
> +			return 0;
> +		}
> +		return pf->real->passes_filter(pf->real, dev);
> +	}
> +
> +	/* Uncached */
>  	if (!l) {
> -		l = pf->real->passes_filter(pf->real, dev) ?
> -		    PF_GOOD_DEVICE : PF_BAD_DEVICE;
> +		l = pf->real->passes_filter(pf->real, dev) ?  PF_GOOD_DEVICE : PF_BAD_DEVICE;
>  
>  		dm_list_iterate_items(sl, &dev->aliases)
>  			dm_hash_insert(pf->devices, sl->str, l);
> -
> -	} else if (l == PF_BAD_DEVICE)
> -			log_debug("%s: Skipping (cached)", dev_name(dev));
> +	}
>  
>  	return (l == PF_BAD_DEVICE) ? 0 : 1;
This looks OK and should fix ignore_suspended_devices. On the other
hand, I am not convinced that it helps in Mikul??'s case (RHBZ
598135). In his case, the device would still end up in valid_devices in
the persistent cache and as long as it was just a regular (non-dm) block
device or partition, the appearance of MD metadata could go unnoticed.

On yet another hand, I guess the MD problem is secondary to the deadlock
problem -- the former can only happen in rather special situations and
is fixed by a vgscan.

[snip]

Yours,
   Petr.


