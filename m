From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 14:25:33 +0000 (UTC)
Subject: master - cleanup: rename 'invisible devices' to 'hidden devices'
Message-ID: <20160113142533.8849B60527@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1417ed304bf7db0bda167ee83cfbb4126ba4913d
Commit:        1417ed304bf7db0bda167ee83cfbb4126ba4913d
Parent:        d2d5c5e6c995b34ba36c026c8da7cdd316b69ee5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 15:21:05 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 15:22:46 2016 +0100

cleanup: rename 'invisible devices' to 'hidden devices'

---
 WHATS_NEW                      |    4 ++--
 conf/example.conf.in           |    6 +++---
 lib/commands/toolcontext.c     |    2 +-
 lib/commands/toolcontext.h     |    2 +-
 lib/config/config_settings.h   |    4 ++--
 lib/metadata/lv.c              |   14 +++++++-------
 lib/report/report.c            |    2 +-
 test/shell/report-hidden.sh    |   39 +++++++++++++++++++++++++++++++++++++++
 test/shell/report-invisible.sh |   39 ---------------------------------------
 9 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fb485b3..aff000f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
 Version 2.02.140 -
 ===================================
-  Add report/mark_invisible_devices to lvm.conf.
-  Use brackets consistently in report fields to mark invisible devices.
+  Add report/mark_hidden_devices to lvm.conf.
+  Use brackets consistently in report fields to mark hidden devices.
   Restore background polling processing during auto-activation (2.02.119).
   Fix invalid memory read when reporting cache LV policy_name (2.02.126).
 
diff --git a/conf/example.conf.in b/conf/example.conf.in
index f549f15..e567a73 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1809,10 +1809,10 @@ activation {
 	# This configuration option has an automatic default value.
 	# pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
 
-	# Configuration option report/mark_invisible_devices.
-	# Use brackets [] to mark invisible devices.
+	# Configuration option report/mark_hidden_devices.
+	# Use brackets [] to mark hidden devices.
 	# This configuration option has an automatic default value.
-	# mark_invisible_devices = 1
+	# mark_hidden_devices = 1
 # }
 
 # Configuration section dmeventd.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a8bf187..6163bdc 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -478,7 +478,7 @@ int process_profilable_config(struct cmd_context *cmd)
 
 	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
 	cmd->report_binary_values_as_numeric = find_config_tree_bool(cmd, report_binary_values_as_numeric_CFG, NULL);
-	cmd->report_mark_invisible_devices = find_config_tree_bool(cmd, report_mark_invisible_devices_CFG, NULL);
+	cmd->report_mark_hidden_devices = find_config_tree_bool(cmd, report_mark_hidden_devices_CFG, NULL);
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 	cmd->report_list_item_separator = find_config_tree_str(cmd, report_list_item_separator_CFG, NULL);
 	if (!(cmd->time_format = _set_time_format(cmd)))
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 5a7b3af..b2033fc 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -121,7 +121,7 @@ struct cmd_context {
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
 	unsigned report_binary_values_as_numeric:1;
-	unsigned report_mark_invisible_devices:1;
+	unsigned report_mark_hidden_devices:1;
 	unsigned metadata_read_only:1;
 	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;			/* set if running within a thread e.g. clvmd */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index bb5d7d9..60b5110 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1671,8 +1671,8 @@ cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, C
 	"List of columns to sort by when reporting 'pvs --segments' command in verbose mode.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_mark_invisible_devices_CFG, "mark_invisible_devices", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 140), NULL, 0, NULL,
-	"Use brackets [] to mark invisible devices.\n")
+cfg(report_mark_hidden_devices_CFG, "mark_hidden_devices", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 140), NULL, 0, NULL,
+	"Use brackets [] to mark hidden devices.\n")
 
 cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a mirror device.\n"
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 44db4df..96f6f5c 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -30,7 +30,7 @@ static int _utsinit = 0;
 
 static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			    int range_format, int metadata_areas_only,
-			    int mark_invisible)
+			    int mark_hidden)
 {
 	static const char pool_grow_object_failed_msg[] = "dm_pool_grow_object failed";
 	unsigned int s;
@@ -72,7 +72,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			return NULL;
 		}
 
