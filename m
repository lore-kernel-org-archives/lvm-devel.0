From: Petr Rockai <prockai@redhat.com>
Date: Sun, 10 May 2009 21:06:37 +0200
Subject: [PATCH 4/7] Introduce vg_add_lc and vg_remove_lv functions.
In-Reply-To: <bf14f3b5346d9d6ddf3ecfe7c064caf2b1bb9bcd.1241620083.git.mbroz@redhat.com>
	(Milan Broz's message of "Wed, 6 May 2009 16:43:01 +0200")
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<bf14f3b5346d9d6ddf3ecfe7c064caf2b1bb9bcd.1241620083.git.mbroz@redhat.com>
Message-ID: <87eiuwu69u.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> vg_add_lv and vg_remove_lv are the only functions for
> adding/removing logical volume into volume group.
Another good refactor.

> Only these function should manipulate with vg->lvs list and (together with
> following patches) will update VG logical volume counter (vg->lv_count).
I guess there's no easy way in C to enforce this? (vg->lvs is only ever touched
by vg_add_lv, vg_remove_lv). Not necessary, but would be nice to have.

Btw., would vg_link_lv and vg_unlink_lv describe better what these two
functions do? It seems a little easy to confuse _add_lv and vg_add_lv, while
the two do quite a different thing.

Acked-By: Petr Rockai <prockai@redhat.com>

(Detailed review comments inline.)

LVM1 format
-----------

> diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
> index 4a3b31a..138794e 100644
> --- a/lib/format1/disk-rep.h
> +++ b/lib/format1/disk-rep.h
> @@ -215,7 +215,8 @@ int import_vg(struct dm_pool *mem,
>  	      struct volume_group *vg, struct disk_list *dl);
>  int export_vg(struct vg_disk *vgd, struct volume_group *vg);
>  
> -int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd);
> +int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
> +	      struct logical_volume *lv, struct lv_disk *lvd);
>  
>  int import_extents(struct cmd_context *cmd, struct volume_group *vg,
>  		   struct dm_list *pvds);
> diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
> index 627ee05..573836d 100644
> --- a/lib/format1/import-export.c
> +++ b/lib/format1/import-export.c
> @@ -294,10 +294,9 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
>  	return 1;
>  }
>  
> -int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd)
> +int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
> +	      struct logical_volume *lv, struct lv_disk *lvd)
>  {
> -	lvid_from_lvnum(&lv->lvid, &lv->vg->id, lvd->lv_number);
> -
>  	if (!(lv->name = _create_lv_name(mem, (char *)lvd->lv_name)))
>  		return_0;
>  
> @@ -331,7 +330,7 @@ int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lv
>  		lv->alloc = ALLOC_NORMAL;
>  
>  	if (!lvd->lv_read_ahead)
> -		lv->read_ahead = lv->vg->cmd->default_settings.read_ahead;
> +		lv->read_ahead = cmd->default_settings.read_ahead;
>  	else
>  		lv->read_ahead = lvd->lv_read_ahead;
>  
I'm not sure why is this change needed? (Adding cmd_context parameter to
import_lv.)

> @@ -456,22 +455,19 @@ static struct logical_volume *_add_lv(struct dm_pool *mem,
>  				      struct volume_group *vg,
>  				      struct lv_disk *lvd)
>  {
> -	struct lv_list *ll;
>  	struct logical_volume *lv;
>  
> -	if (!(ll = dm_pool_zalloc(mem, sizeof(*ll))) ||
> -	    !(ll->lv = dm_pool_zalloc(mem, sizeof(*ll->lv))))
> +	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
>  		return_NULL;
> -	lv = ll->lv;
> -	lv->vg = vg;
>  
> -	if (!import_lv(mem, lv, lvd))
> -		return_NULL;
> +	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
>  
> -	dm_list_add(&vg->lvs, &ll->list);
> -	vg->lv_count++;
> +	if (!import_lv(vg->cmd, mem, lv, lvd)) {
> +		dm_pool_free(mem, lv);
> +		return_NULL;
> +	}
>  
> -	return lv;
> +	return vg_add_lv(vg, lv) ? lv : NULL;
>  }

Does not change what the code does, just shuffles the lines somewhat. It does
change semantics of import_lv, but that function is never used outside _add_lv
anyway (would it make sense to make it static _import_lv, in a separate
patch?).

Pool Format
-----------

> diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
> index 4d2163d..91e3bcd 100644
> --- a/lib/format_pool/import_export.c
> +++ b/lib/format_pool/import_export.c
> @@ -58,22 +58,14 @@ int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list
>  int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
>  {
>  	struct pool_list *pl;
> -	struct lv_list *lvl = dm_pool_zalloc(mem, sizeof(*lvl));
>  	struct logical_volume *lv;
>  
> -	if (!lvl) {
> -		log_error("Unable to allocate lv list structure");
> -		return 0;
> -	}
> -
> -	if (!(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv)))) {
> +	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv)))) {
>  		log_error("Unable to allocate logical volume structure");
>  		return 0;
>  	}
>  
> -	lv = lvl->lv;
>  	lv->status = 0;
> -	lv->vg = vg;
>  	lv->alloc = ALLOC_NORMAL;
>  	lv->size = 0;
>  	lv->name = NULL;
> @@ -115,11 +107,8 @@ int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list
>  	}
>  
>  	lv->le_count = lv->size / POOL_PE_SIZE;
> -	lvl->lv = lv;
> -	dm_list_add(&vg->lvs, &lvl->list);
> -	vg->lv_count++;
>  
> -	return 1;
> +	return vg_add_lv(vg, lv);
>  }

Again, harmless reordering of code. As a side-effect, unifies the error
handling code with other instances of similar code.

Text (LVM2) format
------------------

> diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
> index a9748aa..52ef075 100644
> --- a/lib/format_text/import_vsn1.c
> +++ b/lib/format_text/import_vsn1.c
> @@ -495,15 +495,11 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
>  			 struct dm_hash_table *pv_hash __attribute((unused)))
>  {
>  	struct logical_volume *lv;
> -	struct lv_list *lvl;
>  	struct config_node *cn;
>  
> -	if (!(lvl = dm_pool_zalloc(mem, sizeof(*lvl))) ||
> -	    !(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv))))
> +	if (!(lv = dm_pool_zalloc(mem, sizeof(*lv))))
>  		return_0;
>  
> -	lv = lvl->lv;
> -
>  	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
>  		return_0;
>  
> @@ -561,11 +557,7 @@ static int _read_lvnames(struct format_instance *fid __attribute((unused)),
>  		return 0;
>  	}
>  
> -	lv->vg = vg;
> -	vg->lv_count++;
> -	dm_list_add(&vg->lvs, &lvl->list);
> -
> -	return 1;
> +	return vg_add_lv(vg, lv);
>  }
The new code is equivalent to the older version, just the ordering is
(harmlessly) different.

General metadata code
---------------------

> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index 7214b27..1903320 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -402,7 +402,6 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
>   */
>  static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
>  {
> -	struct lv_list *lvl;
>  	struct lv_segment *seg;
>  	uint32_t count = extents;
>  	uint32_t reduction;
> @@ -434,13 +433,11 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
>  
>  	/* Remove the LV if it is now empty */
>  	if (!lv->le_count) {
> -		if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
> +		if(!vg_remove_lv(lv))
>  			return_0;
> -
> -		dm_list_del(&lvl->list);
> -
> -		if (!(lv->status & SNAPSHOT))
> -			lv->vg->lv_count--;
> +		//FIXME: cow still in VG, fix count, remove this later
> +		if (lv->status & SNAPSHOT)
> +			lv->vg->lv_count++;
^^ This is indeed ugly (see also my previous mail: it might be worth getting
rid of lv_count altogether) ... although this patch is a definite improvement,
it is still suboptimal in this respect.

>  	} else if (lv->vg->fid->fmt->ops->lv_setup &&
>  		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
>  		return_0;
> @@ -1822,8 +1819,6 @@ struct logical_volume *lv_create_empty(const char *name,
>  				       struct volume_group *vg)
>  {
>  	struct format_instance *fi = vg->fid;
> -	struct cmd_context *cmd = vg->cmd;
> -	struct lv_list *ll = NULL;
>  	struct logical_volume *lv;
>  	char dname[NAME_LEN];
>  
> @@ -1843,23 +1838,11 @@ struct logical_volume *lv_create_empty(const char *name,
>  	if (!import)
>  		log_verbose("Creating logical volume %s", name);
>  
> -	if (!(ll = dm_pool_zalloc(cmd->mem, sizeof(*ll))) ||
> -	    !(ll->lv = dm_pool_zalloc(cmd->mem, sizeof(*ll->lv)))) {
> -		log_error("lv_list allocation failed");
> -		if (ll)
> -			dm_pool_free(cmd->mem, ll);
> -		return NULL;
> -	}
> +	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
> +		return_NULL;
.

>  
> -	lv = ll->lv;
> -	lv->vg = vg;
> -
> -	if (!(lv->name = dm_pool_strdup(cmd->mem, name))) {
> -		log_error("lv name strdup failed");
> -		if (ll)
> -			dm_pool_free(cmd->mem, ll);
> -		return NULL;
> -	}
> +	if (!(lv->name = dm_pool_strdup(vg->vgmem, name)))
> +		goto_bad;
.

>  
>  	lv->status = status;
>  	lv->alloc = alloc;
> @@ -1877,18 +1860,20 @@ struct logical_volume *lv_create_empty(const char *name,
>  	if (lvid)
>  		lv->lvid = *lvid;
>  
> -	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv)) {
> -		if (ll)
> -			dm_pool_free(cmd->mem, ll);
> -		return_NULL;
> -	}
> +	if (!vg_add_lv(vg, lv))
> +		goto_bad;
.

>  
> -	if (!import)
> -		vg->lv_count++;
> +	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
> +		goto_bad;
>  
> -	dm_list_add(&vg->lvs, &ll->list);
> +	//FIXME: remove that
> +	if (import)
> +		vg->lv_count--;
The same about the FIXME, see above.

>  
>  	return lv;
> +bad:
> +	dm_pool_free(vg->vgmem, lv);
> +	return_NULL;
>  }
Other than that, the code looks equivalent to me, although there's a fair
amount of logic shuffling. It goes to a great length to make the function less
tangled though, so I guess it's a good thing (for example it gets rid of the
repeated error handler by using goto_bad instead).

>  static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
> @@ -1957,6 +1942,36 @@ struct dm_list *build_parallel_areas_from_lv(struct cmd_context *cmd,
>  	return parallel_areas;
>  }
>  
> +int vg_add_lv(struct volume_group *vg, struct logical_volume *lv)
> +{
> +	struct lv_list *lvl;
> +
> +	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
> +		return_0;
> +
> +	lvl->lv = lv;
> +	lv->vg = vg;
> +	dm_list_add(&vg->lvs, &lvl->list);
> +
> +	vg->lv_count++;
> +
> +	return 1;
> +}
> +
> +int vg_remove_lv(struct logical_volume *lv)
> +{
> +	struct lv_list *lvl;
> +
> +	if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
> +			return_0;
> +
> +	dm_list_del(&lvl->list);
> +
> +	lvl->lv->vg->lv_count--;
> +
> +	return 1;
> +}
These two look good, and are implemented in accord with how they are used in
the code above.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


