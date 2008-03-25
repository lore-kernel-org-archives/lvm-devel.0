From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 24 Mar 2008 21:11:23 -0400
Subject: [PATCH vgsplit 2/4] Update vgsplit to allow a list of LVs or PVs on the commandline.
In-Reply-To: <20080324202437.539525068@redhat.com>
References: <20080324202343.627758622@redhat.com>
	<20080324202437.539525068@redhat.com>
Message-ID: <47E8513B.1000502@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Dave,

I quickly looked through the patch.
Please see comments below.

> Add some helper functions to allow vgsplit to continue in more cases.
> Introduce "related volumes" concept, as defined in the comments below.
> 
> 
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -151,6 +151,9 @@ struct pv_segment {
>  	uint32_t lv_area;	/* Index to area in LV segment */
>  };
>  
> +#define pvseg_is_allocated(pvseg) (pvseg->lvseg)
> +#define pvseg_is_free(pvseg) (!pvseg_is_allocated(pvseg))

Macro parameters should be surrounded by ().
#define pvseg_is_allocated(pvseg) ((pvseg)->lvseg)
#define pvseg_is_free(pvseg) (!pvseg_is_allocated((pvseg)))

> +struct related_volumes {
> +	struct volume_group *vg;
> +	struct list ll; /* struct lv_list */
> +	struct list pl; /* struct pv_list */
> +};

I think 'lvs' and 'pvs' are more descriptive.

struct related_volumes {
	struct volume_group *vg;
	struct list lvs; /* struct lv_list */
	struct list pvs; /* struct pv_list */
};

> +void pv_add_related_volume(struct related_volumes *rvs, struct pv_list *pvl);
> +void lv_add_related_volume(struct related_volumes *rvs, struct lv_list *lvl);

On the analogy of other function names in LVM2,
these sound like 'adding "related volume" to pv/lv'.

What these functions actually do is collecting related volumes for
given LV/PV and adding them to rvs.
How about collect_related_volumes_for_{pv,lv} or collect_rvs_for_{pv,lv}?

Or IOW, the functions add given PV/LV (and its relatives) to rvs.
So add_{pv,lv}_to_related_volumes() might be good as well.


> +static void _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
> +		     struct pv_list *pvl)
> +{
> +	struct physical_volume *pv;
> +
> +	list_del(&pvl->list);
> +	list_add(&vg_to->pvs, &pvl->list);

Since this del-and-add logic appears many times through this patch,
how about adding list_move() to lib/datastruct/list.h?

static inline list_move(struct list *item, struct list *head)
{
	list_del(item);
	list_add(head, item);
}

> +	pv = list_item(pvl, struct pv_list)->pv;

This is a bug, though it works with luck by struct pv_list layout.
It should be:
  pv = pvl->pv;

Not a problem of this patch, as it exists in the original code.

> +static int find_in_pv_list(const struct list *pl,
> +			   const struct physical_volume *pv)

I think other find_* functions in LVM2 returns what it finds.
Also, names of static functions tend to start with '_'.

So how about _find_pv_in_pv_list() and return a pointer to
the matched pvl otherwise NULL?
Or _pv_is_in_pv_list(), if the matched pvl has no use.

> +{
> +	const struct pv_list *pvl;
> +
> +	list_iterate_items(pvl, pl)
> +		if (pvl->pv == pv)
> +			return 1;
> +	return 0;
> +}

_add_pvs() in lib/metadata/lv_manip.c can use this function, too.


> +static int find_in_lv_list(const struct list *ll,
> +			   const struct logical_volume *lv)

Ditto about the naming.

> +static void add_related_pv(struct related_volumes *rvs,
> +			   const struct physical_volume *pv)
...
> +static void add_related_lv(struct related_volumes *rvs,
> +			   const struct logical_volume *lv)
...
> +static void add_related_segment(struct related_volumes *rvs,
> +				const struct lv_segment *lvseg)

These names sound like 'adding given pv/lv/lvseg to rvs'.
but actually are 'adding related volumes for pv/lv/lvseg to rvs'.
So similar renaming as pv_add_related_volume() would be nice, IMO.

> +	if (!list_empty(&lvseg->lv->segs_using_this_lv)) {
> +		lvseg2 = get_only_segment_using_this_lv(lvseg->lv);
> +		if (lvseg2)
> +			add_related_segment(rvs, lvseg2);
> +	}

First, I think this part should be moved to lv_find_related_volumes()
because segs_using_this_lv is a property of lv, not lvseg.

Second, you should walk through segs_using_this_lv, instead of
using get_only_segment_using_this_lv(). e.g. "pvmove" LV may be used by
multiple lvsegs.

> @@ -302,28 +146,64 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
...
> +	init_related_volumes(&rvs, vg_from);
> +	lv_count_cmdline = 0;
> +	pv_count_cmdline = 0;
> +	for (opt = 0; opt < argc; opt++) {
> +		/* FIXME: handle tags */
> +		if ((lvl = find_lv_in_vg(vg_from, argv[opt]))) {
> +			lv_count_cmdline++;
> +			lv_add_related_volume(&rvs, lvl);
> +		} else if ((pvl = find_pv_in_vg(vg_from, argv[opt]))) {
> +			pv_count_cmdline++;
> +			pv_add_related_volume(&rvs, pvl);
> +		}
>  	}
>  
> -	/* Move required LVs across, checking consistency */
> -	if (!(_move_lvs(vg_from, vg_to)))
> -		goto error;
> +	/*
> +	 * Now that we have the lists of all PVs and LVs involved in the
> +	 * split, check if this list contains PVs or LVs above what the user
> +	 * requested.  If so, ask for confirmation before continuing, as this
> +	 * is most likely what the user would expect.
> +	 */
> +	if ( ((pv_count_cmdline && list_size(&rvs.pl) > pv_count_cmdline) ||
> +	      (lv_count_cmdline && list_size(&rvs.ll) > lv_count_cmdline)) &&
> +	     !arg_count(cmd, force_ARG) ) {
> +		if (!confirm_vgsplit(&rvs.ll, &rvs.pl))
> +			goto error;
> +	}

The above condition won't work as expected if specified LV is composed
of some hidden LVs, e.g. mirror?

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America



