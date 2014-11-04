From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:33:06 +0000 (UTC)
Subject: master - thin: validate unused thin pool
Message-ID: <20141104143306.0E834608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6116b1d6e302097086c9dcd418e4404ddd337939
Commit:        6116b1d6e302097086c9dcd418e4404ddd337939
Parent:        ee627884de95ae5a40f0fc2534dcd60e63e2a58d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 15:06:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:28:00 2014 +0100

thin: validate unused thin pool

Function tests, that given new thin pool is still unused.
---
 lib/metadata/metadata.h   |    3 ++
 lib/metadata/thin_manip.c |   52 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1dd8867..48c1b3c 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -389,6 +389,9 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg);
 /* Find some unused device_id for thin pool LV segment. */
 uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg);
 
+/* Check if the new thin-pool could be used for lvm2 thin volumes */
+int check_new_thin_pool(const struct logical_volume *pool_lv);
+
 /*
  * Remove a dev_dir if present.
  */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 8569ac1..50354cc 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -569,3 +569,55 @@ int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snap_count)
 
 	return r;
 }
+
+/*
+ * Explict check of new thin pool for usability
+ *
+ * Allow use of thin pools by external apps. When lvm2 metadata has
+ * transaction_id == 0 for a new thin pool, it will explicitely validate
+ * the pool is still unused.
+ *
+ * To prevent lvm2 to create thin volumes in externally used thin pools
+ * simply increment its transaction_id.
+ */
+int check_new_thin_pool(const struct logical_volume *pool_lv)
+{
+	struct cmd_context *cmd = pool_lv->vg->cmd;
+	uint64_t transaction_id;
+
+	/* For transaction_id check LOCAL activation is required */
+	if (!activate_lv_excl_local(cmd, pool_lv)) {
+		log_error("Aborting. Failed to locally activate thin pool %s.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
+	/* With volume lists, check pool really is locally active */
+	if (!lv_thin_pool_transaction_id(pool_lv, &transaction_id)) {
+		log_error("Cannot read thin pool %s transaction id locally, perhaps skipped in lvm.conf volume_list?",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
+	/* Require pool to have same transaction_id as new  */
+	if (first_seg(pool_lv)->transaction_id != transaction_id) {
+		log_error("Cannot use thin pool %s with transaction id "
+			  "%" PRIu64 " for thin volumes. "
+			  "Expected transaction id %" PRIu64 ".",
+			  display_lvname(pool_lv), transaction_id,
+			  first_seg(pool_lv)->transaction_id);
+		return 0;
+	}
+
+	log_verbose("Deactivating public thin pool %s",
+		    display_lvname(pool_lv));
+
+	/* Prevent any 'race' with in-use thin pool and always deactivate */
+	if (!deactivate_lv(pool_lv->vg->cmd, pool_lv)) {
+		log_error("Aborting. Could not deactivate thin pool %s.",
+			  display_lvname(pool_lv));
+		return 0;
+	}
+
+	return 1;
+}


