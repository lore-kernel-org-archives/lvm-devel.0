From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Dec 2015 12:04:45 +0000 (UTC)
Subject: master - libdm: introduce dm_get_status_mirror
Message-ID: <20151201120445.311C960CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa87979004a0bbce2e4e3eacaeab0c4e0e0827eb
Commit:        fa87979004a0bbce2e4e3eacaeab0c4e0e0827eb
Parent:        46c8d6bb8ae91ee67c8633496cc6c3d92bb4f3ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 30 21:16:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 1 13:00:43 2015 +0100

libdm: introduce  dm_get_status_mirror

Add missing function to parse mirror status.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_113 |    1 +
 libdm/libdevmapper.h                |   56 +++++++++++++-----
 libdm/libdm-targets.c               |  109 +++++++++++++++++++++++++++++++++++
 4 files changed, 152 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9f15242..689fe43 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.113 - 
 =====================================
+  Add dm_get_status_mirror() for parsing mirror status line.
 
 Version 1.02.112 - 28th November 2015
 =====================================
diff --git a/libdm/.exported_symbols.DM_1_02_113 b/libdm/.exported_symbols.DM_1_02_113
new file mode 100644
index 0000000..30d973c
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_113
@@ -0,0 +1 @@
+dm_get_status_mirror
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 310ceb7..48f8682 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -127,6 +127,7 @@ enum {
  * each ioctl command you want to execute.
  */
 
+struct dm_pool;
 struct dm_task;
 struct dm_timestamp;
 
@@ -281,17 +282,43 @@ void *dm_get_next_target(struct dm_task *dmt,
 			 char **target_type, char **params);
 
 /*
- * Parse params from STATUS call for raid target
+ * Following dm_get_status_* functions will allocate approriate status structure
+ * from passed mempool together with the necessary character arrays.
+ * Destroying the mempool will release all asociated allocation.
  */
-struct dm_pool;
 
-/*
- * dm_get_status_raid will allocate the dm_status_raid structure and
- * the necessary character arrays from the mempool provided to the
- * function.  If the mempool is from a dev_manager struct (dm->mem),
- * then the caller does not need to free the memory - simply calling
- * dev_manager_destroy will do.
- */
+/* Parse params from STATUS call for mirror target */
+typedef enum {
+	DM_STATUS_MIRROR_ALIVE	      = 'A',/* No failures */
+	DM_STATUS_MIRROR_FLUSH_FAILED = 'F',/* Mirror out-of-sync */
+	DM_STATUS_MIRROR_WRITE_FAILED = 'D',/* Mirror out-of-sync */
+	DM_STATUS_MIRROR_SYNC_FAILED  = 'S',/* Mirror out-of-sync */
+	DM_STATUS_MIRROR_READ_FAILED  = 'R',/* Mirror data unaffected */
+	DM_STATUS_MIRROR_UNCLASSIFIED = 'U' /* Bug */
+} dm_status_mirror_health_t;
+
+struct dm_status_mirror {
+	uint64_t total_regions;
+	uint64_t insync_regions;
+	uint32_t dev_count;
+	struct {
+		dm_status_mirror_health_t health;
+		uint32_t major;
+		uint32_t minor;
+	} *devs;
+	const char *log_type;
+	uint32_t log_count;
+	struct {
+		dm_status_mirror_health_t health;
+		uint32_t major;
+		uint32_t minor;
+	} *logs;
+};
+
+int dm_get_status_mirror(struct dm_pool *mem, const char *params,
+			 struct dm_status_mirror **status);
+
+/* Parse params from STATUS call for raid target */
 struct dm_status_raid {
 	uint64_t reserved;
 	uint64_t total_regions;
@@ -306,6 +333,7 @@ struct dm_status_raid {
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status);
 
+/* Parse params from STATUS call for cache target */
 struct dm_status_cache {
 	uint64_t version;  /* zero for now */
 
@@ -341,6 +369,8 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			struct dm_status_cache **status);
 
 /*
+ * Parse params from STATUS call for snapshot target
+ *
  * Snapshot target's format:
  * <= 1.7.0: <used_sectors>/<total_sectors>
  * >= 1.8.0: <used_sectors>/<total_sectors> <metadata_sectors>
@@ -358,9 +388,7 @@ struct dm_status_snapshot {
 int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
 			   struct dm_status_snapshot **status);
 
-/*
- * Parse params from STATUS call for thin_pool target
- */
+/* Parse params from STATUS call for thin_pool target */
 typedef enum {
 	DM_THIN_DISCARDS_IGNORE,
 	DM_THIN_DISCARDS_NO_PASSDOWN,
@@ -385,9 +413,7 @@ struct dm_status_thin_pool {
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 			    struct dm_status_thin_pool **status);
 
-/*
- * Parse params from STATUS call for thin target
- */
+/* Parse params from STATUS call for thin target */
 struct dm_status_thin {
 	uint64_t mapped_sectors;
 	uint64_t highest_mapped_sector;
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 166396c..e2d5c44 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -355,3 +355,112 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 
 	return 1;
 }
+
+/*
+ * dm core parms:	     0 409600 mirror
+ * Mirror core parms:	     2 253:4 253:5 400/400
+ * New-style failure params: 1 AA
+ * New-style log params:     3 cluster 253:3 A
+ *			 or  3 disk 253:3 A
+ *			 or  1 core
+ */
+#define DM_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+
+int dm_get_status_mirror(struct dm_pool *mem, const char *params,
+			 struct dm_status_mirror **status)
+{
+	struct dm_status_mirror *s;
+	const char *p, *pos = params;
+	unsigned num_devs, argc, i;
+	int used;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(*s)))) {
+		log_error("Failed to alloc mem pool to parse mirror status.");
+		return 0;
+	}
+
+	if (sscanf(pos, "%u %n", &num_devs, &used) != 1)
+		goto_out;
+	pos += used;
+
+	if (num_devs > DM_MIRROR_MAX_IMAGES) {
+		log_error(INTERNAL_ERROR "More then " DM_TO_STRING(DM_MIRROR_MAX_IMAGES)
+			  " reported in mirror status.");
+		goto out;
+	}
+
+	if (!(s->devs = dm_pool_alloc(mem, num_devs * sizeof(*(s->devs))))) {
+		log_error("Allocation of devs failed.");
+		goto out;
+	}
+
+	for (i = 0; i < num_devs; ++i, pos += used)
+		if (sscanf(pos, "%u:%u %n",
+			   &(s->devs[i].major), &(s->devs[i].minor), &used) != 2)
+			goto_out;
+
+	if (sscanf(pos, FMTu64 "/" FMTu64 "%n",
+		   &s->insync_regions, &s->total_regions, &used) != 2)
+		goto_out;
+	pos += used;
+
+	if (sscanf(pos, "%u %n", &argc, &used) != 1)
+		goto_out;
+	pos += used;
+
+	for (i = 0; i < num_devs ; ++i)
+		s->devs[i].health = pos[i];
+
+	if (!(pos = _advance_to_next_word(pos, argc)))
+		goto_out;
+
+	if (sscanf(pos, "%u %n", &argc, &used) != 1)
+		goto_out;
+	pos += used;
+
+	if (argc == 1) {
+		/* core, cluster-core */
+		if (!(s->log_type = dm_pool_strdup(mem, pos))) {
+			log_error("Allocation of log type string failed.");
+			goto out;
+		}
+	} else {
+		if (!(p = _advance_to_next_word(pos, 1)))
+			goto_out;
+
+		/* disk, cluster-disk */
+		if (!(s->log_type = dm_pool_strndup(mem, pos, p - pos - 1))) {
+			log_error("Allocation of log type string failed.");
+			goto out;
+		}
+		pos = p;
+
+		if ((argc > 2) && !strcmp(s->log_type, "disk")) {
+			s->log_count = argc - 2;
+
+			if (!(s->logs = dm_pool_alloc(mem, s->log_count * sizeof(*(s->logs))))) {
+				log_error("Allocation of logs failed.");
+				goto out;
+			}
+
+			for (i = 0; i < s->log_count; ++i, pos += used)
+				if (sscanf(pos, "%u:%u %n",
+					   &s->logs[i].major, &s->logs[i].minor, &used) != 2)
+					goto_out;
+
+			for (i = 0; i < s->log_count; ++i)
+				s->logs[i].health = pos[i];
+		}
+	}
+
+	s->dev_count = num_devs;
+	*status = s;
+
+	return 1;
+out:
+	log_error("Failed to parse mirror status %s.", params);
+	dm_pool_free(mem, s);
+	*status = NULL;
+
+	return 0;
+}


