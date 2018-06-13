From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 15:33:16 -0400
Subject: master - Remove independent metadata areas
Message-ID: <201806131933.w5DJXGMJ016915@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17f5572bc972c932bcf62fc2bff3029268ae0109
Commit:        17f5572bc972c932bcf62fc2bff3029268ae0109
Parent:        9df6f601e019d0e5b052d9e6aa0bd9dc732e411d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 12:25:19 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 12:25:19 2018 -0500

Remove independent metadata areas

in which metadata is stored in files on the local fs
instead of on PVs.
---
 lib/cache/lvmcache.c          |   36 -----
 lib/commands/toolcontext.c    |    3 -
 lib/commands/toolcontext.h    |    1 -
 lib/config/config_settings.h  |   15 +--
 lib/format_text/format-text.c |  340 +----------------------------------------
 lib/format_text/layout.h      |    2 -
 lib/metadata/metadata.c       |   12 --
 7 files changed, 2 insertions(+), 407 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8db964c..c7e3903 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -60,7 +60,6 @@ struct lvmcache_vginfo {
 	uint32_t mda_checksum;
 	size_t mda_size;
 	int seqno;
-	int independent_metadata_location; /* metadata read from independent areas */
 	int scan_summary_mismatch; /* vgsummary from devs had mismatching seqno or checksum */
 };
 
@@ -794,16 +793,6 @@ next:
  * VG metadata to figure out that a dev with no metadata belongs
  * to a particular VG, so a device with no mdas will not be linked
  * to that VG after a scan.
- *
- * (In the special case where VG metadata is stored in files on the
- * file system (configured in lvm.conf), the
- * vginfo->independent_metadata_location flag is set during label scan.
- * When we get here to rescan, we are revalidating the device to VG
- * mapping from label scan by repeating the label scan on a subset of
- * devices.  If we see independent_metadata_location is set from the
- * initial label scan, we know that there is nothing to do because
- * there is no device to VG mapping to revalidate, since the VG metadata
- * comes directly from files.)
  */
 
 int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid)
@@ -821,16 +810,6 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
 		return_0;
 
-	/*
-	 * When the VG metadata is from an independent location,
-	 * then rescanning the devices in the VG won't find the
-	 * metadata, and will destroy the vginfo/info associations
-	 * that were created during label scan when the
-	 * independent locations were read.
-	 */
-	if (vginfo->independent_metadata_location)
-		return 1;
-
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(devl = malloc(sizeof(*devl)))) {
 			log_error("device_list element allocation failed");
@@ -897,7 +876,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	struct lvmcache_info *info;
 	struct lvmcache_vginfo *vginfo;
 	struct device_list *devl;
-	struct format_type *fmt;
 	int vginfo_count = 0;
 
 	int r = 0;
@@ -998,12 +976,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		}
 	}
 
-	/* Perform any format-specific scanning e.g. text files */
-	if (cmd->independent_metadata_areas)
-		dm_list_iterate_items(fmt, &cmd->formats)
-			if (fmt->ops->scan && !fmt->ops->scan(fmt, NULL))
-				goto out;
-
 	r = 1;
 
       out:
@@ -2234,14 +2206,6 @@ int lvmcache_vgid_is_cached(const char *vgid) {
 	return 1;
 }
 
