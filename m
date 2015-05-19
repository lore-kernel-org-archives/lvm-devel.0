From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:03:01 +0000 (UTC)
Subject: master - polldaemon: remove get_copy_vg and get_copy_lv wrappers
Message-ID: <20150519190301.EF3A860FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a8ce8dbf73fc149c67b22e3b90f542f70944e93
Commit:        7a8ce8dbf73fc149c67b22e3b90f542f70944e93
Parent:        6fba37777c8a0931adf1164ff914aa494d8bcee8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 15:13:01 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:56:15 2015 +0200

polldaemon: remove get_copy_vg and get_copy_lv wrappers

These wrappers have been replaced by direct calls
to vg_read() and find_lv() in previous commits.

This commit should have no functional impact since
all bits were already unreachable.
---
 lib/lvmpolld/polldaemon.h |   17 -----------------
 tools/lvconvert.c         |    6 ------
 tools/lvpoll.c            |    8 --------
 tools/polldaemon.c        |   26 --------------------------
 tools/pvmove.c            |    2 --
 5 files changed, 0 insertions(+), 59 deletions(-)

diff --git a/lib/lvmpolld/polldaemon.h b/lib/lvmpolld/polldaemon.h
index 2c7ce4b..36b654f 100644
--- a/lib/lvmpolld/polldaemon.h
+++ b/lib/lvmpolld/polldaemon.h
@@ -29,15 +29,6 @@ struct daemon_parms;
 
 struct poll_functions {
 	const char *(*get_copy_name_from_lv) (const struct logical_volume *lv);
-	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
-					     const char *name,
-					     const char *uuid,
-					     uint32_t flags);
-	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
-					       struct volume_group *vg,
-					       const char *name,
-					       const char *uuid,
-					       uint64_t lv_type);
 	progress_t (*poll_progress)(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    const char *name,
@@ -79,14 +70,6 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
 				struct daemon_parms *parms);
 
-struct volume_group *poll_get_copy_vg(struct cmd_context *cmd, const char *name,
-				      const char *uuid, uint32_t flags);
-
-struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd,
-					struct volume_group *vg,
-					const char *name, const char *uuid,
-					uint64_t lv_type);
-
 int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		       struct daemon_parms *parms);
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7267c2f..9192d04 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -700,22 +700,16 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 }
 
 static struct poll_functions _lvconvert_mirror_fns = {
-	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_mirror_progress,
 	.finish_copy = lvconvert_mirror_finish,
 };
 
 static struct poll_functions _lvconvert_merge_fns = {
-	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_merge_progress,
 	.finish_copy = lvconvert_merge_finish,
 };
 
 static struct poll_functions _lvconvert_thin_merge_fns = {
-	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_thin_merge_progress,
 	.finish_copy = lvconvert_merge_finish,
 };
diff --git a/tools/lvpoll.c b/tools/lvpoll.c
index 0ed2d45..178392e 100644
--- a/tools/lvpoll.c
+++ b/tools/lvpoll.c
@@ -19,30 +19,22 @@
 #include "polling_ops.h"
 
 static struct poll_functions _pvmove_fns = {
-	.get_copy_lv = poll_get_copy_lv,
-	.get_copy_vg = poll_get_copy_vg,
 	.poll_progress = poll_mirror_progress,
 	.update_metadata = pvmove_update_metadata,
 	.finish_copy = pvmove_finish
 };
 
 static struct poll_functions _convert_fns = {
-	.get_copy_lv = poll_get_copy_lv,
-	.get_copy_vg = poll_get_copy_vg,
 	.poll_progress = poll_mirror_progress,
 	.finish_copy = lvconvert_mirror_finish
 };
 
 static struct poll_functions _merge_fns = {
-	.get_copy_lv = poll_get_copy_lv,
-	.get_copy_vg = poll_get_copy_vg,
 	.poll_progress = poll_merge_progress,
 	.finish_copy = lvconvert_merge_finish
 };
 
 static struct poll_functions _thin_merge_fns = {
-	.get_copy_lv = poll_get_copy_lv,
-	.get_copy_vg = poll_get_copy_vg,
 	.poll_progress = poll_thin_merge_progress,
 	.finish_copy = lvconvert_merge_finish
 };
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d5daa62..9f4fc94 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -54,32 +54,6 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 	return PROGRESS_FINISHED_SEGMENT;
 }
 
-struct volume_group *poll_get_copy_vg(struct cmd_context *cmd,
-				      const char *name,
-				      const char *uuid __attribute__((unused)),
-				      uint32_t flags)
-{
-	if (name && !strchr(name, '/'))
-		return vg_read(cmd, name, NULL, flags);
-
-	/* 'name' is the full LV name; must extract_vgname() */
-	return vg_read(cmd, extract_vgname(cmd, name), NULL, flags);
-}
-
-struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
-					struct volume_group *vg,
-					const char *name,
-					const char *uuid,
-					uint64_t lv_type)
-{
-	struct logical_volume *lv = find_lv(vg, name);
-
-	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)) || (lv_type && !(lv->status & lv_type)))
-		return NULL;
-
-	return lv;
-}
-
 static int _check_lv_status(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
diff --git a/tools/pvmove.c b/tools/pvmove.c
index dc36955..d5b246f 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -744,8 +744,6 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 
 static struct poll_functions _pvmove_fns = {
 	.get_copy_name_from_lv = get_pvmove_pvname_from_lv_mirr,
-	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_mirror_progress,
 	.update_metadata = pvmove_update_metadata,
 	.finish_copy = pvmove_finish,


