From: Petr Rockai <prockai@redhat.com>
Date: Tue, 25 Jan 2011 14:30:00 +0100
Subject: [PATCH 04/17] Add format_instance support for pv_read.
In-Reply-To: <1295867048-21558-5-git-send-email-prajnoha@redhat.com> (Peter
	Rajnoha's message of "Mon, 24 Jan 2011 12:03:55 +0100")
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
	<1295867048-21558-5-git-send-email-prajnoha@redhat.com>
Message-ID: <87lj29ru07.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:

> We don't need to store metadata areas in a separate "mdas" parameter
> since it is in the pv->fid now. If the fid is not defined yet and is
> NULL, pv_read code will create a new one (if there's no VG fid yet
> where the metadata areas read off of a PV should be attached to).

This is somewhat hairy... With this patch, it's starting to seem that PV
will sometimes point to a VG FID and other times to PV FID. Is there a
good reason for that? Is the PV FID only used with orphan PVs?

I think this is something that really needs to be documented. If nothing
else, the format_instance type value (as suggested in an earlier
comment) should read ORPHAN_PV_FID and VG_FID. It also does raise the
question, why we don't always use VG_FID even for orphans, given how we
have an orphans VG? Would simply using the orphans VG FID be more
consistent overall?

Please also see below.

> ---
>  lib/metadata/metadata.c |   26 +++++++++++++++++++++-----
>  1 files changed, 21 insertions(+), 5 deletions(-)
>
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index ed2084d..f6ea0e5 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -37,6 +37,7 @@
>  static struct physical_volume *_pv_read(struct cmd_context *cmd,
>  					struct dm_pool *pvmem,
>  					const char *pv_name,
> +					struct format_instance *fid,
>  					struct dm_list *mdas,
>  					uint64_t *label_sector,
>  					int warnings, int scan_label_only);
> @@ -166,6 +167,7 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
>  	dm_list_add(&vg->pvs, &pvl->list);
>  	vg->pv_count++;
>  	pvl->pv->vg = vg;
> +	pvl->pv->fid = vg->fid;
>  }
>  
>  void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
> @@ -1813,7 +1815,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
>  	struct physical_volume *pv;
>  
>  	dm_list_init(&mdas);
> -	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0))) {
> +	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0))) {
>  		log_error("Physical volume %s not found", pv_name);
>  		return NULL;
>  	}
> @@ -1822,7 +1824,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
>  		/* If a PV has no MDAs - need to search all VGs for it */
>  		if (!scan_vgs_for_pvs(cmd, 1))
>  			return_NULL;
> -		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
> +		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, NULL, 1, 0))) {
>  			log_error("Physical volume %s not found", pv_name);
>  			return NULL;
>  		}
> @@ -2644,7 +2646,8 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
>  	}
>  
>  	dm_list_iterate_items(info, &vginfo->infos) {
> -		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, warnings, 0))) {
> +		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), vg->fid,
> +				    NULL, NULL, warnings, 0))) {
>  			continue;
>  		}
>  		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
> @@ -3357,13 +3360,14 @@ struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
>  				struct dm_list *mdas, uint64_t *label_sector,
>  				int warnings, int scan_label_only)
>  {
> -	return _pv_read(cmd, cmd->mem, pv_name, mdas, label_sector, warnings, scan_label_only);
> +	return _pv_read(cmd, cmd->mem, pv_name, NULL, mdas, label_sector, warnings, scan_label_only);
>  }
>  
>  /* FIXME Use label functions instead of PV functions */
>  static struct physical_volume *_pv_read(struct cmd_context *cmd,
>  					struct dm_pool *pvmem,
>  					const char *pv_name,
> +					struct format_instance *fid,
>  					struct dm_list *mdas,
>  					uint64_t *label_sector,
>  					int warnings, int scan_label_only)
> @@ -3407,6 +3411,18 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
>  	if (!alloc_pv_segment_whole_pv(pvmem, pv))
>  		goto_bad;
>  
> +	if (fid)
> +		fid_add_mdas(fid, &info->mdas, (const char *) &pv->id, ID_LEN);
> +	else {
> +		if (!(pv->fid = pv->fmt->ops->create_instance(pv->fmt,
> +						(const char *) &pv->id,
> +						NULL, NULL, NULL))) {
> +			log_error("_pv_read: Couldn't create format instance "
> +				  "for PV %s", pv_name);
> +			goto bad;
> +		}
> +	}
> +

The code above is certainly confusing. A comment is needed, explaining
what is going on. Please explain that non-NULL "fid" means that this PV
belongs to a VG, and the fid variable points to that VG's fid.

Also, why mdas are added to the VG fid, but the (orphan) PV fid is left
empty? Should the code read

if (!fid) {
    if (!(fid = pv->fid = ...
}

fid_add_mdas(fid, ...)

?

If, as I suspect, it's because create_instance adds the MDA's itself,
please add a comment to that effect. (Also, is it necessary that
create_instance does this? I am not sure it is entirely intuitive...)

>  	return pv;
>  bad:
>  	_free_pv(pvmem, pv);
> @@ -4213,5 +4229,5 @@ struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name)
>  	struct dm_list mdas;
>  
>  	dm_list_init(&mdas);
> -	return _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0);
> +	return _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0);
>  }

Yours,
   Petr


