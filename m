From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Mon, 17 Jul 2023 11:51:45 +0000
Subject: [Git][lvmteam/lvm2][main] 14 commits: active: device name limit is NAME_LEN
Message-ID: <64b52b515a2e0_286c76608971b@gitlab-sidekiq-low-urgency-cpu-bound-v2-5867f8689f-sf824.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
c5e43263 by Zdenek Kabelac at 2023-07-17T12:43:39+02:00
active: device name limit is NAME_LEN

Use existing NAME_LEN instead of 257 value.
Add missing backtrace.

- - - - -
f78b0247 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lv_manip: refactor code

Simplify initialization of exec buffer.
Check for misconfigured &#39;fsadm&#39; executable path.

- - - - -
4d231165 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvm-exec: refactor code

Add prepare_exec_args() for reading option list for
thin/cache_repair, thin/cache_check.

- - - - -
409a7962 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
vdo: refactor code

Shuffle code to use prepare_exec_args().
Simplify generation of options string within a single char buffer.

- - - - -
d040b68a by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvconvert: use public LVs for recovery

Replace the use of internal /dev/mapper names with the use of
public LV names /dev/vg/lv for use with repair tools.
For this make the activation of _pmspare LV to be handled as
a component activation with public name.
Metadata is already atomatically activated this way (as readonly).

So if there is any &#39;error&#39; happening, we leave public LVs in
system.

- - - - -
f078ffc5 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvconvert: add support --setactivationskip

When repair thinpool or cachepool, lvm2 leaves original metadata
volume backup. To avoid potential damage of those data, mark such
volume as &#39;read-only&#39; and also allow user to use --setactivationskip
option for this volume.

TODO: likely better default would be to automatically skip, but
that might need some more thinking about recovery reporting doc.

- - - - -
d6771e51 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
lvconvert: code shuffle

