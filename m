From: Milan Broz <mbroz@redhat.com>
Date: Sun, 31 May 2009 22:47:11 +0200
Subject: [PATCH] Fix rename of active snapshot with virtual origin.
Message-ID: <4A22ECCF.7030809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix rename of active snapshot with virtual origin.

Code must suspend/resume virtual origin too when renaming
snapshot otherwise in kernel old name remains.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c  |   21 ++++++++++++++-------
 test/t-lvcreate-usage.sh |    7 +++++++
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 68092a8..79407ae 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1761,6 +1761,8 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names;
+	DM_LIST_INIT(lvs_changed);
+	struct lv_list lvl, lvl2;
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
@@ -1795,22 +1797,27 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	lvl.lv = lv;
+	dm_list_add(&lvs_changed, &lvl.list);
+
+	/* rename active virtual origin too */
+	if (lv_is_cow(lv) && lv_is_virtual_origin(lvl2.lv = origin_from_cow(lv)))
+		dm_list_add(&lvs_changed, &lvl2.list);
+
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg))
 		return 0;
 
-	if (!suspend_lv(cmd, lv)) {
+
+	if (!suspend_lvs(cmd, &lvs_changed)) {
 		vg_revert(vg);
 		goto_out;
 	}
 
-	if (!vg_commit(vg)) {
-		resume_lv(cmd, lv);
-		goto_out;
-	}
+	if (!(r = vg_commit(vg)))
+		stack;
 
-	resume_lv(cmd, lv);
-	r = 1;
+	resume_lvs(cmd, &lvs_changed);
 out:
 	backup(vg);
 	return r;
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 43cf716..d947023 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -116,3 +116,10 @@ lvcreate -L 32M -n $lv --regionsize 4M -m 1 $vg
 check_lv_field_ $vg/$lv regionsize "4.00M"
 lvremove -ff $vg
 
+# snapshot with virtual origin works
+lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvrename $vg/$lv1 $vg/$lv2
+lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvchange -a n $vg/$lv1
+lvremove $vg/$lv1
+lvremove -ff $vg



