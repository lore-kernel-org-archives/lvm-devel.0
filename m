From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 25 Sep 2008 13:15:40 -0400
Subject: [PATCH 2/2] Add 'PROCESS_ONLY_VISIBLE_LVS' flag to modify LV iteration functions.
In-Reply-To: <1222362940-4580-1-git-send-email-dwysocha@redhat.com>
References: <1222362940-4580-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1222362940-4580-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fixes rhbz 232499: 'lvchange -a' w/VG arg causes "Unable" msgs for hidden LVs

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvchange.c |    2 +-
 tools/toollib.c  |    9 +++++++++
 tools/toollib.h  |   11 +++++++++++
 3 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 299abd8..e541158 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -732,5 +732,5 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
-			       &lvchange_single, 0);
+			       &lvchange_single, PROCESS_ONLY_VISIBLE_LVS);
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index e0b7f2f..34cf0ce 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -179,6 +179,15 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
+		/*
+		 * If no LVs given on the cmdline, this is not a visible LV,
+		 * and we should process only visible ones, then skip this LV.
+		 */
+		if (!lvargs_supplied && 
+		    !lv_is_visible(lvl->lv) &&
+		    (flags & PROCESS_ONLY_VISIBLE_LVS))
+			continue;
+
 		/* Should we process this LV? */
 		if (process_all)
 			process_lv = 1;
diff --git a/tools/toollib.h b/tools/toollib.h
index 44c5fbd..de748c7 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -18,6 +18,17 @@
 
 #include "metadata-exported.h"
 
+/* Flags that modify iterator function behavior */
+/*
+ * Indicates whether we should process only visible LVs when looping
+ * through a list of LVs on a VG.
+ * NOTE: This does not apply if a hidden/non-visible LV is given on the
+ * commandline for a tool, only if another option is given (e.g. a VG) that
+ * implies a list of LVs and the tools need to make a decision.
+ */
+#define PROCESS_ONLY_VISIBLE_LVS 0x1
+
+
 int autobackup_set(void);
 int autobackup_init(const char *backup_dir, int keep_days, int keep_number,
 		    int autobackup);
-- 
1.5.5.1


