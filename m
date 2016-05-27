From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:45 +0000 (UTC)
Subject: master - refresh: call resume after failing suspend
Message-ID: <20160527134745.5F52660642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=067c0a23e5c0d41e92551c2d3e40bcaf4aeb1488
Commit:        067c0a23e5c0d41e92551c2d3e40bcaf4aeb1488
Parent:        98b41db324a432db5860cb7dbea697a09bc4321e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 20 13:20:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

refresh: call resume after failing suspend

lv_refresh_suspend_resume() has escaped with fail ret code
after failing suspend and could have left many volumes in suspend state.

So always unconditionally call resume also  when suspend has failed.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 213bc72..48e0109 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  When refresh failed in suspend, call resume upon error path.
   Support passthrough cache mode when waiting for clean cache.
   Check cache status only for 'in-use' cache pools.
   Extend setup_task() to preset flushing for dm_task object.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 625cea6..fdf0c86 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1376,6 +1376,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 int lv_refresh_suspend_resume(const struct logical_volume *lv)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
+	int r = 1;
 
 	if (!cmd->partial_activation && lv_is_partial(lv)) {
 		log_error("Refusing refresh of partial LV %s."
@@ -1386,15 +1387,15 @@ int lv_refresh_suspend_resume(const struct logical_volume *lv)
 
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to suspend %s.", display_lvname(lv));
-		return 0;
+		r = 0;
 	}
 
 	if (!resume_lv(cmd, lv)) {
 		log_error("Failed to reactivate %s.", display_lvname(lv));
-		return 0;
+		r = 0;
 	}
 
-	return 1;
+	return r;
 }
 
 /*


