From: Petr Rockai <prockai@redhat.com>
Date: Tue, 25 Jan 2011 14:16:05 +0100
Subject: [PATCH 02/17] Add supporting functions for metadata areas stored in format instance.
In-Reply-To: <1295867048-21558-3-git-send-email-prajnoha@redhat.com> (Peter
	Rajnoha's message of "Mon, 24 Jan 2011 12:03:53 +0100")
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
	<1295867048-21558-3-git-send-email-prajnoha@redhat.com>
Message-ID: <87pqrlrune.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:
> This patch divides current create_instance functionality into PV-based
> and VG-based. We add a simple flag "pv_only" in struct format_instance
> that will help us to identify the type of the format_instance when used
> later on (since we will always have PV/VG separation, I think it would
> be useless to define an interface for this where we would attach supporting
> functions on the fly like we do for mda->ops as an example. In this case,
> a simple flag is fine to switch the functionality).
>
> Another change is the metadata_areas_index we have in the struct
> format_instance. To access a certain metadata area, we need to know
> two keys - PV id and metadta area index within that PV. So a few new
> functions have been modified/added to support this:
> - fid_add_mda (modified)
> - fid_add_mdas (modified)
> - fid_remove_mda (new)
> - fid_get_mda_indexed (new)
>
> Actually, the form of the key that will be used is up to the caller,
> but he needs to remember the key somehow to get the mda back :)
>
> The key is simply made up of the base key (a string) and a subkey
> (an unsigned integer). The actual key used internally is then a string:
>
>   <basekey>_<subkey>
>
> Now, the metadata_areas_index is format specific. This is because
> each format can have different number and types of metadata areas
> it can support and so we'd like to be able to use the most suitable
> index for the specific format. Also, we can use a different indexing
> scheme for PV and VG based format_instance.
>
> For PV based format instance in current lvm2 format, we have only
> 2 metadata areas at maximum. So we use only a simple array. No need
> to use any buldozer-type indexing here :)
>
> For VG based format instance, we can group many many mdas together
> from numerous PVs. So we'll use a hash here (like we use for the cache).
> (but maybe we can add even better indexing in the future!)
>
> If key is not defined, we just store the mda without indexing.
> We'll have it in the metadata_areas_in_use/ignored list directly.
>
> ...but we can change these later if needed, of course. The
> implementation is internal, the interface stays the same)
>
> Also, I kept the format instance's metadata_areas_in_use/ignored for
> now, but eventually, I'd like this to be accessed through the index
> in the future. But that is another step to take later...
>
> Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>

Comments below. I think this patch could be improved. On the other hand,
none of the issues are a serious showstopper, but I would definitely
like to see at least the pv_only thing addressed before proceeding. (See
below.)

Reviewed-by: Petr Rockai <prockai@redhat.com>

Yours,
   Petr

> ---
>  lib/format1/format1.c            |    1 +
>  lib/format_text/format-text.c    |  137 ++++++++++++++++++++++++++++----------
>  lib/format_text/format-text.h    |    1 +
>  lib/metadata/metadata-exported.h |    3 +
>  lib/metadata/metadata.c          |  103 +++++++++++++++++++++++++++-
>  lib/metadata/metadata.h          |   10 ++-
>  6 files changed, 213 insertions(+), 42 deletions(-)
>
> diff --git a/lib/format1/format1.c b/lib/format1/format1.c
> index 13b757d..ff5b0f5 100644
> --- a/lib/format1/format1.c
> +++ b/lib/format1/format1.c
> @@ -534,6 +534,7 @@ static struct format_instance *_format1_create_instance(const struct format_type
>  		return_NULL;
>  
>  	fid->fmt = fmt;
> +	fid->metadata_areas_index = NULL;
>  	dm_list_init(&fid->metadata_areas_in_use);
>  	dm_list_init(&fid->metadata_areas_ignored);
>  
> diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
> index fda8255..c8c56f7 100644
> --- a/lib/format_text/format-text.c
> +++ b/lib/format_text/format-text.c
> @@ -48,6 +48,10 @@ struct text_fid_context {
>  	uint32_t raw_metadata_buf_size;
>  };
>  
> +struct text_fid_pv_context {
> +	int64_t label_sector;
> +};
> +
>  struct dir_list {
>  	struct dm_list list;
>  	char dir[0];
> @@ -1912,14 +1916,38 @@ static int _text_pv_setup(const struct format_type *fmt,
>  	return 1;
>  }
>  
> -/* NULL vgname means use only the supplied context e.g. an archive file */
> -static struct format_instance *_text_create_text_instance(const struct format_type*fmt,
> -							  const char *pvid,
> -							  const char *vgname,
> -							  const char *vgid,
> -							  void *context)
> +static int _create_pv_text_instance(struct format_instance *fid, const char *pvid)
> +{
> +	struct text_fid_pv_context *fid_pv_tc;
> +	struct lvmcache_info *info;
> +
> +	fid->pv_only = 1;
> +
> +	if (!(fid_pv_tc = (struct text_fid_pv_context *)
> +			  dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*fid_pv_tc)))) {
> +		log_error("Couldn't allocate text_fid_pv_context.");
> +		return 0;
> +	}
> +	fid_pv_tc->label_sector = -1;
> +	fid->private = (void *) fid_pv_tc;
> +
> +	if (!(fid->metadata_areas_index = dm_pool_zalloc(fid->fmt->cmd->mem,
> +						   FMT_TEXT_MAX_MDAS_PER_PV *
> +						   sizeof(struct metadata_area *)))) {
> +		log_error("Couldn't allocate format instance metadata index.");
> +		return 0;
> +	}
> +
> +	if ((info = info_from_pvid(pvid, 0)))
> +		fid_add_mdas(fid, &info->mdas, pvid, ID_LEN);
> +
> +	return 1;
> +}
OK

