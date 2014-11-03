From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:09 +0000 (UTC)
Subject: master - cleanup: use logical_volume* directly
Message-ID: <20141103132409.D047960E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ba5571bab4ea0d9e1f30bd35033033bdb477417
Commit:        0ba5571bab4ea0d9e1f30bd35033033bdb477417
Parent:        fdc252ec35c8c08ef4674bb1656bf4bfed641add
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 10:15:00 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: use logical_volume* directly

---
 tools/lvresize.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 133cc6f..08248bb 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -168,7 +168,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct lvresize_params lp = { 0 };
 	struct volume_group *vg;
 	struct dm_list *pvh = NULL;
-	struct lv_list *lvl;
+	struct logical_volume *lv;
 	int r = ECMD_FAILED;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
@@ -181,23 +181,23 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-        /* Does LV exist? */
-        if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
-                log_error("Logical volume %s not found in volume group %s",
-                          lp.lv_name, lp.vg_name);
+	/* Does LV exist? */
+	if (!(lv = find_lv(vg, lp.lv_name))) {
+		log_error("Logical volume %s not found in volume group %s",
+			  lp.lv_name, lp.vg_name);
 		goto out;
-        }
+	}
 
 	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
 					     lp.argv, 1) : &vg->pvs))
 		goto_out;
 
-	if (!lv_resize_prepare(cmd, lvl->lv, &lp, pvh)) {
+	if (!lv_resize_prepare(cmd, lv, &lp, pvh)) {
 		r = EINVALID_CMD_LINE;
 		goto_out;
 	}
 
-	if (!lv_resize(cmd, lvl->lv, &lp, pvh))
+	if (!lv_resize(cmd, lv, &lp, pvh))
 		goto_out;
 
 	r = ECMD_PROCESSED;


