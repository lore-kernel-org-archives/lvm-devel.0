From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 20 Aug 2013 23:26:50 +0000 (UTC)
Subject: dev-dct-process-part3 - toollib: Avoid a spurious orphan unlock.
Message-ID: <20130820232650.712CC61119@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=940aeee4e7e86f4f389dd20cdd82826c7eeb470c
Commit:        940aeee4e7e86f4f389dd20cdd82826c7eeb470c
Parent:        2963000d1026f4374489a08c9f74b19fd9994f3e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Aug 21 01:23:39 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Aug 21 01:23:39 2013 +0200

toollib: Avoid a spurious orphan unlock.

---
 tools/toollib.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 95606e4..0af018a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1302,15 +1302,18 @@ static struct vg_list *find_vgl(struct dm_list *vgl_list, const char *vg_name)
 	return NULL;
 }
 
-static void release_vgl(struct cmd_context *cmd, struct vg_list *vgl)
+static int release_vgl(struct cmd_context *cmd, struct vg_list *vgl)
 {
 	if (!vgl->vg)
-		return;
+		return 0;
+
+	int r = 0;
 
 	if (is_orphan_vg(vgl->vg->name)) {
 		log_debug("release_vgl orphan %s", vgl->vg->name);
 		dev_close_vg(vgl->vg->name);
 		release_vg(vgl->vg);
+		r = 1;
 	} else if (vg_read_error(vgl->vg)) {
 		log_debug("release_vgl error %s", vgl->vg->name);
 		dev_close_vg(vgl->vg->name);
@@ -1323,14 +1326,24 @@ static void release_vgl(struct cmd_context *cmd, struct vg_list *vgl)
 	}
 
 	vgl->vg = NULL;
+	return r;
 }
 
-static void release_vg_list(struct cmd_context *cmd, struct dm_list *vgl_list)
+/*
+* Special treatment is needed for unlocking orphan vgs. There are three orphan
+* vgs, and all three share one orphan clvm lock. We return 1 if the orphan VG
+* was in the list to be released.
+*/
+static int release_vg_list(struct cmd_context *cmd, struct dm_list *vgl_list)
 {
 	struct vg_list *vgl;
 
+	int r = 0;
+
 	dm_list_iterate_items(vgl, vgl_list)
-		release_vgl(cmd, vgl);
+		r += release_vgl(cmd, vgl);
+
+	return r;
 }
 
 static int read_vg_name_list(struct cmd_context *cmd, uint32_t flags,
@@ -2009,6 +2022,7 @@ int process_each_pv(struct cmd_context *cmd,
 	int include_other_devs = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
+	int unlock_orphans = 0;
 
 	/*
 	 * arg_tags, arg_pvnames are names specified in argv.
@@ -2104,7 +2118,8 @@ int process_each_pv(struct cmd_context *cmd,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		release_vg_list(cmd, &all_vgs);
+		if (release_vg_list(cmd, &all_vgs))
+			unlock_orphans = 1;
 
 	} else if (flags & ENABLE_ALL_VGNAMES) {
 		/*
@@ -2134,15 +2149,8 @@ process:
 			ret_max = ret;
 	}
 out:
-	if (!vg)
-		release_vg_list(cmd, &use_vgs);
-
-	/*
-	 * This is needed because release_vg_list does not do any unlocks
-	 * for orphan vgs.  There are three orphan vgs, and all three share
-	 * this one orphan clvm lock.
-	 */
-	unlock_vg(cmd, VG_ORPHANS);
+	if (!vg && release_vg_list(cmd, &use_vgs) || unlock_orphans)
+		unlock_vg(cmd, VG_ORPHANS);
 
 	return ret_max;
 }


