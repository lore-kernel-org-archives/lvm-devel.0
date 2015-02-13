From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:29:35 +0000 (UTC)
Subject: master - cleanup: remove deallocate_handle_root arg from destroy_procesing_handle fnw
Message-ID: <20150213102935.20ECF6102A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=969d2bf4484810e1c3d402a45cb433b3bee19191
Commit:        969d2bf4484810e1c3d402a45cb433b3bee19191
Parent:        66b10d6d126fdf476cf43eec25820b021752b383
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 10:42:21 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 11:27:09 2015 +0100

cleanup: remove deallocate_handle_root arg from destroy_procesing_handle fnw

---
 tools/lvconvert.c   |    2 +-
 tools/polldaemon.c  |    4 ++--
 tools/pvchange.c    |    2 +-
 tools/pvresize.c    |    2 +-
 tools/reporter.c    |    2 +-
 tools/toollib.c     |   14 ++++++--------
 tools/toollib.h     |    3 +--
 tools/vgcfgbackup.c |    2 +-
 8 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b2527e4..3bbe65f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3563,6 +3563,6 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	else
 		ret = lvconvert_single(cmd, &lp);
 out:
-	destroy_processing_handle(cmd, handle, 1);
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 722a385..10ca4a5 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -314,7 +314,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	}
 
 	if (parms.background && daemon_mode == 1) {
-		destroy_processing_handle(cmd, handle, 1);
+		destroy_processing_handle(cmd, handle);
 		/*
 		 * child was successfully forked:
 		 * background polldaemon must not return to the caller
@@ -325,6 +325,6 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		_exit(lvm_return_code(ret));
 	}
 
-	destroy_processing_handle(cmd, handle, 1);
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }
diff --git a/tools/pvchange.c b/tools/pvchange.c
index a8414c1..c3e9215 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -216,6 +216,6 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 				params.total - params.done, (params.total - params.done) == 1 ? "" : "s");
 
 out:
-	destroy_processing_handle(cmd, handle, 1);
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index ec638a4..0f992a2 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -82,6 +82,6 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
 				"not resized", params.done, params.total - params.done);
 out:
-	destroy_processing_handle(cmd, handle, 1);
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index 9cc87bd..eb62bcf 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -578,7 +578,7 @@ int report_for_selection(struct cmd_context *cmd,
 	 * pass the result through it to layers above.
 	 */
 	handle->selection_handle = NULL;
-	destroy_processing_handle(cmd, handle, 1);
+	destroy_processing_handle(cmd, handle);
 	return r;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 4e0d0e7..b0f603b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1615,14 +1615,12 @@ int init_selection_handle(struct cmd_context *cmd, struct processing_handle *han
 	return 1;
 }
 
-void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle,
-			       int deallocate_handle_root)
+void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle)
 {
 	if (handle) {
 		if (handle->selection_handle && handle->selection_handle->selection_rh)
 			dm_report_free(handle->selection_handle->selection_rh);
-		if (deallocate_handle_root)
-			dm_pool_free(cmd->mem, handle);
+		dm_pool_free(cmd->mem, handle);
 	}
 }
 
@@ -1856,7 +1854,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 				     &arg_vgnames, &arg_tags, handle, process_single_vg);
 out:
 	if (!handle_supplied)
-		destroy_processing_handle(cmd, handle, 1);
+		destroy_processing_handle(cmd, handle);
 	return ret;
 }
 
@@ -1997,7 +1995,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 out:
 	if (!handle_supplied)
-		destroy_processing_handle(cmd, handle, 1);
+		destroy_processing_handle(cmd, handle);
 	else
 		_set_final_selection_result(handle, whole_selected);
 	return ret_max;
@@ -2257,7 +2255,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 					&arg_tags, handle, process_single_lv);
 out:
 	if (!handle_supplied)
-		destroy_processing_handle(cmd, handle, 1);
+		destroy_processing_handle(cmd, handle);
 	return ret;
 }
 
@@ -2600,7 +2598,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	}
 out:
 	if (!handle_supplied)
-		destroy_processing_handle(cmd, handle, 1);
+		destroy_processing_handle(cmd, handle);
 	return ret_max;
 }
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 3a2c5f8..7486d44 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -140,8 +140,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 struct processing_handle *init_processing_handle(struct cmd_context *cmd);
 int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle,
 			  report_type_t initial_report_type);
-void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle,
-			       int deallocate_handle_root);
+void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle);
 
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, int *selected);
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index a25a718..5e80c80 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -101,6 +101,6 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(0);
 
-	destroy_processing_handle(cmd, handle, 1);
+	destroy_processing_handle(cmd, handle);
 	return ret;
 }


