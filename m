From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 24 Jan 2009 16:46:00 -0500
Subject: [PATCH] Convert vgreduce to use vg_read_for_update.
In-Reply-To: <1232833560-2964-1-git-send-email-dwysocha@redhat.com>
References: <1232619010-4858-9-git-send-email-prockai@redhat.com>
	<1232833560-2964-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1232833560-2964-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Petr Rockai <prockai@redhat.com>

Fri Jan  9 15:38:20 CET 2009  Petr Rockai <me@mornfall.net>
  * Convert vgreduce to use vg_read_for_update.

Remove incorrect unlock_vg() in vgreduce_single() error path.
If dev_get_size() fails we don't have the orphan lock yet so
don't try to unlock.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgreduce.c |   57 +++++++++++++++++++----------------------------------
 1 files changed, 21 insertions(+), 36 deletions(-)

diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 79bf3e0..09bbd09 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -382,7 +382,6 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg;
-	int consistent = 1;
 	const char *name = pv_dev_name(pv);
 
 	if (pv_pe_alloc_count(pv)) {
@@ -396,17 +395,10 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	pvl = find_pv_in_vg(vg, name);
 
-	if (!archive(vg)) {
-		unlock_vg(cmd, VG_ORPHANS);
+	if (!archive(vg))
 		return ECMD_FAILED;
-	}
 
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
@@ -418,7 +410,6 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (!dev_get_size(pv_dev(pv), &pv->size)) {
 		log_error("%s: Couldn't get size.", pv_dev_name(pv));
-		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
@@ -426,12 +417,11 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
-	   !consistent) {
-		log_error("Unable to read existing orphan PVs");
-		unlock_vg(cmd, VG_ORPHANS);
+	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
+				       NULL, NONBLOCKING_LOCK | ORPHAN_LOCK);
+
+	if (vg_read_error(orphan_vg))
 		return ECMD_FAILED;
-	}
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
 		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
@@ -468,7 +458,6 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	struct volume_group *vg;
 	char *vg_name;
 	int ret = 1;
-	int consistent = 1;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
 
@@ -515,41 +504,37 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name);
-		return ECMD_FAILED;
-	}
 
-	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
-	    && !repairing) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name);
-		unlock_vg(cmd, vg_name);
+	vg = vg_read_for_update(cmd, vg_name, NULL, ALLOW_EXPORTED);
+	if (vg_read_error(vg) == FAILED_ALLOCATION ||
+	    vg_read_error(vg) == FAILED_NOTFOUND)
 		return ECMD_FAILED;
-	}
 
-	if (vg && !vg_check_status(vg, CLUSTERED)) {
-		unlock_vg(cmd, vg_name);
+	/* FIXME We want to allow read-only VGs to be changed here? */
+	if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
+	    && !arg_count(cmd, removemissing_ARG))
 		return ECMD_FAILED;
-	}
 
 	if (repairing) {
-		if (vg && consistent && !vg_missing_pv_count(vg)) {
+		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
 			log_error("Volume group \"%s\" is already consistent",
 				  vg_name);
 			unlock_vg(cmd, vg_name);
 			return ECMD_PROCESSED;
 		}
 
-		consistent = !arg_count(cmd, force_ARG);
-		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-			log_error("Volume group \"%s\" not found", vg_name);
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
-		if (!vg_check_status(vg, CLUSTERED)) {
+		log_verbose("Trying to open VG %s for recovery...", vg_name);
+
+		vg = vg_read_for_update(cmd, vg_name, NULL,
+					ALLOW_INCONSISTENT | DISABLE_LOCK
+					| ALLOW_EXPORTED);
+
+		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
+		    && vg_read_error(vg) != FAILED_INCONSISTENT) {
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
+
 		if (!archive(vg)) {
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
-- 
1.5.5.1