-void lvmcache_set_independent_location(const char *vgname)
-{
-	struct lvmcache_vginfo *vginfo;
-
-	if ((vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
-		vginfo->independent_metadata_location = 1;
-}
-
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 {
 	if (!info)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index aca93f9..8c18fc6 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1796,7 +1796,6 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	cmd->threaded = threaded ? 1 : 0;
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
-	cmd->independent_metadata_areas = 0;
 	cmd->ignore_clustered_vgs = 0;
 	cmd->hosttags = 0;
 	dm_list_init(&cmd->arg_value_groups);
@@ -1968,8 +1967,6 @@ static void _destroy_formats(struct cmd_context *cmd, struct dm_list *formats)
 		dm_list_del(&fmt->list);
 		fmt->ops->destroy(fmt);
 	}
-
-	cmd->independent_metadata_areas = 0;
 }
 
 static void _destroy_segtypes(struct dm_list *segtypes)
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index fee35d4..18e1b7d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -146,7 +146,6 @@ struct cmd_context {
 	unsigned metadata_read_only:1;
 	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;			/* set if running within a thread e.g. clvmd */
-	unsigned independent_metadata_areas:1;	/* active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
 	unsigned include_historical_lvs:1;	/* also process/report/display historical LVs */
 	unsigned record_historical_lvs:1;	/* record historical LVs */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 32a6476..8aa4879 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1509,20 +1509,7 @@ cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
-	"Directories holding live copies of text format metadata.\n"
-	"These directories must not be on logical volumes!\n"
-	"It's possible to use LVM with a couple of directories here,\n"
-	"preferably on different (non-LV) filesystems, and with no other\n"
-	"on-disk metadata (pvmetadatacopies = 0). Or this can be in addition\n"
-	"to on-disk metadata areas. The feature was originally added to\n"
-	"simplify testing and is not supported under low memory situations -\n"
-	"the machine could lock up. Never edit any files in these directories\n"
-	"by hand unless you are absolutely sure you know what you are doing!\n"
-	"Use the supplied toolset to make changes (e.g. vgcfgrestore).\n"
-	"#\n"
-	"Example\n"
-	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n"
-	"#\n")
+	  "This setting is no longer used.\n")
 
 cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
 cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 907944a..a1fce86 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -45,16 +45,6 @@ struct text_fid_context {
 	uint32_t raw_metadata_buf_size;
 };
 
-struct dir_list {
-	struct dm_list list;
-	char dir[0];
-};
-
-struct raw_list {
-	struct dm_list list;
-	struct device_area dev_area;
-};
-
 int rlocn_is_ignored(const struct raw_locn *rlocn)
 {
 	return (rlocn->flags & RAW_LOCN_IGNORED ? 1 : 0);
@@ -505,22 +495,6 @@ static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *md
 	return new_start_offset;
 }
 
-static int _raw_holds_vgname(struct format_instance *fid,
-			     struct device_area *dev_area, const char *vgname)
-{
-	int r = 0;
-	int noprecommit = 0;
-	struct mda_header *mdah;
-
-	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area, 0)))
-		return_0;
-
-	if (_read_metadata_location_vg(dev_area, mdah, 0, vgname, &noprecommit))
-		r = 1;
-
-	return r;
-}
-
 static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      const char *vgname,
 					      struct device_area *area,
@@ -1118,75 +1092,6 @@ static int _vg_remove_file(struct format_instance *fid __attribute__((unused)),
 	return 1;
 }
 
-static int _scan_file(const struct format_type *fmt, const char *vgname)
-{
-	struct dirent *dirent;
-	struct dir_list *dl;
-	struct dm_list *dir_list;
-	char *tmp;
-	DIR *d;
-	struct volume_group *vg;
-	struct format_instance *fid;
-	struct format_instance_ctx fic;
-	char path[PATH_MAX];
-	char *scanned_vgname;
-
-	dir_list = &((struct mda_lists *) fmt->private)->dirs;
-
-	if (!dm_list_empty(dir_list))
-		log_debug_metadata("Scanning independent files for %s", vgname ? vgname : "VGs");
-
-	dm_list_iterate_items(dl, dir_list) {
-		if (!(d = opendir(dl->dir))) {
-			log_sys_error("opendir", dl->dir);
-			continue;
-		}
-		while ((dirent = readdir(d)))
-			if (strcmp(dirent->d_name, ".") &&
-			    strcmp(dirent->d_name, "..") &&
-			    (!(tmp = strstr(dirent->d_name, ".tmp")) ||
-			     tmp != dirent->d_name + strlen(dirent->d_name)
-			     - 4)) {
-				scanned_vgname = dirent->d_name;
-
-				/* If vgname supplied, only scan that one VG */
-				if (vgname && strcmp(vgname, scanned_vgname))
-					continue;
-
-				if (dm_snprintf(path, PATH_MAX, "%s/%s",
-						 dl->dir, scanned_vgname) < 0) {
-					log_error("Name too long %s/%s",
-						  dl->dir, scanned_vgname);
-					break;
-				}
-
-				/* FIXME stat file to see if it's changed */
-				/* FIXME: Check this fid is OK! */
-				fic.type = FMT_INSTANCE_PRIVATE_MDAS;
-				fic.context.private = NULL;
-				if (!(fid = _text_create_text_instance(fmt, &fic))) {
-					stack;
-					break;
-				}
-
-				log_debug_metadata("Scanning independent file %s for VG %s", path, scanned_vgname);
-
-				if ((vg = _vg_read_file_name(fid, scanned_vgname,
-							     path))) {
-					/* FIXME Store creation host in vg */
-					lvmcache_update_vg(vg, 0);
-					lvmcache_set_independent_location(vg->name);
-					release_vg(vg);
-				}
-			}
-
-		if (closedir(d))
-			log_sys_error("closedir", dl->dir);
-	}
-
-	return 1;
-}
-
 int read_metadata_location_summary(const struct format_type *fmt,
 		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
 		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
@@ -1326,55 +1231,6 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	return 1;
 }
 
