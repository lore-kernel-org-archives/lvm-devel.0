From: Petr Rockai <prockai@redhat.com>
Date: Thu, 14 Oct 2010 21:16:22 +0200
Subject: [patch] Fix for handling simultaneous failure of mirrored-log devices
In-Reply-To: <1287083242.3762.3.camel@hydrogen.msp.redhat.com> (Jonathan
	Brassow's message of "Thu, 14 Oct 2010 14:07:22 -0500")
References: <1287083242.3762.3.camel@hydrogen.msp.redhat.com>
Message-ID: <87eibsfuux.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

we had those changes re-invented when Jon realized that this code
already existed at some point. The below changes correspond to what we
ended up doing to make the code behave correctly. I believe the result
is correct. As Jon mentions, we have a semi-automated test, which I will
try to convert to a fully automated one, but I wouldn't block the patch
on that. It's been sufficiently hand-checked for now.

Green for checking this in.

> Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
Reviewed-by: Petr Rockai <prockai@redhat.com>

Jonathan Brassow <jbrassow@redhat.com> writes:
> Index: LVM2/lib/metadata/lv_manip.c
> ===================================================================
> --- LVM2.orig/lib/metadata/lv_manip.c
> +++ LVM2/lib/metadata/lv_manip.c
> @@ -462,6 +462,15 @@ int replace_lv_with_error_segment(struct
>  	if (!lv_empty(lv))
>  		return_0;
>  
> +	/*
> +	 * Since we are replacing the whatever-was-there with
> +	 * an error segment, we should also clear any flags
> +	 * that suggest it is anything other than "error".
> +	 */
> +	lv->status &= ~MIRRORED;
> +
> +	/* FIXME: Should we bug if we find a log_lv attached? */
> +
>  	if (!lv_add_virtual_segment(lv, 0, len,
>  				    get_segtype_from_string(lv->vg->cmd,
>  							    "error")))
> Index: LVM2/lib/metadata/mirror.c
> ===================================================================
> --- LVM2.orig/lib/metadata/mirror.c
> +++ LVM2/lib/metadata/mirror.c
> @@ -896,18 +896,40 @@ static int _remove_mirror_images(struct 
>  	 */
>  	if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
>  	    (detached_log_lv->status & PARTIAL_LV)) {
> +		struct lv_segment *seg = first_seg(detached_log_lv);
> +
>  		log_very_verbose("%s being removed due to failures",
>  				 detached_log_lv->name);
>  
> +		/*
> +		 * We are going to replace the mirror with an
> +		 * error segment, but before we do, we must remember
> +		 * all of the LVs that must be deleted later (i.e.
> +		 * the sub-lv's)
> +		 */
> +		for (m = 0; m < seg->area_count; m++) {
> +			seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
> +			lv_set_visible(seg_lv(seg, m));
> +			if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
> +						  sizeof(*lvl)))) {
> +				log_error("dm_pool_alloc failed");
> +				return 0;
> +			}
> +			lvl->lv = seg_lv(seg, m);
> +			dm_list_add(&tmp_orphan_lvs, &lvl->list);
> +		}
> +
>  		if (!replace_lv_with_error_segment(detached_log_lv)) {
>  			log_error("Failed error target substitution for %s",
>  				  detached_log_lv->name);
>  			return 0;
>  		}
>  
> -		/*
> -		 * Flush all I/Os held by mirrored log.
> -		 */
> +		if (!vg_write(detached_log_lv->vg)) {
> +			log_error("intermediate VG write failed.");
> +			return 0;
> +		}
> +
>  		if (!suspend_lv(detached_log_lv->vg->cmd,
>  				detached_log_lv)) {
>  			log_error("Failed to suspend %s",
> @@ -915,8 +937,14 @@ static int _remove_mirror_images(struct 
>  			return 0;
>   		}
>  
> -		if (!resume_lv(detached_log_lv->vg->cmd,
> -			       detached_log_lv)) {
> +		if (!vg_commit(detached_log_lv->vg)) {
> +			if (!resume_lv(detached_log_lv->vg->cmd,
> +				       detached_log_lv))
> +				stack;
> +			return_0;
> +		}
> +
> +		if (!resume_lv(detached_log_lv->vg->cmd, detached_log_lv)) {
>  			log_error("Failed to resume %s",
>  				  detached_log_lv->name);
>  			return_0;


