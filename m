From: Petr Rockai <prockai@redhat.com>
Date: Thu, 29 Jul 2010 12:54:15 +0200
Subject: [PATCH] Fix log disk disappear with mirror allocate policy
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228865A8@USINDEVS02.corp.hds.com>
	(Takahiro Yasui's message of "Wed, 28 Jul 2010 19:49:36 -0400")
References: <5C30BE7ED8B03E448B2E104602D4848A59228865A8@USINDEVS02.corp.hds.com>
Message-ID: <874ofi8so8.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Takahiro Yasui <takahiro.yasui@hds.com> writes:
> With mirror_log_fault_policy of 'remove' and mirror_image_fault_policy
> of 'allocate', the log type of the mirror volume is converted from
> 'disk' or 'mirrored' to 'core' when all mirror legs but one in a mirror
> volume broke.
I see.

> --- LVM2-2.02.71.orig/tools/lvconvert.c
> +++ LVM2-2.02.71/tools/lvconvert.c
> @@ -1237,25 +1237,27 @@ static int _lvconvert_mirrors_repair(str
>  	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))
>  		return_0;
>  
> +	log_count = new_log_count;
> +
>  	/*
>  	 * We must adjust the log first, or the entire mirror
>  	 * will get stuck during a suspend.
>  	 */
> -	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, new_log_count))
> +	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, log_count))
>  		return 0;
>  
>  	if (lp->mirrors == 1)
> -		new_log_count = 0;
> +		log_count = 0;
Here we used to overwrite new_log_count which is later used for
restoring the mirror (i.e. when allocating new legs).

>  	if (failed_mirrors) {
>  		if (!lv_remove_mirrors(cmd, lv, failed_mirrors,
> -				       new_log_count ? 0U : 1U,
> +				       log_count ? 0U : 1U,
>  				       _is_partial_lv, NULL, 0))
>  			return 0;
>  	}
>  
>  	if (!_lv_update_log_type(cmd, lp, lv, lp->failed_pvs,
> -				 new_log_count))
> +				 log_count))
>  		return 0;
>  
>  	if (!_reload_lv(cmd, lv))

Ack.

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


