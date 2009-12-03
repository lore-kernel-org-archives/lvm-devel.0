From: Milan Broz <mbroz@redhat.com>
Date: Thu,  3 Dec 2009 15:13:29 +0100
Subject: [PATCH] Fix tools to report error when stopped by user.
Message-ID: <1259849609-26973-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(And do not produce internal error message.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/archive.c |    2 +-
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/metadata.c   |    2 +-
 tools/lvchange.c          |    4 ++--
 tools/lvmchange.c         |    2 +-
 tools/lvresize.c          |    2 +-
 tools/pvremove.c          |    2 +-
 tools/vgremove.c          |    2 +-
 8 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 7fb2a48..3bc14bf 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -317,7 +317,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	 */
 	/* FIXME Use variation on _vg_read */
 	if (!(vg = text_vg_import_file(tf, af->path, &when, &desc))) {
-		log_print("Unable to read archive file.");
+		log_error("Unable to read archive file.");
 		tf->fmt->ops->destroy_instance(tf);
 		return;
 	}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c440278..b020cf5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2103,7 +2103,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 				  "%slogical volume %s? [y/n]: ",
 				  vg_is_clustered(vg) ? "clustered " : "",
 				  lv->name) == 'n') {
-			log_print("Logical volume %s not removed", lv->name);
+			log_error("Logical volume %s not removed", lv->name);
 			return 0;
 		}
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d38f9ac..9d5b1ae 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1223,7 +1223,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	/* prompt */
 	if (pv && !is_orphan(pv) && !pp->yes &&
 	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
-		log_print("%s: physical volume not initialized", name);
+		log_error("%s: physical volume not initialized", name);
 		return 0;
 	}
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index ab4dc33..f43b07a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -183,7 +183,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 			    yes_no_prompt("Do you really want to deactivate "
 					  "logical volume %s to resync it? [y/n]: ",
 					  lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not resynced",
+				log_error("Logical volume \"%s\" not resynced",
 					  lv->name);
 				return 0;
 			}
@@ -433,7 +433,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 		    yes_no_prompt("Logical volume %s will be "
 				  "deactivated temporarily. "
 				  "Continue? [y/n]: ", lv->name) == 'n') {
-			log_print("%s device number not changed.",
+			log_error("%s device number not changed.",
 				  lv->name);
 			return 0;
 		}
diff --git a/tools/lvmchange.c b/tools/lvmchange.c
index 8997d89..c4417c3 100644
--- a/tools/lvmchange.c
+++ b/tools/lvmchange.c
@@ -18,6 +18,6 @@
 int lvmchange(struct cmd_context *cmd __attribute((unused)),
 	      int argc __attribute((unused)), char **argv __attribute((unused)))
 {
-	log_print("With LVM2 and the device mapper, this program is obsolete.");
+	log_error("With LVM2 and the device mapper, this program is obsolete.");
 	return ECMD_FAILED;
 }
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 3b3a2eb..5adaf3c 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -120,7 +120,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 	if (!arg_count(cmd, force_ARG)) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
 				  lp->lv_name) == 'n') {
-			log_print("Logical volume %s NOT reduced", lp->lv_name);
+			log_error("Logical volume %s NOT reduced", lp->lv_name);
 			return 0;
 		}
 		if (sigint_caught())
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 3d75480..34b7214 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -74,7 +74,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
-		log_print("%s: physical volume label not removed", name);
+		log_error("%s: physical volume label not removed", name);
 		return 0;
 	}
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index bc29d99..ecb130d 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -36,7 +36,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 				   "group \"%s\" containing %u "
 				   "logical volumes? [y/n]: ",
 				   vg_name, lv_count) == 'n')) {
-			log_print("Volume group \"%s\" not removed", vg_name);
+			log_error("Volume group \"%s\" not removed", vg_name);
 			return ECMD_FAILED;
 		}
 		if (!remove_lvs_in_vg(cmd, vg, force)) {
-- 
1.6.5.3