-/* used for independent_metadata_areas */
-
-static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
-{
-	struct raw_list *rl;
-	struct dm_list *raw_list;
-	struct volume_group *vg;
-	struct format_instance fid;
-	struct lvmcache_vgsummary vgsummary = { 0 };
-	struct mda_header *mdah;
-
-	raw_list = &((struct mda_lists *) fmt->private)->raws;
-
-	if (!dm_list_empty(raw_list))
-		log_debug_metadata("Scanning independent raw locations for %s", vgname ? vgname : "VGs");
-
-	fid.fmt = fmt;
-	dm_list_init(&fid.metadata_areas_in_use);
-	dm_list_init(&fid.metadata_areas_ignored);
-
-	dm_list_iterate_items(rl, raw_list) {
-		log_debug_metadata("Scanning independent dev %s", dev_name(rl->dev_area.dev));
-
-		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area, 0))) {
-			stack;
-			continue;
-		}
-
-		if (read_metadata_location_summary(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
-			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0);
-			if (vg) {
-				lvmcache_update_vg(vg, 0);
-				lvmcache_set_independent_location(vg->name);
-			}
-		}
-	}
-
-	return 1;
-}
-
-/* used for independent_metadata_areas */
-
-static int _text_scan(const struct format_type *fmt, const char *vgname)
-{
-	_scan_file(fmt, vgname);
-	_scan_raw(fmt, vgname);
-	return 1;
-}
-
 struct _write_single_mda_baton {
 	const struct format_type *fmt;
 	struct physical_volume *pv;
@@ -1535,28 +1391,6 @@ static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical
 	return 1;
 }
 
-static int _add_raw(struct dm_list *raw_list, struct device_area *dev_area)
-{
-	struct raw_list *rl;
-
-	/* Already present? */
-	dm_list_iterate_items(rl, raw_list) {
-		/* FIXME Check size/overlap consistency too */
-		if (rl->dev_area.dev == dev_area->dev &&
-		    rl->dev_area.start == dev_area->start)
-			return 1;
-	}
-
-	if (!(rl = malloc(sizeof(struct raw_list)))) {
-		log_error("_add_raw allocation failed");
-		return 0;
-	}
-	memcpy(&rl->dev_area, dev_area, sizeof(*dev_area));
-	dm_list_add(raw_list, &rl->list);
-
-	return 1;
-}
-
 /*
  * Copy constructor for a metadata_locn.
  */
@@ -1709,36 +1543,13 @@ static void _text_destroy_instance(struct format_instance *fid)
 	}
 }
 
-static void _free_dirs(struct dm_list *dir_list)
-{
-	struct dm_list *dl, *tmp;
-
-	dm_list_iterate_safe(dl, tmp, dir_list) {
-		dm_list_del(dl);
-		free(dl);
-	}
-}
-
-static void _free_raws(struct dm_list *raw_list)
-{
-	struct dm_list *rl, *tmp;
-
-	dm_list_iterate_safe(rl, tmp, raw_list) {
-		dm_list_del(rl);
-		free(rl);
-	}
-}
-
 static void _text_destroy(struct format_type *fmt)
 {
 	if (fmt->orphan_vg)
 		free_orphan_vg(fmt->orphan_vg);
 
-	if (fmt->private) {
-		_free_dirs(&((struct mda_lists *) fmt->private)->dirs);
-		_free_raws(&((struct mda_lists *) fmt->private)->raws);
+	if (fmt->private)
 		free(fmt->private);
-	}
 
 	free(fmt);
 }
