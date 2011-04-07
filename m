From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 07 Apr 2011 14:09:49 +0200
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
In-Reply-To: <20110406213222.10912.qmail@sourceware.org>
References: <20110406213222.10912.qmail@sourceware.org>
Message-ID: <4D9DA98D.2000007@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.4.2011 23:32, jbrassow at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	jbrassow at sourceware.org	2011-04-06 21:32:21
> 
> Modified files:
> 	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
> 	tools          : lvresize.c 
> 
> Log message:
> 	This patch adds the ability to extend 0 length layered LVs.  This
> 	allows us to allocate all images of a mirror (or RAID array) at one
> 	time during create.
> 	
> 	The current mirror implementation still requires a separate allocation
> 	for the log, however.
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.254&r2=1.255
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.188&r2=1.189
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
> 
> --- LVM2/lib/metadata/lv_manip.c	2011/03/29 20:19:04	1.254
> +++ LVM2/lib/metadata/lv_manip.c	2011/04/06 21:32:20	1.255
> @@ -2106,29 +2106,87 @@
>  			      0, status, 0);
>  }
>  
> -static int _lv_extend_mirror(struct alloc_handle *ah,
> -			     struct logical_volume *lv,
> -			     uint32_t extents, uint32_t first_area,
> -			     uint32_t stripes, uint32_t stripe_size)
> +static int _lv_insert_empty_sublvs(struct logical_volume *lv,
> +				   const struct segment_type *segtype,
> +				   uint32_t region_size,
> +				   uint32_t devices)
> +{
> +	struct logical_volume *sub_lv;
> +	uint32_t i;
> +	uint64_t status = 0;
> +	char *img_name;
> +	size_t len;
> +	struct lv_segment *mapseg;
> +
> +	if (lv->le_count || first_seg(lv)) {
> +		log_error(INTERNAL_ERROR
> +			  "Non-empty LV passed to _lv_insert_empty_sublv");
> +		return 0;
> +	}
> +
> +	if (!segtype_is_mirrored(segtype))
> +		return_0;
> +	lv->status |= MIRRORED;
> +
> +	/*
> +	 * First, create our top-level segment for our top-level LV
> +	 */
> +	if (!(mapseg = alloc_lv_segment(lv->vg->cmd->mem, segtype,
> +					lv, 0, 0, lv->status, 0, NULL,
> +					devices, 0, 0, region_size, 0, NULL))) {
> +		log_error("Failed to create mapping segment for %s", lv->name);
> +		return 0;
> +	}
> +
> +	/*
> +	 * Next, create all of our sub_lv's and link them in.
> +	 */
> +	len = strlen(lv->name) + 32;
> +	if (!(img_name = dm_pool_alloc(lv->vg->cmd->mem, len)))
> +		return_0;
> +	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
> +		return_0;
> +
> +	for (i = 0; i < devices; i++) {
> +		sub_lv = lv_create_empty(img_name, NULL,
> +					 MIRROR_IMAGE, lv->alloc, lv->vg);
> +		if (!sub_lv)
> +			return_0;
> +		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))
> +			return_0;
> +	}
> +	dm_list_add(&lv->segments, &mapseg->list);
> +
> +	dm_pool_free(lv->vg->cmd->mem, img_name);


Aren't you experiencing random crashes with this  dm_pool_free() ?
It removes also all objects allocated past this img_name.
(Also I think there is already an internal function for building such names)

Zdenek


