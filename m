From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 23 Oct 2015 15:27:00 +0000 (UTC)
Subject: master - vg_read: sometimes ignore read errors
Message-ID: <20151023152700.2599660A36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a74171ca5682a684d0e05c6090c3d33cab8795b
Commit:        1a74171ca5682a684d0e05c6090c3d33cab8795b
Parent:        51735f09f79794d6609913b4c117f1a4a0e491fe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 22 14:56:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 23 10:12:34 2015 -0500

vg_read: sometimes ignore read errors

Running "vgremove -f VG & pvs" results in the pvs
command reporting that the VG is not found or is
inconsistent.  If the VG is gone or being removed,
the pvs command should just skip it and not print
errors about it.

"Not found" is because the pvs command created the
list of VGs to process, including VG, then vgremove
removed the VG, then the pvs command came to to read
the VG to process it and did not find it.

An "inconsistent" error could be reported if vgremove
had only partially completed removing VG when pvs did
vg_read on the VG to process it, causing pvs to find
the VG in a partially-removed state.

This fix adds a flag that pvs uses to ignore a VG
that can't be read or is inconsistent.
---
 lib/metadata/metadata-exported.h |    9 +++----
 lib/metadata/metadata.c          |   33 +++++++++++++++-------------
 tools/toollib.c                  |   43 ++++++++++++++++++++++++++++++--------
 3 files changed, 56 insertions(+), 29 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 25320fd..41838a8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -163,10 +163,9 @@
 /* vg_read and vg_read_for_update flags */
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
+#define READ_OK_NOTFOUND	0x00040000U
 #define READ_WARN_INCONSISTENT	0x00080000U
-
-/* A meta-flag, useful with toollib for_each_* functions. */
-#define READ_FOR_UPDATE		0x00100000U
+#define READ_FOR_UPDATE		0x00100000U /* A meta-flag, useful with toollib for_each_* functions. */
 
 /* vg's "read_status" field */
 #define FAILED_INCONSISTENT	0x00000001U
@@ -650,9 +649,9 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
  * Return a handle to VG metadata.
  */
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, uint32_t flags, uint32_t lockd_state);
+			     const char *vgid, uint32_t read_flags, uint32_t lockd_state);
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
-			 const char *vgid, uint32_t flags, uint32_t lockd_state);
+			 const char *vgid, uint32_t read_flags, uint32_t lockd_state);
 
 /* 
  * Test validity of a VG handle.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9bd42c9..1db8f58 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4925,7 +4925,7 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
  * Consolidated locking, reading, and status flag checking.
  *
  * If the metadata is inconsistent, setting READ_ALLOW_INCONSISTENT in
- * misc_flags will return it with FAILED_INCONSISTENT set instead of 
+ * read_flags will return it with FAILED_INCONSISTENT set instead of 
  * giving you nothing.
  *
  * Use vg_read_error(vg) to determine the result.  Nonzero means there were
@@ -4933,8 +4933,10 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
  * Zero value means that the VG is open and appropriate locks are held.
  */
 static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
-			       const char *vgid, uint32_t lock_flags,
-			       uint64_t status_flags, uint32_t misc_flags,
+			       const char *vgid,
+			       uint32_t lock_flags,
+			       uint64_t status_flags,
+			       uint32_t read_flags,
 			       uint32_t lockd_state)
 {
 	struct volume_group *vg = NULL;
@@ -4944,7 +4946,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	uint32_t warn_flags = 0;
 	int already_locked;
 
-	if (misc_flags & READ_ALLOW_INCONSISTENT || lock_flags != LCK_VG_WRITE)
+	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE))
 		consistent = 0;
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
@@ -4967,7 +4969,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	consistent_in = consistent;
 
 	warn_flags = WARN_PV_READ;
-	if (consistent || (misc_flags & READ_WARN_INCONSISTENT))
+	if (consistent || (read_flags & READ_WARN_INCONSISTENT))
 		warn_flags |= WARN_INCONSISTENT;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
@@ -4976,7 +4978,8 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 			failure |= FAILED_INCONSISTENT;
 			goto bad;
 		}
-		log_error("Volume group \"%s\" not found", vg_name);
+		if (!(read_flags & READ_OK_NOTFOUND))
+			log_error("Volume group \"%s\" not found", vg_name);
 		failure |= FAILED_NOTFOUND;
 		goto bad;
 	}
