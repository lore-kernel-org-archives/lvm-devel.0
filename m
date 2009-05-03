From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:55 +0200
Subject: [PATCH 3/9] Convert vgreduce to use vg_read_for_update.
In-Reply-To: <1241350741-31349-3-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-4-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 12:50:58 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert vgreduce to use vg_read_for_update.
diff -rN -u -p old-temp.31080/tools/vgreduce.c new-temp.31080/tools/vgreduce.c
--- old-temp.31080/tools/vgreduce.c	2009-05-03 13:29:29.730232352 +0200
+++ new-temp.31080/tools/vgreduce.c	2009-05-03 13:29:29.830234657 +0200
@@ -382,7 +382,6 @@ static int _vgreduce_single(struct cmd_c
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
-	int consistent = 1;
 	int r = ECMD_FAILED;
 	const char *name = pv_dev_name(pv);
 
@@ -397,15 +396,10 @@ static int _vgreduce_single(struct cmd_c
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	pvl = find_pv_in_vg(vg, name);
 
 	if (!archive(vg))
-		goto bad;
+		return ECMD_FAILED;
 
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
@@ -424,11 +418,11 @@ static int _vgreduce_single(struct cmd_c
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
-	   !consistent) {
-		log_error("Unable to read existing orphan PVs");
+ 	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
+ 				       NULL, LOCK_NONBLOCKING);
+
+ 	if (vg_read_error(orphan_vg))
 		goto bad;
-	}
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
 		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
@@ -463,7 +457,6 @@ int vgreduce(struct cmd_context *cmd, in
 	struct volume_group *vg;
 	char *vg_name;
 	int ret = ECMD_FAILED;
-	int consistent = 1;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
 
@@ -510,22 +503,19 @@ int vgreduce(struct cmd_context *cmd, in
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name);
-		return ECMD_FAILED;
-	}
 
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
@@ -533,13 +523,16 @@ int vgreduce(struct cmd_context *cmd, in
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
 


