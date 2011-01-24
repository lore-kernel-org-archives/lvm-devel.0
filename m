From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:39 +0100
Subject: [PATCH 15/15] const fixing
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <ba0552102c44bd7e7c236041267847d4d740126c.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fixing some of the remaining const warnings - major change:

int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,

Change is needed - as lvm2api seems to expect const behaviour here.
So vg_extend() is doing local strdup for unescaping.

skip_dev_dir return const char* from const char* vg_name.

Rest of the patch is cleanup of related warnings.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.h            |    2 +-
 lib/activate/activate.c          |    4 ++--
 lib/activate/activate.h          |    2 +-
 lib/filters/filter-regex.c       |    2 +-
 lib/metadata/lv.h                |    2 +-
 lib/metadata/lv_manip.c          |    3 ++-
 lib/metadata/metadata-exported.h |    8 ++++----
 lib/metadata/metadata.c          |   27 ++++++++++++++++-----------
 lib/metadata/mirror.c            |   18 +++++++++---------
 lib/report/properties.c          |    3 +--
 lib/report/report.c              |    6 +++---
 liblvm/lvm_vg.c                  |    4 ++--
 tools/lvcreate.c                 |    2 +-
 tools/reporter.c                 |    4 ++--
 tools/toollib.c                  |   10 +++++-----
 tools/toollib.h                  |    4 ++--
 tools/vgcfgrestore.c             |    2 +-
 tools/vgcreate.c                 |    2 +-
 tools/vgextend.c                 |    4 ++--
 tools/vgmerge.c                  |    2 +-
 tools/vgreduce.c                 |    2 +-
 tools/vgrename.c                 |    2 +-
 tools/vgsplit.c                  |    2 +-
 23 files changed, 61 insertions(+), 56 deletions(-)

diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index 95244e1..5bad43a 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -112,7 +112,7 @@ extern void cmd_client_cleanup(struct local_client *client);
 extern int add_client(struct local_client *new_client);
 
 extern void clvmd_cluster_init_completed(void);
-extern void process_message(struct local_client *client, const char *buf,
+extern void process_message(struct local_client *client, char *buf,
 			    int len, const char *csid);
 extern void debuglog(const char *fmt, ... )
   __attribute__ ((format(printf, 1, 2)));
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3670ea4..3331ed2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -162,7 +162,7 @@ int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 {
 	return 0;
 }
-int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr)
 {
 	return 0;
@@ -541,7 +541,7 @@ int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 }
 
 /* FIXME Merge with snapshot_percent */
-int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr)
 {
 	int r;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 2bc73dd..24d8cb0 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -84,7 +84,7 @@ int lv_check_transient(struct logical_volume *lv);
  * Returns 1 if percent has been set, else 0.
  */
 int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent);
-int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
 
 /*
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index e046c71..fc83469 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -135,7 +135,7 @@ static int _build_matcher(struct rfilter *rf, const struct config_value *val)
 	/*
 	 * build the matcher.
 	 */