> +
> +static int _create_vg_text_instance(struct format_instance *fid,
> +				    const char *vgname, const char *vgid,
> +				    void *context)
>  {
> -	struct format_instance *fid;
>  	struct text_fid_context *fidtc;
>  	struct metadata_area *mda;
>  	struct mda_context *mdac;
> @@ -1930,85 +1958,122 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
>  	struct lvmcache_vginfo *vginfo;
>  	struct lvmcache_info *info;
>  
> -	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
> -		log_error("Couldn't allocate format instance object.");
> -		return NULL;
> -	}
> +	fid->pv_only = 0;
>  
>  	if (!(fidtc = (struct text_fid_context *)
> -			dm_pool_zalloc(fmt->cmd->mem,sizeof(*fidtc)))) {
> +			dm_pool_zalloc(fid->fmt->cmd->mem,sizeof(*fidtc)))) {
>  		log_error("Couldn't allocate text_fid_context.");
> -		return NULL;
> +		return 0;
>  	}
>  
>  	fidtc->raw_metadata_buf = NULL;
>  	fid->private = (void *) fidtc;
>  
> -	fid->fmt = fmt;
> -	dm_list_init(&fid->metadata_areas_in_use);
> -	dm_list_init(&fid->metadata_areas_ignored);
> -
>  	if (!vgname) {
> -		if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
> -			return_NULL;
> +		if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
> +			return_0;
>  		mda->ops = &_metadata_text_file_backup_ops;
>  		mda->metadata_locn = context;
>  		mda->status = 0;
> -		fid_add_mda(fid, mda);
> +		fid_add_mda(fid, mda, NULL, 0, 0);
>  	} else {
> -		dir_list = &((struct mda_lists *) fmt->private)->dirs;
> +		if (!(fid->metadata_areas_index = dm_hash_create(128))) {
> +			log_error("Couldn't create metadata index for format "
> +				  "instance of VG %s.", vgname);
> +			return 0;
> +		}
> +
> +		dir_list = &((struct mda_lists *) fid->fmt->private)->dirs;
>  
>  		dm_list_iterate_items(dl, dir_list) {
>  			if (dm_snprintf(path, PATH_MAX, "%s/%s",
>  					 dl->dir, vgname) < 0) {
>  				log_error("Name too long %s/%s", dl->dir,
>  					  vgname);
> -				return NULL;
> +				return 0;
>  			}
>  
> -			context = create_text_context(fmt->cmd, path, NULL);
> -			if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
> -				return_NULL;
> +			context = create_text_context(fid->fmt->cmd, path, NULL);
> +			if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
> +				return_0;
>  			mda->ops = &_metadata_text_file_ops;
>  			mda->metadata_locn = context;
>  			mda->status = 0;
> -			fid_add_mda(fid, mda);
> +			fid_add_mda(fid, mda, NULL, 0, 0);
>  		}
>  
> -		raw_list = &((struct mda_lists *) fmt->private)->raws;
> +		raw_list = &((struct mda_lists *) fid->fmt->private)->raws;
>  
>  		dm_list_iterate_items(rl, raw_list) {
>  			/* FIXME Cache this; rescan below if some missing */
>  			if (!_raw_holds_vgname(fid, &rl->dev_area, vgname))
>  				continue;
>  
> -			if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda))))
> -				return_NULL;
> +			if (!(mda = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mda))))
> +				return_0;
>  
> -			if (!(mdac = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mdac))))
> -				return_NULL;
> +			if (!(mdac = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*mdac))))
> +				return_0;
>  			mda->metadata_locn = mdac;
>  			/* FIXME Allow multiple dev_areas inside area */
>  			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
>  			mda->ops = &_metadata_text_raw_ops;
>  			mda->status = 0;
>  			/* FIXME MISTAKE? mda->metadata_locn = context; */
> -			fid_add_mda(fid, mda);
> +			fid_add_mda(fid, mda, NULL, 0, 0);
>  		}
>  
>  		/* Scan PVs in VG for any further MDAs */
> -		lvmcache_label_scan(fmt->cmd, 0);
> +		lvmcache_label_scan(fid->fmt->cmd, 0);
>  		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
>  			goto_out;
>  		dm_list_iterate_items(info, &vginfo->infos) {
> -			if (!fid_add_mdas(fid, &info->mdas))
> -				return_NULL;
> +			if (!fid_add_mdas(fid, &info->mdas, info->dev->pvid,
> +					  ID_LEN))
> +				return_0;
>  		}
>  		/* FIXME Check raw metadata area count - rescan if required */
>  	}
>  
>        out:
> -	return fid;
> +	return 1;
> +}
> +
> +/* NULL vgname means use only the supplied context e.g. an archive file */
> +static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
> +							  const char *pvid,
> +							  const char *vgname,
> +							  const char *vgid,
> +							  void *context)
> +{
> +	struct format_instance *fid;
> +	int r;
> +
> +	if (pvid && (vgname || vgid)) {
> +		log_error(INTERNAL_ERROR "Format instance must be PV "
> +					 "or VG specific, not both.");
> +		return NULL;
> +	}
> +
> +	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
> +		log_error("Couldn't allocate format instance object.");
> +		return NULL;
> +	}
> +
> +	fid->fmt = fmt;
> +	fid->metadata_areas_index = NULL;
> +	dm_list_init(&fid->metadata_areas_in_use);
> +	dm_list_init(&fid->metadata_areas_ignored);
> +
> +	r = pvid ? _create_pv_text_instance(fid, pvid) :
> +		   _create_vg_text_instance(fid, vgname, vgid, context);
> +
> +	if (r)
> +		return fid;
> +	else {
> +		dm_pool_free(fmt->cmd->mem, fid);
> +		return NULL;
> +	}
>  }

