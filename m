From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 26 May 2016 13:54:19 +0000 (UTC)
Subject: master - vgreduce: use process_each_vg
Message-ID: <20160526135419.DCF4B60D75@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5dc2ed0c71eab9081ef6245150f5efad2a7c77b9
Commit:        5dc2ed0c71eab9081ef6245150f5efad2a7c77b9
Parent:        2f2b3c9100443593d94ed4ed2ed014b56537c0e0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 25 15:04:30 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 25 16:41:59 2016 -0500

vgreduce: use process_each_vg

---
 lib/metadata/metadata.c |    1 +
 tools/vgreduce.c        |  140 ++++++++++++++++++++--------------------------
 2 files changed, 62 insertions(+), 79 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9e31ba4..bd97cd2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -773,6 +773,7 @@ bad:
  * . find_pv_by_name()
  * . get_pvs()
  * . the vg->pvs_to_write list and pv_to_write struct
+ * . vg_reduce()
  */
 
 /*
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index e7c66fe..a10e12c 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -15,6 +15,12 @@
 
 #include "tools.h"
 
+struct vgreduce_params {
+	int force;
+	int fixed;
+	int already_consistent;
+};
+
 static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 {
 	char uuid[64] __attribute__((aligned(8)));
@@ -137,16 +143,43 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	return ECMD_PROCESSED;
 }
 
+static int _vgreduce_repair_single(struct cmd_context *cmd, const char *vg_name,
+		                   struct volume_group *vg, struct processing_handle *handle)
+{
+	struct vgreduce_params *vp = (struct vgreduce_params *) handle->custom_handle;
+
+	if (!vg_missing_pv_count(vg)) {
+		vp->already_consistent = 1;
+		return ECMD_PROCESSED;
+	}
+
+	if (!archive(vg))
+		return_ECMD_FAILED;
+
+	if (vp->force) {
+		if (!_make_vg_consistent(cmd, vg))
+			return_ECMD_FAILED;
+		vp->fixed = 1;
+	} else
+		vp->fixed = _consolidate_vg(cmd, vg);
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Failed to write out a consistent VG for %s", vg_name);
+		return ECMD_FAILED;
+	}
+
+	backup(vg);
+	return ECMD_PROCESSED;
+}
+
 int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct volume_group *vg;
+	struct processing_handle *handle;
+	struct vgreduce_params vp = { 0 };
 	const char *vg_name;
-	uint32_t lockd_state = 0;
-	int ret = ECMD_FAILED;
-	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
-	int locked = 0;
+	int ret;
 
 	if (!argc && !repairing) {
 		log_error("Please give volume group name and "
@@ -184,99 +217,48 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 	argc--;
 
-	if (!repairing)
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+	handle->custom_handle = &vp;
+
+	if (!repairing) {
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch afterwards? */
-		return process_each_pv(cmd, argc, argv, vg_name,
-				       0, READ_FOR_UPDATE, NULL,
-				      _vgreduce_single);
+		ret = process_each_pv(cmd, argc, argv, vg_name, 0, READ_FOR_UPDATE, handle, _vgreduce_single);
+		goto out;
+	}
 
-	log_verbose("Finding volume group \"%s\"", vg_name);
+	/*
+	 * VG repair (removemissing)
+	 */
 
-	init_ignore_suspended_devices(1);
-	cmd->handles_missing_pvs = 1;
+	vp.force = arg_count(cmd, force_ARG);
 
 	/* Needed to change the set of orphan PVs. */
 	if (!lockd_gl(cmd, "ex", 0))
 		return_ECMD_FAILED;
+	cmd->lockd_gl_disable = 1;
 
-	if (!lockd_vg(cmd, vg_name, "ex", 0, &lockd_state))
-		return_ECMD_FAILED;
-
-	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED, lockd_state);
-	if (vg_read_error(vg) == FAILED_ALLOCATION ||
-	    vg_read_error(vg) == FAILED_NOTFOUND)
-		goto_out;
+	cmd->handles_missing_pvs = 1;
 
-	/* FIXME We want to allow read-only VGs to be changed here? */
-	if (vg_read_error(vg) &&
-	    (vg_read_error(vg) != FAILED_READ_ONLY) &&
-	    !arg_count(cmd, removemissing_ARG))
-		goto_out;
+	init_ignore_suspended_devices(1);
 
-	locked = !vg_read_error(vg);
+	process_each_vg(cmd, 0, NULL, vg_name, NULL,
+			READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
+			handle, &_vgreduce_repair_single);
 
-	if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
-		log_error("Volume group \"%s\" is already consistent", vg_name);
+	if (vp.already_consistent) {
+		log_print_unless_silent("Volume group \"%s\" is already consistent", vg_name);
 		ret = ECMD_PROCESSED;
-		goto out;
-	}
-
-	release_vg(vg);
-	log_verbose("Trying to open VG %s for recovery...", vg_name);
-
-	vg = vg_read_for_update(cmd, vg_name, NULL,
-				READ_ALLOW_INCONSISTENT | READ_ALLOW_EXPORTED, lockd_state);
-
-	locked |= !vg_read_error(vg);
-
-	if (vg_read_error(vg) &&
-	    (vg_read_error(vg) != FAILED_READ_ONLY) &&
-	    (vg_read_error(vg) != FAILED_INCONSISTENT))
-		goto_out;
-
-	if (!archive(vg))
-		goto_out;
-
-	if (arg_count(cmd, force_ARG)) {
-		if (!_make_vg_consistent(cmd, vg))
-			goto_out;
-	} else
-		fixed = _consolidate_vg(cmd, vg);
-
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("Failed to write out a consistent VG for %s", vg_name);
-		goto out;
-	}
-
-	backup(vg);
-
-	if (fixed) {
+	} else if (vp.fixed) {
 		log_print_unless_silent("Wrote out consistent volume group %s", vg_name);
 		ret = ECMD_PROCESSED;
 	} else
 		ret = ECMD_FAILED;
-
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	if (locked)
-		unlock_vg(cmd, vg_name);
-
-	release_vg(vg);
 
 	return ret;
-
-/******* FIXME
-	log_error ("no empty physical volumes found in volume group \"%s\"", vg_name);
-
-	log_verbose("volume group \"%s\" will be reduced by %d physical volume%s",
-		    vg_name, np, np > 1 ? "s" : "");
-	log_verbose("reducing volume group \"%s\" by physical volume \"%s\"",
-		    vg_name, pv_names[p]);
-
-	log_print("volume group \"%s\" %ssuccessfully reduced by physical volume%s:",
-		  vg_name, error > 0 ? "NOT " : "", p > 1 ? "s" : "");
-	log_print("%s", pv_this[p]->pv_name);
-********/
-
 }