-		if (!visible && mark_invisible && !dm_pool_grow_object(mem, "[", 1)) {
+		if (!visible && mark_hidden && !dm_pool_grow_object(mem, "[", 1)) {
 			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
@@ -82,7 +82,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			return NULL;
 		}
 
-		if (!visible && mark_invisible && !dm_pool_grow_object(mem, "]", 1)) {
+		if (!visible && mark_hidden && !dm_pool_grow_object(mem, "]", 1)) {
 			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
@@ -129,22 +129,22 @@ out:
 
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0, 0, seg->lv->vg->cmd->report_mark_invisible_devices);
+	return _format_pvsegs(mem, seg, 0, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
 char *lvseg_metadata_devices(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 0, 1, seg->lv->vg->cmd->report_mark_invisible_devices);
+	return _format_pvsegs(mem, seg, 0, 1, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 1, 0, seg->lv->vg->cmd->report_mark_invisible_devices);
+	return _format_pvsegs(mem, seg, 1, 0, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
 char *lvseg_seg_metadata_le_ranges(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return _format_pvsegs(mem, seg, 1, 1, seg->lv->vg->cmd->report_mark_invisible_devices);
+	return _format_pvsegs(mem, seg, 1, 1, seg->lv->vg->cmd->report_mark_hidden_devices);
 }
 
 char *lvseg_tags_dup(const struct lv_segment *seg)
diff --git a/lib/report/report.c b/lib/report/report.c
index 3c73a2f..40fcdd8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1586,7 +1586,7 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_visible(lv) || !cmd->report_mark_invisible_devices)
+	if (lv_is_visible(lv) || !cmd->report_mark_hidden_devices)
 		return _string_disp(rh, mem, field, &lv->name, private);
 
 	len = strlen(lv->name) + 3;
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
new file mode 100644
index 0000000..ff33df5
--- /dev/null
+++ b/test/shell/report-hidden.sh
@@ -0,0 +1,39 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 1
+lvcreate --type mirror -m1 -l1 --alloc anywhere -n $lv1 $vg
+
+aux lvmconf 'log/prefix=""'
+
+aux lvmconf "report/mark_hidden_devices = 0"
+lvs --noheadings -a -o name $vg > out
+grep "^${lv1}_mimage_0" out
+not grep "^\[${lv1}_mimage_0\]" out
+lvs --noheadings -a -o devices $vg/$lv1 > out
+grep "^${lv1}_mimage_0" out
+not grep "^\[${lv1}_mimage_0\]" out
+
+aux lvmconf "report/mark_hidden_devices = 1"
+lvs --noheadings -a -o name $vg > out
+grep "^\[${lv1}_mimage_0\]" out
+not grep "^${lv1}_mimage_0" out
+lvs --noheadings -a -o devices $vg/$lv1 > out
+grep "^\[${lv1}_mimage_0\]" out
+not grep "^${lv1}_mimage_0" out
+
+vgremove -ff $vg
diff --git a/test/shell/report-invisible.sh b/test/shell/report-invisible.sh
deleted file mode 100644
index d906c97..0000000
--- a/test/shell/report-invisible.sh
+++ /dev/null
@@ -1,39 +0,0 @@
-#!/bin/sh
-# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-SKIP_WITH_LVMETAD=1
-SKIP_WITH_CLVMD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_vg 1
-lvcreate --type mirror -m1 -l1 --alloc anywhere -n $lv1 $vg
-
-aux lvmconf 'log/prefix=""'
-
-aux lvmconf "report/mark_invisible_devices = 0"
-lvs --noheadings -a -o name $vg > out
-grep "^${lv1}_mimage_0" out
-not grep "^\[${lv1}_mimage_0\]" out
-lvs --noheadings -a -o devices $vg/$lv1 > out
-grep "^${lv1}_mimage_0" out
-not grep "^\[${lv1}_mimage_0\]" out
-
-aux lvmconf "report/mark_invisible_devices = 1"
-lvs --noheadings -a -o name $vg > out
-grep "^\[${lv1}_mimage_0\]" out
-not grep "^${lv1}_mimage_0" out
-lvs --noheadings -a -o devices $vg/$lv1 > out
-grep "^\[${lv1}_mimage_0\]" out
-not grep "^${lv1}_mimage_0" out
-
-vgremove -ff $vg