-	if (!(rf->engine = dm_regex_create(rf->mem, (const char **) regex,
+	if (!(rf->engine = dm_regex_create(rf->mem, (const char * const*) regex,
 					   count)))
 		goto_out;
 	r = 1;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bff36d2..50afa28 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -23,7 +23,7 @@ struct replicator_device;
 
 struct logical_volume {
 	union lvid lvid;
-	char *name;
+	const char *name;
 
 	struct volume_group *vg;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a2ae30e..fc0d97a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1897,7 +1897,8 @@ static int _rename_sub_lv(struct cmd_context *cmd,
 			  struct logical_volume *lv,
 			  const char *lv_name_old, const char *lv_name_new)
 {
-	char *suffix, *new_name;
+	const char *suffix;
+	char *new_name;
 	size_t len;
 
 	/*
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4e2463a..32f0ac3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -410,9 +410,9 @@ void vg_remove_pvs(struct volume_group *vg);
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp);
-int vg_reduce(struct volume_group *vg, char *pv_name);
+int vg_reduce(struct volume_group *vg, const char *pv_name);
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
@@ -698,7 +698,7 @@ struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-percent_t copy_percent(struct logical_volume *lv_mirr);
+percent_t copy_percent(const struct logical_volume *lv_mirr);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
@@ -721,7 +721,7 @@ int lv_has_unknown_segments(const struct logical_volume *lv);
 int vg_has_unknown_segments(const struct volume_group *vg);
 
 struct vgcreate_params {
-	char *vg_name;
+	const char *vg_name;
 	uint32_t extent_size;
 	size_t max_pv;
 	size_t max_lv;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a9c7830..cfc209c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -662,33 +662,38 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
  * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
  *
  */
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp)
 {
 	int i;
+	char *pv_name;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return 0;
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		unescape_colons_and_at_signs(pv_names[i], NULL, NULL);
-		if (!vg_extend_single_pv(vg, pv_names[i], pp))
-			goto bad;
+		if (!(pv_name = dm_strdup(pv_names[i]))) {
+			log_error("Failed to duplicate pv name %s.", pv_names[i]);
+			return 0;
+		}
+		unescape_colons_and_at_signs(pv_name, NULL, NULL);
+		if (!vg_extend_single_pv(vg, pv_name, pp)) {
+			log_error("Unable to add physical volume '%s' to "
+				  "volume group '%s'.", pv_name, vg->name);
+			dm_free(pv_name);
+			return 0;
+		}
+		dm_free(pv_name);
 	}
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
 	return 1;
-
-      bad:
-	log_error("Unable to add physical volume '%s' to "
-		  "volume group '%s'.", pv_names[i], vg->name);
-	return 0;
 }
 
 /* FIXME: use this inside vgreduce_single? */
-int vg_reduce(struct volume_group *vg, char *pv_name)
+int vg_reduce(struct volume_group *vg, const char *pv_name)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -1875,7 +1880,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute__((unused)),
 {
 	struct lv_list *lvl1, *lvl2;
 	struct pv_list *pvl;
-	char *name1, *name2;
+	const char *name1, *name2;
 
 	if (lvs_in_vg_activated(vg_from)) {
 		log_error("Logical volumes in \"%s\" must be inactive",
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index f4d3a10..dc123ec 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1509,7 +1509,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 	return lvs;
 }
 
-percent_t copy_percent(struct logical_volume *lv_mirr)
+percent_t copy_percent(const struct logical_volume *lv_mirr)
 {
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
@@ -1722,8 +1722,8 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 						 int in_sync)
 {
 	struct logical_volume *log_lv;
-	const char *suffix, *c;
-	char *lv_name;
+	const char *suffix, *lv_name;
+	char *tmp_name;
 	size_t len;
 	struct lv_segment *seg;
 
@@ -1742,21 +1742,21 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 	    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER)) {
 		lv_name = lv->name;
 		suffix = "_mlogtmp_%d";
-	} else if ((c = strstr(lv->name, MIRROR_SYNC_LAYER))) {
-		len = c - lv->name + 1;
-		if (!(lv_name = alloca(len)) ||
-		    !dm_snprintf(lv_name, len, "%s", lv->name)) {
+	} else if ((lv_name = strstr(lv->name, MIRROR_SYNC_LAYER))) {
+		len = lv_name - lv->name + 1;
+		if (!(tmp_name = alloca(len)) ||
+		    !dm_snprintf(tmp_name, len, "%s", lv->name)) {
 			log_error("mirror log name allocation failed");
 			return 0;
 		}
+		lv_name = tmp_name;
 		suffix = "_mlog";
 	} else {
 		lv_name = lv->name;
 		suffix = "_mlog";
 	}
 
-	if (!(log_lv = _create_mirror_log(lv, ah, alloc,
-					  (const char *) lv_name, suffix))) {
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv_name, suffix))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 06e11ba..a08470c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -88,8 +88,7 @@ static int _not_implemented_set(void *obj, struct lvm_property_type *prop)
 
 static percent_t _copy_percent(const struct logical_volume *lv) {
 	percent_t perc;
-	if (!lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv,
-			   0, &perc, NULL))
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &perc, NULL))
 		perc = PERCENT_INVALID;
 	return perc;
 }
diff --git a/lib/report/report.c b/lib/report/report.c
index 136ad4c..5079cd1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -615,7 +615,7 @@ static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 {
 	char *repstr = NULL;
 
-	if (!(repstr = id_format_and_copy(mem, (struct id *)data)))
+	if (!(repstr = id_format_and_copy(mem, data)))
 		return_0;
 
 	dm_report_field_set_value(field, repstr, NULL);
@@ -853,7 +853,7 @@ static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute__((unused)))
 {
-	struct logical_volume *lv = (struct logical_volume *) data;
+	const struct logical_volume *lv = (const struct logical_volume *) data;
 	percent_t percent;
 	uint64_t *sortval;
 	char *repstr;
@@ -899,7 +899,7 @@ static struct format_instance _dummy_fid = {
 
 static struct volume_group _dummy_vg = {
 	.fid = &_dummy_fid,
-	.name = (char *) "",
+	.name = "",
 	.system_id = (char *) "",
 	.pvs = { &(_dummy_vg.pvs), &(_dummy_vg.pvs) },
 	.lvs = { &(_dummy_vg.lvs), &(_dummy_vg.lvs) },
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index f087ba4..dfc0c5e 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -79,7 +79,7 @@ int lvm_vg_extend(vg_t vg, const char *device)
 	}
 
 	pvcreate_params_set_defaults(&pp);
-	if (!vg_extend(vg, 1, (char **) &device, &pp)) {
+	if (!vg_extend(vg, 1, &device, &pp)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}
@@ -98,7 +98,7 @@ int lvm_vg_reduce(vg_t vg, const char *device)
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_reduce(vg, (char *)device))
+	if (!vg_reduce(vg, device))
 		return -1;
 	return 0;
 }
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7016417..d1abdf7 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -31,7 +31,7 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
 {
 	int argc = *pargc;
 	char **argv = *pargv, *ptr;
-	char *vg_name;
+	const char *vg_name;
 
 	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index fbd0c27..ebe85e7 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -61,7 +61,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 
 	struct volume_group _free_vg = {
 		.cmd = cmd,
-		.name = (char *)"",
+		.name = "",
 	};
 
         if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
@@ -69,7 +69,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
-		.name = (char *) "",
+		.name = "",
 		.snapshot = NULL,
 		.status = VISIBLE_LV,
 		.major = -1,
diff --git a/tools/toollib.c b/tools/toollib.c
index f76aacd..09e3c37 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -28,7 +28,7 @@ const char *command_name(struct cmd_context *cmd)
 /*
  * Strip dev_dir if present
  */
-char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
+const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 		   unsigned *dev_dir_found)
 {
 	const char *dmdir = dm_dir();
@@ -54,7 +54,7 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 		    *layer) {
 			log_error("skip_dev_dir: Couldn't split up device name %s",
 				  vg_name);
-			return (char *) vg_name;
+			return vg_name;
 		}
 		vglv_sz = strlen(vgname) + strlen(lvname) + 2;
 		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
@@ -62,7 +62,7 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 				 *lvname ? "/" : "",
 				 lvname) < 0) {
 			log_error("vg/lv string alloc failed");
-			return (char *) vg_name;
+			return vg_name;
 		}
 		return vglv;
 	}
