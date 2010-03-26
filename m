From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Mar 2010 12:15:08 -0400
Subject: [PATCH] Fix vg_write/vg_commit to not reset position in metadata ring buffer on vgrename
In-Reply-To: <4BACBD1F.80101@redhat.com>
References: <4BACBD1F.80101@redhat.com>
Message-ID: <1269620108.2508.3.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2010-03-26 at 14:56 +0100, Peter Rajnoha wrote:
> We should write metadata into next position in the ring buffer while calling vgrename.
> At this code level (_vg_write_raw), we're not able to determine if this is a rename
> or not. If yes, then accompanying VG structure passed here has a new name set,
> not the old one.
> 
> When looking for a location where to put metadata next, we're given a NULL value because
> of failed VG name comparison (in _find_vg_rlocn) between the name in existing metadata
> and metadata we're just about to write.
> 
> This resets the position in the ring buffer, overwriting any existing metadata
> (and also incorrectly updates the cache to "orphan" afterwards).
> 
> This patch just adds old_name item in struct volume_group that we can check and use
> if necessary and detect renames at lower layers as well.
> 
> Peter
> 
>  lib/format_text/format-text.c    |   17 +++++++++++++----
>  lib/metadata/metadata-exported.h |    1 +
>  lib/metadata/metadata.c          |    2 ++
>  3 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
> index ad4db34..4856d07 100644
> --- a/lib/format_text/format-text.c
> +++ b/lib/format_text/format-text.c
> @@ -380,6 +380,10 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
>  	} else
>  		*precommitted = 0;
>  
> +	/* Do not check non-existent metadata. */
> +	if (!rlocn->offset && !rlocn->size)
> +		return NULL;
> +
>  	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
>  	/* FIXME Ignore if checksum incorrect!!! */
>  	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
> @@ -387,9 +391,11 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
>  		goto_bad;
>  
>  	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
> -	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{')) {
> +	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
>  		return rlocn;
> -	}
> +	else
> +		log_debug("Volume group name found in metadata does "
> +			  "not match expected name %s.", vgname);
>  
>        bad:
>  	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
> @@ -542,7 +548,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
>  	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
>  		goto_out;
>  
> -	rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit);
> +	rlocn = _find_vg_rlocn(&mdac->area, mdah,
> +			vg->old_name ? vg->old_name : vg->name, &noprecommit);
>  	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
>  
>  	if (!fidtc->raw_metadata_buf &&
> @@ -647,7 +654,9 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
>  	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
>  		goto_out;
>  
> -	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
> +	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah,
> +				     vg->old_name ? vg->old_name : vg->name,
> +				     &noprecommit))) {
>  		mdah->raw_locns[0].offset = 0;
>  		mdah->raw_locns[0].size = 0;
>  		mdah->raw_locns[0].checksum = 0;
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index 2f1405f..855ab47 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -216,6 +216,7 @@ struct volume_group {
>  
>  	struct id id;
>  	char *name;
> +	char *old_name;
>  	char *system_id;
>  
>  	uint32_t extent_size;
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 020e897..867e004 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -437,6 +437,8 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
>  	struct dm_pool *mem = vg->vgmem;
>  	struct pv_list *pvl;
>  
> +	vg->old_name = vg->name;
> +
>  	if (!(vg->name = dm_pool_strdup(mem, new_name))) {
>  		log_error("vg->name allocation failed for '%s'", new_name);
>  		return 0;
> 

Seems reasonable.

But while we're on this topic, can you explain why _find_vg_rlocn() is
necessary at all?

Why are we not just using a precommit or non-precommit area here.  This
whole function looks like a hack and it makes some things harder.  IMO
if we could get rid of it we'd be better off.


