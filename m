From: Petr Rockai <prockai@redhat.com>
Date: Tue, 10 Feb 2009 18:46:11 +0100
Subject: [PATCH] lvconvert --repair
In-Reply-To: <498B2A94.7050105@redhat.com> (Milan Broz's message of "Thu, 05
	Feb 2009 19:06:12 +0100")
References: <87skn1p0jo.fsf@eriador.mornfall.net> <498B2A94.7050105@redhat.com>
Message-ID: <877i3y9od8.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Also there should be
> -	int ret = 1;
> +	int ret = ECMD_PROCESSED;
>
> to be consistent enough...
will fix

> - missing man page update
indeed

> --- old-lvconvert-reorder-2/lib/metadata/pv_map.c	2009-01-30 11:03:20.569284247 +0100
> +++ new-lvconvert-reorder-2/lib/metadata/pv_map.c	2009-01-30 11:03:20.625285639 +0100
> @@ -129,6 +129,11 @@ static int _create_maps(struct dm_pool *
>  	dm_list_iterate_items(pvl, pvs) {
>  		if (!(pvl->pv->status & ALLOCATABLE_PV))
>  			continue;
> +		if (pvl->pv->status & MISSING_PV) {
> +			log_very_verbose("skipping missing pv ...");
>
> Do we have name of PV (hint in metadata?) or something to print here?
I don't think (the hint tends to be empty for missing PVs). Maybe remove that
log message altogether, it was more useful for debugging.

> +/* FIXME we want to handle mirror stacks here... */
> +static int _count_failed_mirrors(struct logical_volume *lv)
> +{
> +	struct lv_segment *lvseg;
> +	int ret = 0;
> +	int s;
> +	dm_list_iterate_items(lvseg, &lv->segments) {
> +		if (!seg_is_mirrored(lvseg))
> +			return -1;
>
> why -1 here and not simply continue or return_0 ?
Because 0 would mean that there are no failed legs, not an error. Not continue
because it'd probably break anyway. I'll fix the callers to check for -1.

> If this can really happen, it adds mirror lp->mirrors...
>
> 		int failed_mirrors = 0;
> 		...
> 		failed_mirrors = _count_failed_mirrors(lv);

                if (failed_mirrors < 0)
                           error out...

> +		if (!(new_pvl = dm_pool_alloc(cmd->mem, sizeof(*new_pvl)))) {
> +			log_err("Unable to allocate physical volume list.");
> +			return 0;
>
> s/log_err/log_error, return_0 :)
Ok (dunno how log_err crept in...).

> also it should check for 0 othewwise it expects empty list (not NULL) later
> I mean this
>
> 		- lp->pvh = _failed_pv_list(cmd, lv->vg);
>
> 		+ if (!(lp->pvh = ...)
> 		+	return_0; 
>
>
> +	if (arg_count(cmd,repair_ARG)) {
> +		cmd->handles_missing_pvs = 1;
> +		cmd->partial_activation = 1;
> +		lp->need_polling = 0;
> +		if (!(lv->status & PARTIAL_LV)) {
> +			log_error("The mirror is consistent, nothing to repair.");
> +			return_0;
>
> why return_0? PEBKAC :)
Ah ah.

> +		log_lv=first_seg(lv)->log_lv;
> Someone could say that there should be space before and after equal sign :-]
I'll fix this (and any other formatting problems I spot). Will send a patch
amended with the above (real) fixes and cosmetic fixes in a bit.

> Why this testcase doesn't work (resp. doesn't finish without
> manual intervention and hangs in lvconvert?)
> It seems that some devices are left suspended...
>
> prepare_vg 3
>
> lvcreate --alloc anywhere -m1 -L 1 -n mirror $vg
>
> dd if=/dev/zero of=$dev1 bs=1M count=1
>
> #not vgreduce -v --removemissing $vg
> lvconvert --repair $vg/mirror
> vgreduce --removemissing $vg
We have tried to reproduce this without any success, on either my laptop or
Milan's test machine. Let's assume it was a problem with loop devices or
similar that went away in the meantime.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


