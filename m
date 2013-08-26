From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 26 Aug 2013 19:17:09 +0000 (UTC)
Subject: master - pvmove: Fix inability to specify LV name when moving RAID, mirror, or thin LV
Message-ID: <20130826191709.2A827612CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=caa77b33f2d5e59f2906b9f08f59ac2e64b14682
Commit:        caa77b33f2d5e59f2906b9f08f59ac2e64b14682
Parent:        d34ab5e0d39543db4f17994432a49a77709b3487
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Aug 26 14:12:31 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Aug 26 14:12:31 2013 -0500

pvmove: Fix inability to specify LV name when moving RAID, mirror, or thin LV

Top-level LVs (like RAID, mirror or thin) are ignored when determining which
portions of an LV to pvmove.  If the user specified the name of an LV to
move and it was one of the above types, it would be skipped.  The code would
never move on to check whether its sub-LVs needed moving because their names
did not match what the user specified.

The solution is to check whether a sub-LVs is part of the LV whose name was
specified by the user - not just if there was a name match.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |   26 +++++++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c0744f6..069c3c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Fix inability to specify LV name when pvmove'ing a RAID, mirror, or thin-LV.
   Inform lvmetad about any lost PV label to make it in sync with system state.
   Support most of lvchange operations on stacked thin pool meta/data LVs.
   Add ability to pvmove RAID, mirror, and thin volumes.
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 8e95048..2868290 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -16,6 +16,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "display.h"
+#include "metadata.h"  /* for 'get_only_segment_using_this_lv' */
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
 #define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
@@ -209,6 +210,29 @@ static int _insert_pvmove_mirrors(struct cmd_context *cmd,
 	return 1;
 }
 
+/*
+ * Is 'lv' a sub_lv of the LV by the name of 'lv_name'?
+ *
+ * Returns: 1 if true, 0 otherwise
+ */
+static int sub_lv_of(struct logical_volume *lv, const char *lv_name)
+{
+	struct lv_segment *seg;
+
+	/* Sub-LVs only ever have one segment using them */
+	if (dm_list_size(&lv->segs_using_this_lv) != 1)
+		return 0;
+
+	if (!(seg = get_only_segment_using_this_lv(lv)))
+		return_0;
+
+	if (!strcmp(seg->lv->name, lv_name))
+		return 1;
+
+	/* Continue up the tree */
+	return sub_lv_of(seg->lv, lv_name);
+}
+
 /* Create new LV with mirror segments for the required copies */
 static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						struct volume_group *vg,
@@ -295,7 +319,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (lv == lv_mirr)
 			continue;
 		if (lv_name) {
-			if (strcmp(lv->name, lv_name))
+			if (strcmp(lv->name, lv_name) && !sub_lv_of(lv, lv_name))
 				continue;
 			lv_found = 1;
 		}


