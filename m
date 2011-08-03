From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 3 Aug 2011 09:50:55 -0500
Subject: [PATCH 2 of 5] LVM: New function - lv_is_on_pv
In-Reply-To: <1312382633.1169.20.camel@f14.redhat.com>
References: <1312381844.1169.8.camel@f14.redhat.com>
	<1312382633.1169.20.camel@f14.redhat.com>
Message-ID: <7E7E858B-2CCB-47AB-95E8-D98F9070F651@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

forgive the mistake.  I had originally called the function lv_is_on_pv, but
changed it to pv_is_in_lv to match the existing function pv_is_in_vg...

The header and subject should have said 'pv_is_in_lv'.
 brassow

On Aug 3, 2011, at 9:43 AM, Jonathan Brassow wrote:

> lv_is_on_pv - A useful function when devices are specified for removal from RAID
> 
> This function should also be useful for mirror down-converting.
> 
> Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
> 
> Index: LVM2/lib/metadata/lv_manip.c
> ===================================================================
> --- LVM2.orig/lib/metadata/lv_manip.c
> +++ LVM2/lib/metadata/lv_manip.c
> @@ -3513,6 +3513,61 @@ static int _match_seg_area_to_pe_range(s
> }
> 
> /*
> + * pv_is_in_lv
> + * @lv:
> + * @pv:
> + *
> + * If any of the component devices of the LV are on the given PV, 1
> + * is returned; otherwise 0.  For example if one of the images of a mirror
> + * (or its log) is on the PV, 1 would be returned for the top-level LV.
> + * If you wish to check the images themselves, you should pass them.
> + */
> +int pv_is_in_lv(struct logical_volume *lv, struct physical_volume *pv)
> +{
> +	uint32_t s;
> +	struct physical_volume *pv2;
> +	struct lv_segment *seg;
> +
> +	if (!lv)
> +		return 0;
> +
> +	seg = first_seg(lv);
> +	if (!seg)
> +		return 0;
> +
> +	/* Check mirror log */
> +	if (pv_is_in_lv(seg->log_lv, pv))
> +		return 1;
> +
> +	/* Check stack of LVs */
> +	dm_list_iterate_items(seg, &lv->segments) {
> +		for (s = 0; s < seg->area_count; s++) {
> +			if (seg_type(seg, s) == AREA_PV) {
> +				pv2 = seg_pv(seg, s);
> +				if (id_equal(&pv->id, &pv2->id))
> +					return 1;
> +				if (pv->dev && pv2->dev &&
> +				    (pv->dev->dev == pv2->dev->dev))
> +					return 1;
> +			}
> +
> +			if ((seg_type(seg, s) == AREA_LV) &&
> +			    pv_is_in_lv(seg_lv(seg, s), pv))
> +				return 1;
> +
> +			if (!seg_is_raid(seg))
> +				continue;
> +
> +			/* This is RAID, so we know the meta_area is AREA_LV */
> +			if (pv_is_in_lv(seg_metalv(seg, s), pv))
> +				return 1;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +/*
>  * For each segment in lv_where that uses a PV in pvl directly,
>  * split the segment if it spans more than one underlying PV.
>  */
> Index: LVM2/lib/metadata/metadata-exported.h
> ===================================================================
> --- LVM2.orig/lib/metadata/metadata-exported.h
> +++ LVM2/lib/metadata/metadata-exported.h
> @@ -645,6 +645,7 @@ int lv_is_merging_cow(const struct logic
> int lv_is_visible(const struct logical_volume *lv);
> 
> int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
> +int pv_is_in_lv(struct logical_volume *lv, struct physical_volume *pv);
> 
> struct lv_segment *find_merging_cow(const struct logical_volume *origin);
> 
> 
> 
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



