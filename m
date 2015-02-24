From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 24 Feb 2015 09:39:51 +0100
Subject: master - lvm1: Reenable sys ID.
In-Reply-To: <20150223230937.E62EF6142F@fedorahosted.org>
References: <20150223230937.E62EF6142F@fedorahosted.org>
Message-ID: <54EC38D7.8020400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Oops, apparently this does not work as expected all the time.
When lvm1 format is used with lvmetad, lvm1_system_id is NULL causing 
segfaults like here:

http://saturnin.lab.eng.brq.redhat.com:8010/lvm2-reports/Fedora_Rawhide_x86_64_KVM/1386/ndev-lvmetad:shell_lvmetad-lvm1.sh.txt

#0  0x00007fcb416417d7 in export_pv (cmd=0x7fcb41bdb030, 
mem=mem at entry=0x7fcb41c32c40, vg=vg at entry=0x7fcb41c33dd0, 
pvd=pvd at entry=0x7fcb41c3be10,
     pv=pv at entry=0x7fcb41c34148) at format1/import-export.c:159

(gdb) l
154                             return_0;
155                     strncpy((char *)pvd->vg_name, pv->vg_name, 
sizeof(pvd->vg_name));
156             }
157
158             /* Preserve existing system_id if it exists */
159             if (vg && *vg->lvm1_system_id)
160                     strncpy((char *)pvd->system_id, 
vg->lvm1_system_id, sizeof(pvd->system_id));
161
162             /* Is VG already exported or being exported? */
163             if (vg && vg_is_exported(vg)) {
(gdb) p *vg

$1 = {cmd = 0x7fcb41bdb030, vgmem = 0x7fcb41c2c6c0, fid = 
0x7fcb41c2b560, vginfo = 0x0, cmd_vgs = 0x0, cmd_missing_vgs = 0, seqno 
= 2,
   vg_ondisk = 0x7fcb41c37de0, cft_precommitted = 0x0, vg_precommitted = 
0x0, alloc = ALLOC_NORMAL, profile = 0x0, status = 780, id = {
     uuid = "fyJ5DLOsqAI3tzK92lgdqO7YFcIA0uZ1"}, name = 0x7fcb41c33efa 
"LVMTEST3295vg1", old_name = 0x0, system_id = 0x7fcb41c33f10 "", 
lvm1_system_id = 0x0,
   extent_size = 8192, extent_count = 28, free_count = 28, max_lv = 255, 
max_pv = 255, pv_count = 4, pvs = {n = 0x7fcb41c34118, p = 0x7fcb41c34598},
   pvs_to_create = {n = 0x7fcb41c33e98, p = 0x7fcb41c33e98}, lvs = {n = 
0x7fcb41c33ea8, p = 0x7fcb41c33ea8}, tags = {n = 0x7fcb41c33eb8, p = 
0x7fcb41c33eb8},
   removed_pvs = {n = 0x7fcb41c33ec8, p = 0x7fcb41c33ec8}, open_mode = 
0, read_status = 0, mda_copies = 0, hostnames = 0x7fcb41c2bd80,
   pool_metadata_spare_lv = 0x0}

agk, do you need to know more?

On 02/24/2015 12:09 AM, Alasdair Kergon wrote:
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df227be37cb113a1093b2ed092af582c5a900315
> Commit:        df227be37cb113a1093b2ed092af582c5a900315
> Parent:        2fc2928978bb592a6b62a18bbbb0acee10efbfe2
> Author:        Alasdair G Kergon <agk@redhat.com>
> AuthorDate:    Mon Feb 23 23:03:52 2015 +0000
> Committer:     Alasdair G Kergon <agk@redhat.com>
> CommitterDate: Mon Feb 23 23:03:52 2015 +0000
>
> lvm1: Reenable sys ID.
>
> Move the lvm1 sys ID into vg->lvm1_system_id and reenable the #if 0
> LVM1 code.  Still display the new-style system ID in the same
> reporting field, though, as only one can be set.
> Add a format feature flag FMT_SYSTEM_ON_PVS for LVM1 and disallow
> access to LVM1 VGs if a new-style system ID has been set.
> Treat the new vg->system_id as const.
> ---
>   WHATS_NEW                        |    1 +
>   lib/commands/toolcontext.c       |   10 ++++----
>   lib/commands/toolcontext.h       |    2 +-
>   lib/format1/format1.c            |    3 +-
>   lib/format1/import-export.c      |   48 +++++++++++++++-----------------------
>   lib/metadata/metadata-exported.h |    3 ++
>   lib/metadata/metadata.c          |   21 ++++++++++++++--
>   lib/metadata/vg.c                |   13 ++++++++--
>   lib/metadata/vg.h                |    3 +-
>   lib/report/columns.h             |    4 +-
>   lib/report/report.c              |   11 ++++++++
>   11 files changed, 74 insertions(+), 45 deletions(-)
>
> diff --git a/WHATS_NEW b/WHATS_NEW
> index 0ae007d..983189c 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,6 @@
>   Version 2.02.117 -
>   ====================================
> +  Install /etc/lvm/lvmlocal.conf template with local section for systemid.
>     Record creation_host_system_id in lvm2 metadata.
>     Reinstate recursive config file tag section processing. (2.02.99)
>     Add 'lvm systemid' to display the current system ID.
> diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
> index d81de97..7539b4a 100644
> --- a/lib/commands/toolcontext.c
> +++ b/lib/commands/toolcontext.c
> @@ -58,7 +58,7 @@ static const size_t linebuffer_size = 4096;
>   /*
>    * Copy the input string, removing invalid characters.
>    */
> -char *system_id_from_string(struct cmd_context *cmd, const char *str)
> +const char *system_id_from_string(struct cmd_context *cmd, const char *str)
>   {
>   	char *system_id;
>
> @@ -82,12 +82,12 @@ char *system_id_from_string(struct cmd_context *cmd, const char *str)
>   	return system_id;
>   }
>
> -static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file)
> +static const char *_read_system_id_from_file(struct cmd_context *cmd, const char *file)
>   {
>   	char *line = NULL;
>   	size_t line_size;
>   	char *start, *end;
> -	char *system_id = NULL;
> +	const char *system_id = NULL;
>   	FILE *fp;
>
>   	if (!file || !strlen(file) || !file[0])
> @@ -132,13 +132,13 @@ static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file
>   	return system_id;
>   }
>
> -static char *_system_id_from_source(struct cmd_context *cmd, const char *source)
> +static const char *_system_id_from_source(struct cmd_context *cmd, const char *source)
>   {
>   	char filebuf[PATH_MAX];
>   	const char *file;
>   	const char *etc_str;
>   	const char *str;
> -	char *system_id = NULL;
> +	const char *system_id = NULL;
>
>   	if (!strcasecmp(source, "uname")) {
>   		if (cmd->hostname)
> diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
> index 8b3e48e..8b38fb1 100644
> --- a/lib/commands/toolcontext.h
> +++ b/lib/commands/toolcontext.h
> @@ -163,6 +163,6 @@ int init_lvmcache_orphans(struct cmd_context *cmd);
>
>   struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format);
>
> -char *system_id_from_string(struct cmd_context *cmd, const char *system_id_string);
> +const char *system_id_from_string(struct cmd_context *cmd, const char *str);
>
>   #endif
> diff --git a/lib/format1/format1.c b/lib/format1/format1.c
> index b0943b1..f7df7c3 100644
> --- a/lib/format1/format1.c
> +++ b/lib/format1/format1.c
> @@ -590,7 +590,8 @@ struct format_type *init_format(struct cmd_context *cmd)
>   	fmt->alias = NULL;
>   	fmt->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
>   	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE |
> -			FMT_RESTRICTED_READAHEAD | FMT_OBSOLETE;
> +			FMT_RESTRICTED_READAHEAD | FMT_OBSOLETE |
> +			FMT_SYSTEMID_ON_PVS;
>   	fmt->private = NULL;
>
>   	dm_list_init(&fmt->mda_ops);
> diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
> index 9318945..a3c060f 100644
> --- a/lib/format1/import-export.c
> +++ b/lib/format1/import-export.c
> @@ -69,14 +69,14 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
>   	memcpy(&pv->vgid, vgd->vg_uuid, sizeof(vg->id));
>
>   	/* Store system_id from first PV if PV belongs to a VG */
> -	if (vg && !*vg->system_id)
> -		strncpy(vg->system_id, (char *)pvd->system_id, NAME_LEN);
> +	if (vg && !*vg->lvm1_system_id)
> +		strncpy(vg->lvm1_system_id, (char *)pvd->system_id, NAME_LEN);
>
>   	if (vg &&
> -	    strncmp(vg->system_id, (char *)pvd->system_id, sizeof(pvd->system_id)))
> +	    strncmp(vg->lvm1_system_id, (char *)pvd->system_id, sizeof(pvd->system_id)))
>   		    log_very_verbose("System ID %s on %s differs from %s for "
>   				     "volume group", pvd->system_id,
> -				     pv_dev_name(pv), vg->system_id);
> +				     pv_dev_name(pv), vg->lvm1_system_id);
>
>   	/*
>   	 * If exported, we still need to flag in pv->status too because
> @@ -125,19 +125,17 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
>   	return 1;
>   }
>
> -#if 0
> -static int _system_id(struct cmd_context *cmd, char *s, const char *prefix)
> +static int _lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix)
>   {
>
>   	if (dm_snprintf(s, NAME_LEN, "%s%s%lu",
>   			 prefix, cmd->hostname, time(NULL)) < 0) {
> -		log_error("Generated system_id too long");
> +		log_error("Generated LVM1 format system_id too long");
>   		return 0;
>   	}
>
>   	return 1;
>   }
> -#endif
>
>   int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused)),
>   	      struct volume_group *vg,
> @@ -158,22 +156,18 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
>   	}
>
>   	/* Preserve existing system_id if it exists */
> -#if 0
> -	if (vg && *vg->system_id)
> -		strncpy((char *)pvd->system_id, vg->system_id, sizeof(pvd->system_id));
> -#endif
> +	if (vg && *vg->lvm1_system_id)
> +		strncpy((char *)pvd->system_id, vg->lvm1_system_id, sizeof(pvd->system_id));
>
>   	/* Is VG already exported or being exported? */
>   	if (vg && vg_is_exported(vg)) {
> -#if 0
>   		/* Does system_id need setting? */
> -		if (!*vg->system_id ||
> -		    strncmp(vg->system_id, EXPORTED_TAG,
> +		if (!*vg->lvm1_system_id ||
> +		    strncmp(vg->lvm1_system_id, EXPORTED_TAG,
>   			    sizeof(EXPORTED_TAG) - 1)) {
> -			if (!_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
> +			if (!_lvm1_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
>   				return_0;
>   		}
> -#endif
>   		if (strlen((char *)pvd->vg_name) + sizeof(EXPORTED_TAG) >
>   		    sizeof(pvd->vg_name)) {
>   			log_error("Volume group name %s too long to export",
> @@ -183,25 +177,23 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
>   		strcat((char *)pvd->vg_name, EXPORTED_TAG);
>   	}
>
> -#if 0
>   	/* Is VG being imported? */
> -	if (vg && !vg_is_exported(vg) && *vg->system_id &&
> -	    !strncmp(vg->system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
> -		if (!_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
> +	if (vg && !vg_is_exported(vg) && *vg->lvm1_system_id &&
> +	    !strncmp(vg->lvm1_system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
> +		if (!_lvm1_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
>   			return_0;
>   	}
>
>   	/* Generate system_id if PV is in VG */
>   	if (!pvd->system_id[0])
> -		if (!_system_id(cmd, (char *)pvd->system_id, ""))
> +		if (!_lvm1_system_id(cmd, (char *)pvd->system_id, ""))
>   			return_0;
>
>   	/* Update internal system_id if we changed it */
>   	if (vg &&
> -	    (!*vg->system_id ||
> -	     strncmp(vg->system_id, (char *)pvd->system_id, sizeof(pvd->system_id))))
> -		    strncpy(vg->system_id, (char *)pvd->system_id, NAME_LEN);
> -#endif
> +	    (!*vg->lvm1_system_id ||
> +	     strncmp(vg->lvm1_system_id, (char *)pvd->system_id, sizeof(pvd->system_id))))
> +		    strncpy(vg->lvm1_system_id, (char *)pvd->system_id, NAME_LEN);
>
>   	//pvd->pv_major = MAJOR(pv->dev);
>
> @@ -233,11 +225,9 @@ int import_vg(struct dm_pool *mem,
>   	if (!(vg->name = dm_pool_strdup(mem, (char *)dl->pvd.vg_name)))
>   		return_0;
>
> -	if (!(vg->system_id = dm_pool_zalloc(mem, NAME_LEN + 1)))
> +	if (!(vg->lvm1_system_id = dm_pool_zalloc(mem, NAME_LEN + 1)))
>   		return_0;
>
> -	*vg->system_id = '\0';
> -
>   	if (vgd->vg_status & VG_EXPORTED)
>   		vg->status |= EXPORTED_VG;
>
> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index 6631b1f..2dbaaf0 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -139,6 +139,9 @@
>   #define FMT_CONFIG_PROFILE	0x000000800U	/* Supports configuration profiles? */
>   #define FMT_OBSOLETE		0x000001000U	/* Obsolete format? */
>   #define FMT_NON_POWER2_EXTENTS	0x000002000U	/* Non-power-of-2 extent sizes? */
> +#define FMT_SYSTEMID_ON_PVS	0x000004000U	/* System ID is stored on PVs not VG */
> +
> +#define systemid_on_pvs(vg)	((vg)->fid->fmt->features & FMT_SYSTEMID_ON_PVS)
>
>   /* Mirror conversion type flags */
>   #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index c04b67c..9fb289d 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -1045,10 +1045,10 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
>   	}
>
>   	vg->status = (RESIZEABLE_VG | LVM_READ | LVM_WRITE);
> -	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
> +	vg->system_id = NULL;
> +	if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
>   		goto_bad;
>
> -	*vg->system_id = '\0';
>   	vg->extent_size = DEFAULT_EXTENT_SIZE * 2;
>   	vg->max_lv = DEFAULT_MAX_LV;
>   	vg->max_pv = DEFAULT_MAX_PV;
> @@ -4380,6 +4380,15 @@ static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg
>   static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
>   {
>   	/*
> +	 * LVM1 VGs must not be accessed if a new-style LVM2 system ID is set.
> +	 */
> +	if (cmd->system_id && systemid_on_pvs(vg)) {
> +		log_error("Cannot access VG %s with LVM1 system ID \"%s\" when host system ID is set.",
> +			  vg->name, vg->lvm1_system_id);
> +		return 0;
> +	}
> +
> +	/*
>   	 * A VG without a system_id can be accessed by anyone.
>   	 */
>   	if (!vg->system_id || !vg->system_id[0])
> @@ -4436,8 +4445,14 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
>    */
>   static int _access_vg(struct cmd_context *cmd, struct volume_group *vg, uint32_t *failure)
>   {
> -	if (!is_real_vg(vg->name))
> +	if (!is_real_vg(vg->name)) {
> +		/* Disallow use of LVM1 orphans when a host system ID is set. */
> +		if (cmd->system_id && *cmd->system_id && systemid_on_pvs(vg)) {
> +			*failure |= FAILED_SYSTEMID;
> +			return_0;
> +		}
>   		return 1;
> +	}
>
>   	if (!_access_vg_clustered(cmd, vg)) {
>   		*failure |= FAILED_CLUSTERED;
> diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
> index dbc791b..0143b7b 100644
> --- a/lib/metadata/vg.c
> +++ b/lib/metadata/vg.c
> @@ -121,7 +121,7 @@ char *vg_name_dup(const struct volume_group *vg)
>
>   char *vg_system_id_dup(const struct volume_group *vg)
>   {
> -	return dm_pool_strdup(vg->vgmem, vg->system_id);
> +	return dm_pool_strdup(vg->vgmem, vg->system_id ? : vg->lvm1_system_id ? : "");
>   }
>
>   char *vg_uuid_dup(const struct volume_group *vg)
> @@ -605,15 +605,22 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
>
>   int vg_set_system_id(struct volume_group *vg, const char *system_id)
>   {
> -	if (!system_id) {
> +	if (!system_id || !*system_id) {
>   		vg->system_id = NULL;
>   		return 1;
>   	}
>
> +	if (systemid_on_pvs(vg)) {
> +		log_error("Metadata format %s does not support this type of system id.",
> +			  vg->fid->fmt->name);
> +		return 0;
> +	}
> +
>   	if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
> -		log_error("vg_set_system_id no mem");
> +		log_error("Failed to allocate memory for system_id in vg_set_system_id.");
>   		return 0;
>   	}
> +
>   	return 1;
>   }
>
> diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
> index 23d60ac..2964b82 100644
> --- a/lib/metadata/vg.h
> +++ b/lib/metadata/vg.h
> @@ -67,7 +67,8 @@ struct volume_group {
>   	struct id id;
>   	const char *name;
>   	const char *old_name;		/* Set during vgrename and vgcfgrestore */
> -	char *system_id;
> +	const char *system_id;
> +	char *lvm1_system_id;
>
>   	uint32_t extent_size;
>   	uint32_t extent_count;
> diff --git a/lib/report/columns.h b/lib/report/columns.h
> index 1dd56ac..a957d98 100644
> --- a/lib/report/columns.h
> +++ b/lib/report/columns.h
> @@ -139,8 +139,8 @@ FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_polic
>   FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Set if VG is clustered.", 0)
>   FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
>   FIELD(VGS, vg, SIZ, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
> -FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID of the VG indicating its owner.", 0)
> -FIELD(VGS, vg, STR, "System ID", system_id, 9, string, vg_systemid, "System ID of the VG indicating its owner.", 0)
> +FIELD(VGS, vg, STR, "SYS ID", cmd, 6, vgsystemid, vg_sysid, "System ID of the VG indicating which host owns it.", 0)
> +FIELD(VGS, vg, STR, "System ID", cmd, 9, vgsystemid, vg_systemid, "System ID of the VG indicating which host owns it.", 0)
>   FIELD(VGS, vg, SIZ, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
>   FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
>   FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
> diff --git a/lib/report/report.c b/lib/report/report.c
> index cf3d9b6..b5418e5 100644
> --- a/lib/report/report.c
> +++ b/lib/report/report.c
> @@ -984,6 +984,16 @@ static int _vgfree_disp(struct dm_report *rh, struct dm_pool *mem,
>   	return _size64_disp(rh, mem, field, &freespace, private);
>   }
>
> +static int _vgsystemid_disp(struct dm_report *rh, struct dm_pool *mem,
> +			    struct dm_report_field *field,
> +			    const void *data, void *private)
> +{
> +	const struct volume_group *vg = (const struct volume_group *) data;
> +	const char *repstr = vg->system_id ? : vg->lvm1_system_id ? : "";
> +
> +	return _string_disp(rh, mem, field, &repstr, private);
> +}
> +
>   static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
>   		      struct dm_report_field *field,
>   		      const void *data, void *private __attribute__((unused)))
> @@ -1864,6 +1874,7 @@ static struct volume_group _dummy_vg = {
>   	.fid = &_dummy_fid,
>   	.name = "",
>   	.system_id = (char *) "",
> +	.lvm1_system_id = (char *) "",
>   	.pvs = DM_LIST_HEAD_INIT(_dummy_vg.pvs),
>   	.lvs = DM_LIST_HEAD_INIT(_dummy_vg.lvs),
>   	.tags = DM_LIST_HEAD_INIT(_dummy_vg.tags),
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


