From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 27 Jan 2021 15:59:25 +0000 (GMT)
Subject: stable-2.02 - lvdisplay: enhance LV status output for raid(0)
Message-ID: <20210127155925.5F1FA386F02F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c56b3fa4e2042230054786697cd0781f44d56f93
Commit:        c56b3fa4e2042230054786697cd0781f44d56f93
Parent:        1d94748601056442b160df8802817404e0a5c7c4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jan 26 19:32:24 2021 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jan 27 16:59:02 2021 +0100

lvdisplay: enhance LV status output for raid(0)

In case legs of a raid0 LV are removed, the lvdisplay command still
reports 'available' though raid0 is not providing any resilience
compared to the other raid levels.

Also lvdisplay does not display '(partial)' in case of missing raid0
legs as oposed to the lvs command.

Enhance lvdisplay to report "NOT available" for any RaidLV type in case
too many legs are inaccessible hence causing data loss.  I.e. any leg
for raid0, all for raid1, more than 1 for raid4/5, more than 2 for raid6
and in case of completely lost mirror groups for raid10.

Add test/shell/lvdisplay-raid.sh.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1872678
---
 WHATS_NEW                        |  1 +
 lib/display/display.c            | 13 +++++--
 lib/metadata/metadata-exported.h |  1 +
 lib/metadata/segtype.h           |  1 +
 lib/raid/raid.c                  | 57 +++++++++++++++++++++++++++++
 test/shell/lvdisplay-raid.sh     | 79 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 149 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2a745dbdd..311923204 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Enhance lvdisplay to report raid availiable/partial.
   Enhance error handling for fsadm and hanled correct fsck result.
   Stop logging rename errors from persintent filter.
   Dmeventd lvm plugin ignores higher reserved_stack lvm.conf values.
