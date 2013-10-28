From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 28 Oct 2013 11:09:38 -0500
Subject: [RFC PATCH] lvm2app: List snapshot LV information for a given origin LV
In-Reply-To: <1380651882-11757-1-git-send-email-mohan@in.ibm.com>
References: <1380651882-11757-1-git-send-email-mohan@in.ibm.com>
Message-ID: <526E8C42.20603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Mohan,

Please rebase your patch and I will take a look at it.

Thanks,
Tony

On 10/01/2013 01:24 PM, M. Mohan Kumar wrote:
> From: "M. Mohan Kumar" <mohan@in.ibm.com>
> 
> Similar to origin property list snapshot information for a given LV.
> Also this feature extended to lvs command.
> 
> lvs -oname,snapshot displays name of the LV and snapshot LV name if any.
> 
> lvm2app enhanced to support the property "lv_snapshot", the call
> lvm_lv_get_property(lv, "lv_snapshot") returns list of snapshot for
> given lv 'lv'.
> 
> Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
> ---
> For Block Device xlator work, its better to support providing list of
> snapshots for a given origin LV. This feature will be exploited by BD
> xlator to list out snapshots for a given origin LV.
> 
>  lib/metadata/lv.c       |  5 +++++
>  lib/metadata/lv.h       |  1 +
>  lib/metadata/metadata.c | 26 ++++++++++++++++++++++++++
>  lib/metadata/metadata.h |  1 +
>  lib/report/columns.h    |  1 +
>  lib/report/properties.c |  2 ++
>  lib/report/report.c     | 16 ++++++++++++++++
>  7 files changed, 52 insertions(+)
> 
> diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
> index db71cf0..216fd99 100644
> --- a/lib/metadata/lv.c
> +++ b/lib/metadata/lv.c
> @@ -378,6 +378,11 @@ char *lv_tags_dup(const struct logical_volume *lv)
>  	return tags_format_and_copy(lv->vg->vgmem, &lv->tags);
>  }
>  
> +char *lv_snapshot_dup(const struct logical_volume *lv)
> +{
> +	return list_snapshot(lv->vg->vgmem, &lv->snapshot_segs);
> +}
> +
>  uint64_t lv_size(const struct logical_volume *lv)
>  {
>  	return lv->size;
> diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
> index 06f8c60..0da81ef 100644
> --- a/lib/metadata/lv.h
> +++ b/lib/metadata/lv.h
> @@ -94,4 +94,5 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
>  struct logical_volume *lv_ondisk(struct logical_volume *lv);
>  struct profile *lv_config_profile(const struct logical_volume *lv);
>  char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
> +char *lv_snapshot_dup(const struct logical_volume *lv);
>  #endif /* _LVM_LV_H */
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 4ae7726..7753def 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -4629,6 +4629,32 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
>  	return dm_pool_end_object(mem);
>  }
>  
> +char *list_snapshot(struct dm_pool *mem, const struct dm_list *snap)
> +{
> +	struct str_list *sl;
> +	char *c = NULL;
> +	struct lv_segment *snap_seg;
> +
> +	if (!dm_pool_begin_object(mem, 256)) {
> +		log_error("dm_pool_begin_object failed");
> +		return NULL;
> +	}
> +	dm_list_iterate_items_gen(snap_seg, snap, origin_list) {
> +		if (!dm_pool_grow_object(mem, snap_seg->cow->name,
> +					 strlen(snap_seg->cow->name)) ||
> +		    (!dm_pool_grow_object(mem, ",", 1))) {
> +			log_error("dm_pool_grow_object failed");
> +			return NULL;
> +		}
> +	}
> +
> +	if (!dm_pool_grow_object(mem, "\0", 1)) {
> +		log_error("dm_pool_grow_object failed");
> +		return NULL;
> +	}
> +	return dm_pool_end_object(mem);
> +}
> +
>  struct logical_volume *lv_ondisk(struct logical_volume *lv)
>  {
>  	struct volume_group *vg;
> diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
> index 2408c23..e998534 100644
> --- a/lib/metadata/metadata.h
> +++ b/lib/metadata/metadata.h
> @@ -485,6 +485,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
>  
>  uint64_t find_min_mda_size(struct dm_list *mdas);
>  char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
> +char *list_snapshot(struct dm_pool *mem, const struct dm_list *tags);
>  
>  void check_reappeared_pv(struct volume_group *correct_vg,
>  			 struct physical_volume *pv);
> diff --git a/lib/report/columns.h b/lib/report/columns.h
> index 9bb99d3..da09ddb 100644
> --- a/lib/report/columns.h
> +++ b/lib/report/columns.h
> @@ -65,6 +65,7 @@ FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration p
>  FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
>  FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
>  FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
> +FIELD(LVS, lv, STR, "snapshot", lvid, 8, snapshot, lv_snapshot, "Snapshots for this LV.", 0)
>  
>  FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
>  FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
> diff --git a/lib/report/properties.c b/lib/report/properties.c
> index 3eeb78a..2481c69 100644
> --- a/lib/report/properties.c
> +++ b/lib/report/properties.c
> @@ -235,6 +235,8 @@ GET_LV_STR_PROPERTY_FN(lv_active, lv_active_dup(lv->vg->vgmem, lv))
>  #define _lv_active_set prop_not_implemented_set
>  GET_LV_STR_PROPERTY_FN(lv_profile, lv_profile_dup(lv->vg->vgmem, lv))
>  #define _lv_profile_set prop_not_implemented_set
> +GET_LV_STR_PROPERTY_FN(lv_snapshot, lv_snapshot_dup(lv))
> +#define _lv_snapshot_set prop_not_implemented_set
>  
>  /* VG */
>  GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
> diff --git a/lib/report/report.c b/lib/report/report.c
> index 77332a2..2070a55 100644
> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -97,6 +97,21 @@ static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
>  	return 1;
>  }
>  
> +static int _snapshot_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
> +		      struct dm_report_field *field,
> +		      const void *data, void *private __attribute__((unused)))
> +{
> +	const struct logical_volume *lv = (const struct logical_volume *) data;
> +	char *tags_str;
> +
> +	if (!(tags_str = list_snapshot(mem, &lv->snapshot_segs)))
> +		return 0;
> +
> +	dm_report_field_set_value(field, tags_str, NULL);
> +
> +	return 1;
> +}
> +
>  static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
>  			 struct dm_report_field *field,
>  			 const void *data, void *private)
> @@ -124,6 +139,7 @@ static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
>  	return 1;
>  }
>  
> +
>  static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
>  		       struct dm_report_field *field,
>  		       const void *data, void *private)
> 


