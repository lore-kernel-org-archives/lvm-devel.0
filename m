From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:18 +0000 (UTC)
Subject: master - mirror: extra parsing for mirrorlog arg
Message-ID: <20141024144118.B6F5860CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11ea72cfd872d4a54e7db52e347688039378bc72
Commit:        11ea72cfd872d4a54e7db52e347688039378bc72
Parent:        29c14a11943d52e47424140ffa3b91dc9b095bc5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 21:02:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

mirror: extra parsing for mirrorlog arg

Put validation of mirrorlog arg into a separate function.
---
 lib/config/defaults.h            |    2 +-
 lib/metadata/metadata-exported.h |    8 ++++++++
 lib/metadata/mirror.c            |   27 +++++++++++++++++++++++++++
 tools/args.h                     |    2 +-
 tools/lvconvert.c                |   23 ++++-------------------
 tools/lvcreate.c                 |   19 ++++---------------
 tools/lvmcmdline.c               |   13 +++++++++++++
 tools/tools.h                    |    1 +
 8 files changed, 59 insertions(+), 36 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2cb1e5a..2724cd1 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -53,7 +53,7 @@
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 
 #define DEFAULT_MIRROR_SEGTYPE "raid1"
-#define DEFAULT_MIRRORLOG "disk"
+#define DEFAULT_MIRRORLOG MIRROR_LOG_DISK
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 19508ab..7467b64 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -225,6 +225,12 @@ typedef enum {
 	DONT_PROMPT_OVERRIDE = 2 /* Add even more dangerous prompts */
 } force_t;
 
+enum {
+	MIRROR_LOG_CORE,
+	MIRROR_LOG_DISK,
+	MIRROR_LOG_MIRRORED,
+};
+
 typedef enum {
 	THIN_DISCARDS_IGNORE,
 	THIN_DISCARDS_NO_PASSDOWN,
@@ -1003,6 +1009,8 @@ int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      int (*is_removable)(struct logical_volume *, void *),
 		      void *removable_baton, uint64_t status_mask);
+int get_mirror_log_count(const char *mirrorlog, int *log_count);
+const char *get_mirror_log_name(int log_count);
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index d89e5cd..a943ac4 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2273,3 +2273,30 @@ int lv_remove_mirrors(struct cmd_context *cmd __attribute__((unused)),
 	return remove_mirrors_from_segments(lv, new_mirrors, status_mask);
 }
 
+int get_mirror_log_count(const char *mirrorlog, int *log_count)
+{
+	if (!strcmp("core", mirrorlog))
+		*log_count = MIRROR_LOG_CORE;
+	else if (!strcmp("disk", mirrorlog))
+		*log_count = MIRROR_LOG_DISK;
+	else if (!strcmp("mirrored", mirrorlog))
+		*log_count = MIRROR_LOG_MIRRORED;
+	else {
+		log_error("Mirror log type \"%s\" is unknown.", mirrorlog);
+		return 0;
+	}
+
+	return 1;
+}
+
+const char *get_mirror_log_name(int log_count)
+{
+	switch (log_count) {
+	case MIRROR_LOG_CORE: return "core";
+	case MIRROR_LOG_DISK: return "disk";
+	case MIRROR_LOG_MIRRORED: return "mirrored";
+	default:
+		log_error(INTERNAL_ERROR "Unknown mirror log count %d.", log_count);
+		return "unknown";
+	}
+}
diff --git a/tools/args.h b/tools/args.h
index 4a4845f..000af01 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -55,7 +55,7 @@ arg(metadataprofile_ARG, '\0', "metadataprofile", string_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(minor_ARG, '\0', "minor", int_arg, ARG_GROUPABLE)
 arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
-arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_arg, 0)
 arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL, 0)
 arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c792986..6d6d305 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1265,7 +1265,6 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 					   uint32_t *new_log_count)
 {
 	int repair = arg_count(cmd, repair_ARG);
-	const char *mirrorlog;
 	*old_mimage_count = lv_mirror_count(lv);
 	*old_log_count = _get_log_count(lv);
 
@@ -1334,33 +1333,19 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	if (!arg_count(cmd, corelog_ARG) && !arg_count(cmd, mirrorlog_ARG))
 		return 1;
 
-	if (arg_count(cmd, corelog_ARG))
-		*new_log_count = 0;
-
-	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-				  !*new_log_count ? "core" : DEFAULT_MIRRORLOG);
-
-	if (!strcmp("mirrored", mirrorlog))
-		*new_log_count = 2;
-	else if (!strcmp("disk", mirrorlog))
-		*new_log_count = 1;
-	else if (!strcmp("core", mirrorlog))
-		*new_log_count = 0;
-	else {
-		log_error("Unknown mirrorlog type: %s", mirrorlog);
-		return 0;
-	}
+	*new_log_count = arg_int_value(cmd, mirrorlog_ARG,
+				       arg_is_set(cmd, corelog_ARG) ? MIRROR_LOG_CORE : DEFAULT_MIRRORLOG);
 
 	/*
 	 * No mirrored logs for cluster mirrors until
 	 * log daemon is multi-threaded.
 	 */
