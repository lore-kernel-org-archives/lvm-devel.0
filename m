From: okozina <okozina@fedoraproject.org>
Date: Mon,  4 May 2015 14:57:29 +0000 (UTC)
Subject: master - polldaemon: move lvconvert_get_copy_vg code
Message-ID: <20150504145729.BA1B360DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=079895b8bee452c36bf1952df7e40d508ff299eb
Commit:        079895b8bee452c36bf1952df7e40d508ff299eb
Parent:        7a5a4f952e567ebb32e61414db62292eab81b6c7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 4 14:32:32 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 4 16:56:28 2015 +0200

polldaemon: move lvconvert_get_copy_vg code

Moving lvconvert_get_copy_vg to polldaemon (poll_get_copy_vg).
Clear move and rename.
---
 tools/lvconvert.c      |    8 ++++----
 tools/lvconvert_poll.c |   14 --------------
 tools/lvconvert_poll.h |    4 ----
 tools/polldaemon.c     |   13 +++++++++++++
 tools/polldaemon.h     |    5 ++++-
 5 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 732f6fd..4d8d08c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -700,21 +700,21 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 }
 
 static struct poll_functions _lvconvert_mirror_fns = {
-	.get_copy_vg = lvconvert_get_copy_vg,
+	.get_copy_vg = poll_get_copy_vg,
 	.get_copy_lv = lvconvert_get_copy_lv,
 	.poll_progress = poll_mirror_progress,
 	.finish_copy = lvconvert_mirror_finish,
 };
 
 static struct poll_functions _lvconvert_merge_fns = {
-	.get_copy_vg = lvconvert_get_copy_vg,
+	.get_copy_vg = poll_get_copy_vg,
 	.get_copy_lv = lvconvert_get_copy_lv,
 	.poll_progress = poll_merge_progress,
 	.finish_copy = lvconvert_merge_finish,
 };
 
 static struct poll_functions _lvconvert_thin_merge_fns = {
-	.get_copy_vg = lvconvert_get_copy_vg,
+	.get_copy_vg = poll_get_copy_vg,
 	.get_copy_lv = lvconvert_get_copy_lv,
 	.poll_progress = poll_thin_merge_progress,
 	.finish_copy = lvconvert_merge_finish,
@@ -3219,7 +3219,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 	struct volume_group *vg;
 	struct logical_volume* lv = NULL;
 
-	vg = lvconvert_get_copy_vg(cmd, vg_name, NULL);
+	vg = poll_get_copy_vg(cmd, vg_name, NULL);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_NULL;
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 4745d06..b6ee980 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -16,20 +16,6 @@
 #include "lvconvert_poll.h"
 #include "tools.h"
 
-struct volume_group *lvconvert_get_copy_vg(struct cmd_context *cmd,
-					   const char *name,
-					   const char *uuid __attribute__((unused)))
-{
-	dev_close_all();
-
-	if (name && !strchr(name, '/'))
-		return vg_read_for_update(cmd, name, NULL, 0);
-
-	/* 'name' is the full LV name; must extract_vgname() */
-	return vg_read_for_update(cmd, extract_vgname(cmd, name),
-				  NULL, 0);
-}
-
 struct logical_volume *lvconvert_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
 					     struct volume_group *vg,
 					     const char *name,
diff --git a/tools/lvconvert_poll.h b/tools/lvconvert_poll.h
index d79962c..801633e 100644
--- a/tools/lvconvert_poll.h
+++ b/tools/lvconvert_poll.h
@@ -21,10 +21,6 @@ struct cmd_context;
 struct logical_volume;
 struct volume_group;
 
-struct volume_group *lvconvert_get_copy_vg(struct cmd_context *cmd,
-					   const char *name,
-					   const char *uuid __attribute__((unused)));
-
 struct logical_volume *lvconvert_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
 					     struct volume_group *vg,
 					     const char *name,
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 2684f63..b78e364 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -49,6 +49,19 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 	return PROGRESS_FINISHED_SEGMENT;
 }
 
+struct volume_group *poll_get_copy_vg(struct cmd_context *cmd,
+				      const char *name,
+				      const char *uuid __attribute__((unused)))
+{
+	dev_close_all();
+
+	if (name && !strchr(name, '/'))
+		return vg_read_for_update(cmd, name, NULL, 0);
+
+	/* 'name' is the full LV name; must extract_vgname() */
+	return vg_read_for_update(cmd, extract_vgname(cmd, name), NULL, 0);
+}
+
 static int _check_lv_status(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index 89c3aae..b602a08 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -72,4 +72,7 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
 				struct daemon_parms *parms);
 
+struct volume_group *poll_get_copy_vg(struct cmd_context *cmd, const char *name,
+				      const char *uuid);
+
 #endif