@@ -1963,15 +1774,9 @@ static void *_create_text_context(struct dm_pool *mem, struct text_context *tc)
 static int _create_vg_text_instance(struct format_instance *fid,
                                     const struct format_instance_ctx *fic)
 {
-	static char path[PATH_MAX];
 	uint32_t type = fic->type;
 	struct text_fid_context *fidtc;
 	struct metadata_area *mda;
-	struct mda_context *mdac;
-	struct dir_list *dl;
-	struct raw_list *rl;
-	struct dm_list *dir_list, *raw_list;
-	struct text_context tc;
 	struct lvmcache_vginfo *vginfo;
 	const char *vg_name, *vg_id;
 
@@ -2001,53 +1806,12 @@ static int _create_vg_text_instance(struct format_instance *fid,
 			return 0;
 		}
 
-		if (type & FMT_INSTANCE_AUX_MDAS) {
-			dir_list = &((struct mda_lists *) fid->fmt->private)->dirs;
-			dm_list_iterate_items(dl, dir_list) {
-				if (dm_snprintf(path, PATH_MAX, "%s/%s", dl->dir, vg_name) < 0) {
-					log_error("Name too long %s/%s", dl->dir, vg_name);
-					return 0;
-				}
-
-				if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
-					return_0;
-				mda->ops = &_metadata_text_file_ops;
-				tc.path_live = path;
-				tc.path_edit = tc.desc = NULL;
-				mda->metadata_locn = _create_text_context(fid->mem, &tc);
-				mda->status = 0;
-				fid_add_mda(fid, mda, NULL, 0, 0);
-			}
-
-			raw_list = &((struct mda_lists *) fid->fmt->private)->raws;
-			dm_list_iterate_items(rl, raw_list) {
-				/* FIXME Cache this; rescan below if some missing */
-				if (!_raw_holds_vgname(fid, &rl->dev_area, vg_name))
-					continue;
-
-				if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda))))
-					return_0;
-
-				if (!(mdac = dm_pool_zalloc(fid->mem, sizeof(*mdac))))
-					return_0;
-				mda->metadata_locn = mdac;
-				/* FIXME Allow multiple dev_areas inside area */
-				memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
-				mda->ops = &_metadata_text_raw_ops;
-				mda->status = 0;
-				/* FIXME MISTAKE? mda->metadata_locn = context; */
-				fid_add_mda(fid, mda, NULL, 0, 0);
-			}
-		}
-
 		if (type & FMT_INSTANCE_MDAS) {
 			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
 				goto_out;
 			if (!lvmcache_fid_add_mdas_vg(vginfo, fid))
 				goto_out;
 		}
-
-		/* FIXME If PV list or raw metadata area count are not as expected rescan */
 	}
 
 out:
