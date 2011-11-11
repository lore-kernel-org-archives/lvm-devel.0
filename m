From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Nov 2011 17:23:10 +0100
Subject: [PATCH] LVM: New flag, LV_REBUILD
In-Reply-To: <1320963969.7209.1.camel@f14.redhat.com>
References: <1320963969.7209.1.camel@f14.redhat.com>
Message-ID: <4EBD4BEE.2050301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.11.2011 23:26, Jonathan Brassow napsal(a):
> Any objections to a new flag?
> 
>  brassow
> 
> Add new flag, LV_REBUILD.
> 
> Until now, I had been using the LV_NOTSYNCED as a flag to indicate that RAID
> sub-LVs needed to be rebuilt.  (The 'rebuild' parameter is then specified in
> the DM CTR table.)  However, I don't want to use a flag that gets written to
> the LVM metadata... and the LV_NOTSYNCED flag's original meaning does not
> suite the purpose adequately.
> 
> This patch proposes and uses a new flag, LV_REBUILD.

Hmm and how is this going to work in some crash scenarios - are you always
able to deduce the raid was not yet build ?

Also it seems we encode each flag into lib/format_text/flags.c


> 
> 
> Index: LVM2/lib/metadata/metadata-exported.h
> ===================================================================
> --- LVM2.orig/lib/metadata/metadata-exported.h
> +++ LVM2/lib/metadata/metadata-exported.h
> @@ -61,7 +61,9 @@
>  //#define VIRTUAL		UINT64_C(0x00010000)	/* LV - internal use only */
>  #define MIRROR_LOG		UINT64_C(0x00020000)	/* LV */
>  #define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
> +
>  #define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
> +#define LV_REBUILD		UINT64_C(0x00100000)	/* LV */
>  //#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
>  #define CONVERTING		UINT64_C(0x00400000)	/* LV */
>  
> Index: LVM2/lib/metadata/raid_manip.c
> ===================================================================
> --- LVM2.orig/lib/metadata/raid_manip.c
> +++ LVM2/lib/metadata/raid_manip.c
> @@ -440,7 +440,7 @@ static int _alloc_image_component(struct
>  		return 0;
>  	}
>  
> -	status = LVM_READ | LVM_WRITE | LV_NOTSYNCED | type;
> +	status = LVM_READ | LVM_WRITE | LV_REBUILD | type;
>  	tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg);
>  	if (!tmp_lv) {
>  		log_error("Failed to allocate new raid component, %s", img_name);
> @@ -588,7 +588,7 @@ static int _raid_add_images(struct logic
>  	 */
>  	if (seg_is_linear(seg)) {
>  		/* A complete resync will be done, no need to mark each sub-lv */
> -		status_mask = ~(LV_NOTSYNCED);
> +		status_mask = ~(LV_REBUILD);
>  
>  		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
>  			log_error("Memory allocation failed");
> @@ -1335,8 +1335,8 @@ static int _convert_mirror_to_raid1(stru
>  		log_debug("Adding %s to %s", lvl->lv->name, lv->name);
>  
>  		/* Images are known to be in-sync */
> -		lvl->lv->status &= ~LV_NOTSYNCED;
> -		first_seg(lvl->lv)->status &= ~LV_NOTSYNCED;
> +		lvl->lv->status &= ~LV_REBUILD;
> +		first_seg(lvl->lv)->status &= ~LV_REBUILD;
>  		lv_set_hidden(lvl->lv);
>  
>  		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
> Index: LVM2/lib/raid/raid.c
> ===================================================================
> --- LVM2.orig/lib/raid/raid.c
> +++ LVM2/lib/raid/raid.c
> @@ -183,7 +183,7 @@ static int _raid_add_target_line(struct 
>  	}
>  
>  	for (s = 0; s < seg->area_count; s++)
> -		if (seg_lv(seg, s)->status & LV_NOTSYNCED)
> +		if (seg_lv(seg, s)->status & LV_REBUILD)
>  			rebuilds |= 1 << s;
>  
>  	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
> 
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