diff --git a/lib/display/display.c b/lib/display/display.c
index e9cfaa985..cd911feea 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -399,7 +399,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 		   void *handle __attribute__((unused)))
 {
 	struct lvinfo info;
-	int inkernel, snap_active = 0;
+	int inkernel, snap_active = 0, partial = 0, raid_is_avail = 1;
 	char uuid[64] __attribute__((aligned(8)));
 	const char *access_str;
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
@@ -536,11 +536,18 @@ int lvdisplay_full(struct cmd_context *cmd,
 		log_print("LV Pool data           %s", seg_lv(seg, 0)->name);
 	}
 
+	if (lv_is_partial(lv))
+		partial = 1;
+
+	if (lv_is_raid(lv))
+		raid_is_avail = raid_is_available(lv) ? 1 : 0;
+
 	if (inkernel && info.suspended)
 		log_print("LV Status              suspended");
 	else if (activation())
-		log_print("LV Status              %savailable",
-			  inkernel ? "" : "NOT ");
+		log_print("LV Status              %savailable%s",
+			  (inkernel && raid_is_avail) ? "" : "NOT ",
+			  partial ? " (partial)" : "");
 
 /********* FIXME lv_number
     log_print("LV #                   %u", lv->lv_number + 1);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8f173059b..30ab47576 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -26,6 +26,7 @@
 #include "vg.h"
 #include "lv.h"
 #include "lvm-percent.h"
+#include <stdbool.h>
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 9c05836bf..009ec16cf 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -310,6 +310,7 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+bool raid_is_available(const struct logical_volume *lv);
 #endif
 
 #define THIN_FEATURE_DISCARDS			(1U << 0)
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 28340a0ca..f75c676e8 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -468,6 +468,63 @@ static int _check_feature(const struct raid_feature *feature, uint32_t maj, uint
 	       (maj == feature->maj && min == feature->min && patchlevel >= feature->patchlevel);
 }
 
+/* Check availability of raid10 taking data copies into consideration. */
+static bool _raid10_is_available(const struct logical_volume *lv)
+{
+	uint32_t i, rebuilds_per_group, s;
+	const uint32_t copies = 2; /* FIXME: we only support 2-way mirrors (i.e. 2 data copies) in RAID10 for now. */
+	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
+
+	for (i = 0; i < seg->area_count * copies; ++i) {
+		s = i % seg->area_count;
+
+		if (!(i % copies))
+			rebuilds_per_group = 0;
+
+		if (seg_type(seg, s) == AREA_LV &&
+		    (lv_is_partial(seg_lv(seg, s)) ||
+		     lv_is_virtual(seg_lv(seg, s))))
+			rebuilds_per_group++;
+
+		if (rebuilds_per_group >= copies)
+			return false;
+	}
+
+	return true;
+}
+
+/*
+ * Return true in case RaidLV with specific RAID level is available.
+ *
+ * - raid0: all legs have to be live
+ * - raid1 : minimum of 1 leg live
+ * - raid4/5: maximum of 1 leg unavailable
+ * - raid6:  maximum of 2 legs unavailable
+ * - raid10: minimum of 1 leg per mirror group available
+ *
+ */
+bool raid_is_available(const struct logical_volume *lv)
+{
+	uint32_t s, missing_legs = 0;
+	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
+
+	/* Be cautious about bogus calls. */
+	if (!seg || !seg_is_raid(seg))
+		return false;
+
+	if (seg_is_any_raid10(seg))
+		return _raid10_is_available(lv);
+
+	/* Count missing RAID legs */
+	for (s = 0; s < seg->area_count; ++s)
+		if (seg_type(seg, s) == AREA_LV &&
+		    lv_is_partial(seg_lv(seg, s)))
+			missing_legs++;
+
+	/* Degradation: segtype raid1 may miss legs-1, raid0/4/5/6 may loose parity devices. */
+	return missing_legs <= (seg_is_raid1(seg) ? seg->area_count - 1 : seg->segtype->parity_devs);
+}
+
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes)
diff --git a/test/shell/lvdisplay-raid.sh b/test/shell/lvdisplay-raid.sh
new file mode 100644
index 000000000..18ea9ae1e
--- /dev/null
+++ b/test/shell/lvdisplay-raid.sh
@@ -0,0 +1,79 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+#
+# tests functionality lvdisplay tool for RAID
+#
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 6
+get_devs
+
+# raid0 loosing a leg
+lvcreate -aey --type raid0 -i5 -l5 -n $lv $vg
+lvdisplay $vg/$lv|grep "LV Status *available"
+aux disable_dev $dev1
+lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
+aux enable_dev $dev1
+lvremove -y $vg/$lv
+
+# raid1 loosing a leg/all legs
+lvcreate -aey --type raid1 -m1 -l5 -n $lv $vg $dev1 $dev2
+lvdisplay $vg/$lv|grep "LV Status *available"
+aux disable_dev $dev1
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux disable_dev $dev2
+lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
+aux enable_dev $dev1 $dev2
+lvremove -y $vg/$lv
+
+# raid5 loosing a leg/2 legs
+lvcreate -aey --type raid5 -i3 -l5 -n $lv $vg
+lvdisplay $vg/$lv|grep "LV Status *available"
+aux disable_dev $dev1
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux disable_dev $dev2
+lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
+aux enable_dev $dev1 $dev2
+lvremove -y $vg/$lv
+
+# raid6 loosing a leg/2 legs/3 legs
+lvcreate -aey --type raid6 -i3 -l5 -n $lv $vg
+lvdisplay $vg/$lv|grep "LV Status *available"
+aux disable_dev $dev1
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux disable_dev $dev2
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux disable_dev $dev3
+lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
+aux enable_dev $dev1 $dev2 $dev3
+lvremove -y $vg/$lv
+
+# raid10 loosing a leg per mirror group / a complete mirror group
+lvcreate -aey --type raid10 -i3 -l3 -n $lv $vg
+lvdisplay $vg/$lv|grep "LV Status *available"
+aux disable_dev $dev1
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux disable_dev $dev3
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux disable_dev $dev6
+lvdisplay $vg/$lv|grep "LV Status *available (partial)"
+aux enable_dev $dev1 $dev3 $dev6
+lvdisplay $vg/$lv|grep "LV Status *available"
+aux disable_dev $dev1 $dev2
+lvdisplay $vg/$lv|grep "LV Status *NOT available (partial)"
+aux enable_dev $dev1 $dev2
+
+vgremove -y -f $vg


