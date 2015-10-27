From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 27 Oct 2015 15:55:22 +0000 (UTC)
Subject: master - vgs, lvs: ignore error if VG is removed
Message-ID: <20151027155522.1913A606C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4418b34c150299aa88c6540bb4e3680f8bb4dae
Commit:        a4418b34c150299aa88c6540bb4e3680f8bb4dae
Parent:        65ec00ce202411f6e6f91955ab9422d44bb86a9b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 27 10:52:01 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 27 10:52:01 2015 -0500

vgs, lvs: ignore error if VG is removed

If a VG is removed between the time that 'vgs'
or 'lvs' (with no args) creates the list of VGs
and the time that it reads the VG to process it,
then ignore the removed VG; don't report an error
that it could not be found, since it wasn't named
by the command.
---
 tools/toollib.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 59ba29f..3804d66 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1909,7 +1909,7 @@ int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
 	return 1;
 }
 
-static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
+static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				  struct dm_list *vgnameids_to_process,
 				  struct dm_list *arg_vgnames,
 				  struct dm_list *arg_tags,
@@ -1952,8 +1952,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			continue;
 		}
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip, &notfound)) {
+		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
+		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			goto endvg;
@@ -2020,7 +2020,7 @@ static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *s
  * Call process_single_vg() for each VG selected by the command line arguments.
  */
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, struct processing_handle *handle,
+		    uint32_t read_flags, struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
 	int handle_supplied = handle != NULL;
@@ -2070,6 +2070,9 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		goto out;
 	}
 
+	if (dm_list_empty(&arg_vgnames))
+		read_flags |= READ_OK_NOTFOUND;
+
 	/*
 	 * If we obtained a full list of VGs on the system, we need to work through them all;
 	 * otherwise we can merely work through the VG names provided.
@@ -2086,7 +2089,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	    !init_selection_handle(cmd, handle, VGS))
 		goto_out;
 
-	ret = _process_vgnameid_list(cmd, flags, &vgnameids_to_process,
+	ret = _process_vgnameid_list(cmd, read_flags, &vgnameids_to_process,
 				     &arg_vgnames, &arg_tags, handle, process_single_vg);
 out:
 	if (!handle_supplied)
@@ -2375,7 +2378,7 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
+static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				     struct dm_list *vgnameids_to_process,
 				     struct dm_list *arg_vgnames,
 				     struct dm_list *arg_lvnames,
@@ -2442,8 +2445,8 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			continue;
 		}
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip, &notfound)) {
+		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
+		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			goto endvg;
@@ -2471,7 +2474,7 @@ endvg:
 /*
  * Call process_single_lv() for each LV selected by the command line arguments.
  */
-int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t flags,
+int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t read_flags,
 		    struct processing_handle *handle, process_single_lv_fn_t process_single_lv)
 {
 	int handle_supplied = handle != NULL;
@@ -2538,6 +2541,9 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 		goto out;
 	}
 
+	if (dm_list_empty(&arg_vgnames))
+		read_flags |= READ_OK_NOTFOUND;
+
 	/*
 	 * If we obtained a full list of VGs on the system, we need to work through them all;
 	 * otherwise we can merely work through the VG names provided.
@@ -2547,7 +2553,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED)
 		goto_out;
 
-	ret = _process_lv_vgnameid_list(cmd, flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
+	ret = _process_lv_vgnameid_list(cmd, read_flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
 					&arg_tags, handle, process_single_lv);
 out:
 	if (!handle_supplied)