OK, _text_create_text_instance is split into 3. The changes are
relatively straightforward.

>  
>  void *create_text_context(struct cmd_context *cmd, const char *path,
> diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
> index 79365ea..f3cf4f5 100644
> --- a/lib/format_text/format-text.h
> +++ b/lib/format_text/format-text.h
> @@ -22,6 +22,7 @@
>  #define FMT_TEXT_NAME "lvm2"
>  #define FMT_TEXT_ALIAS "text"
>  #define FMT_TEXT_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_TEXT_NAME)
> +#define FMT_TEXT_MAX_MDAS_PER_PV 2
>  
>  /*
>   * Archives a vg config.  'retain_days' is the minimum number of
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index a9709d6..d8247dd 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -173,6 +173,8 @@ struct pv_segment {
>  
>  struct format_instance {
>  	const struct format_type *fmt;
> +	int pv_only;

Could this be changed to an enumerated "type" field, instead of pv_only?
If I understand correctly, types are mutually exclusive anyway, and
pv_only is rather confusing and non-obvious when reading the code.

> +
>  	/*
>  	 * Each mda in a vg is on exactly one of the below lists.
>  	 * MDAs on the 'in_use' list will be read from / written to
> @@ -181,6 +183,7 @@ struct format_instance {
>  	 */
>  	struct dm_list metadata_areas_in_use;
>  	struct dm_list metadata_areas_ignored;
> +	void *metadata_areas_index;

I don't currently expect that we would need as much genericity as void *
offers (and that we could use a little extra safety). Would an union be
better here, with an explicit list of types that can go in?

>  	void *private;
>  };
>  
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index fd1948a..c3accaf 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -2881,7 +2881,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
>  					break;
>  				}
>  				if (dm_list_size(&info->mdas)) {
> -					if (!fid_add_mdas(fid, &info->mdas))
> +					if (!fid_add_mdas(fid, &info->mdas,
> +							info->dev->pvid, ID_LEN))
>  						return_NULL;
>  					 
>  					log_debug("Empty mda found for VG %s.", vgname);
> @@ -3912,22 +3913,116 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
>  	return FAILED_EXIST;
>  }
>  
> -void fid_add_mda(struct format_instance *fid, struct metadata_area *mda)
> +static int _convert_key_to_string(const char *key, size_t key_len,
> +				  unsigned subkey, char *buf, size_t buf_len)
>  {
> +	memcpy(buf, key, key_len);
> +	buf += key_len;
> +	buf_len -= key_len;
> +	if ((dm_snprintf(buf, buf_len, "_%u", subkey) == -1))
> +		return_0;
> +
> +	return 1;
> +}

