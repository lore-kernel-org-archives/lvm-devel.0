From: Petr Rockai <prockai@redhat.com>
Date: Mon, 02 Nov 2009 14:24:45 +0100
Subject: [PATCH 1 of 1] LVM: add split capability
In-Reply-To: <200910302323.n9UNN2nV009157@hydrogen.msp.redhat.com> (Jonathan
	Brassow's message of "Fri, 30 Oct 2009 18:23:02 -0500")
References: <200910302323.n9UNN2nV009157@hydrogen.msp.redhat.com>
Message-ID: <874opdrrdu.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Jonathan Brassow <jbrassow@redhat.com> writes:
> It cleans up the comments and removes the error I made of adding code in the
> first patch that was being removed in the second.  The 'splitmirror' argument
> is changed to 'splitmirrors'.  (splitmirror will still work.)  Man page
> language clean-up.

> Fix bug introduce in the initialization of 'lp->alloc'.

(in lvconvert.c, line ~132)
> -	lp->alloc = ALLOC_INHERIT;
> -	if (arg_count(cmd, alloc_ARG))
> -		lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
> +	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
I don't quite understand this bug (nor the fix; although the original code was
a little weird). However, could you please post it separately and note what the
problem was?

Also, changes like the following (that got interwoven with other changes, so
copying it out here) make the review needlessly harder (since the reviewer has
to check that the change is just superficial).
> -		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
> +		lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
> +		if (!lvl) {

(The rest of the patch is in original order, with inline review comments.)

>  static int _remove_mirror_images(struct logical_volume *lv,
>  				 uint32_t num_removed,
>  				 struct dm_list *removable_pvs,
> -				 unsigned remove_log, unsigned collapse,
> +				 unsigned remove_log,
> +				 unsigned collapse,
> +				 const char *split,
>  				 uint32_t *removed)
>  {
It might be worth considering chopping up this function into a few smaller
pieces, considering how big it has grown, and the huge parameter list. This may
require some refactoring (I haven't checked very closely) and would be probably
best done in a separate (followup, I guess) patch.

>  	uint32_t m;
> @@ -537,13 +542,30 @@ static int _remove_mirror_images(struct 
>  	for (m = new_area_count; m < mirrored_seg->area_count; m++) {
>  		seg_lv(mirrored_seg, m)->status &= ~MIRROR_IMAGE;
>  		lv_set_visible(seg_lv(mirrored_seg, m));
> -		if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl)))) {
> +
> +		if (split) {
> +			remove_seg_from_segs_using_this_lv(seg_lv(mirrored_seg, m),
> +							   mirrored_seg);
> +
> +			sub_lv = seg_lv(mirrored_seg, m);
> +			sub_lv->name = dm_pool_strdup(lv->vg->cmd->mem, split);
> +			if (!sub_lv->name) {
> +				log_error("Unable to rename newly split LV");
> +				return 0;
> +			}
> +
> +			break;
> +		}
> +
> +		lvl = dm_pool_alloc(lv->vg->cmd->mem, sizeof(*lvl));
> +		if (!lvl) {
>  			log_error("lv_list alloc failed");
>  			return 0;
>  		}
Looks reasonable.

>  		lvl->lv = seg_lv(mirrored_seg, m);
>  		dm_list_add(&tmp_orphan_lvs, &lvl->list);
> -		release_lv_segment_area(mirrored_seg, m, mirrored_seg->area_len);
> +		release_lv_segment_area(mirrored_seg, m,
> +					mirrored_seg->area_len);
Again, a superfluous change.

>  		if (!_remove_mirror_images(mirror_seg->lv,
>  					   mirror_seg->area_count - 1,
> -					   NULL, 1, 1, NULL)) {
> +					   NULL, 1, 1, 0, NULL)) {
>  			log_error("Failed to release mirror images");
>  			return 0;
>  		}
This demonstrates the problem with many parameters in _remove_mirror_images:
NULL 1, 1, 0, NULL -- what exactly does that mean? Hard to tell, and even when
you are looking at the prototype, you may need to resort to counting on fingers
to figure which parameter is what. Also, the second-to-last 0 ought to be NULL,
as far as I can tell (in other instances, left out from here, too).

> +int lv_split_mirror_images(struct logical_volume *lv, const char *split_lv_name,
> +			   uint32_t split_count, struct dm_list *removable_pvs)
> +{
> +	int r;
> +
> +	/*
> +	 * FIXME: Need ability to split off more than one mirror leg
> +	 *
> +	 * Right now, we only allow the user to split a single
> +	 * leg off at a time.  In the future, we might allow a
> +	 * 4-way mirror to be split into 2 2-way mirrors, but
> +	 * not right now.
> +	 */
> +	if (split_count != 1) {
> +		log_error("Unable to split more than one leg from a mirror.");
> +		return_0;
> +	}
> +
> +	/* Can't split a mirror that is not in-sync... unless force? */
> +	if (!_mirrored_lv_in_sync(lv)) {
> +		log_error("Unable to split mirror that is not in-sync.");
> +		return_0;
> +	}
> +
> +	/*
> +	 * FIXME: Generate default name when not supplied.
> +	 *
> +	 * If we were going to generate a default name, we would
> +	 * do it here.  Better to wait for a decision on the form
> +	 * of the default name when '--track_deltas' (the ability
> +	 * to merge a split leg back in and only copy the changes)
> +	 * is being implemented.  For now, we force the user to
> +	 * come up with a name for their LV.
> +	 */
> +	r = _remove_mirror_images(lv, split_count,
> +				  removable_pvs, 0, 0,
> +				  split_lv_name, NULL);
> +	if (!r)
> +		return 0;
> +
> +	return 1;
> +}
OK. Basically a safe entrypoint for the _remove_mirror_images for the split
case. It seems the "r" variable and the conditional return 0 could be dropped
in favour of just saying "return _remove_mirror_images" (but that's cosmetics).

[snip documentation and bookkeeping]

> Index: LVM2/tools/lvconvert.c
> ===================================================================
> --- LVM2.orig/tools/lvconvert.c
> +++ LVM2/tools/lvconvert.c
> @@ -16,12 +16,16 @@
>  #include "polldaemon.h"
>  #include "lv_alloc.h"
>  
> +#define MIRROR_FLAG_KEEP_IMAGES  0x1
> +#define MIRROR_FLAG_TRACK_DELTAS 0x2
> +
>  struct lvconvert_params {
>  	int snapshot;
>  	int zero;
>  
>  	const char *origin;
>  	const char *lv_name;
> +	const char *lv_split_name;
>  	const char *lv_name_full;
>  	const char *vg_name;
>  	int wait_completion;
> @@ -30,8 +34,10 @@ struct lvconvert_params {
>  	uint32_t chunk_size;
>  	uint32_t region_size;
>  
> +	int track_deltas;
>  	uint32_t mirrors;
>  	sign_t mirrors_sign;
> +	uint32_t mirror_flags;
Hmm, would it make more sense to use mirror_keep_images:1 and
mirror_track_deltas:1 instead of doing the bit-mapping by hand? I think the
code is less error-prone that way, since you need to be a lot less careful
about operator priorities, masking and so on. We don't need to store this
anywhere, so I think any advantages a single variable holding all the flags may
have are moot here.

> +	if (arg_count(cmd, splitmirrors_ARG) && arg_count(cmd, mirrors_ARG)) {
> +		log_error("--mirrors (-m) and --splitmirrors are "
> +			  "mutually exclusive");
> +		return 0;
> +	}
> +
> +	/*
> +	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
> +	 * (note the minus sign), except that it signifies the additional
> +	 * intent to keep the mimage that is detached, rather than
> +	 * discarding it.
> +	 */
> +	if (arg_count(cmd, splitmirrors_ARG)) {
> +		if (!arg_count(cmd, name_ARG)) {
> +			log_error("The split off mirror image requires a name");
> +			return 0;
> +		}
> +
> +		lp->lv_split_name = arg_value(cmd, name_ARG);
> +		if (!apply_lvname_restrictions(lp->lv_split_name))
> +			return_0;
> +
> +		lp->mirror_flags |= MIRROR_FLAG_KEEP_IMAGES;
> +		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
> +			log_error("Argument to --splitmirrors"
> +				  " cannot be negative");
> +			return 0;
> +		}
> +		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
> +		lp->mirrors_sign = SIGN_MINUS;
> +	} else if (arg_count(cmd, name_ARG)) {
> +		log_error("The 'name' argument is only valid"
> +			  " with --splitmirrors");
> +		return 0;
> +	}
> +
>  	if (arg_count(cmd, mirrors_ARG)) {
> +		/*
> +		 * --splitmirrors has been chosen as the mechanism for
> +		 * specifying the intent of detaching and keeping a mimage
> +		 * versus an argument such as '--keep' being added here.
> +		 */
>  		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
>  		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
>  	}
>  

> -	lp->alloc = ALLOC_INHERIT;
> -	if (arg_count(cmd, alloc_ARG))
> -		lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
> +	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
See above near the top of this mail.

[snip]
> @@ -681,10 +726,17 @@ static int _lvconvert_mirrors(struct cmd
>  		/* Reduce number of mirrors */
>  		if (repair || lp->pv_count)
>  			remove_pvs = lp->pvh;
> -		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
> -				       (!log_count || lp->mirrors == 1) ? 1U : 0U,
> -				       remove_pvs, 0))
> +
> +		if (lp->mirror_flags & MIRROR_FLAG_KEEP_IMAGES) {
> +			if (!lv_split_mirror_images(lv, lp->lv_split_name,
> +						    existing_mirrors - lp->mirrors,
> +						    remove_pvs))
> +				return 0;
> +		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
> +					      (!log_count || lp->mirrors == 1) ? 1U : 0U,
> +					      remove_pvs, 0))
>  			return_0;
> +
>  		if (lp->mirrors > 1 &&
>  		    !_lv_update_log_type(cmd, lp, lv, log_count))
>  			return_0;

OK.

Overall, the patch looks OK to me, although I'd probably give it another
iteration to address the mentioned issues (I'd also say that the
_remove_mirror_images refactor I have mentioned is, although quite desirable,
not something that should hold this patch back.)

Yours,
   Petr.


