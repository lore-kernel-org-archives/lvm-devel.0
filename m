From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  8 Jun 2015 15:48:27 +0800
Subject: [RFC 1/6] Enable the keep_log feature while creating a mirror device
In-Reply-To: <1433749712-11837-1-git-send-email-lzhong@suse.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
Message-ID: <1433749712-11837-2-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Here we refer to the --trackchanges parameter in lvconvert to enable
this feature. This feature depends on handle_errors.
---
 lib/metadata/lv_manip.c          |  1 +
 lib/metadata/metadata-exported.h |  1 +
 lib/mirror/mirrored.c            |  3 +++
 lib/misc/lvm-globals.c           | 11 +++++++++++
 lib/misc/lvm-globals.h           |  2 ++
 libdm/libdevmapper.h             |  1 +
 libdm/libdm-deptree.c            | 17 ++++++++++++++++-
 tools/commands.h                 |  4 ++--
 tools/lvcreate.c                 |  4 +++-
 9 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1251a5d..e955a02 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7036,6 +7036,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		/* FIXME This will not pass cluster lock! */
 		init_mirror_in_sync(lp->nosync);
+		init_track_changes(lp->track_changes);
 
 		if (lp->nosync) {
 			log_warn("WARNING: New %s won't be synchronised. "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0e52153..7b5e078 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -848,6 +848,7 @@ struct lvcreate_params {
 	int32_t minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+	int track_changes; /* mirror */
 	int pool_metadata_spare; /* pools */
 	int type;   /* type arg is given */
 	int temporary; /* temporary LV */
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index e57e9bb..8447b8e 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -371,6 +371,9 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	if (_block_on_error_available && !(seg->status & PVMOVE))
 		log_flags |= DM_BLOCK_ON_ERROR;
 
+	if (track_changes())
+		log_flags |= DM_KEEPLOG;
+
 	return dm_tree_node_add_mirror_target_log(node, region_size, clustered, log_dlid, area_count, log_flags);
 }
 
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 6455788..3a00beb 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -39,6 +39,7 @@ static int _ignorelockingfailure = 0;
 static int _security_level = SECURITY_LEVEL;
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
+static int _track_changes = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
@@ -121,6 +122,11 @@ void init_mirror_in_sync(int in_sync)
 	_mirror_in_sync = in_sync;
 }
 
+void init_track_changes(int track_changes)
+{
+	_track_changes = track_changes;
+}
+
 void init_dmeventd_monitor(int reg)
 {
 	_dmeventd_monitor = reg;
@@ -277,6 +283,11 @@ int mirror_in_sync(void)
 	return _mirror_in_sync;
 }
 
+int track_changes(void)
+{
+	return _track_changes;
+}
+
 int dmeventd_monitor_mode(void)
 {
 	return _dmeventd_monitor;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index b25f4ae..55ff3c2 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -37,6 +37,7 @@ void init_ignorelockingfailure(int level);
 void init_lockingfailed(int level);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
+void init_track_changes(int track_changes);
 void init_dmeventd_monitor(int reg);
 void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
@@ -69,6 +70,7 @@ int ignorelockingfailure(void);
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
+int track_changes(void);
 int background_polling(void);
 int ignore_suspended_devices(void);
 int ignore_lvm_mirrors(void);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c811641..30cab21 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -717,6 +717,7 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 #define DM_FORCESYNC		0x00000002	/* Force resync */
 #define DM_BLOCK_ON_ERROR	0x00000004	/* On error, suspend I/O */
 #define DM_CORELOG		0x00000008	/* In-memory log */
+#define DM_KEEPLOG      0x00000010  /* Keep log while device missing*/
 
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 				       uint32_t region_size,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 578f645..c08c776 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2167,6 +2167,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	int block_on_error = 0;
 	int handle_errors = 0;
 	int dm_log_userspace = 0;
+	int track_changes = 0;
 	struct utsname uts;
 	unsigned log_parm_count;
 	int pos = 0, parts;
@@ -2203,6 +2204,14 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 			block_on_error = 1;
 	}
 
+	if (seg->flags & DM_KEEPLOG) {
+		track_changes = 1;
+		if (!handle_errors) {
+			log_error("Feature keep_log depends on handle_errors");
+			return_0;
+		}
+	}
+
 	if (seg->clustered) {
 		/* Cluster mirrors require a UUID */
 		if (!seg->uuid)
@@ -2229,6 +2238,10 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	/* "handle_errors" is a feature arg now */
 	if (handle_errors)
 		log_parm_count--;
+	
+	if (track_changes)
+		log_parm_count--;
+	
 
 	/* DM_CORELOG does not count in the param list */
 	if (seg->flags & DM_CORELOG)
@@ -2280,7 +2293,9 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
 		return_0;
 
-	if (handle_errors)
+	if (handle_errors && track_changes)
+		EMIT_PARAMS(pos, " 2 handle_errors keep_log");
+	else if (handle_errors)
 		EMIT_PARAMS(pos, " 1 handle_errors");
 
 	return 1;
diff --git a/tools/commands.h b/tools/commands.h
index 8e87681..003fc57 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -315,7 +315,7 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
-   "\t[-m|--mirrors Mirrors [--nosync]\n"
+   "\t[-m|--mirrors Mirrors [--nosync][--trackchanges]\n"
    "\t  [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
@@ -381,7 +381,7 @@ xx(lvcreate,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, errorwhenfull_ARG,
    extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
-   minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
+   minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG, trackchanges_ARG,
    noudevsync_ARG, permission_ARG, persistent_ARG,
    //pooldatasize_ARG,
    poolmetadatasize_ARG, poolmetadataspare_ARG,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e41f76c..ac64677 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -535,6 +535,7 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
 
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
+	lp->track_changes = arg_is_set(cmd, trackchanges_ARG);
 
 	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&
 	    ((lp->region_size = get_default_region_size(cmd)) <= 0)) {
@@ -720,7 +721,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 
 #define MIRROR_ARGS \
 	corelog_ARG,\
-	mirrorlog_ARG
+	mirrorlog_ARG,\
+	trackchanges_ARG
 
 #define MIRROR_RAID_ARGS \
 	nosync_ARG,\
-- 
1.8.1.4