Would it be better to require that key is NULL-terminated? It would
simplify a lot of code, by not needing to pass the length as an extra
parameter everywhere. I know that currently we keep the PV/VG/... IDs in
unterminated strings, but I am quite sure this is not a good idea. I
wouldn't expect it to be a *lot* of work to change things to keep a NULL
termination in there as well. Maybe in a followup patch?

> +int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
> +		 const char *key, size_t key_len, const unsigned subkey)
> +{
> +	char extended_key[PATH_MAX];
> +
>  	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
>  					  &fid->metadata_areas_in_use, &mda->list);
> +
> +	/*
> +	 * Return if the mda is not supposed to be
> +	 * indexed or the index itself is not initialised */
> +	if (!key || !fid->metadata_areas_index)
> +		return 1;
> +
> +	if (!_convert_key_to_string(key, key_len, subkey,
> +				    extended_key, PATH_MAX))
> +		return_0;
> +
> +	/* Add metadata area to index. */
> +	if (fid->pv_only)
> +		((struct metadata_area **)fid->metadata_areas_index)[subkey] = mda;

In this branch, all the extended_key logic above is useless. It could be
made more obvious that only the else branch needs extended_key, by
restructuring the code. Also, is key, subkey and extended_key the right
naming scheme? Maybe full_key instead of extended? And maybe sub_key,
for consistency?

> +	else
> +		dm_hash_insert(fid->metadata_areas_index, extended_key, mda);
> +
> +	return 1;
>  }
>  
> -int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas)
> +int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,
> +		 const char *key, size_t key_len)
>  {
>  	struct metadata_area *mda, *mda_new;
> +	unsigned mda_index = 0;
>  
>  	dm_list_iterate_items(mda, mdas) {
>  		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
>  		if (!mda_new)
>  			return_0;
> -		fid_add_mda(fid, mda_new);
> +
> +		fid_add_mda(fid, mda_new, key, key_len, mda_index);
> +		mda_index++;
>  	}
> +
> +	return 1;
> +}
> +
> +struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
> +					  const char *key, size_t key_len,
> +					  const unsigned subkey)
> +{
> +	char extended_key[PATH_MAX];
> +	struct metadata_area *mda = NULL;
> +
> +	if (!_convert_key_to_string(key, key_len, subkey,
> +				    extended_key, PATH_MAX))
> +		return_NULL;
> +
> +	if (fid->pv_only)
> +		mda = ((struct metadata_area **)fid->metadata_areas_index)[subkey];
> +	else
> +		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index,
> +							      extended_key);

Same about extended_key as above (both path coverage and naming).

> +	return mda;
> +}
> +
> +int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
> +		   const char *key, size_t key_len, const unsigned subkey)
> +{
> +	struct metadata_area *mda_indexed = NULL;
> +	char extended_key[PATH_MAX];
> +
> +	/* At least one of mda or key must be specified. */
> +	if (!mda && !key)
> +		return 1;
> +
> +	if (key) {
> +		/*
> +		 * If both mda and key specified, check given mda
> +		 * with what we find using the index and return
> +		 * immediately if these two do not match.
> +		 */
> +		if (!(mda_indexed = fid_get_mda_indexed(fid, key, key_len, subkey)) ||
> +		     (mda && mda != mda_indexed))
> +			return 1;
> +
> +		if (!_convert_key_to_string(key, key_len, subkey,
> +					    extended_key, PATH_MAX))
> +			return_0;
> +
> +		mda = mda_indexed;
> +
> +		if (fid->pv_only)
> +			((struct metadata_area**)fid->metadata_areas_index)[subkey] = NULL;
> +		else
> +			dm_hash_remove(fid->metadata_areas_index, extended_key);

Redundant code paths again.

> +	}
> +
> +	dm_list_del(&mda->list);
> +
>  	return 1;
>  }
>  
> diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
> index ab7cff0..0fbc954 100644
> --- a/lib/metadata/metadata.h
> +++ b/lib/metadata/metadata.h
> @@ -191,8 +191,14 @@ struct metadata_area *mda_copy(struct dm_pool *mem,
>  unsigned mda_is_ignored(struct metadata_area *mda);
>  void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
>  unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
> -void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
> -int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);
> +int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
> +		 const char *key, size_t key_len, const unsigned subkey);
> +int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,
> +		 const char *key, size_t key_len);
> +int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
> +		   const char *key, size_t key_len, const unsigned subkey);
> +struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
> +		const char *key, size_t key_len, const unsigned subkey);
>  int mdas_empty_or_ignored(struct dm_list *mdas);
>  
>  #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg


