From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:07:58 +0000 (UTC)
Subject: master - activate: add lv_layer function
Message-ID: <20130204180758.B0C2B3523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca7abbce8a705c1e690bcc2b0c08c4b510843046
Commit:        ca7abbce8a705c1e690bcc2b0c08c4b510843046
Parent:        4f439707fd4a8837f930c14076bc662ca5c19844
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 1 11:09:34 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:10 2013 +0100

activate: add lv_layer function

Add function to return layer name for LV.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   14 ++++----------
 lib/metadata/lv.c       |   10 ++++++++++
 lib/metadata/lv.h       |    1 +
 4 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ba8d148..cfaa152 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add internal function lv_layer() to obtain layer name for LV.
   Report partial and in-sync RAID attribute based on kernel status
   Fix blkdeactivate to handle nested mountpoints and mangled mount paths.
   Set locales with LC_ALL instead of lower priority LANG variable.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ac19bd2..e39c04a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -604,7 +604,6 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
-	const char *layer;
 
 	if (!activation())
 		return 0;
@@ -621,15 +620,10 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
-	if (use_layer && lv_is_thin_pool(lv))
-		layer = "tpool";
-	else if (use_layer && lv_is_origin(lv))
-		layer = "real";
-	else
-		layer = NULL;
-
-	if (!dev_manager_info(lv->vg->cmd->mem, lv, layer, with_open_count,
-			      with_read_ahead, &dminfo, &info->read_ahead))
+	if (!dev_manager_info(lv->vg->cmd->mem, lv,
+			      (use_layer) ? lv_layer(lv) : NULL,
+			      with_open_count, with_read_ahead,
+			      &dminfo, &info->read_ahead))
 		return_0;
 
 	info->exists = dminfo.exists;
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b571ffd..c27ef08 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -225,6 +225,16 @@ char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		dm_pool_strdup(mem, first_seg(lv)->metadata_lv->name) : NULL;
 }
 
+const char *lv_layer(const struct logical_volume *lv)
+{
+	if (lv_is_thin_pool(lv))
+		return "tpool";
+	else if (lv_is_origin(lv))
+		return "real";
+
+	return NULL;
+}
+
 int lv_kernel_minor(const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 838b002..b1078bb 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -82,4 +82,5 @@ char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
+const char *lv_layer(const struct logical_volume *lv);
 #endif /* _LVM_LV_H */


