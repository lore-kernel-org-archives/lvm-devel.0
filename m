From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 17 Nov 2008 11:29:29 -0500
Subject: [PATCH] Fix "lvremove -f vgname" when vgname contains snapshots.
Message-ID: <1226939369-28344-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Prior to this patch, "lvremove -f vgname" would fail if vgname contained
one or more snapshot LVs.  Now this passes, but has a side-effect.
If you issue "lvremove vgname" where vgname contains one or more snaps,
you will get an extra "y/n" prompt to remove the same snapshot.
---
 WHATS_NEW        |    1 +
 tools/lvremove.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 519802f..4439546 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.43 - 10th November 2008
 ====================================
+  Fix "lvremove -f vgname" when vgname contains snapshots.
   Make man pages consistent with either-or options (use "|" everywhere).
   Merge device-mapper into the lvm2 tree.
   Correct prototype for --permission on lvchange and lvcreate man pages.
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 24278b2..8b8401d 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -18,7 +18,7 @@
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
-	if (!lv_remove_single(cmd, lv, arg_count(cmd, force_ARG)))
+	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
-- 
1.5.5.1


