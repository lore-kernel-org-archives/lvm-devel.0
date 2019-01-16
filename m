From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Jan 2019 16:34:44 -0500
Subject: master - hints: invalidate when pvscan --cache sees a new PV
Message-ID: <201901162134.x0GLYihq017633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f102b3421873a6111e477b40fdbe1a93ef258b9
Commit:        5f102b3421873a6111e477b40fdbe1a93ef258b9
Parent:        facd5209311d0f205229c6943fa3b2ef42fc981f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 16 14:19:09 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 16 15:34:20 2019 -0600

hints: invalidate when pvscan --cache sees a new PV

An idea from Zdenek for better ensuring valid hints by invalidating
them when pvscan --cache <device> sees a new PV, which is a case
where we know that hints should be invalidated.  This is triggered
from systemd/udev logic, and there may be some cases where it would
invalidate hints that the existing methods wouldn't detect.
---
 lib/label/hints.c   |   15 +++++++++++++++
 lib/label/hints.h   |    2 ++
 test/shell/hints.sh |   23 +++++++++++++++++++++--
 tools/pvscan.c      |   16 ++++++++++++++++
 4 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index a9c40c2..4fe44b0 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1026,6 +1026,21 @@ void clear_hint_file(struct cmd_context *cmd)
 }
 
 /*
+ * This is used when pvscan --cache sees a new PV, which
+ * means we should refresh hints.  It could catch some case
+ * which the other methods of detecting stale hints may miss.
+ */
+void invalidate_hints(struct cmd_context *cmd)
+{
+	/* No commands are using hints. */
+	if (!cmd->enable_hints)
+		return;
+
+	if (!_touch_newhints())
+		stack;
+}
+
+/*
  * Currently, all the commands using hints (ALLOW_HINTS) take an optional or
  * required first position arg of a VG name or LV name.  If some other command
  * began using hints which took some other kind of position arg, we would
diff --git a/lib/label/hints.h b/lib/label/hints.h
index a17214c..469e8c4 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -28,6 +28,8 @@ int write_hint_file(struct cmd_context *cmd, int newhints);
 
 void clear_hint_file(struct cmd_context *cmd);
 
+void invalidate_hints(struct cmd_context *cmd);
+
 int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
               struct dm_list *devs_in, struct dm_list *devs_out);
 
diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index bdaf3be..31628b0 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -273,11 +273,12 @@ diff $HINTS $PREV
 #
 
 # pvs (no change), pvscan (hints are new), pvs (no change)
+rm $HINTS $PREV
 pvs
 cp $HINTS $PREV
-diff $HINTS $PREV
-cp $HINTS $PREV
+# this next pvscan recreates the hints file
 pvscan --cache
+# the only diff will be "Created by pvscan ..." vs "Created by pvs ..."
 not diff $HINTS $PREV
 cp $HINTS $PREV
 pvs
@@ -285,6 +286,8 @@ diff $HINTS $PREV
 grep 'Created by pvscan' $HINTS
 # dev4 is a PV not used by a VG, dev5 is not a PV
 # using dd to copy skirts hint tracking so dev5 won't be seen
+# (unless the dd triggers udev which triggers pvscan --cache $dev5,
+# but I've not seen that happen in tests so far.)
 dd if="$dev4" of="$dev5" bs=1M
 # this pvs won't see dev5
 pvs > foo
@@ -314,6 +317,22 @@ not grep "$dev5" foo
 grep "$dev4" $HINTS
 not grep "$dev5" $HINTS
 
+#
+# Test pvscan --cache <dev> forces refresh
+#
+
+rm $HINTS $PREV
+pvs
+cp $HINTS $PREV
+# this next pvscan creates newhints to trigger a refresh
+pvscan --cache "$dev5"
+cat $NEWHINTS
+# this next pvs creates new hints
+pvs
+# the only diff will be "Created by..."
+not diff $HINTS $PREV
+
+
 
 #
 # Test incorrect dev-to-pvid info in hints is detected
diff --git a/tools/pvscan.c b/tools/pvscan.c
index da1e435..098c502 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -17,6 +17,7 @@
 
 #include "lib/cache/lvmcache.h"
 #include "lib/metadata/metadata.h"
+#include "lib/label/hints.h"
 
 #include <dirent.h>
 
@@ -632,6 +633,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	int do_activate = arg_is_set(cmd, activate_ARG);
 	int all_vgs = 0;
 	int add_errors = 0;
+	int add_single_count = 0;
 	int ret = ECMD_PROCESSED;
 
 	dm_list_init(&single_devs);
@@ -750,6 +752,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			if (dev->flags & DEV_FILTER_OUT_SCAN)
 				continue;
 
+			add_single_count++;
+
 			/*
 			 * Devices that exist and pass the lvmetad filter
 			 * are online.
@@ -801,6 +805,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			if (dev->flags & DEV_FILTER_OUT_SCAN)
 				continue;
 
+			add_single_count++;
+
 			/*
 			 * Devices that exist and pass the lvmetad filter
 			 * are online.
@@ -812,6 +818,16 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 activate:
 	/*
+	 * When a new PV appears, the system runs pvscan --cache dev.
+	 * This also means that existing hints are invalid, and
+	 * we can force hints to be refreshed here.  There may be
+	 * cases where this detects a change that the other methods
+	 * of detecting invalid hints doesn't catch.
+	 */
+	if (add_single_count)
+		invalidate_hints(cmd);
+
+	/*
 	 * Special case: pvscan --cache -aay dev 
 	 * where dev has no VG metadata, and it's the final device to
 	 * complete the VG.  In this case we want to autoactivate the


