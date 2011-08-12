From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Aug 2011 22:34:52 +0200
Subject: [PATCH] LVM RAID: a couple more fixes
In-Reply-To: <1313169003.27367.6.camel@f14.redhat.com>
References: <1313169003.27367.6.camel@f14.redhat.com>
Message-ID: <4E458E6C.7090309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.8.2011 19:10, Jonathan Brassow napsal(a):
> Patch includes:
> 1) add new function 'raid_remove_top_layer' which will be useful
>  to other conversion functions later (also cleans up code)
> 2) Add error messages if raid_[extract|add]_images fails
> 3) DO NOT activate sub_lv's between a suspend/resume
> 4) Add function prototypes to prevent compiler warnings when
>  compiling with '--with-raid=shared'
> 
> Also, can someone provide insight on removing the 'sleep(1)'?  Without
> it, I get "device in use: cannot deactivate" error messages - even
> though it is /not/ in-use.
> 
>  brassow
> 
> 
> @@ -465,9 +499,17 @@ int lv_raid_change_image_count(struct lo
>  
>  	/*
>  	 * Eliminate the extracted LVs
> +	 * The extracted devices do not take on their new names
> +	 * (i.e. *_extracted) unless we suspend/resume them.  It
> +	 * is not strictly necessary, so we skip that step.
>  	 */
>  	if (!dm_list_empty(&removal_list)) {
>  		dm_list_iterate_items(lvl, &removal_list) {
> +			/*
> +			 * FIXME: Remove 'sleep' that is necessary to prevent
> +			 * "device in use" errors - udev not fast enough?
> +			 */
> +			sleep(1);
>  			if (!deactivate_lv(lv->vg->cmd, lvl->lv))
>  				return_0;
>  			if (!lv_remove(lvl->lv))

I've not checked the rest of this patch - just noticed this very strange sleep
in the code.

You need to take a look at how vgchange is working.

Essentially you need to split this loop in 2 parts - first deactivate all you
can within one  'udev transaction' - then you need to 'synchronize with udev
(sync_local_dev_names() - i.e. see set_lv() in lv_manip.c)
Once udev is finished you may start to lv_remove() devices - this would give
optimal performance.  If you would do that in one loop - there is huge udev
latency penalty - thought you may just try it for test it's really working ;)

Zdenek


