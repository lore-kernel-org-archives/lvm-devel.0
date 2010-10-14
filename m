From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Oct 2010 11:51:56 +0200
Subject: [PATCH] automatic snapshot extension with dmeventd (BZ 427298)
In-Reply-To: <87r5g4lejw.fsf@twilight.int.mornfall.net.>
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
Message-ID: <4CB6D2BC.9060404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.10.2010 19:44, Petr Rockai napsal(a):
> Attaching a revised patch, addressing couple of points raised on IRC by
> Alasdair. The setting names have changed, I have cleaned up defaults to
> use the standard mechanism and fixed couple of coding style points.
> 
> The tests still pass.
> 
> Yours,
>    Petr.
> 
> 
> 
> dmeventd-snapshot-extend.diff
> 
> 
> diff -rN -u -p old-snapshot-monitoring/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c new-snapshot-monitoring/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
> --- old-snapshot-monitoring/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010-10-05 19:42:32.000000000 +0200
> +++ new-snapshot-monitoring/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010-10-05 19:42:32.000000000 +0200
> @@ -26,8 +26,10 @@
>  
>  /* First warning when snapshot is 80% full. */
>  #define WARNING_THRESH 80
> -/* Further warnings at 85%, 90% and 95% fullness. */
> -#define WARNING_STEP 5
> +/* Run a check every 5%. */
> +#define CHECK_STEP 5
> +/* Do not bother checking snapshots less than 50% full. */
> +#define CHECK_MINIMUM 50
>  
>  struct snap_status {
>  	int invalid;
> @@ -69,6 +71,28 @@ static void _parse_snapshot_params(char 
>  	status->max = atoi(p);
>  }
>  
> +static int _extend(const char *device)
> +{
> +	char *vg = NULL, *lv = NULL, *layer = NULL;
> +	char cmd_str[1024];

I don't like these hard coded numbers - maybe it should be connected to
PATH_MAX * xyz + abc, or maybe just use dm_asprintf ?


> +	int r = 0;
> +
> +	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
> +		syslog(LOG_ERR, "Unable to determine VG name from %s.", device);
> +		return 0;
> +	}
> +	if (sizeof(cmd_str) <= snprintf(cmd_str, sizeof(cmd_str),
> +					"lvextend --use-policies %s/%s", vg, lv)) {
> +		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
> +		return 0;
> +	}
> +




> --- old-snapshot-monitoring/tools/lvresize.c	2010-10-05 19:42:32.000000000 +0200
> +++ new-snapshot-monitoring/tools/lvresize.c	2010-10-05 19:42:32.000000000 +0200
> @@ -196,34 +197,41 @@ static int _lvresize_params(struct cmd_c
...
> +
> +		if (arg_count(cmd, extents_ARG)) {
> +			lp->extents = arg_uint_value(cmd, extents_ARG, 0);
> +			lp->sign = arg_sign_value(cmd, extents_ARG, SIGN_NONE);
> +			lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
> +		}
> +
> +		/* Size returned in kilobyte units; held in sectors */
> +		if (arg_count(cmd, size_ARG)) {
> +			lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));

I know it's just code move - but we could strip this unneeded UINT64_C.


> +			lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
> +			lp->percent = PERCENT_NONE;
> +		}
>  	}
>  
>  	if (lp->resize == LV_EXTEND && lp->sign == SIGN_MINUS) {
> @@ -269,6 +277,33 @@ static int _lvresize_params(struct cmd_c
>  	return 1;
>  }
>  
> +static int _adjust_policy_params(struct cmd_context *cmd,
> +				 struct logical_volume *lv, struct lvresize_params *lp)
> +{
> +	float percent;
> +	percent_range_t range;
> +	int policy_threshold, policy_amount;
> +
> +	policy_threshold =
> +		find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
> +				     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD);
> +	policy_amount =
> +		find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
> +				     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
> +
> +	if (policy_threshold >= 100)
> +		return 1; /* nothing to do */

For some really large sizes - even 1% could be a huge amount of disk space -
so maybe some users would like to see floating number support here?


I'll do some functionality tests later - patch looks good to me so far.

Zdenek


