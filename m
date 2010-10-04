From: Petr Rockai <prockai@redhat.com>
Date: Mon, 04 Oct 2010 19:20:00 +0200
Subject: [PATCH] Restrict lvm1 partial mode.
In-Reply-To: <1286210927-10607-1-git-send-email-mbroz@redhat.com> (Milan
	Broz's message of "Mon, 4 Oct 2010 18:48:47 +0200")
References: <1286210927-10607-1-git-send-email-mbroz@redhat.com>
Message-ID: <8762xh50zj.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> diff --git a/lib/format1/format1.c b/lib/format1/format1.c
> index d6c462a..f5a9d12 100644
> --- a/lib/format1/format1.c
> +++ b/lib/format1/format1.c
> @@ -118,6 +118,28 @@ static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
>  	struct disk_list *dl;
>  	struct dm_list *pvh;
>  	struct pv_list *pvl;
> +	struct lv_list *ll;
> +	struct lv_segment *seg;
> +
> +	/*
> +	 * FIXME: code should remap missing segments to error segment.
> +	 * Also current mapping code allocates 1 segment per missing extent.
> +	 * For now bail out completely - allocated structures are not complete
> +	 */
> +	dm_list_iterate_items(ll, &vg->lvs)
> +		dm_list_iterate_items(seg, &ll->lv->segments) {
> +
> +			/* area_count is always 1 here, s == 0 */
> +			if (seg_type(seg, 0) != AREA_PV)
> +				continue;
> +
> +			if (seg_pv(seg, 0))
> +				continue;
> +
> +			log_error("Partial mode support for missing lvm1 PVs and "
> +				  "partially available LVs is currently not implemented.");
> +			return 0;
> +	}
OK.

>  	dm_list_iterate(pvh, pvs) {
>  		dl = dm_list_item(pvh, struct disk_list);
> @@ -129,8 +151,10 @@ static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
>  	    !(pvl->pv = dm_pool_zalloc(vg->vgmem, sizeof(*pvl->pv))))
>  		return_0;
>  
> -	if (!id_create(&pvl->pv->id))
> -		goto_out;
> +	/* Use vg uuid with replaced first chars to "missing" as missing PV UUID */
> +	memcpy(&pvl->pv->id.uuid, vg->id.uuid, sizeof(pvl->pv->id.uuid));
> +	memcpy(&pvl->pv->id.uuid, "missing", 7);

Does what the comment says... would the result be a bit less confusing
though if it said

memcpy(&pvl->pv->id.uuid, "missing_", 8);

instead? I know, a nitpick.

Other than that,

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.

PS: Would it be possible to have automated tests for LVM1 stuff as well?
The below seems to work (i.e. new LVM1 VGs can still be created), so we
could just add couple tests for missing PV behaviour with LVM1...

aux prepare_devs 4
pvcreate -M1 $devs
vgcreate -M1 $vg $devs

vgs -o +vg_fmt | grep lvm1