@@ -5057,20 +5060,20 @@ bad_no_unlock:
  * *consistent = 1.
  */
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, uint32_t flags, uint32_t lockd_state)
+			     const char *vgid, uint32_t read_flags, uint32_t lockd_state)
 {
-	uint64_t status = UINT64_C(0);
+	uint64_t status_flags = UINT64_C(0);
 	uint32_t lock_flags = LCK_VG_READ;
 
-	if (flags & READ_FOR_UPDATE) {
-		status |= EXPORTED_VG | LVM_WRITE;
+	if (read_flags & READ_FOR_UPDATE) {
+		status_flags |= EXPORTED_VG | LVM_WRITE;
 		lock_flags = LCK_VG_WRITE;
 	}
 
-	if (flags & READ_ALLOW_EXPORTED)
-		status &= ~EXPORTED_VG;
+	if (read_flags & READ_ALLOW_EXPORTED)
+		status_flags &= ~EXPORTED_VG;
 
-	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags, lockd_state);
+	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status_flags, read_flags, lockd_state);
 }
 
 /*
@@ -5079,9 +5082,9 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
  * request the new metadata to be written and committed).
  */
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
-			 const char *vgid, uint32_t flags, uint32_t lockd_state)
+			 const char *vgid, uint32_t read_flags, uint32_t lockd_state)
 {
-	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE, lockd_state);
+	return vg_read(cmd, vg_name, vgid, read_flags | READ_FOR_UPDATE, lockd_state);
 }
 
 /*
diff --git a/tools/toollib.c b/tools/toollib.c
index dfb2b87..b17fe53 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -184,12 +184,24 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
  *   If *skip is 1, it's OK for the caller to read the list of PVs in the VG.
  */
 static int _ignore_vg(struct volume_group *vg, const char *vg_name,
-		      struct dm_list *arg_vgnames, int allow_inconsistent, int *skip)
+		      struct dm_list *arg_vgnames, uint32_t read_flags, int *skip)
 {
 	uint32_t read_error = vg_read_error(vg);
 	*skip = 0;
 
-	if ((read_error & FAILED_INCONSISTENT) && allow_inconsistent)
+	if ((read_error & FAILED_NOTFOUND) && (read_flags & READ_OK_NOTFOUND)) {
+		read_error &= ~FAILED_NOTFOUND;
+		*skip = 1;
+		return 0;
+	}
+
+	if ((read_error & FAILED_INCONSISTENT) && (read_flags & READ_OK_NOTFOUND)) {
+		read_error &= ~FAILED_INCONSISTENT;
+		*skip = 1;
+		return 0;
+	}
+
+	if ((read_error & FAILED_INCONSISTENT) && (read_flags & READ_ALLOW_INCONSISTENT))
 		read_error &= ~FAILED_INCONSISTENT; /* Check for other errors */
 
 	if ((read_error & FAILED_CLUSTERED) && vg->cmd->ignore_clustered_vgs) {
@@ -1943,7 +1955,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			goto endvg;
@@ -2431,7 +2443,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			goto endvg;
@@ -2897,7 +2909,7 @@ out:
  * should produce an error.  Any devices remaining in all_devices were
  * not found and should be processed by process_device_list().
  */
-static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
+static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			       struct dm_list *all_vgnameids,
 			       struct dm_list *all_devices,
 			       struct dm_list *arg_devices,
@@ -2929,8 +2941,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			continue;
 		}
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT, lockd_state);
-		if (_ignore_vg(vg, vg_name, NULL, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
+		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			if (!skip)
@@ -2969,7 +2981,7 @@ endvg:
 int process_each_pv(struct cmd_context *cmd,
 		    int argc, char **argv,
 		    const char *only_this_vgname,
-		    uint32_t flags,
+		    uint32_t read_flags,
 		    struct processing_handle *handle,
 		    process_single_pv_fn_t process_single_pv)
 {
@@ -2984,6 +2996,19 @@ int process_each_pv(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	/*
+	 * When processing a specific VG name, warn if it's inconsistent and
+	 * print an error if it's not found.  Otherwise we're processing all
+	 * VGs, in which case the command doesn't care if the VG is inconsisent
+	 * or not found; it just wants to skip that VG.  (It may be not found
+	 * if it was removed between creating the list of all VGs and then
+	 * processing each VG.
+	 */
+	if (only_this_vgname)
+		read_flags |= READ_WARN_INCONSISTENT;
+	else
+		read_flags |= READ_OK_NOTFOUND;
+
 	/* Disable error in vg_read so we can print it from ignore_vg. */
 	cmd->vg_read_print_access_error = 0;
 
@@ -3040,7 +3065,7 @@ int process_each_pv(struct cmd_context *cmd,
 		/* get_arg_devices reports the error for any PV names not found. */
 		ret_max = ECMD_FAILED;
 
-	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
+	ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
 				  &arg_devices, &arg_tags,
 				  process_all_pvs, process_all_devices,
 				  handle, process_single_pv);