Use cachepool name for create name for metadata backup LV.
(so we do not generate 2 &#39;sequences&#39; of metadata filenames.)
Move path preparion before handling _pmspare.
Also drop extra call to sync_local_dev_names() as it&#39;s
already got in sync with call of exec_cmd().

- - - - -
469bcc28 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
cleanup: remove duplicated code

Commit cac4a9743acb826d785c0e51e9a752d8959ced80 moved setting
if layer structed to the function front, but the old code
was still left in original place.

- - - - -
09e17f99 by Zdenek Kabelac at 2023-07-17T12:44:23+02:00
cleanup: remove double //

dev_dir ends with /.

- - - - -
96b2c209 by Zdenek Kabelac at 2023-07-17T12:44:37+02:00
debug: add backtrace

- - - - -
284fdb17 by Zdenek Kabelac at 2023-07-17T12:44:48+02:00
tests: mark test as warning

Until more universal solution for thin-pool corruption gets in place.

- - - - -
06e39625 by Zdenek Kabelac at 2023-07-17T13:21:59+02:00
tests: check for loaded brd

Skip the test if the brd is already loaded in the system.

- - - - -
39cc12e7 by Zdenek Kabelac at 2023-07-17T13:42:58+02:00
tests: use zero device

Change the test to use &#39;zero&#39; backend, so we could use larger size
and get &#39;larger&#39; buffer of dirty blocks for fast CPUs...

- - - - -
ace8a2a8 by Zdenek Kabelac at 2023-07-17T13:47:57+02:00
WHATS_NEW: update

- - - - -


15 changed files:

- WHATS_NEW
- lib/activate/activate.c
- lib/activate/dev_manager.c
- lib/config/defaults.h
- lib/metadata/lv_manip.c
- lib/metadata/thin_manip.c
- lib/metadata/vdo_manip.c
- lib/misc/lvm-exec.c
- lib/misc/lvm-exec.h
- man/lvconvert.8_pregen
- test/shell/devicesfile-serial.sh
- test/shell/lvconvert-cache-abort.sh
- test/shell/thin-flags.sh
- tools/command-lines.in
- tools/lvconvert.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,7 @@
 version 2.03.22 - 
 =================================
+  Always use cachepool name for metadata backup LV for lvconvert --repair.
+  Make metadata backup LVs read-only after pool's lvconvert --repair.
   Improve VDO and Thin support with lvmlockd.
   Handle 'lvextend --usepolicies' for pools for all activation variants.
   Fix memleak in vgchange autoactivation setup.


=====================================
lib/activate/activate.c
=====================================
@@ -2605,6 +2605,8 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (!lv_is_visible(lv) && lv_is_component(lv)) {
 		laopts->read_only = 1;
 		laopts->component_lv = lv;
+	} else if (lv_is_pool_metadata_spare(lv)) {
+		laopts->component_lv = lv;
 	} else if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
@@ -2721,16 +2723,16 @@ static int _remove_dm_dev_by_name(const char *name)
 /* Work all segments of @lv removing any existing, closed "*-missing_N_0" sub devices. */
 static int _lv_remove_any_missing_subdevs(struct logical_volume *lv)
 {
-	if (lv) {
-		uint32_t seg_no = 0;
-		char name[257];
-		struct lv_segment *seg;
+	char name[NAME_LEN];
+	struct lv_segment *seg;
+	uint32_t seg_no = 0;
 
+	if (lv) {
 		dm_list_iterate_items(seg, &lv->segments) {
 			if (dm_snprintf(name, sizeof(name), "%s-%s-missing_%u_0", seg->lv->vg->name, seg->lv->name, seg_no) < 0)
 				return_0;
 			if (!_remove_dm_dev_by_name(name))
-				return 0;
+				return_0;
 
 			seg_no++;
 		}
@@ -2748,10 +2750,10 @@ int lv_deactivate_any_missing_subdevs(const struct logical_volume *lv)
 	for (s = 0; s < seg->area_count; s++) {
 		if (seg_type(seg, s) == AREA_LV &&
 		    !_lv_remove_any_missing_subdevs(seg_lv(seg, s)))
-			return 0;
+			return_0;
 		if (seg->meta_areas && seg_metatype(seg, s) == AREA_LV &&
 		    !_lv_remove_any_missing_subdevs(seg_metalv(seg, s)))
-			return 0;
+			return_0;
 	}
 
 	return 1;


=====================================
lib/activate/dev_manager.c
=====================================
@@ -2457,8 +2457,6 @@ static int _pool_callback(struct dm_tree_node *node,
 			  dm_node_callback_t type, void *cb_data)
 {
 	int ret, status = 0, fd;
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
 	const struct pool_cb_data *data = cb_data;
 	const struct logical_volume *pool_lv = data->pool_lv;
 	const struct logical_volume *mlv = first_seg(pool_lv)->metadata_lv;
@@ -2466,11 +2464,11 @@ static int _pool_callback(struct dm_tree_node *node,
 	long buf[64 / sizeof(long)]; /* buffer for short disk header (64B) */
 	int args = 0;
 	char *mpath;
-	const char *argv[19] = { /* Max supported 15 args */
+	const char *argv[DEFAULT_MAX_EXEC_ARGS + 7] = { /* Max supported 15 args */
 		find_config_tree_str_allow_empty(cmd, data->exec, NULL)
 	};
 
-	if (!*argv[0]) /* *_check tool is unconfigured/disabled with "" setting */
+	if (!argv[0] || !*argv[0]) /* *_check tool is unconfigured/disabled with "" setting */
 		return 1;
 
 	if (lv_is_cache_vol(pool_lv)) {
@@ -2517,26 +2515,8 @@ static int _pool_callback(struct dm_tree_node *node,
 		}
 	}
 
-	if (!(cn = find_config_tree_array(cmd, data->opts, NULL))) {
-		log_error(INTERNAL_ERROR "Unable to find configuration for pool check options.");
-		return 0;
-	}
-
-	for (cv = cn->v; cv && args < 16; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Invalid string in config file: "
-				  "global/%s_check_options.",
-				  data->global);
-			return 0;
-		}
-		if (cv->v.str[0])
-			argv[++args] = cv->v.str;
-	}
-
-	if (args == 16) {
-		log_error("Too many options for %s command.", argv[0]);
-		return 0;
-	}
+	if (!prepare_exec_args(cmd, argv, &args, data->opts))
+		return_0;
 
 	argv[++args] = mpath;
 
@@ -3606,9 +3586,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	    dm_tree_node_get_context(dnode))
 		return 1;
 
-	lvlayer->lv = lv;
-	lvlayer->visible_component = (laopts->component_lv == lv) ? 1 : 0;
-
 	/*
 	 * Add LV to dtree.
 	 * If we're working with precommitted metadata, clear any


=====================================
lib/config/defaults.h
=====================================
@@ -105,6 +105,8 @@
 #  define DEFAULT_DMEVENTD_PATH DMEVENTD_PATH
 #endif
 
+#define DEFAULT_MAX_EXEC_ARGS	15	/* Max number of accepted options args */
+
 #ifdef THIN_CHECK_NEEDS_CHECK
 #  define DEFAULT_THIN_CHECK_OPTION1 "-q"
 #  define DEFAULT_THIN_CHECK_OPTION2 "--clear-needs-check-flag"


=====================================
lib/metadata/lv_manip.c
=====================================
@@ -5013,7 +5013,7 @@ static int _lv_reduce_confirmation(struct logical_volume *lv,
 
 enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
 
-#define FSADM_CMD_MAX_ARGS 6
+#define FSADM_CMD_MAX_ARGS 10
 #define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
 
 /*
@@ -5031,10 +5031,15 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 	struct cmd_context *cmd = vg->cmd;
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
-	const char *argv[FSADM_CMD_MAX_ARGS + 4];
-	unsigned i = 0;
+	unsigned i = 1;
+	const char *argv[FSADM_CMD_MAX_ARGS] = {
+		find_config_tree_str(cmd, global_fsadm_executable_CFG, NULL)
+	};
 
-	argv[i++] = find_config_tree_str(cmd, global_fsadm_executable_CFG, NULL);
+	if (!argv[0] || !*argv[0]) {
+		log_error("Cannot use misconfigured fsadm executable to resize %s.", display_lvname(lv));
+		return 0;
+	}
 
 	if (test_mode())
 		argv[i++] = "--dry-run";
@@ -5071,8 +5076,6 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 		argv[i++] = size_buf;
 	}
 
-	argv[i] = NULL;
-
 	return exec_cmd(cmd, argv, status, 1);
 }
 


=====================================
lib/metadata/thin_manip.c
=====================================
@@ -460,9 +460,7 @@ int thin_pool_prepare_metadata(struct logical_volume *metadata_lv,
 {
 	struct cmd_context *cmd = metadata_lv->vg->cmd;
 	char lv_path[PATH_MAX], md_path[64], buffer[512];
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
-	const char *argv[20] = { /* Max supported 15 option args */
+	const char *argv[DEFAULT_MAX_EXEC_ARGS + 7] = {
 		find_config_tree_str_allow_empty(cmd, global_thin_restore_executable_CFG, NULL)
 	};
 	int args = 0;
@@ -477,25 +475,8 @@ int thin_pool_prepare_metadata(struct logical_volume *metadata_lv,
 		return 0;
 	}
 
-	if (!(cn = find_config_tree_array(cmd, global_thin_restore_options_CFG, NULL))) {
-		log_error(INTERNAL_ERROR "Unable to find configuration for pool check options.");
-		return 0;
-	}
-
-	for (cv = cn->v; cv && args < 16; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Invalid string in config file: "
-				  "global/thin_restore_options.");
-			return 0;
-		}
-		if (cv->v.str[0])
-			argv[++args] = cv->v.str;
-	}
-
-	if (args == 16) {
-		log_error("Too many options for %s command.", argv[0]);
-		return 0;
-	}
+	if (!prepare_exec_args(cmd, argv, &args, global_thin_restore_options_CFG))
+		return_0;
 
 	if (test_mode()) {
 		log_verbose("Test mode: Skipping creation of provisioned thin pool metadata.");


=====================================
lib/metadata/vdo_manip.c
=====================================
@@ -243,21 +243,22 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 				    uint64_t *logical_size)
 {
 	char *dpath, *c;
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
 	struct pipe_data pdata;
 	uint64_t logical_size_aligned = 1;
 	FILE *f;
 	uint64_t lb;
 	unsigned slabbits;
 	unsigned reformatting = 0;
-	int args = 1;
-	char buf_args[5][128];
+	int args = 0;
 	char buf[256]; /* buffer for short disk header (64B) */
-	const char *argv[19] = { /* Max supported args */
+	char *buf_pos = buf;
+	const char *argv[DEFAULT_MAX_EXEC_ARGS + 9] = { /* Max supported args */
 		find_config_tree_str_allow_empty(data_lv->vg->cmd, global_vdo_format_executable_CFG, NULL)
 	};
 
+	if (!prepare_exec_args(data_lv->vg->cmd, argv, &args, global_vdo_format_options_CFG))
+		return_0;
+
 	if (!(dpath = lv_path_dup(data_lv->vg->cmd->mem, data_lv))) {
 		log_error("Failed to build device path for VDO formatting of data volume %s.",
 			  display_lvname(data_lv));
@@ -266,59 +267,31 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 
 	if (*logical_size) {
 		logical_size_aligned = 0;
-		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--logical-size=" FMTu64 "K",
-			       (*logical_size / 2)) < 0)
-			return_0;
 
-		argv[args] = buf_args[args];
-		args++;
+		argv[++args] = buf_pos;
+		buf_pos += 1 + dm_snprintf(buf_pos, 30, "--logical-size=" FMTu64 "K",
+					   (*logical_size / 2));
 	}
 
 	slabbits = 31 - clz(vtp->slab_size_mb / DM_VDO_BLOCK_SIZE * 2 * 1024);  /* to KiB / block_size */
 	log_debug("Slab size %s converted to %u bits.",
 		  display_size(data_lv->vg->cmd, vtp->slab_size_mb * UINT64_C(2 * 1024)), slabbits);
-	if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--slab-bits=%u", slabbits) < 0)
-		return_0;
 
-	argv[args] = buf_args[args];
-	args++;
+	argv[++args] = buf_pos;
+	buf_pos += 1 + dm_snprintf(buf_pos, 30, "--slab-bits=%u", slabbits);
 
 	/* Convert size to GiB units or one of these strings: 0.25, 0.50, 0.75 */
-	if (vtp->index_memory_size_mb >= 1024) {
-		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-memory-size=%u",
-				vtp->index_memory_size_mb / 1024) < 0)
-			return_0;
-	} else if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-memory-size=0.%u",
-			       (vtp->index_memory_size_mb < 512) ? 25 :
-			       (vtp->index_memory_size_mb < 768) ? 50 : 75) < 0)
-		   return_0;
-
-	argv[args] = buf_args[args];
-	args++;
-
-	if (vtp->use_sparse_index)  {
-		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-sparse") < 0)
-			return_0;
-
-		argv[args] = buf_args[args];
-		args++;
-	}
-
-	/* Any other user opts add here */
-	if (!(cn = find_config_tree_array(data_lv->vg->cmd, global_vdo_format_options_CFG, NULL))) {
-		log_error(INTERNAL_ERROR "Unable to find configuration for vdoformat command options.");
-		return 0;
-	}
-
-	for (cv = cn->v; cv && args < 16; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Invalid string in config file: "
-				  "global/vdoformat_options.");
-			return 0;
-		}
-		if (cv->v.str[0])
-			argv[++args] = cv->v.str;
-	}
+	argv[++args] = buf_pos;
+	if (vtp->index_memory_size_mb >= 1024)
+		buf_pos += 1 + dm_snprintf(buf_pos, 30, "--uds-memory-size=%u",
+					   vtp->index_memory_size_mb / 1024);
+	else
+		buf_pos += 1 + dm_snprintf(buf_pos, 30, "--uds-memory-size=0.%2u",
+					   (vtp->index_memory_size_mb < 512) ? 25 :
+					   (vtp->index_memory_size_mb < 768) ? 50 : 75);
+
+	if (vtp->use_sparse_index)
+		argv[++args] = "--uds-sparse";
 
 	/* Only unused VDO data LV could be activated and wiped */
 	if (!dm_list_empty(&data_lv->segs_using_this_lv)) {


=====================================
lib/misc/lvm-exec.c
=====================================
@@ -217,3 +217,34 @@ int pipe_close(struct pipe_data *pdata)
 
 	return (status == 0) ? 1 : 0;
 }
