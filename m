From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 21 Mar 2011 16:29:06 -0500
Subject: [PATCH] fix bugs in temporary mirror layer handling
In-Reply-To: <87pqpmofca.fsf@twilight.int.mornfall.net.>
References: <87pqpmofca.fsf@twilight.int.mornfall.net.>
Message-ID: <704FD0AA-9F6C-4A01-99D5-967730B7F873@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ack

  brassow

On Mar 19, 2011, at 6:33 PM, Petr Rockai wrote:

> Hi,
>
> while working on vgreduce --removemissing --force, I have uncovered
> about half a dozen bugs in handling mirror image removal with  
> temporary
> layers present in the mirror stack.
>
> In some cases, we could end up with a mirrored LV without a MIRRORED
> flag. In other cases, the code could wind up removing wrong number of
> mirrors. In yet other cases, we could remove the right number of
> mirrors, but fail to respect the removal preferences (i.e. keep an  
> image
> that was requested to be removed while removing an image that was
> requested to be kept). Under some circumstances, remove_mirror_images
> could also get stuck in an infinite loop.
>
> I think the proposed version of remove_mirror_images should get  
> through
> all of these above cases correctly. I have tried to explain specific
> problems in the comments in the code.
>
> The patch did not break any tests from the test suite for me. It is a
> prerequisite for vgreduce --removemissing --force, but it also fixes  
> the
> above bugs when triggered in plain lvconvert and in lvconvert -- 
> repair.
>
> Index: lib/metadata/mirror.c
> ===================================================================
> RCS file: /cvs/lvm2/LVM2/lib/metadata/mirror.c,v
> retrieving revision 1.144
> diff -u -p -r1.144 mirror.c
> --- lib/metadata/mirror.c	11 Mar 2011 14:56:56 -0000	1.144
> +++ lib/metadata/mirror.c	19 Mar 2011 23:08:58 -0000
> @@ -779,7 +779,7 @@ static int _remove_mirror_images(struct
> 				 int (*is_removable)(struct logical_volume *, void *),
> 				 void *removable_baton,
> 				 unsigned remove_log, unsigned collapse,
> -				 uint32_t *removed)
> +				 uint32_t *removed, int preferred_only)
> {
> 	uint32_t m;
> 	int32_t s;
> @@ -791,12 +791,13 @@ static int _remove_mirror_images(struct
> 	uint32_t new_area_count = mirrored_seg->area_count;
> 	struct lv_list *lvl;
> 	struct dm_list tmp_orphan_lvs;
> +	int orig_removed = num_removed;
>
> 	if (removed)
> 		*removed = 0;
>
> -	log_very_verbose("Reducing mirror set from %" PRIu32 " to %"
> -			 PRIu32 " image(s)%s.",
> +	log_very_verbose("Reducing mirror set %s from %" PRIu32 " to %"
> +			 PRIu32 " image(s)%s.", lv->name,
> 			 old_area_count, old_area_count - num_removed,
> 			 remove_log ? " and no log volume" : "");
>
> @@ -805,12 +806,14 @@ static int _remove_mirror_images(struct
> 		return 0;
> 	}
>
> +	num_removed = 0;
> +
> 	/* Move removable_pvs to end of array */
> 	for (s = mirrored_seg->area_count - 1;
> -	     s >= 0 && old_area_count - new_area_count < num_removed;
> +	     s >= 0 && old_area_count - new_area_count < orig_removed;
> 	     s--) {
> 		sub_lv = seg_lv(mirrored_seg, s);
> -		if (!is_temporary_mirror_layer(sub_lv) &&
> +		if (!(is_temporary_mirror_layer(sub_lv) &&  
> lv_mirror_count(sub_lv) != 1) &&
> 		    is_removable(sub_lv, removable_baton)) {
> 			/*
> 			 * Check if the user is trying to pull the
> @@ -825,9 +828,13 @@ static int _remove_mirror_images(struct
> 			if (!shift_mirror_images(mirrored_seg, s))
> 				return_0;
> 			new_area_count--;
> +			num_removed ++;
> 		}
> 	}
>
> +	if (!preferred_only)
> +		num_removed = orig_removed;
> +
> 	/*
> 	 * If removable_pvs were specified, then they have been shifted
> 	 * to the end to ensure they are removed.  The remaining balance
> @@ -864,12 +871,19 @@ static int _remove_mirror_images(struct
> 		detached_log_lv = detach_mirror_log(mirrored_seg);
> 		if (!remove_layer_from_lv(lv, temp_layer_lv))
> 			return_0;
> -		lv->status &= ~MIRRORED;
> -		lv->status &= ~MIRROR_NOTSYNCED;
> 		if (collapse && !_merge_mirror_images(lv, &tmp_orphan_lvs)) {
> 			log_error("Failed to add mirror images");
> 			return 0;
> 		}
> +                /*
> +                 * No longer a mirror? Even though new_area_count  
> was 1,
> +                 * _merge_mirror_images may have resulted into lv  
> being still a
> +                 * mirror. Fix up the flags if we only have one  
> image left.
> +                 */
> +                if (lv_mirror_count(lv) == 1) {
> +                    lv->status &= ~MIRRORED;
> +                    lv->status &= ~MIRROR_NOTSYNCED;
> +                }
> 		mirrored_seg = first_seg(lv);
> 		if (remove_log && !detached_log_lv)
> 			detached_log_lv = detach_mirror_log(mirrored_seg);
> @@ -1035,7 +1049,7 @@ static int _remove_mirror_images(struct
> 		*removed = old_area_count - new_area_count;
>
> 	log_very_verbose("%" PRIu32 " image(s) removed from %s",
> -			 old_area_count - num_removed, lv->name);
> +			 old_area_count - new_area_count, lv->name);
>
> 	return 1;
> }
> @@ -1051,6 +1065,9 @@ int remove_mirror_images(struct logical_
> 	uint32_t existing_mirrors = lv_mirror_count(lv);
> 	struct logical_volume *next_lv = lv;
>
> +	int preferred_only = 1;
> +	int retries = 0;
> +
> 	num_removed = existing_mirrors - num_mirrors;
>
> 	/* num_removed can be 0 if the function is called just to remove  
> log */
> @@ -1062,17 +1079,33 @@ int remove_mirror_images(struct logical_
>
> 		if (!_remove_mirror_images(next_lv, removed_once,
> 					   is_removable, removable_baton,
> -					   remove_log, 0, &r))
> +					   remove_log, 0, &r, preferred_only))
> 			return_0;
>
> -		if (r < removed_once) {
> +		if (r < removed_once || !removed_once) {
> 			/* Some mirrors are removed from the temporary mirror,
> 			 * but the temporary layer still exists.
> 			 * Down the stack and retry for remainder. */
> 			next_lv = find_temporary_mirror(next_lv);
> +			if (!next_lv) {
> +				preferred_only = 0;
> +				next_lv = lv;
> +			}
> 		}
>
> 		num_removed -= r;
> +
> +		/*
> +		 * if there are still images to be removed, try again; this is
> +		 * required since some temporary layers may have been reduced
> +		 * to 1, at which point they are made removable, just like
> +		 * normal images
> +		 */
> +		if (!next_lv && !preferred_only && !retries && num_removed) {
> +			++ retries;
> +			preferred_only = 1;
> +		}
> +
> 	} while (next_lv && num_removed);
>
> 	if (num_removed) {
> @@ -1126,7 +1159,7 @@ int collapse_mirrored_lv(struct logical_
>
> 		if (!_remove_mirror_images(mirror_seg->lv,
> 					   mirror_seg->area_count - 1,
> -					   _no_removable_images, NULL, 0, 1, NULL)) {
> +					   _no_removable_images, NULL, 0, 1, NULL, 0)) {
> 			log_error("Failed to release mirror images");
> 			return 0;
> 		}
> @@ -1252,7 +1285,7 @@ int reconfigure_mirror_images(struct lv_
>
> 	r = _remove_mirror_images(mirrored_seg->lv, old_num_mirrors -  
> num_mirrors,
> 				  is_mirror_image_removable, removable_pvs,
> -				  remove_log, 0, NULL);
> +				  remove_log, 0, NULL, 0);
> 	if (!r)
> 		/* Unable to remove bad devices */
> 		return 0;
>
> Yours,
>   Petr
>
> -- 
> id' Ash = Ash; id' Dust = Dust; id' _ = undefined
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


