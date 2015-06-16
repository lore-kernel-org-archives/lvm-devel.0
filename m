From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 19:24:54 +0000 (UTC)
Subject: master - lv_refresh: move the bulk of the function into lib
Message-ID: <20150616192454.4C7AF60DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e043e03cd853f9dbeb653ecdd63957d39c7136cc
Commit:        e043e03cd853f9dbeb653ecdd63957d39c7136cc
Parent:        3d9957e3dd82666a360481b3a18baa9f23c75300
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 13:38:40 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 13:38:40 2015 -0500

lv_refresh: move the bulk of the function into lib

So that it can be used from other lib code.
---
 lib/metadata/lv_manip.c          |   22 ++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    2 ++
 tools/toollib.c                  |   18 ++----------------
 3 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1251a5d..9983793 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1395,6 +1395,28 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 	return 1;
 }
 
+int lv_refresh_suspend_resume(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
+		log_error("Refusing refresh of partial LV %s."
+			  " Use '--activationmode partial' to override.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to suspend %s.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Failed to reactivate %s.", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Remove given number of extents from LV.
  */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b673af3..ff10a98 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -738,6 +738,8 @@ int lv_empty(struct logical_volume *lv);
 /* Empty an LV and add error segment */
 int replace_lv_with_error_segment(struct logical_volume *lv);
 
+int lv_refresh_suspend_resume(struct cmd_context *cmd, struct logical_volume *lv);
+
 /* Entry point for all LV extent allocations */
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
diff --git a/tools/toollib.c b/tools/toollib.c
index ca198dc..bfd3789 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -850,22 +850,8 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
-		log_error("Refusing refresh of partial LV %s."
-			  " Use '--activationmode partial' to override.",
-			  lv->name);
-		return 0;
-	}
-
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to suspend %s.", lv->name);
-		return 0;
-	}
-
-	if (!resume_lv(cmd, lv)) {
-		log_error("Failed to reactivate %s.", lv->name);
-		return 0;
-	}
+	if (!lv_refresh_suspend_resume(cmd, lv))
+		return_0;
 
 	/*
 	 * check if snapshot merge should be polled


