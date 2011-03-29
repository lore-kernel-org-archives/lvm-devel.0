From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Tue, 29 Mar 2011 16:58:14 +0200
Subject: [PATCH 2 of 2] LVM: allow lv_extend of empty layered volumes
In-Reply-To: <201103291304.p2TD4qWN024143@hydrogen.msp.redhat.com>
References: <201103291304.p2TD4qWN024143@hydrogen.msp.redhat.com>
Message-ID: <4D91F386.4010004@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.3.2011 15:04, Jonathan Brassow napsal(a):
> Patch name: lvm-allow-lv_extend-of-empty-layered-volumes.patch
> 
> This patch adds the ability to extend 0 length layered LVs.  This
> allows us to allocate all images of a mirror (or RAID array) at one
> time during create.
> 
> The current mirror implementation still requires a separate allocation
> for the log, however.
> 
> Index: LVM2/lib/metadata/lv_manip.c
> ===================================================================
> --- LVM2.orig/lib/metadata/lv_manip.c
> +++ LVM2/lib/metadata/lv_manip.c
> @@ -2106,29 +2106,90 @@ int lv_add_log_segment(struct alloc_hand
>  			      0, status, 0);
>  }
>  
> -static int _lv_extend_mirror(struct alloc_handle *ah,
> -			     struct logical_volume *lv,
> -			     uint32_t extents, uint32_t first_area,
> -			     uint32_t stripes, uint32_t stripe_size)
> +static int _lv_insert_empty_layer(struct logical_volume *lv,
> +				  const struct segment_type *segtype,
> +				  uint32_t region_size,
> +				  uint32_t devices)
> +{
> +	struct logical_volume *sub_lv;
> +	uint32_t i;
> +	uint64_t status = 0;
> +	char *img_name;
> +	size_t len;
> +	struct lv_segment *mapseg;
> +
> +	if (lv->le_count || first_seg(lv)) {
> +		/*
> +		 * This should never happen.  The message is meant
> +		 * to help developers.
> +		 */
> +		log_error("Bad arguments to _lv_insert_empty_layer");

log_error(INTERNAL_ERROR...)  - so it's catched by buildbot

> +		return 0;
> +	}
> +
> +	/* FIXME: Mirror specific */
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
> +	if (!(img_name = alloca(len)))
> +		return_0;
> +	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
> +		return_0;
> +
> +	for (i = 0; i < devices; i++) {
> +		sub_lv = lv_create_empty(img_name, NULL,
> +					 MIRROR_IMAGE, lv->alloc, lv->vg);
> +		if (!sub_lv) {
> +			log_error("Failed to allocate sub_lv for %s", lv->name);

log_warn()/log_debug() // as we already get log_error from lv_create_empty().
return_0;

Zdenek


