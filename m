From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 10 Feb 2010 16:39:37 -0500 (EST)
Subject: a bug in snapshots
In-Reply-To: <20100210134035.GA8201@redhat.com>
References: <Pine.LNX.4.64.1002091904560.14493@hs20-bc2-1.build.redhat.com>
	<20100210003902.GA7441@redhat.com>
	<Pine.LNX.4.64.1002092053560.3180@hs20-bc2-1.build.redhat.com>
	<20100210040125.GA24479@redhat.com> <20100210134035.GA8201@redhat.com>
Message-ID: <Pine.LNX.4.64.1002101633010.15802@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> Here is what I came up with.  Justification for this approach is
> explained in the dev_manager_snapshot_percent() comment below.
> 
> diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
> index 6fbc392..ab4f16c 100644
> --- a/lib/activate/dev_manager.c
> +++ b/lib/activate/dev_manager.c
> @@ -423,7 +423,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
>  			const char *target_type, int wait,
>  			const struct logical_volume *lv, float *percent,
>  			percent_range_t *overall_percent_range,
> -			uint32_t *event_nr)
> +			uint32_t *event_nr, int fail_if_percent_unsupported)
>  {
>  	int r = 0;
>  	struct dm_task *dmt;
> @@ -516,10 +516,8 @@ static int _percent_run(struct dev_manager *dm, const char *name,
>  			/* above ->target_percent() was not executed! */
>  			/* FIXME why return PERCENT_100 et. al. in this case? */
>  			*overall_percent_range = PERCENT_100;
> -			if (lv && lv_is_merging_origin(lv)) {
> -				/* must fail in snapshot-merge case */
> +			if (fail_if_percent_unsupported)
>  				goto_out;
> -			}
>  		} else
>  			*overall_percent_range = combined_percent_range;
>  	}
> @@ -535,20 +533,24 @@ static int _percent_run(struct dev_manager *dm, const char *name,
>  static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
>  		    const char *target_type, int wait,
>  		    const struct logical_volume *lv, float *percent,
> -		    percent_range_t *overall_percent_range, uint32_t *event_nr)
> +		    percent_range_t *overall_percent_range, uint32_t *event_nr,
> +		    int fail_if_percent_unsupported)
>  {
>  	if (dlid && *dlid) {
>  		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
> -				 overall_percent_range, event_nr))
> +				 overall_percent_range, event_nr,
> +				 fail_if_percent_unsupported))
>  			return 1;
>  		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
>  				      target_type, wait, lv, percent,
> -				      overall_percent_range, event_nr))
> +				      overall_percent_range, event_nr,
> +				      fail_if_percent_unsupported))
>  			return 1;
>  	}
>  
>  	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
> -				 overall_percent_range, event_nr))
> +				 overall_percent_range, event_nr,
> +				 fail_if_percent_unsupported))
>  		return 1;
>  
>  	return 0;
> @@ -607,6 +609,21 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
>  {
>  	char *name;
>  	const char *dlid;
> +	int fail_if_percent_unsupported = 0;
> +
> +	if (lv_is_merging_origin(lv)) {
> +		/*
> +		 * Passing unsupported LV types to _percent will lead to a
> +		 * default successful return with percent_range as PERCENT_100.
> +		 * - For a merging origin, this will result in a polldaemon
> +		 *   that runs infinitely (because completion is PERCENT_0)
> +		 * - We unfortunately don't yet _know_ if a snapshot-merge
> +		 *   target is active (activation is deferred if dev is open);
> +		 *   so we can't short-circuit origin devices based purely on
> +		 *   existing LVM LV attributes.
> +		 */
> +		fail_if_percent_unsupported = 1;
> +	}
>  
>  	/*
>  	 * Build a name for the top layer.
> @@ -621,8 +638,8 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
>  	 * Try and get some info on this device.
>  	 */
>  	log_debug("Getting device status percentage for %s", name);
> -	if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
> -		       percent_range, NULL)))
> +	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
> +		       percent_range, NULL, fail_if_percent_unsupported)))
>  		return_0;
>  
>  	/* FIXME dm_pool_free ? */
> @@ -657,7 +674,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
>  
>  	log_debug("Getting device mirror status percentage for %s", name);
>  	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
> -		       percent_range, event_nr)))
> +		       percent_range, event_nr, 0)))
>  		return_0;
>  
>  	return 1;
> 

The patch is OK.

Reviewed-by: Mikulas Patocka <mpatocka@redhat.com>

Alasdair, I think you should make a new LVM release after applying this 
patch, this bug is quite serious and it should be fixed ASAP. The 
implication of the bug is that multi-segment snapshots are always being 
reported as 100% full and invalid --- it can result in data loss because 
the user may think that the snapshot is overflowed and delete it.

Mikulas


