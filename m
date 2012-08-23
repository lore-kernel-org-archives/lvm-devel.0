From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:59 +0000 (UTC)
Subject: master - lvconvert: move _reload_lv()
Message-ID: <20120823124259.4ACB7A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4698fb0543637761fc11af76643f6b8e81a631a9
Commit:        4698fb0543637761fc11af76643f6b8e81a631a9
Parent:        243cd3fd2ca377d93fd7407f2a0109a04a189cbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 1 15:34:45 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:52 2012 +0200

lvconvert: move _reload_lv()

Just move in front
---
 tools/lvconvert.c |   55 +++++++++++++++++++++++++++--------------------------
 1 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76cc9b3..4c8dd50 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -492,6 +492,34 @@ static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attrib
 	return lv;
 }
 
+static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to lock %s", lv->name);
+		vg_revert(lv->vg);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, lv))
+			stack;
+		return_0;
+	}
+
+	log_very_verbose("Updating \"%s\" in kernel", lv->name);
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Problem reactivating %s", lv->name);
+		return 0;
+	}
+	return 1;
+}
+
 static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 				    struct volume_group *vg,
 				    struct logical_volume *lv,
@@ -1123,33 +1151,6 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-
-	if (!vg_write(lv->vg))
-		return_0;
-
-	if (!suspend_lv(cmd, lv)) {
-		log_error("Failed to lock %s", lv->name);
-		vg_revert(lv->vg);
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, lv))
-			stack;
-		return_0;
-	}
-
-	log_very_verbose("Updating \"%s\" in kernel", lv->name);
-
-	if (!resume_lv(cmd, lv)) {
-		log_error("Problem reactivating %s", lv->name);
-		return 0;
-	}
-	return 1;
-}
 
 /*
  * _lvconvert_mirrors_aux


