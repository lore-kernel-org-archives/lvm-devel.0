From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 31 Jan 2013 16:52:43 -0600
Subject: [PATCH 1 of 3] New lv_raid_dev_health() function
Message-ID: <1359672763.13305.12.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RAID:  Add RAID status accessibility functions

Similar to the way thin* accesses its kernel status, we add a method
for RAID to grab the various values in its status output without the
higher levels (LVM) having to understand how to parse the output.
Added functions include:
	- lib/activate/dev_manager.c:dev_manager_raid_status()
	  Pulls the status line from the kernel

	- libdm/libdm-deptree.c:dm_get_status_raid()
	  Parses status line and puts components into dm_status_raid struct

	- lib/activate/activate.c:lv_raid_dev_health()
	  Accesses dm_status_raid to deliver raid dev_health string

The new structure and functions can provide a more unified way to access
status information.  ('lv_raid_percent' could switch to using these
functions, for example.)

Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -1020,6 +1020,49 @@ int dev_manager_mirror_percent(struct de
 	return 1;
 }
 
+int dev_manager_raid_status(struct dev_manager *dm,
+			    const struct logical_volume *lv,
+			    struct dm_status_raid **status)
+{
+	int r = 0;
+	const char *dlid;
+	struct dm_task *dmt;
+	struct dm_info info;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	const char *layer = (lv_is_origin(lv)) ? "real" : NULL;
+
+	/* Build dlid for the thin pool layer */
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+		return_0;
+
+	log_debug_activation("Getting raid device status for %s.", lv->name);
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count.");
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
+
+	if (!dm_get_status_raid(dm->mem, params, status))
+		goto_out;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 #if 0
 	log_very_verbose("%s %s", sus ? "Suspending" : "Resuming", name);
 
Index: lvm2/lib/activate/dev_manager.h
===================================================================
--- lvm2.orig/lib/activate/dev_manager.h
+++ lvm2/lib/activate/dev_manager.h
@@ -54,6 +54,9 @@ int dev_manager_snapshot_percent(struct
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
 			       percent_t *percent, uint32_t *event_nr);
+int dev_manager_raid_status(struct dev_manager *dm,
+			    const struct logical_volume *lv,
+			    struct dm_status_raid **status);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status);
Index: lvm2/libdm/libdevmapper.h
===================================================================
--- lvm2.orig/libdm/libdevmapper.h
+++ lvm2/libdm/libdevmapper.h
@@ -260,9 +260,25 @@ void *dm_get_next_target(struct dm_task
 			 void *next, uint64_t *start, uint64_t *length,
 			 char **target_type, char **params);
 
-/* Parse params from STATUS call for thin_pool target */
+/*
+ * Parse params from STATUS call for raid target
+ */
 struct dm_pool;
 
+struct dm_status_raid {
+	char raid_type[16];
+	int dev_count;
+	uint64_t total_regions;
+	uint64_t insync_regions;
+	char dev_health[0];
+};
+
+int dm_get_status_raid(struct dm_pool *mem, const char *params,
+		       struct dm_status_raid **status);
+
+/*
+ * Parse params from STATUS call for thin_pool target
+ */
 struct dm_status_thin_pool {
 	uint64_t transaction_id;
 	uint64_t used_metadata_blocks;
@@ -275,7 +291,9 @@ struct dm_status_thin_pool {
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 			    struct dm_status_thin_pool **status);
 
-/* Parse params from STATUS call for thin target */
+/*
+ * Parse params from STATUS call for thin target
+ */
 struct dm_status_thin {
 	uint64_t mapped_sectors;
 	uint64_t highest_mapped_sector;
Index: lvm2/libdm/libdm-deptree.c
===================================================================
--- lvm2.orig/libdm/libdm-deptree.c
+++ lvm2/libdm/libdm-deptree.c
@@ -2852,6 +2852,42 @@ int dm_tree_node_add_raid_target(struct
 	return 1;
 }
 
+int dm_get_status_raid(struct dm_pool *mem, const char *params,
+		       struct dm_status_raid **status)
+{
+	int dev_count;
+	const char *p = params;
+	struct dm_status_raid *s;
+
+	if (!(p = strchr(p, ' ')))
+		return_0;
+	p++;
+
+	if (sscanf(p, "%d", &dev_count) != 1)
+		return_0;
+
+	s = dm_pool_zalloc(mem, sizeof(struct dm_status_raid) + dev_count);
+	if (!s) {
+		log_error("Failed to allocate raid status structure.");
+		return 0;
+	}
+
+	if (sscanf(params, "%s %d %s %" PRIu64 "/%" PRIu64,
+		   s->raid_type,
+		   &s->dev_count,
+		   s->dev_health,
+		   &s->insync_regions,
+		   &s->total_regions) != 5) {
+		log_error(INTERNAL_ERROR "Failed to parse raid params: %s",
+			  params);
+		return 0;
+	}
+
+	*status = s;
+
+	return 1;
+}
+
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -777,6 +777,40 @@ int lv_raid_percent(const struct logical
 	return lv_mirror_percent(lv->vg->cmd, lv, 0, percent, NULL);
 }
 
+int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
+{
+	int r;
+	struct dev_manager *dm;
+	struct lvinfo info;
+	struct dm_status_raid *status;
+
+	*dev_health = NULL;
+
+	if (!activation())
+		return 0;
+
+	log_debug_activation("Checking raid device health for LV %s/%s",
+			     lv->vg->name, lv->name);
+
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0))
+		return_0;
+
+	if (!info.exists)
+		return 0;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_raid_status(dm, lv, &status)) ||
+	    !(*dev_health = dm_pool_strdup(lv->vg->cmd->mem,
+					   status->dev_health)))
+		stack;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 /*
  * Returns data or metadata percent usage, depends on metadata 0/1.
  * Returns 1 if percent set, else 0 on failure.
Index: lvm2/lib/activate/activate.h
===================================================================
--- lvm2.orig/lib/activate/activate.h
+++ lvm2/lib/activate/activate.h
@@ -117,6 +117,7 @@ int lv_snapshot_percent(const struct log
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
+int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,



