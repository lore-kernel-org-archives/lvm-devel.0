From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Mar 2012 14:29:52 +0100
Subject: [PATCH][lvmetad] Restore lvmetad active state during vgscan to populate lvmetad
Message-ID: <4F688650.8020505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvmetad_vg_update does nothing for inactive lvmetad state so
restore it in the vgscan_single temporarily...

Or should we abandon the vgscan in case we're using lvmetad
and allow only "pvscan --cache"???

Peter
---
 tools/vgscan.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/vgscan.c b/tools/vgscan.c
index a353c43..f7fbd54 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -15,6 +15,8 @@
 
 #include "tools.h"
 
+static int _lvmetad;
+
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle __attribute__((unused)))
@@ -25,16 +27,18 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 
 	check_current_backup(vg);
 
-	/* keep lvmetad up to date */
+	/* keep lvmetad up to date, restore the "active" state temporarily */
+	lvmetad_set_active(_lvmetad);
 	if (!lvmetad_vg_update(vg))
 		stack;
+	lvmetad_set_active(0);
 
 	return ECMD_PROCESSED;
 }
 
 int vgscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	int maxret, ret, lvmetad;
+	int maxret, ret;
 
 	if (argc) {
 		log_error("Too many parameters on command line");
@@ -48,7 +52,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	persistent_filter_wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
-	lvmetad = lvmetad_active();
+	_lvmetad = lvmetad_active();
 	lvmetad_set_active(0); /* do not rely on lvmetad info */
 
 	log_print("Reading all physical volumes.  This may take a while...");
@@ -62,7 +66,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 			maxret = ret;
 	}
 
-	lvmetad_set_active(lvmetad); /* restore */
+	lvmetad_set_active(_lvmetad); /* restore */
 	unlock_vg(cmd, VG_GLOBAL);
 	return maxret;
 }


