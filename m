From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:25 +0000 (UTC)
Subject: master - lvinfo: allow to use lv_info with NULL info
Message-ID: <20130923101625.CDAD2606F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b604e5c8e505138fc86e009375fd33160ab84ff
Commit:        3b604e5c8e505138fc86e009375fd33160ab84ff
Parent:        b29adbbc4da6f016735929ce6a944639254a6c49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 19 14:05:55 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:13:06 2013 +0200

lvinfo: allow to use lv_info with NULL info

When NULL info struct is passed in - function is usable
as a quick query for  lv_is_active_locally() - with a bonus
we may query for layered device.

So it could be seen as a more efficient lv_is_active_locally().
---
 WHATS_NEW               |    4 ++++
 lib/activate/activate.c |    6 +++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e969620..cca4c0e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,7 @@
+Version 2.02.102
+======================================
+  Extend lv_info() for more efficient lv_is_active_locally() check.
+
 Version 2.02.101 - 20th September 2013
 ======================================
   Fix 3-thread clvmd deadlock triggered by cleanup on EOF from client.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ecd35b2..e4d9b49 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -616,6 +616,7 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 
 /*
  * Returns 1 if info structure populated, else 0 on failure.
+ * When lvinfo* is NULL, it returns 1 if the device is locally active, 0 otherwise.
  */
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead)
@@ -640,9 +641,12 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 	if (!dev_manager_info(lv->vg->cmd->mem, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
 			      with_open_count, with_read_ahead,
-			      &dminfo, &info->read_ahead))
+			      &dminfo, (info) ? &info->read_ahead : NULL))
 		return_0;
 
+	if (!info)
+		return dminfo.exists;
+
 	info->exists = dminfo.exists;
 	info->suspended = dminfo.suspended;
 	info->open_count = dminfo.open_count;


