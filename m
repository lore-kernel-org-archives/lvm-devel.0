From: Petr Rockai <prockai@redhat.com>
Date: Wed, 21 Apr 2010 09:49:22 +0200
Subject: [PATCH] Prevent primary image removal from non-sync'ed mirror (bug 581611)
In-Reply-To: <1271816027.18449.24.camel@hydrogen.msp.redhat.com> (Jonathan
	Brassow's message of "Tue, 20 Apr 2010 21:13:47 -0500")
References: <1271816027.18449.24.camel@hydrogen.msp.redhat.com>
Message-ID: <87ochdz1ml.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow <jbrassow@redhat.com> writes:
> Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
Overall OK, please see the inline comments though.

>
> Index: LVM2/lib/metadata/mirror.c
> ===================================================================
> --- LVM2.orig/lib/metadata/mirror.c
> +++ LVM2/lib/metadata/mirror.c
> @@ -516,6 +516,21 @@ static int _move_removable_mimages_to_en
>  	return !count;
>  }
>  
> +static int _mirrored_lv_in_sync(struct logical_volume *lv)
> +{
> +	float sync_percent;
> +	percent_range_t percent_range;
> +
> +	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
> +			       &percent_range, NULL)) {
> +		log_error("Unable to determine mirror sync status of %s/%s.",
> +			  lv->vg->name, lv->name);
> +		return 0;
> +	}
> +
> +	return (percent_range == PERCENT_100) ? 1 : 0;
> +}
> +
>  /*
>   * Split off 'split_count' legs from a mirror
>   *
> @@ -736,7 +751,7 @@ static int _remove_mirror_images(struct 
>  				 uint32_t *removed)
>  {
>  	uint32_t m;
> -	uint32_t s;
> +	int32_t s;
>  	int removable_pvs_specified;
>  	struct logical_volume *sub_lv;
>  	struct logical_volume *detached_log_lv = NULL;
> @@ -766,15 +781,25 @@ static int _remove_mirror_images(struct 
>  
>  	/* Move removable_pvs to end of array */
>  	if (removable_pvs_specified) {
> -		for (s = 0; s < mirrored_seg->area_count &&
> -			    old_area_count - new_area_count < num_removed; s++) {
> +		for (s = mirrored_seg->area_count - 1;
> +		     s >= 0 && old_area_count - new_area_count < num_removed;
> +		     s--) {
>  			sub_lv = seg_lv(mirrored_seg, s);
>  
>  			if (!is_temporary_mirror_layer(sub_lv) &&
>  			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
> +				/*
> +				 * Check if the user is trying to pull the
> +				 * primary mirror image when the mirror is
> +				 * not in-sync.
> +				 */
> +				if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
> +				    !(lv->status & PARTIAL_LV)) {
> +					log_error("Unable to remove primary mirror image while mirror is not in-sync");
I think you should even leave out the lv->status & PARTIAL_LV check. The
story here is that if the mirror is out of sync and the primary device
fails, we can introduce corruption as well. I think it is much better to
refuse the repair in this case. Otherwise, we silently remove the
primary and possibly introduce subtle corruption without any warnings
whatsoever. So a failure here is good for --repair as well, and can
prompt people to repair the mirror manually.

On the other hand, this may interfere with block_on_error, IIUIC. So I
guess the question is, whether it's worse to corrupt data or to lock up
the mirror. If you decide to keep the check in, please add a FIXME
comment noting the above problem. I will try to address that separately
when I am done with the transient error handling.

> +					return_0;
> +				}
>  				if (!shift_mirror_images(mirrored_seg, s))
>  					return_0;
> -				s--; /* adjust counter after shifting */
>  				new_area_count--;
>  			}
>  		}
The changed loop is OK as far as I can tell (and s-- is not required
anymore since the image that is shifted into the current "s" position is
one that's been already checked before).

> @@ -960,21 +985,6 @@ int remove_mirror_images(struct logical_
>  	return 1;
>  }
>  
> -static int _mirrored_lv_in_sync(struct logical_volume *lv)
> -{
> -	float sync_percent;
> -	percent_range_t percent_range;
> -
> -	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
> -			       &percent_range, NULL)) {
> -		log_error("Unable to determine mirror sync status of %s/%s.",
> -			  lv->vg->name, lv->name);
> -		return 0;
> -	}
> -
> -	return (percent_range == PERCENT_100) ? 1 : 0;
> -}
> -
>  /*
>   * Collapsing temporary mirror layers.
>   *
> Index: LVM2/test/t-lvconvert-mirror.sh
> ===================================================================
> --- LVM2.orig/test/t-lvconvert-mirror.sh
> +++ LVM2/test/t-lvconvert-mirror.sh
> @@ -61,10 +61,20 @@ lvcreate -l2 -n $lv1 $vg $dev1
>  not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
>  lvremove -ff $vg
>  
> -lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
> +# Start w/ 3-way mirror
> +# Test pulling primary image before mirror in-sync (should fail)
> +# Test pulling primary image after mirror in-sync (should work)
> +# Test that the correct devices remain in the mirror
> +lvcreate -l8 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
> +# FIXME:
> +#  This is somewhat timing dependent - sync /could/ finish before
> +#  we get a chance to have this command fail
Can the timing problem be fixed by suspending one of the leg devices? I
guess dm-delay would be enough to offset the race as well, but we
probably don't have that either. I guess it's OK for now, there are
other timing-dependent tests in the testsuite. We can try to address
them later. (In this case, something like --synclater would be probably
the right way around.)

> +not lvconvert -m-1 $vg/$lv1 $dev1
> +while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do
> +	sleep 1
> +done
Could this loop be replaced with just "lvconvert $vg/$lv1"? I think that
should do exactly what you need...


>  lvconvert -m-1 $vg/$lv1 $dev1
>  check mirror_images_on $lv1 $dev2 $dev4
>  lvconvert -m-1 $vg/$lv1 $dev2
>  check linear $vg $lv1
>  check lv_on $vg/$lv1 $dev4
> -
> Index: LVM2/test/t-mirror-lvconvert.sh
> ===================================================================
> --- LVM2.orig/test/t-mirror-lvconvert.sh
> +++ LVM2/test/t-mirror-lvconvert.sh
> @@ -98,6 +98,12 @@ wait_conversion_()
>    while (lvs --noheadings -oattr "$lv" | grep -q '^ *c'); do sleep 1; done
>  }
>  
> +wait_sync_()
> +{
> +  local lv=$1
> +  while [ `lvs --noheadings -o copy_percent $lv` != "100.00" ]; do sleep 1; done
> +}
Same as above, re lvconvert $lv.

> +
>  check_no_tmplvs_()
>  {
>    local lv=$1
> @@ -404,6 +410,7 @@ lvcreate -l`pvs --noheadings -ope_count 
>  lvs -a -o+devices $vg
>  check_mirror_count_ $vg/$lv1 2 
>  check_mirror_log_ $vg/$lv1 
> +wait_sync_ $vg/$lv1 # cannot pull primary unless mirror in-sync
>  lvconvert -m0 $vg/$lv1 $dev1 
>  lvs -a -o+devices $vg
>  check_no_tmplvs_ $vg/$lv1 

So I think overall, if you can change the waiting loops in tests (unless
I missed something) and stick a FIXME to the PARTIAL_LV check in
_remove_mirror_images, this is good to check in.

Acked-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


