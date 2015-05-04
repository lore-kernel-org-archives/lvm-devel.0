From: okozina <okozina@fedoraproject.org>
Date: Mon,  4 May 2015 14:57:31 +0000 (UTC)
Subject: master - polldaemon: move lvconvert_get_copy_lv code
Message-ID: <20150504145731.DF38860DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26f4b1da88ed1b26be232cbdab1d000697ef5aa9
Commit:        26f4b1da88ed1b26be232cbdab1d000697ef5aa9
Parent:        079895b8bee452c36bf1952df7e40d508ff299eb
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Apr 10 13:57:13 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 4 16:56:39 2015 +0200

polldaemon: move lvconvert_get_copy_lv code

Moving lvconvert_get_copy_lv to polldaemon (poll_get_copy_lv).
Clear move and rename.
---
 tools/lvconvert.c      |    8 ++++----
 tools/lvconvert_poll.c |   14 --------------
 tools/lvconvert_poll.h |    6 ------
 tools/polldaemon.c     |   14 ++++++++++++++
 tools/polldaemon.h     |    5 +++++
 5 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4d8d08c..357a3ce 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -701,21 +701,21 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = lvconvert_get_copy_lv,
+	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_mirror_progress,
 	.finish_copy = lvconvert_mirror_finish,
 };
 
 static struct poll_functions _lvconvert_merge_fns = {
 	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = lvconvert_get_copy_lv,
+	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_merge_progress,
 	.finish_copy = lvconvert_merge_finish,
 };
 
 static struct poll_functions _lvconvert_thin_merge_fns = {
 	.get_copy_vg = poll_get_copy_vg,
-	.get_copy_lv = lvconvert_get_copy_lv,
+	.get_copy_lv = poll_get_copy_lv,
 	.poll_progress = poll_thin_merge_progress,
 	.finish_copy = lvconvert_merge_finish,
 };
@@ -3225,7 +3225,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 		return_NULL;
 	}
 
-	if (!(lv = lvconvert_get_copy_lv(cmd, vg, lv_name, NULL, 0))) {
+	if (!(lv = poll_get_copy_lv(cmd, vg, lv_name, NULL, 0))) {
 		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index b6ee980..72c8df8 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -16,20 +16,6 @@
 #include "lvconvert_poll.h"
 #include "tools.h"
 
-struct logical_volume *lvconvert_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
-					     struct volume_group *vg,
-					     const char *name,
-					     const char *uuid,
-					     uint64_t lv_type __attribute__((unused)))
-{
-	struct logical_volume *lv = find_lv(vg, name);
-
-	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
-		return NULL;
-
-	return lv;
-}
-
 int lvconvert_mirror_finish(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
diff --git a/tools/lvconvert_poll.h b/tools/lvconvert_poll.h
index 801633e..7c97ec8 100644
--- a/tools/lvconvert_poll.h
+++ b/tools/lvconvert_poll.h
@@ -21,12 +21,6 @@ struct cmd_context;
 struct logical_volume;
 struct volume_group;
 
-struct logical_volume *lvconvert_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
-					     struct volume_group *vg,
-					     const char *name,
-					     const char *uuid,
-					     uint64_t lv_type __attribute__((unused)));
-
 int lvconvert_mirror_finish(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index b78e364..a90bcfb 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -62,6 +62,20 @@ struct volume_group *poll_get_copy_vg(struct cmd_context *cmd,
 	return vg_read_for_update(cmd, extract_vgname(cmd, name), NULL, 0);
 }
 
+struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd __attribute__((unused)),
+					struct volume_group *vg,
+					const char *name,
+					const char *uuid,
+					uint64_t lv_type __attribute__((unused)))
+{
+	struct logical_volume *lv = find_lv(vg, name);
+
+	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
+		return NULL;
+
+	return lv;
+}
+
 static int _check_lv_status(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index b602a08..c896021 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -75,4 +75,9 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 struct volume_group *poll_get_copy_vg(struct cmd_context *cmd, const char *name,
 				      const char *uuid);
 
+struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd,
+					struct volume_group *vg,
+					const char *name, const char *uuid,
+					uint64_t lv_type);
+
 #endif


