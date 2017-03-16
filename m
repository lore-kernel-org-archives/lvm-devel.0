From: David Teigland <teigland@sourceware.org>
Date: Thu, 16 Mar 2017 12:52:21 -0400
Subject: master - lvconvert: disable lvmetad for repair
Message-ID: <201703161652.v2GGqLl9015227@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=506d88a2ec8cc4960b907b2cf34ca5786d060943
Commit:        506d88a2ec8cc4960b907b2cf34ca5786d060943
Parent:        e5b6f2685a462fbdd262685b39c2ac186475a051
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 16 10:56:05 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 16 11:50:36 2017 -0500

lvconvert: disable lvmetad for repair

Repairing missing devices does not work reliably
with lvmetad, so disable lvmetad before repair.
A standard lvmetad refresh (pvscan --cache) will
enable lvmetad again.
---
 daemons/lvmetad/lvmetad-client.h |    1 +
 daemons/lvmetad/lvmetad-core.c   |    6 +++++-
 lib/cache/lvmetad.c              |    3 +++
 tools/lvmcmdline.c               |   10 +++++++++-
 4 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index dd6a379..a2adfe6 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -25,6 +25,7 @@
 #define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
 #define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
 #define LVMETAD_DISABLE_REASON_VGRESTORE	"VGRESTORE"
+#define LVMETAD_DISABLE_REASON_REPAIR		"REPAIR"
 
 struct volume_group;
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1faae11..aa00329 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -203,8 +203,9 @@ struct vg_info {
 #define GLFL_DISABLE_REASON_LVM1       0x00000008
 #define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
 #define GLFL_DISABLE_REASON_VGRESTORE  0x00000020
+#define GLFL_DISABLE_REASON_REPAIR     0x00000040
 
-#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_VGRESTORE)
+#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_REPAIR | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_VGRESTORE)
 
 #define VGFL_INVALID 0x00000001
 
@@ -2355,6 +2356,8 @@ static response set_global_info(lvmetad_state *s, request r)
 	if ((reason = daemon_request_str(r, "disable_reason", NULL))) {
 		if (strstr(reason, LVMETAD_DISABLE_REASON_DIRECT))
 			reason_flags |= GLFL_DISABLE_REASON_DIRECT;
+		if (strstr(reason, LVMETAD_DISABLE_REASON_REPAIR))
+			reason_flags |= GLFL_DISABLE_REASON_REPAIR;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_LVM1))
 			reason_flags |= GLFL_DISABLE_REASON_LVM1;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
@@ -2420,6 +2423,7 @@ static response get_global_info(lvmetad_state *s, request r)
 	if (s->flags & GLFL_DISABLE) {
 		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
+			 (s->flags & GLFL_DISABLE_REASON_REPAIR)     ? LVMETAD_DISABLE_REASON_REPAIR "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_VGRESTORE)  ? LVMETAD_DISABLE_REASON_VGRESTORE "," : "");
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 843e1c3..e67fe31 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2874,6 +2874,9 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DIRECT)) {
 			*reason = "the disable flag was set directly";
 
+		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_REPAIR)) {
+			*reason = "a repair command was run";
+
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_LVM1)) {
 			*reason = "LVM1 metadata was found";
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index baf5d3b..5386bf3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -19,6 +19,7 @@
 #include "label.h"
 #include "lvm-version.h"
 #include "lvmlockd.h"
+#include "lvmetad-client.h"
 
 #include "stub.h"
 #include "last-path-component.h"
@@ -2777,11 +2778,18 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!strcmp(cmd->fmt->name, FMT_LVM1_NAME) && lvmetad_used()) {
 		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
-		lvmetad_set_disabled(cmd, "LVM1");
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 		log_warn("WARNING: Not using lvmetad because lvm1 format is used.");
 		lvmetad_make_unused(cmd);
 	}
 
+	if (cmd->command->command_enum == lvconvert_repair_pvs_or_thinpool_CMD) {
+		log_warn("WARNING: Disabling lvmetad cache for repair command.");
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
+		log_warn("WARNING: Not using lvmetad because of repair.");
+		lvmetad_make_unused(cmd);
+	}
+
 	if (cmd->metadata_read_only &&
 	    !(cmd->cname->flags & PERMITTED_READ_ONLY)) {
 		log_error("%s: Command not permitted while global/metadata_read_only "


