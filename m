From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 05:33:14 -0400
Subject: [PATCH 6/6] Convert vgsplit to use vg_read_for_update.
In-Reply-To: <1246008794-30493-6-git-send-email-dwysocha@redhat.com>
References: <1246008794-30493-1-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-2-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-3-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-4-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-5-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1246008794-30493-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Petr Rockai <prockai@redhat.com>

Sun May  3 13:12:28 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert vgsplit to use vg_read_for_update.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index f2be249..bd9e8ec 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -282,7 +282,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
 	int existing_vg = 0;
-	int consistent;
 	int r = ECMD_FAILED;
 	const char *lv_name;
 	uint32_t rc;
@@ -315,11 +314,11 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG |
-				       RESIZEABLE_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		 return ECMD_FAILED;
+
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+				     READ_REQUIRE_RESIZEABLE);
+	if (vg_read_error(vg_from))
+		return ECMD_FAILED;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*
@@ -339,12 +338,14 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	}
 	if (rc == FAILED_EXIST) {
 		existing_vg = 1;
-		if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
-					       LCK_VG_WRITE,
-					       CLUSTERED | EXPORTED_VG |
-					       RESIZEABLE_VG | LVM_WRITE,
-					       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-			return ECMD_FAILED;
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+					   READ_REQUIRE_RESIZEABLE |
+					   LOCK_NONBLOCKING | LOCK_KEEP |
+					   READ_CHECK_EXISTENCE);
+
+		if (vg_read_error(vg_to))
+			goto_bad;
+
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
@@ -456,13 +457,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	/*
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
-	consistent = 1;
 	if (!test_mode()) {
-		vg_release(vg_to);
-		if (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
-		    !consistent) {
-			log_error("Volume group \"%s\" became inconsistent: please "
-				  "fix manually", vg_name_to);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
+					   READ_ALLOW_EXPORTED);
+		if (vg_read_error(vg_to)) {
+			log_error("Volume group \"%s\" became inconsistent: "
+				  "please fix manually", vg_name_to);
 			goto_bad;
 		}
 	}
-- 
1.6.0.6


