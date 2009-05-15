From: Milan Broz <mbroz@redhat.com>
Date: Fri, 15 May 2009 18:17:56 +0200
Subject: [RFC PATCH] pvmove: do not keep suspended devices behind and try automatically restore previous state
Message-ID: <4A0D95B4.1060300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If pvmove fails activating mirror volume, try restroe to previous state.

pvmove now keep suspended devices if temporary mirror creation fails.

We can try to restore previous state if it is first attempt to activate 
pvmove (code basically run the same code as --abort automatically).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 test/t-pvmove-basic.sh |    5 +++++
 tools/pvmove.c         |   20 ++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/test/t-pvmove-basic.sh b/test/t-pvmove-basic.sh
index ab39e4f..cbd5c8c 100755
--- a/test/t-pvmove-basic.sh
+++ b/test/t-pvmove-basic.sh
@@ -370,3 +370,8 @@ vgcreate $vg -s 256k $devs
 lvcreate -l4 -n $lv1 $vg $dev1
 pvmove -i1 $dev1
 
+#COMM "pvmove fails activating mirror, properly restores state before pvmove"
+dmsetup create "$vg-pvmove0" --notable
+not pvmove -i 1 $dev2
+test $(dmsetup info --noheadings -c -o suspended "$vg-$lv1") = "Active"
+dmsetup remove "$vg-pvmove0"
diff --git a/tools/pvmove.c b/tools/pvmove.c
index d760802..3e12ec1 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -274,6 +274,10 @@ static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 	return activate_lv(cmd, lv_mirr);
 }
 
+static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
+			  struct logical_volume *lv_mirr,
+			  struct dm_list *lvs_changed);
+
 static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
 			    struct dm_list *lvs_changed, unsigned flags)
@@ -315,12 +319,16 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME: Add option to use a log */
 	if (first_time) {
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
-			if (!test_mode())
-				log_error("ABORTING: Temporary mirror "
-					  "activation failed.  "
-					  "Run pvmove --abort.");
-			/* FIXME Resume using *original* metadata here! */
-			resume_lvs(cmd, lvs_changed);
+			if (test_mode())
+				goto out;
+
+			/*
+			 * Nothing changed yet, try to revert pvmove.
+			 */
+			log_error("Temporary pvmove mirror activation failed.");
+			if (!_finish_pvmove(cmd, vg, lv_mirr, lvs_changed))
+				log_error("ABORTING: Restoring original configuration "
+					  "before pvmove failed. Run pvmove --abort.");
 			goto out;
 		}
 	} else if (!resume_lv(cmd, lv_mirr)) {