@@ -76,7 +76,7 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 	} else if (dev_dir_found)
 		*dev_dir_found = 0;
 
-	return (char *) vg_name;
+	return vg_name;
 }
 
 /*
@@ -898,7 +898,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
  */
 char *default_vgname(struct cmd_context *cmd)
 {
-	char *vg_path;
+	const char *vg_path;
 
 	/* Take default VG from environment? */
 	vg_path = getenv("LVM_VG_NAME");
diff --git a/tools/toollib.h b/tools/toollib.h
index 71e516f..62dd427 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -84,8 +84,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 
 char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
-char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
-		   unsigned *dev_dir_found);
+const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
+			 unsigned *dev_dir_found);
 
 /*
  * Builds a list of pv's from the names in argv.  Used in
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index dc0158f..1f1ab52 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -17,7 +17,7 @@
 
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name = NULL;
+	const char *vg_name = NULL;
 
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 49574f3..62b5ac7 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -74,7 +74,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc, argv, &pp))
+	if (!vg_extend(vg, argc, (const char* const*)argv, &pp))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
diff --git a/tools/vgextend.c b/tools/vgextend.c
index a0c166b..5d2b54d 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -40,7 +40,7 @@ static int _restore_pv(struct volume_group *vg, char *pv_name)
 
 int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name;
+	const char *vg_name;
 	struct volume_group *vg = NULL;
 	int r = ECMD_FAILED;
 	struct pvcreate_params pp;
@@ -107,7 +107,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		}
 
 		/* extend vg */
-		if (!vg_extend(vg, argc, argv, &pp))
+		if (!vg_extend(vg, argc, (const char* const*)argv, &pp))
 			goto_bad;
 
 		if (arg_count(cmd, metadataignore_ARG) &&
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 391764f..adb00a0 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -163,7 +163,7 @@ bad:
 
 int vgmerge(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name_to, *vg_name_from;
+	const char *vg_name_to, *vg_name_from;
 	int opt = 0;
 	int ret = 0, ret_max = 0;
 
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 4aa8f01..5e61cf8 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -457,7 +457,7 @@ bad:
 int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct volume_group *vg;
-	char *vg_name;
+	const char *vg_name;
 	int ret = ECMD_FAILED;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 7a4e730..2f83fc6 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -63,7 +63,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	int found_id = 0;
 	struct dm_list *vgids;
 	struct str_list *sl;
-	char *vg_name_new;
+	const char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
 	struct volume_group *vg = NULL;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index bd2f0ab..b97db97 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -281,7 +281,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct vgcreate_params vp_new;
 	struct vgcreate_params vp_def;
-	char *vg_name_from, *vg_name_to;
+	const char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
 	int existing_vg = 0;
-- 
1.7.3.5


