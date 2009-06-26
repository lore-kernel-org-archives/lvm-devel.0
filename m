From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 05:33:12 -0400
Subject: [PATCH 4/6] Convert vgrename to vg_read_for_update.
In-Reply-To: <1246008794-30493-4-git-send-email-dwysocha@redhat.com>
References: <1246008794-30493-1-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-2-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-3-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1246008794-30493-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Petr Rockai <prockai@redhat.com>

Sun May  3 12:54:28 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert vgrename to vg_read_for_update.

Rebased 6/26/2009 - Dave W.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgrename.c |   25 +++++--------------------
 1 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index b2366a4..4d115d0 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -20,7 +20,6 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 {
 	char *dev_dir;
 	struct id id;
-	int consistent = 1;
 	int match = 0;
 	int found_id = 0;
 	struct dm_list *vgids;
@@ -71,25 +70,11 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	} else
 		vgid = NULL;
 
-	if (!lock_vol(cmd, vg_name_old, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name_old);
-		return 0;
-	}
-
-	if (!(vg = vg_read_internal(cmd, vg_name_old, vgid, &consistent)) || !consistent) {
-		log_error("Volume group %s %s%s%snot found.", vg_name_old,
-		vgid ? "(" : "", vgid ? vgid : "", vgid ? ") " : "");
-		unlock_vg(cmd, vg_name_old);
-		return 0;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED | LVM_WRITE)) {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		return 0;
-	}
-
-	/* Don't return failure for EXPORTED_VG */
-	vg_check_status(vg, EXPORTED_VG);
+	/* FIXME we used to print an error about EXPORTED, but proceeded
+	   nevertheless. */
+	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
+	if (vg_read_error(vg))
+		return_0;
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
-- 
1.6.0.6


