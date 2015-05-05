From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:11 +0000 (UTC)
Subject: master - polldaemon: get get_copy_vg ready for refactoring
Message-ID: <20150505185411.4BB3C60ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22ae43a11ef9bea5ae3a9c6127bb1ed07f93d103
Commit:        22ae43a11ef9bea5ae3a9c6127bb1ed07f93d103
Parent:        991d646354a10e9953fdf0e75cb2a33a81f6ffef
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 5 16:06:24 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:51:34 2015 +0200

polldaemon: get get_copy_vg ready for refactoring

with refactored code we take some VG locks as read-only.
Make the poll_get_copy_vg ready for the change.
---
 tools/lvconvert.c   |    2 +-
 tools/polldaemon.c  |    9 +++++----
 tools/polldaemon.h  |    5 +++--
 tools/pvmove_poll.c |    3 ++-
 tools/pvmove_poll.h |    6 +++++-
 5 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5f5b551..41aaad6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3222,7 +3222,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 	struct volume_group *vg;
 	struct logical_volume* lv = NULL;
 
-	vg = poll_get_copy_vg(cmd, vg_name, NULL);
+	vg = poll_get_copy_vg(cmd, vg_name, NULL, READ_FOR_UPDATE);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_NULL;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 75a1224..259ea47 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -51,15 +51,16 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 
 struct volume_group *poll_get_copy_vg(struct cmd_context *cmd,
 				      const char *name,
-				      const char *uuid __attribute__((unused)))
+				      const char *uuid __attribute__((unused)),
+				      uint32_t flags)
 {
 	dev_close_all();
 
 	if (name && !strchr(name, '/'))
-		return vg_read_for_update(cmd, name, NULL, 0);
+		return vg_read(cmd, name, NULL, flags);
 
 	/* 'name' is the full LV name; must extract_vgname() */
-	return vg_read_for_update(cmd, extract_vgname(cmd, name), NULL, 0);
+	return vg_read(cmd, extract_vgname(cmd, name), NULL, flags);
 }
 
 struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
@@ -155,7 +156,7 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 			_sleep_and_rescan_devices(parms);
 
 		/* Locks the (possibly renamed) VG again */
-		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
+		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid, READ_FOR_UPDATE);
 		if (vg_read_error(vg)) {
 			release_vg(vg);
 			log_error("ABORTING: Can't reread VG for %s", name);
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index c896021..1779007 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -31,7 +31,8 @@ struct poll_functions {
 	const char *(*get_copy_name_from_lv) (const struct logical_volume *lv);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
 					     const char *name,
-					     const char *uuid);
+					     const char *uuid,
+					     uint32_t flags);
 	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
 					       struct volume_group *vg,
 					       const char *name,
@@ -73,7 +74,7 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct daemon_parms *parms);
 
 struct volume_group *poll_get_copy_vg(struct cmd_context *cmd, const char *name,
-				      const char *uuid);
+				      const char *uuid, uint32_t flags);
 
 struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd,
 					struct volume_group *vg,
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index cd32476..eeaf390 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -203,7 +203,8 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 }
 
 struct volume_group *pvmove_get_copy_vg(struct cmd_context *cmd, const char *name,
-					const char *uuid __attribute__((unused)))
+					const char *uuid __attribute__((unused)),
+					uint32_t flags __attribute__((unused)))
 {
 	struct physical_volume *pv;
 	struct volume_group *vg;
diff --git a/tools/pvmove_poll.h b/tools/pvmove_poll.h
index 776920c..ae7505a 100644
--- a/tools/pvmove_poll.h
+++ b/tools/pvmove_poll.h
@@ -15,6 +15,9 @@
 #ifndef _LVM_PVMOVE_H
 #define _LVM_PVMOVE_H
 
+/* FIXME: remove it after refactoring completes */
+#include <stdint.h>
+
 struct cmd_context;
 struct dm_list;
 struct logical_volume;
@@ -30,6 +33,7 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed);
 
 struct volume_group *pvmove_get_copy_vg(struct cmd_context *cmd,
-					const char *name, const char *uuid);
+					const char *name, const char *uuid,
+					uint32_t flags);
 
 #endif  /* _LVM_PVMOVE_H */


