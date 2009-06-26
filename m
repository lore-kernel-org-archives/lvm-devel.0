From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 05:33:11 -0400
Subject: [PATCH 3/6] Convert vgreduce to use vg_read_for_update.
In-Reply-To: <1246008794-30493-3-git-send-email-dwysocha@redhat.com>
References: <1246008794-30493-1-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-2-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1246008794-30493-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 12:50:58 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert vgreduce to use vg_read_for_update.

Rebased 6/26/2009 - Dave W.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgreduce.c |   42 ++++++++++++++++++++----------------------
 1 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 1428a99..44010e3 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -382,7 +382,6 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
-	int consistent = 1;
 	int r = ECMD_FAILED;
 	const char *name = pv_dev_name(pv);
 
@@ -424,11 +423,11 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
-	   !consistent) {
-		log_error("Unable to read existing orphan PVs");
+	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
+				       NULL, LOCK_NONBLOCKING);
+
+	if (vg_read_error(orphan_vg))
 		goto bad;
-	}
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
 		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
@@ -463,7 +462,6 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	struct volume_group *vg;
 	char *vg_name;
 	int ret = ECMD_FAILED;
-	int consistent = 1;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
@@ -511,25 +509,22 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name);
-		return ECMD_FAILED;
-	}
 
 	if (repairing)
 		init_ignore_suspended_devices(1);
 
-	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
-	    && !repairing) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name);
+	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED);
+	if (vg_read_error(vg) == FAILED_ALLOCATION ||
+	    vg_read_error(vg) == FAILED_NOTFOUND)
 		goto out;
-	}
 
-	if (vg && !vg_check_status(vg, CLUSTERED))
+	/* FIXME We want to allow read-only VGs to be changed here? */
+	if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
+	    && !arg_count(cmd, removemissing_ARG))
 		goto out;
 
 	if (repairing) {
-		if (vg && consistent && !vg_missing_pv_count(vg)) {
+		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
 			log_error("Volume group \"%s\" is already consistent",
 				  vg_name);
 			ret = ECMD_PROCESSED;
@@ -537,13 +532,16 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		}
 
 		vg_release(vg);
-		consistent = !arg_count(cmd, force_ARG);
-		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-			log_error("Volume group \"%s\" not found", vg_name);
-			goto out;
-		}
-		if (!vg_check_status(vg, CLUSTERED))
+		log_verbose("Trying to open VG %s for recovery...", vg_name);
+
+		vg = vg_read_for_update(cmd, vg_name, NULL,
+					READ_ALLOW_INCONSISTENT
+					| READ_ALLOW_EXPORTED);
+
+		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
+		    && vg_read_error(vg) != FAILED_INCONSISTENT)
 			goto out;
+
 		if (!archive(vg))
 			goto out;
 
-- 
1.6.0.6


