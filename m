From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon,  8 Apr 2013 20:15:27 +0000 (UTC)
Subject: master - RAID: Capture new RAID kernel sync_action status fields
Message-ID: <20130408201527.D4F7D145A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38f8f4a958980c236bf19f6e58afd55fdcdd3312
Commit:        38f8f4a958980c236bf19f6e58afd55fdcdd3312
Parent:        c22e925ce4fa765b208670e851eae5103fb141f4
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Apr 8 15:04:08 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Apr 8 15:04:08 2013 -0500

RAID:  Capture new RAID kernel sync_action status fields

I've updated the dm_status_raid structure and dm_get_status_raid()
function to make it handle the new kernel status fields that will
be coming in dm-raid v1.5.0.  It is backwards compatible with the
old status line - initializing the new fields to '0'.  The new
structure is also more amenable to future changes.  It includes a
'reserved' field that is currently initialized to zero but could
be used to hold flags describing new features.  It also now uses
pointers for the character strings instead of attempting to allocate
their space along with the structure (causing the size of the
structure to be variable).  This allows future fields to be appended.

The new fields that are available are:
 - sync_action : shows what the sync thread in the kernel is doing
                 (idle, frozen, resync, recover, check, repair, or
                 reshape)
 - mismatch_count: shows the number of discrepancies which were
                   found or repaired by a "check" or "repair"
                   process, respectively.
---
 lib/activate/activate.c    |    6 +++-
 lib/activate/dev_manager.c |    7 ++++-
 libdm/libdevmapper.h       |   14 +++++++++-
 libdm/libdm-deptree.c      |   55 ++++++++++++++++++++++++++++++++++++-------
 4 files changed, 68 insertions(+), 14 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 26d357b..572383f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -809,8 +809,10 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 
 	if (!(r = dev_manager_raid_status(dm, lv, &status)) ||
 	    !(*dev_health = dm_pool_strdup(lv->vg->cmd->mem,
-					   status->dev_health)))
-		stack;
+					   status->dev_health))) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
 
 	cached_dev_health = *dev_health;
 	dev_manager_destroy(dm);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 906f53a..4a77320 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1031,7 +1031,6 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	char *params = NULL;
 	const char *layer = lv_layer(lv);
 
-	/* Build dlid for the thin pool layer */
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
@@ -1051,6 +1050,12 @@ int dev_manager_raid_status(struct dev_manager *dm,
 
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
+	if (!type || strcmp(type, "raid")) {
+		log_debug("Expected raid segment type but got %s instead",
+			  type ? type : "NULL");
+		goto out;
+	}
+
 	if (!dm_get_status_raid(dm->mem, params, status))
 		goto_out;
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 184615f..2f2c77d 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -265,12 +265,22 @@ void *dm_get_next_target(struct dm_task *dmt,
  */
 struct dm_pool;
 
+/*
+ * dm_get_status_raid will allocate the dm_status_raid structure and
+ * the necessary character arrays from the mempool provided to the
+ * function.  If the mempool is from a dev_manager struct (dm->mem),
+ * then the caller does not need to free the memory - simply calling
+ * dev_manager_destroy will do.
+ */
 struct dm_status_raid {
+	uint64_t reserved;
 	uint64_t total_regions;
 	uint64_t insync_regions;
+	uint64_t mismatch_count;
 	int dev_count;
-	char raid_type[16];
-	char dev_health[0];
+	char *raid_type;
+	char *dev_health;
+	char *sync_action;
 };
 
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8292791..750f494 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2873,28 +2873,39 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 	return 1;
 }
 
+
+/*
+ * Various RAID status versions include:
+ * Versions < 1.5.0 (4 fields):
+ *   <raid_type> <#devs> <health_str> <sync_ratio>
+ * Versions 1.5.0+  (6 fields):
+ *   <raid_type> <#devs> <health_str> <sync_ratio> <sync_action> <mismatch_cnt>
+ */
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status)
 {
-	int dev_count;
-	const char *p;
+	int i;
+	const char *pp, *p;
 	struct dm_status_raid *s;
 
 	if (!params || !(p = strchr(params, ' '))) {
 		log_error("Failed to parse invalid raid params.");
 		return 0;
 	}
-
 	p++;
 
-	if (sscanf(p, "%d", &dev_count) != 1)
+	/* second field holds the device count */
+	if (sscanf(p, "%d", &i) != 1)
 		return_0;
 
-	s = dm_pool_zalloc(mem, sizeof(struct dm_status_raid) + dev_count + 1);
-	if (!s) {
-		log_error("Failed to allocate raid status structure.");
-		return 0;
-	}
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_raid))))
+		return_0;
+
+	if (!(s->raid_type = dm_pool_zalloc(mem, p - params)))
+		return_0; /* memory is freed went pool is destroyed */
+
+	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
+		return_0;
 
 	if (sscanf(params, "%s %d %s %" PRIu64 "/%" PRIu64,
 		   s->raid_type,
@@ -2908,6 +2919,32 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 
 	*status = s;
 
+	/*
+	 * All pre-1.5.0 version parameters are read.  Now we check
+	 * for additional 1.5.0+ parameters.
+	 *
+	 * Note that 'sync_action' will be NULL (and mismatch_count
+	 * will be 0) if the kernel returns a pre-1.5.0 status.
+	 */
+	for (p = params, i = 0; i < 4; i++, p++)
+		if (!(p = strchr(p, ' ')))
+			return 1;  /* return pre-1.5.0 status */
+
+	pp = p;
+	if (!(p = strchr(p, ' '))) {
+		log_error(INTERNAL_ERROR "Bad RAID status received.");
+		return 0;
+	}
+	p++;
+
+	if (!(s->sync_action = dm_pool_zalloc(mem, p - pp)))
+		return_0;
+
+	if (sscanf(pp, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2) {
+		log_error("Failed to parse raid params: %s", params);
+		return 0;
+	}
+
 	return 1;
 }
 


