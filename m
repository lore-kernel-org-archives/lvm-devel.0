From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:22 +0000 (UTC)
Subject: master - refresh: print error message with failing lv name
Message-ID: <20131204133122.E48BB60EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=778de22d51aae736d6891920617191a41c236596
Commit:        778de22d51aae736d6891920617191a41c236596
Parent:        37853cc7a9e60036134034718f22ec688917146b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 11:10:41 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:24 2013 +0100

refresh: print error message with failing lv name

If there is  suspend/resume error, print error message
with lv name.
Drop goto.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   21 ++++++++++-----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f299b84..0689b18 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Add error messages with LV names for failing lv refresh.
   Compile/link daemons with RELRO and PIE options to harden daemon security.
   Support per-object compilation cflags via CFLAGS_object.o.
   Automatically detect support for compiler/linker options to use RELRO and PIE.
diff --git a/tools/toollib.c b/tools/toollib.c
index 654384d..868fc69 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1417,21 +1417,21 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	int r = 0;
-
 	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
 		log_error("Refusing refresh of partial LV %s. Use --partial to override.",
 			  lv->name);
-		goto out;
+		return 0;
 	}
 
-	r = suspend_lv(cmd, lv);
-	if (!r)
-		goto_out;
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to suspend %s.", lv->name);
+		return 0;
+	}
 
-	r = resume_lv(cmd, lv);
-	if (!r)
-		goto_out;
+	if (!resume_lv(cmd, lv)) {
+		log_error("Failed to reactivate %s.", lv->name);
+		return 0;
+	}
 
 	/*
 	 * check if snapshot merge should be polled
@@ -1445,8 +1445,7 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	if (background_polling() && lv_is_origin(lv) && lv_is_merging_origin(lv))
 		lv_spawn_background_polling(cmd, lv);
 
-out:
-	return r;
+	return 1;
 }
 
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg)


