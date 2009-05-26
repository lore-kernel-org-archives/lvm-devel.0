From: Milan Broz <mbroz@redhat.com>
Date: Tue, 26 May 2009 20:07:59 +0200
Subject: [PATCH] Fix handling of snapshots with virtual origin.
Message-ID: <4A1C2FFF.8050604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix handling of snapshots with virtual origin.

 * validate code must count virtual origin into "invisible"
 volume count otherwise the test fails

 * when creating new LV snapshot with virtual origin, the virtual origin
 must be explicitly activated otherwise COW mapping table remains linear
 (but metadata are written correctly so later vgchange fixes it)
 Fix it by calling activate_lv on newly created origin.

 * when removing snapshot with virtual origin, code should not ask
 confirmation question for virtual origin
 (but it prints informational message that origin was removed too).

 Also skip virtual origin when iterating volumes in VG.
 (All operations are handled on snapshot above.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c  |    6 +++++-
 test/t-lvcreate-usage.sh |    6 ++++++
 tools/lvcreate.c         |   16 +++++++++-------
 tools/lvremove.c         |    9 ++++++---
 tools/toollib.c          |    3 +++
 5 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f16cd55..f4ea237 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1492,7 +1492,11 @@ int vg_validate(struct volume_group *vg)
 			continue;
 
 		/* snapshots */
-		if (lv_is_cow(lvl->lv) || lv_is_origin(lvl->lv))
+		if (lv_is_cow(lvl->lv))
+			continue;
+
+		/* virtual origin is invisible always */
+		if (lv_is_origin(lvl->lv) && !lv_is_virtual_origin(lvl->lv))
 			continue;
 
 		/* count other non-snapshot invisible volumes */
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 43cf716..d6708ca 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -116,3 +116,9 @@ lvcreate -L 32M -n $lv --regionsize 4M -m 1 $vg
 check_lv_field_ $vg/$lv regionsize "4.00M"
 lvremove -ff $vg
 
+# snapshot with virtual origin works
+lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvcreate -s --virtualoriginsize 64M -L 32M -n $lv2 $vg
+lvchange -a n $vg/$lv1
+lvremove $vg/$lv1
+lvremove -ff $vg
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 67d065c..8d4ec23 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -913,13 +913,15 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 			return 0;
 		}
 
-		if (lp->voriginsize &&
-		    !(org = _create_virtual_origin(cmd, vg, lv->name,
-						   lp->permission,
-						   lp->voriginextents))) {
-			log_error("Couldn't create virtual origin for LV %s",
-				  lv->name);
-			goto deactivate_and_revert_new_lv;
+		if (lp->voriginsize) {
+			org = _create_virtual_origin(cmd, vg, lv->name,
+						     lp->permission,
+						     lp->voriginextents);
+			if (!org || !activate_lv(cmd, org)) {
+				log_error("Couldn't create virtual origin "
+					  "for LV %s", lv->name);
+				goto deactivate_and_revert_new_lv;
+			}
 		}
 
 		/* cow LV remains active and becomes snapshot LV */
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 712f175..56b304e 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -18,17 +18,20 @@
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
-	struct logical_volume *origin;
+	struct logical_volume *virtual_origin = NULL;
 
 	/*
 	 * If this is a sparse device, remove its origin too.
 	 */
-        if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
-                lv = origin;
+        if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
+                virtual_origin = origin_from_cow(lv);
 
 	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
+	if (virtual_origin && !lv_remove_single(cmd, virtual_origin, DONT_PROMPT))
+		return ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 7f9eef1..fed2406 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -122,6 +122,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
+		if (lv_is_virtual_origin(lvl->lv))
+			continue;
+
 		/* Should we process this LV? */
 		if (process_all)
 			process_lv = 1;



