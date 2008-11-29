From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 29 Nov 2008 16:02:32 -0500
Subject: [PATCH 3/4] Change pvcreate_single() to return pv_t * in preparation for other callers.
In-Reply-To: <1227992553-4381-2-git-send-email-dwysocha@redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1227992553-4381-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 ++--
 lib/metadata/metadata.c          |   12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 829a894..c77ebdd 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -369,8 +369,8 @@ struct pvcreate_params {
 	unsigned yes;
 };
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		    void *handle);
+pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		      void *handle);
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 pv_t *pv_create(const struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 09c345f..4b231d3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -990,8 +990,8 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	return 1;
 }
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		    void *handle)
+pv_t *pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		      void *handle)
 {
 	struct pvcreate_params *pp;
 	void *pv;
@@ -1021,13 +1021,13 @@ int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
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
@@ -1086,11 +1086,11 @@ int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
 	unlock_vg(cmd, VG_ORPHANS);
-	return 1;
+	return pv;
 
       error:
 	unlock_vg(cmd, VG_ORPHANS);
-	return 0;
+	return NULL;
 }
 
 /* FIXME: liblvm todo - make into function that returns handle */
-- 
1.5.5.1