+
+int prepare_exec_args(struct cmd_context *cmd,
+		      const char *argv[], int *argc, int options_id)
+{
+	const struct dm_config_value *cv;
+	const struct dm_config_node *cn;
+
+	if (!(cn = find_config_tree_array(cmd, options_id, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for %s options.",
+			  argv[0]);
+		return 0;
+	}
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (*argc >= DEFAULT_MAX_EXEC_ARGS) {
+			log_error("Too many options for %s command.", argv[0]);
+			return 0;
+		}
+
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Invalid string in config file: "
+				  "global/%s_options.", argv[0]);
+			return 0;
+		}
+
+		if (cv->v.str[0])
+			argv[++(*argc)] = cv->v.str;
+	}
+
+	return 1;
+}


=====================================
lib/misc/lvm-exec.h
=====================================
@@ -67,4 +67,8 @@ FILE *pipe_open(struct cmd_context *cmd, const char *const argv[],
 
 int pipe_close(struct pipe_data *pdata);
 
+/* Prepare argv options list */
+int prepare_exec_args(struct cmd_context *cmd,
+		      const char *argv[], int *argc, int options_id);
+
 #endif


=====================================
man/lvconvert.8_pregen
=====================================
@@ -120,6 +120,8 @@ lvconvert \(em Change logical volume layout
     \fB--repair\fP
 .br
     \fB--replace\fP \fIPV\fP
+.br
+ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
  \fB-s\fP|\fB--snapshot\fP
 .br
@@ -882,6 +884,8 @@ Repair a cache pool.
 .ad l
 [ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
 .br
+[ \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP ]
+.br
 [    \fB--usepolicies\fP ]
 .br
 [    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
@@ -1446,6 +1450,16 @@ Multiple PVs can be replaced by repeating this option.
 See \fBlvmraid\fP(7) for more information.
 .
 .HP
+\fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
+.br
+Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
+An LV with this flag set is not activated unless the
+--ignoreactivationskip option is used by the activation command.
+This flag is set by default on new thin snapshot LVs.
+The flag is not applied to deactivation.
+The current value of the flag is indicated in the lvs lv_attr bits.
+.
+.HP
 \fB-s\fP|\fB--snapshot\fP
 .br
 Combine a former COW snapshot LV with a former origin LV to reverse


=====================================
test/shell/devicesfile-serial.sh
=====================================
@@ -16,6 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+test -d /sys/block/ram0 && skip "Ramdisk already loaded"
+
 test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"
 
 # requires trailing / to match dm


=====================================
test/shell/lvconvert-cache-abort.sh
=====================================
@@ -19,14 +19,15 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_cache 1 3 0 || skip
 
-aux prepare_vg 2
+aux prepare_vg
 
-SIZE_MB=4
+SIZE_MB=200
 
-# Data device on later delayed dev1
-lvcreate -L4 -n cpool $vg "$dev1"
-lvconvert -y --type cache-pool $vg/cpool "$dev2"
-lvcreate -H -L $SIZE_MB -n $lv1 --chunksize 32k --cachemode writeback --cachepool $vg/cpool $vg "$dev2"
+# Use large zero device and later delayed metadata dev1
+lvcreate -L$((SIZE_MB * 2))M --type zero -n cpool $vg
+lvconvert -y --type cache-pool --chunksize 32k $vg/cpool "$dev1"
+lvcreate -L$((SIZE_MB * 2))M --type zero -n $lv1 $vg
+lvconvert -y -H --chunksize 32k --cachemode writeback --cachepool $vg/cpool $vg/$lv1
 
 #
 # Ensure cache gets promoted blocks
@@ -36,7 +37,7 @@ dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=$SIZE_MB oflag=direct || t
 dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=1M count=$SIZE_MB iflag=direct || true
 done
 
-aux delay_dev "$dev2" 0 300 "$(get first_extent_sector "$dev2"):"
+aux delay_dev "$dev1" 0 200 "$(get first_extent_sector "$dev1"):"
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=$SIZE_MB
 
 lvdisplay --maps $vg
@@ -83,5 +84,6 @@ grep -E "Flushing.*aborted" logconvert || {
 
 # check the table got restored
 check grep_dmsetup table $vg-$lv1 "writeback"
+lvdisplay --maps $vg
 
 vgremove -f $vg


=====================================
test/shell/thin-flags.sh
=====================================
@@ -87,7 +87,11 @@ lvchange -ay $vg/$lv2
 # Provisiong and last free bits in metadata
 dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=1 oflag=direct || true
 
-check lv_attr_bit health $vg/pool "M"
+check lv_attr_bit health $vg/pool "M" || {
+        echo "TEST ""WARNING: Missing metadata corruption for this version of thin-pool."
+        exit 0
+}
+
 # TODO - use spaces ??
 check lv_field $vg/pool lv_health_status "metadata_read_only"
 check lv_attr_bit health $vg/$lv2 "-"


=====================================
tools/command-lines.in
=====================================
@@ -795,7 +795,7 @@ AUTOTYPE: snapshot
 # and the LV type is known.
 
 lvconvert --repair LV_cache_cachepool_mirror_raid_thinpool
-OO: --usepolicies, --interval Number, --poolmetadataspare Bool, OO_LVCONVERT
+OO: --usepolicies, --interval Number, --setactivationskip Bool, --poolmetadataspare Bool, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_repair
 DESC: Replace failed PVs in a raid or mirror LV.
@@ -803,6 +803,7 @@ DESC: Repair a thin pool.
 DESC: Repair a cache pool.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: --poolmetadataspare and LV_cache LV_cachepool LV_thinpool
+RULE: --setactivationskip and LV_cache LV_cachepool LV_thinpool
 
 lvconvert --replace PV LV_raid
 OO: OO_LVCONVERT


=====================================
tools/lvconvert.c
=====================================
@@ -19,8 +19,6 @@
 #include "lib/metadata/metadata.h"
 #include "lvconvert_poll.h"
 
-#define MAX_PDATA_ARGS	10	/* Max number of accepted args for d-m-p-d tools */
-
 typedef enum {
 	/* Split:
 	 *   For a mirrored or raid LV, split mirror into two mirrors, optionally tracking
@@ -2338,17 +2336,14 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 				       struct logical_volume *pool_lv,
 				       struct dm_list *pvh, int poolmetadataspare)
 {
-	const char *dmdir = dm_dir();
 	const char *thin_dump =
 		find_config_tree_str_allow_empty(cmd, global_thin_dump_executable_CFG, NULL);
-	const char *thin_repair =
-		find_config_tree_str_allow_empty(cmd, global_thin_repair_executable_CFG, NULL);
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
 	int ret = 0, status;
 	int args = 0;
-	const char *argv[MAX_PDATA_ARGS + 7]; /* Max supported args */
-	char *dm_name, *trans_id_str;
+	const char *argv[DEFAULT_MAX_EXEC_ARGS + 7] = { /* Max supported args */
+		find_config_tree_str_allow_empty(cmd, global_thin_repair_executable_CFG, NULL)
+	};
+	char *trans_id_str;
 	char meta_path[PATH_MAX];
 	char pms_path[PATH_MAX];
 	uint64_t trans_id;
@@ -2357,9 +2352,15 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	struct pipe_data pdata;
 	FILE *f;
 
-	if (!thin_repair || !thin_repair[0]) {
-		log_error("Thin repair commnand is not configured. Repair is disabled.");
-		return 0; /* Checking disabled */
+	if (!argv[0] || !*argv[0]) {
+		log_error("Thin repair command is not configured. Repair is disabled.");
+		return 0;
+	}
+
+	if (thin_pool_is_active(pool_lv)) {
+		log_error("Cannot repair active pool %s.  Use lvchange -an first.",
+			  display_lvname(pool_lv));
+		return 0;
 	}
 
 	pmslv = pool_lv->vg->pool_metadata_spare_lv;
@@ -2374,50 +2375,25 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		pmslv = pool_lv->vg->pool_metadata_spare_lv;
 	}
 
-	if (!(dm_name = dm_build_dm_name(cmd->mem, mlv->vg->name,
-					 mlv->name, NULL)) ||
-	    (dm_snprintf(meta_path, sizeof(meta_path), "%s/%s", dmdir, dm_name) < 0)) {
+	if (dm_snprintf(meta_path, sizeof(meta_path), "%s%s/%s",
+			cmd->dev_dir, mlv->vg->name, mlv->name) < 0) {
 		log_error("Failed to build thin metadata path.");
 		return 0;
 	}
 
-	if (!(dm_name = dm_build_dm_name(cmd->mem, pmslv->vg->name,
-					 pmslv->name, NULL)) ||
-	    (dm_snprintf(pms_path, sizeof(pms_path), "%s/%s", dmdir, dm_name) < 0)) {
+	if (dm_snprintf(pms_path, sizeof(pms_path), "%s%s/%s",
+			cmd->dev_dir, pmslv->vg->name, pmslv->name) < 0) {
 		log_error("Failed to build pool metadata spare path.");
 		return 0;
 	}
 
-	if (!(cn = find_config_tree_array(cmd, global_thin_repair_options_CFG, NULL))) {
-		log_error(INTERNAL_ERROR "Unable to find configuration for global/thin_repair_options");
-		return 0;
-	}
-
-	for (cv = cn->v; cv && args < MAX_PDATA_ARGS; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Invalid string in config file: "
-				  "global/thin_repair_options");
-			return 0;
-		}
-		argv[++args] = cv->v.str;
-	}
-
-	if (args >= MAX_PDATA_ARGS) {
-		log_error("Too many options for thin repair command.");
-		return 0;
-	}
+	if (!prepare_exec_args(cmd, argv, &args, global_thin_repair_options_CFG))
+		return_0;
 
-	argv[0] = thin_repair;
 	argv[++args] = "-i";
 	argv[++args] = meta_path;
 	argv[++args] = "-o";
 	argv[++args] = pms_path;
-	argv[++args] = NULL;
-
-	if (thin_pool_is_active(pool_lv)) {
-		log_error("Active pools cannot be repaired.  Use lvchange -an first.");
-		return 0;
-	}
 
 	if (!activate_lv(cmd, pmslv)) {
 		log_error("Cannot activate pool metadata spare volume %s.",
@@ -2439,7 +2415,7 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 	}
 
 	/* Check matching transactionId when thin-pool is used by lvm2 (transactionId != 0) */
-	if (first_seg(pool_lv)->transaction_id && thin_dump[0]) {
+	if (first_seg(pool_lv)->transaction_id && thin_dump && thin_dump[0]) {
 		argv[0] = thin_dump;
 		argv[1] = pms_path;
 		argv[2] = NULL;
@@ -2455,13 +2431,15 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 			    (trans_id_str = strstr(meta_path, "transaction=\"")) &&
 			    (sscanf(trans_id_str + 13, FMTu64, &trans_id) == 1) &&
 			    (trans_id != first_seg(pool_lv)->transaction_id) &&
-			    ((trans_id - 1) != first_seg(pool_lv)->transaction_id))
+			    ((trans_id - 1) != first_seg(pool_lv)->transaction_id)) {
 				log_error("Transaction id " FMTu64 " from pool \"%s/%s\" "
 					  "does not match repaired transaction id "
 					  FMTu64 " from %s.",
 					  first_seg(pool_lv)->transaction_id,
 					  pool_lv->vg->name, pool_lv->name, trans_id,
 					  pms_path);
+				ret = 0;
+			}
 
 			(void) pipe_close(&pdata); /* killing pipe */
 		}
@@ -2484,16 +2462,6 @@ deactivate_pmslv:
 	if (!ret)
 		return 0;
 
-	if (pmslv == pool_lv->vg->pool_metadata_spare_lv) {
-		pool_lv->vg->pool_metadata_spare_lv = NULL;
-		pmslv->status &= ~POOL_METADATA_SPARE;
-		lv_set_visible(pmslv);
-	}
-
-	/* Try to allocate new pool metadata spare LV */
-	if (!handle_pool_metadata_spare(pool_lv->vg, 0, pvh, poolmetadataspare))
-		stack;
-
 	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", pool_lv->name) < 0) {
 		log_error("Can't prepare new metadata name for %s.", pool_lv->name);
 		return 0;
@@ -2504,9 +2472,23 @@ deactivate_pmslv:
 		return 0;
 	}
 
+	if (pmslv == pool_lv->vg->pool_metadata_spare_lv) {
+		pool_lv->vg->pool_metadata_spare_lv = NULL;
+		pmslv->status &= ~POOL_METADATA_SPARE;
+		lv_set_visible(pmslv);
+	}
+
+	/* Try to allocate new pool metadata spare LV */
+	if (!handle_pool_metadata_spare(pool_lv->vg, 0, pvh, poolmetadataspare))
+		stack;
+
 	if (!detach_pool_metadata_lv(first_seg(pool_lv), &mlv))
 		return_0;
 
+	/* TODO: change default to skip */
+	lv_set_activation_skip(mlv, 1, arg_int_value(cmd, setactivationskip_ARG, 0));
+	mlv->status &= ~LVM_WRITE; /* read-only metadata backup */
+
 	/* Swap _pmspare and _tmeta name */
 	if (!swap_lv_identifiers(cmd, mlv, pmslv))
 		return_0;
@@ -2538,15 +2520,11 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 				   struct logical_volume *cache_lv,
 				   struct dm_list *pvh, int poolmetadataspare)
 {
-	const char *dmdir = dm_dir();
-	const char *cache_repair =
-		find_config_tree_str_allow_empty(cmd, global_cache_repair_executable_CFG, NULL);
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
 	int ret = 0, status;
 	int args = 0;
-	const char *argv[MAX_PDATA_ARGS + 7]; /* Max supported args */
-	char *dm_name;
+	const char *argv[DEFAULT_MAX_EXEC_ARGS + 7] = { /* Max supported args */
+		find_config_tree_str_allow_empty(cmd, global_cache_repair_executable_CFG, NULL)
+	};
 	char meta_path[PATH_MAX];
 	char pms_path[PATH_MAX];
 	struct logical_volume *pool_lv;
@@ -2558,11 +2536,16 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_active(cache_lv)) {
+		log_error("Only inactive cache can be repaired.");
+		return 0;
+	}
+
 	pool_lv = lv_is_cache_pool(cache_lv) ? cache_lv : first_seg(cache_lv)->pool_lv;
 	mlv = first_seg(pool_lv)->metadata_lv;
 
-	if (!cache_repair || !cache_repair[0]) {
-		log_error("Cache repair commnand is not configured. Repair is disabled.");
+	if (!argv[0] || !*argv[0]) {
+		log_error("Cache repair command is not configured. Repair is disabled.");
 		return 0; /* Checking disabled */
 	}
 
@@ -2578,50 +2561,25 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		pmslv = cache_lv->vg->pool_metadata_spare_lv;
 	}
 
-	if (!(dm_name = dm_build_dm_name(cmd->mem, mlv->vg->name,
-					 mlv->name, NULL)) ||
-	    (dm_snprintf(meta_path, sizeof(meta_path), "%s/%s", dmdir, dm_name) < 0)) {
+	if (dm_snprintf(meta_path, sizeof(meta_path), "%s%s/%s",
+			cmd->dev_dir, mlv->vg->name, mlv->name) < 0) {
 		log_error("Failed to build cache metadata path.");
 		return 0;
 	}
 
-	if (!(dm_name = dm_build_dm_name(cmd->mem, pmslv->vg->name,
-					 pmslv->name, NULL)) ||
-	    (dm_snprintf(pms_path, sizeof(pms_path), "%s/%s", dmdir, dm_name) < 0)) {
+	if (dm_snprintf(pms_path, sizeof(pms_path), "%s%s/%s",
+			cmd->dev_dir, pmslv->vg->name, pmslv->name) < 0) {
 		log_error("Failed to build pool metadata spare path.");
 		return 0;
 	}
 
-	if (!(cn = find_config_tree_array(cmd, global_cache_repair_options_CFG, NULL))) {
-		log_error(INTERNAL_ERROR "Unable to find configuration for global/cache_repair_options");
-		return 0;
-	}
-
-	for (cv = cn->v; cv && args < MAX_PDATA_ARGS; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Invalid string in config file: "
-				  "global/cache_repair_options");
-			return 0;
-		}
-		argv[++args] = cv->v.str;
-	}
-
-	if (args >= MAX_PDATA_ARGS) {
-		log_error("Too many options for cache repair command.");
-		return 0;
-	}
+	if (!prepare_exec_args(cmd, argv, &args, global_cache_repair_options_CFG))
+		return_0;
 
-	argv[0] = cache_repair;
 	argv[++args] = "-i";
 	argv[++args] = meta_path;
 	argv[++args] = "-o";
 	argv[++args] = pms_path;
-	argv[++args] = NULL;
-
-	if (lv_is_active(cache_lv)) {
-		log_error("Only inactive cache can be repaired.");
-		return 0;
-	}
 
 	if (!activate_lv(cmd, pmslv)) {
 		log_error("Cannot activate pool metadata spare volume %s.",
@@ -2645,12 +2603,6 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 	/* TODO: any active validation of cache-pool metadata? */
 
 deactivate_mlv:
-	if (!sync_local_dev_names(cmd)) {
-		log_error("Failed to sync local devices before deactivating LV %s.",
-			  display_lvname(mlv));
-		return 0;
-	}
-
 	if (!deactivate_lv(cmd, mlv)) {
 		log_error("Cannot deactivate pool metadata volume %s.",
 			  display_lvname(mlv));
@@ -2658,12 +2610,6 @@ deactivate_mlv:
 	}
 
 deactivate_pmslv:
-	if (!sync_local_dev_names(cmd)) {
-		log_error("Failed to sync local devices before deactivating LV %s.",
-			  display_lvname(pmslv));
-		return 0;
-	}
-
 	if (!deactivate_lv(cmd, pmslv)) {
 		log_error("Cannot deactivate pool metadata spare volume %s.",
 			  display_lvname(pmslv));
@@ -2673,6 +2619,16 @@ deactivate_pmslv:
 	if (!ret)
 		return 0;
 
+	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", pool_lv->name) < 0) {
+		log_error("Can't prepare new metadata name for %s.", display_lvname(pool_lv));
+		return 0;
+	}
+
+	if (!generate_lv_name(cache_lv->vg, meta_path, pms_path, sizeof(pms_path))) {
+		log_error("Can't generate new name for %s.", meta_path);
+		return 0;
+	}
+
 	if (pmslv == cache_lv->vg->pool_metadata_spare_lv) {
 		cache_lv->vg->pool_metadata_spare_lv = NULL;
 		pmslv->status &= ~POOL_METADATA_SPARE;
@@ -2683,19 +2639,13 @@ deactivate_pmslv:
 	if (!handle_pool_metadata_spare(cache_lv->vg, 0, pvh, poolmetadataspare))
 		stack;
 
-	if (dm_snprintf(meta_path, sizeof(meta_path), "%s_meta%%d", cache_lv->name) < 0) {
-		log_error("Can't prepare new metadata name for %s.", cache_lv->name);
-		return 0;
-	}
-
-	if (!generate_lv_name(cache_lv->vg, meta_path, pms_path, sizeof(pms_path))) {
-		log_error("Can't generate new name for %s.", meta_path);
-		return 0;
-	}
-
 	if (!detach_pool_metadata_lv(first_seg(pool_lv), &mlv))
 		return_0;
 
+	/* TODO: change default to skip */
+	lv_set_activation_skip(mlv, 1, arg_int_value(cmd, setactivationskip_ARG, 0));
+	mlv->status &= ~LVM_WRITE; /* read-only metadata backup */
+
 	/* Swap _pmspare and _cmeta name */
 	if (!swap_lv_identifiers(cmd, mlv, pmslv))
 		return_0;
@@ -6039,8 +5989,8 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 		goto out;
 	}
 
-	if (dm_snprintf(pathname, sizeof(pathname), "%s/%s/%s", cmd->dev_dir,
-			lv->vg->name, lv->name) < 0) {
+	if (dm_snprintf(pathname, sizeof(pathname), "%s%s/%s",
+			cmd->dev_dir, lv->vg->name, lv->name) < 0) {
 		log_error("Path name too long to get LV block size %s", display_lvname(lv));
 		goto bad;
 	}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0670338e0b352490a12a5291a2b571846fb7b09d...ace8a2a86813d30ec50b182f9d87db2849b6fd1d

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0670338e0b352490a12a5291a2b571846fb7b09d...ace8a2a86813d30ec50b182f9d87db2849b6fd1d
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230717/e55427c1/attachment-0001.htm>
