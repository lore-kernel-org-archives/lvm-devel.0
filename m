From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Feb 2014 10:51:13 +0000 (UTC)
Subject: master - activation: lv_activation_skip remove always same arg.
Message-ID: <20140219105113.8123360BD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c71a3bcbc07c277b277201425567f7e0864f3819
Commit:        c71a3bcbc07c277b277201425567f7e0864f3819
Parent:        750a310a40c09cd222d52299f2d682082d6a133c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 19 11:02:16 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 19 11:33:39 2014 +0100

activation: lv_activation_skip remove always same arg.

Remove 'skip' argument passed into the function.
We always used '0' - as this is the only supported
option (-K) and there is no complementary option.

Also add some testing for behaviour of skipping.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    9 +++------
 lib/metadata/metadata-exported.h |    2 +-
 test/shell/activation-skip.sh    |   32 ++++++++++++++++++++++++++++++++
 tools/lvchange.c                 |    2 +-
 tools/vgchange.c                 |    2 +-
 6 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5bb37d8..c081898 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Remove (always 0) skip argument from lv_activation_skip().
   Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV via udev.
   lvcreate computes RAID4/5/6 stripes if not given from # of allocatable PVs.
   Fix merging of old snapshot into thin volume origin.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d0ae11e..5d49a70 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5673,11 +5673,11 @@ void lv_set_activation_skip(struct logical_volume *lv, int override_default,
  * of the 'skip' arg supplied instead.
  */
 int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
-		      int override_lv_skip_flag, int skip)
+		       int override_lv_skip_flag)
 {
 	if (!(lv->status & LV_ACTIVATION_SKIP) ||
 	    !is_change_activating(activate) || /* Do not skip deactivation */
-	    (override_lv_skip_flag && !skip))
+	    override_lv_skip_flag)
 		return 0;
 
 	log_verbose("ACTIVATON_SKIP flag set for LV %s/%s, skipping activation.",
@@ -6244,11 +6244,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->activate = lv_passes_auto_activation_filter(cmd, lv) ?
 				CHANGE_ALY : CHANGE_ALN;
 
-	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE, 0)) {
-		log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
-			    lv->vg->name, lv->name);
+	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE))
 		lp->activate = CHANGE_AN;
-	}
 
 	/*
 	 * For thin pools - deactivate when inactive pool is requested or
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 438f5b2..3e57113 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -832,7 +832,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
  */
 void lv_set_activation_skip(struct logical_volume *lv, int override_default, int add_skip_flag);
 int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
-		       int override_lv_skip_flag, int skip);
+		       int override_lv_skip_flag);
 
 /*
  * Functions for layer manipulation
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
new file mode 100644
index 0000000..7c80283
--- /dev/null
+++ b/test/shell/activation-skip.sh
@@ -0,0 +1,32 @@
+#!/bin/bash
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# Test skip activation flag  -k|--setactivationskip
+
+aux prepare_vg
+
+lvcreate -an --zero n -l 1 -n $lv1 $vg
+lvcreate -ky -K -l1 -n $lv2 $vg
+get lv_field $vg/$lv2 lv_attr | grep -- "-wi-a----k"
+
+lvchange -ay -K $vg
+check active $vg $lv1
+lvchange -an $vg
+
+lvchange -ay --setactivationskip y $vg/$lv1
+check inactive $vg $lv1
+
+get lv_field $vg/$lv1 lv_attr | grep -- "-wi------k"
+
+lvchange -ay -K $vg
+check active $vg $lv1
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5b6da56..8ceacc5 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -215,7 +215,7 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 
 	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
-	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0))
+	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
 		return 1;
 
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
diff --git a/tools/vgchange.c b/tools/vgchange.c
index cb2d84b..e7b5e59 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -120,7 +120,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if ((lv->status & PVMOVE) && !is_change_activating(activate))
 			continue;
 
-		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0))
+		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
 			continue;
 
 		if ((activate == CHANGE_AAY) &&