-	if ((*new_log_count == 2) && vg_is_clustered(lv->vg)) {
+	if ((*new_log_count == MIRROR_LOG_MIRRORED) && vg_is_clustered(lv->vg)) {
 		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
 		return 0;
 	}
 
-	log_verbose("Setting logging type to %s", mirrorlog);
+	log_verbose("Setting logging type to %s", get_mirror_log_name(*new_log_count));
 
 	/*
 	 * Region size must not change on existing mirrors
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 45f432e..199636c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -428,27 +428,16 @@ static int _read_size_params(struct cmd_context *cmd,
 static int _read_mirror_params(struct cmd_context *cmd,
 			       struct lvcreate_params *lp)
 {
-	int corelog = arg_count(cmd, corelog_ARG);
-	const char *mirrorlog = arg_str_value(cmd, mirrorlog_ARG, corelog
-					      ? "core" : DEFAULT_MIRRORLOG);
-
-	if (!strcmp("mirrored", mirrorlog))
-		lp->log_count = 2;
-	else if (!strcmp("disk", mirrorlog))
-		lp->log_count = 1;
-	else if (!strcmp("core", mirrorlog)) {
-		lp->log_count = 0;
-	} else {
-		log_error("Unknown mirrorlog type: %s", mirrorlog);
-		return 0;
-	}
+	int corelog = arg_is_set(cmd, corelog_ARG);
+
+	lp->log_count = arg_int_value(cmd, mirrorlog_ARG, corelog ? 0 : DEFAULT_MIRRORLOG);
 
 	if (corelog && (lp->log_count != 0)) {
 		log_error("Please use only one of --corelog or --mirrorlog.");
 		return 0;
 	}
 
-	log_verbose("Setting logging type to %s", mirrorlog);
+	log_verbose("Setting logging type to %s", get_mirror_log_name(lp->log_count));
 
 	return 1;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bbf0145..c426873 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -327,6 +327,19 @@ int discards_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_val
 	return 1;
 }
 
+int mirrorlog_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+{
+	int log_count;
+
+	if (!get_mirror_log_count(av->value, &log_count))
+		return_0;
+
+	av->i_value = log_count;
+	av->ui_value = log_count;
+
+	return 1;
+}
+
 int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	return get_format_by_name(cmd, av->value) ? 1 : 0;
diff --git a/tools/tools.h b/tools/tools.h
index 75c3eaa..5a5d729 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -126,6 +126,7 @@ void usage(const char *name);
 int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
 int activation_arg(struct cmd_context *cmd, struct arg_values *av);
 int discards_arg(struct cmd_context *cmd, struct arg_values *av);
+int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);