@@ -2440,7 +2204,6 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 }
 
 static struct format_handler _text_handler = {
-	.scan = _text_scan,
 	.pv_initialise = _text_pv_initialise,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
@@ -2455,84 +2218,11 @@ static struct format_handler _text_handler = {
 	.destroy = _text_destroy
 };
 
-static int _add_dir(const char *dir, struct dm_list *dir_list)
-{
-	struct dir_list *dl;
-
-	if (dm_create_dir(dir)) {
-		if (!(dl = malloc(sizeof(struct dm_list) + strlen(dir) + 1))) {
-			log_error("_add_dir allocation failed");
-			return 0;
-		}
-		log_very_verbose("Adding text format metadata dir: %s", dir);
-		strcpy(dl->dir, dir);
-		dm_list_add(dir_list, &dl->list);
-		return 1;
-	}
-
-	return 0;
-}
-
-static int _get_config_disk_area(struct cmd_context *cmd,
-				 const struct dm_config_node *cn, struct dm_list *raw_list)
-{
-	struct device_area dev_area;
-	const char *id_str;
-	struct id id;
-
-	if (!(cn = cn->child)) {
-		log_error("Empty metadata disk_area section of config file");
-		return 0;
-	}
-
-	if (!dm_config_get_uint64(cn, "start_sector", &dev_area.start)) {
-		log_error("Missing start_sector in metadata disk_area section "
-			  "of config file");
-		return 0;
-	}
-	dev_area.start <<= SECTOR_SHIFT;
-
-	if (!dm_config_get_uint64(cn, "size", &dev_area.size)) {
-		log_error("Missing size in metadata disk_area section "
-			  "of config file");
-		return 0;
-	}
-	dev_area.size <<= SECTOR_SHIFT;
-
-	if (!dm_config_get_str(cn, "id", &id_str)) {
-		log_error("Missing uuid in metadata disk_area section "
-			  "of config file");
-		return 0;
-	}
-
-	if (!id_read_format(&id, id_str)) {
-		log_error("Invalid uuid in metadata disk_area section "
-			  "of config file: %s", id_str);
-		return 0;
-	}
-
-	if (!(dev_area.dev = lvmcache_device_from_pvid(cmd, &id, NULL))) {
-		char buffer[64] __attribute__((aligned(8)));
-
-		if (!id_write_format(&id, buffer, sizeof(buffer)))
-			log_error("Couldn't find device.");
-		else
-			log_error("Couldn't find device with uuid '%s'.",
-				  buffer);
-
-		return 0;
-	}
-
-	return _add_raw(raw_list, &dev_area);
-}
-
 struct format_type *create_text_format(struct cmd_context *cmd)
 {
 	struct format_instance_ctx fic;
 	struct format_instance *fid;
 	struct format_type *fmt;
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
 	struct mda_lists *mda_lists;
 
 	if (!(fmt = malloc(sizeof(*fmt)))) {
@@ -2556,8 +2246,6 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		return NULL;
 	}
 
-	dm_list_init(&mda_lists->dirs);
-	dm_list_init(&mda_lists->raws);
 	mda_lists->file_ops = &_metadata_text_file_ops;
 	mda_lists->raw_ops = &_metadata_text_raw_ops;
 	fmt->private = (void *) mda_lists;
@@ -2576,32 +2264,6 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		goto bad;
 	}
 
-	if ((cn = find_config_tree_array(cmd, metadata_dirs_CFG, NULL))) {
-		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Invalid string in config file: "
-					  "metadata/dirs");
-				goto bad;
-			}
-
-			if (!_add_dir(cv->v.str, &mda_lists->dirs)) {
-				log_error("Failed to add %s to text format "
-					  "metadata directory list ", cv->v.str);
-				goto bad;
-			}
-			cmd->independent_metadata_areas = 1;
-		}
-	}
-
-	if ((cn = find_config_tree_node(cmd, metadata_disk_areas_CFG_SUBSECTION, NULL))) {
-		/* FIXME: disk_areas do not work with lvmetad - the "id" can't be found. */
-		for (cn = cn->child; cn; cn = cn->sib) {
-			if (!_get_config_disk_area(cmd, cn, &mda_lists->raws))
-				goto_bad;
-			cmd->independent_metadata_areas = 1;
-		}
-	}
-
 	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name)))
 		goto_bad;
 
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 0a63708..e1462f1 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -84,8 +84,6 @@ struct mda_header *raw_read_mda_header(const struct format_type *fmt,
 				       struct device_area *dev_area, int primary_mda);
 
 struct mda_lists {
-	struct dm_list dirs;
-	struct dm_list raws;
 	struct metadata_area_ops *file_ops;
 	struct metadata_area_ops *raw_ops;
 };
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a4308bc..40854de 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4026,9 +4026,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		inconsistent = 0;
 
-		/* Independent MDAs aren't supported under low memory */
-		if (!cmd->independent_metadata_areas && prioritized_section())
-			return_NULL;
 		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
 			return_NULL;
 
@@ -5211,15 +5208,6 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 	if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
 		lvmcache_label_scan(cmd);
 		if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
-			/* Independent MDAs aren't supported under low memory */
-			if (!cmd->independent_metadata_areas && critical_section()) {
-				/*
-				 * FIXME: Disallow calling this function if
-				 * critical_section() is true.
-				 */
-				unlock_vg(cmd, NULL, vgname);
-				return FAILED_LOCKING;
-			}
 			lvmcache_label_scan(cmd);
 			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0))
 				return SUCCESS; /* vgname not found after scanning */


