From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:49 -0400
Subject: [PATCH 4/8] Change pvcreate_single to return pv_t and update function description.
In-Reply-To: <1248235553-13519-4-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-2-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-3-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.c          |   22 +++++++++++++++++-----
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 586db06..aa096ef 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -354,7 +354,8 @@ struct pvcreate_params {
 	unsigned yes;
 };
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle);
+pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		       void *handle);
 
 /*
 * Utility functions
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6b7039f..01fa4d8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1115,7 +1115,19 @@ static void fill_default_pvcreate_params(struct pvcreate_params *pp)
 	pp->yes = 0;
 }
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
+/*
+ * pvcreate_single() - initialize a device with PV label and metadata
+ *
+ * Parameters:
+ * - pv_name: device path to initialize
+ * - handle: options to pass to pv_create; NULL indicates use defaults
+ *
+ * Returns:
+ * NULL: error
+ * pv_t * (non-NULL): handle to physical volume created
+ */
+pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		       void *handle)
 {
 	struct pvcreate_params *pp;
 	void *pv;
@@ -1134,13 +1146,13 @@ int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			log_error("uuid %s already in use on \"%s\"",
 				  pp->idp->uuid, dev_name(dev));
-			return 0;
+			return NULL;
 		}
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
-		return 0;
+		return NULL;
 	}
 
 	if (!pvcreate_check(cmd, pv_name, pp))
@@ -1200,11 +1212,11 @@ int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
 	unlock_vg(cmd, VG_ORPHANS);
-	return 1;
+	return pv;
 
       error:
 	unlock_vg(cmd, VG_ORPHANS);
-	return 0;
+	return NULL;
 }
 
 static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)
-- 
1.6.0.6


