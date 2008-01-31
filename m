From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jan 2008 12:19:38 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirr ...
Message-ID: <20080131121938.5498.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-31 12:19:36

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 
	dmeventd/snapshot: dmeventd_snapshot.c 
	lib/activate   : activate.c 
	lib/filters    : filter-md.c 
	lib/metadata   : mirror.c 
	lib/mirror     : mirrored.c 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	tools          : lvm-static.c lvm.c lvm2cmd.c 
Added files:
	test           : t-mirror-names.sh 

Log message:
	Fix mirror log name construction during lvconvert. (2.02.30)
	Make monitor_dev_for_events recurse through the stack of LVs.
	Clean up some more compiler warnings.
	Add mirror names test script.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.784&r2=1.785
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-md.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2008/01/30 13:59:56	1.784
+++ LVM2/WHATS_NEW	2008/01/31 12:19:34	1.785
@@ -1,5 +1,8 @@
 Version 2.02.33 -
 ===================================
+  Fix mirror log name construction during lvconvert. (2.02.30)
+  Make monitor_dev_for_events recurse through the stack of LVs.
+  Clean up some more compiler warnings.
   Some whitespace tidy-ups.
   Use stack return macros throughout.
   Rely upon internally-cached PV labels while corresponding VG lock is held.
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/04/27 17:46:16	1.18
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2008/01/31 12:19:35	1.19
@@ -125,8 +125,9 @@
 	return ME_IGNORE;
 }
 
-static void _temporary_log_fn(int level, const char *file,
-			      int line, const char *format)
+static void _temporary_log_fn(int level, const char *file __attribute((unused)),
+			      int line __attribute((unused)),
+			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
 		syslog(LOG_CRIT, "%s", format);
@@ -164,7 +165,8 @@
 	return (r == 1) ? 0 : -1;
 }
 
-void process_event(struct dm_task *dmt, enum dm_event_mask event,
+void process_event(struct dm_task *dmt,
+		   enum dm_event_mask event __attribute((unused)),
 		   void **unused __attribute((unused)))
 {
 	void *next = NULL;
@@ -222,8 +224,11 @@
 	pthread_mutex_unlock(&_event_mutex);
 }
 
-int register_device(const char *device, const char *uuid, int major, int minor,
-		   void **unused __attribute((unused)))
+int register_device(const char *device,
+		    const char *uuid __attribute((unused)),
+		    int major __attribute((unused)),
+		    int minor __attribute((unused)),
+		    void **unused __attribute((unused)))
 {
 	int r = 0;
 
@@ -259,8 +264,11 @@
 	return r;
 }
 
-int unregister_device(const char *device, const char *uuid, int major, int minor,
-		   void **unused __attribute((unused)))
+int unregister_device(const char *device,
+		      const char *uuid __attribute((unused)),
+		      int major __attribute((unused)),
+		      int minor __attribute((unused)),
+		      void **unused __attribute((unused)))
 {
 	pthread_mutex_lock(&_register_mutex);
 
--- LVM2/dmeventd/snapshot/dmeventd_snapshot.c	2008/01/09 15:32:19	1.1
+++ LVM2/dmeventd/snapshot/dmeventd_snapshot.c	2008/01/31 12:19:35	1.2
@@ -54,8 +54,10 @@
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
-static void _temporary_log_fn(int level, const char *file,
-			      int line, const char *format)
+static void _temporary_log_fn(int level,
+			      const char *file __attribute((unused)),
+			      int line __attribute((unused)),
+			      const char *format)
 {
 	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
 		syslog(LOG_CRIT, "%s", format);
@@ -115,7 +117,8 @@
 	dm_event_handler_destroy(dmevh);
 }
 
-void process_event(struct dm_task *dmt, enum dm_event_mask event,
+void process_event(struct dm_task *dmt,
+		   enum dm_event_mask event __attribute((unused)),
 		   void **private)
 {
 	void *next = NULL;
@@ -161,8 +164,11 @@
 	pthread_mutex_unlock(&_event_mutex);
 }
 
-int register_device(const char *device, const char *uuid, int major, int minor,
-		   void **private)
+int register_device(const char *device,
+		    const char *uuid __attribute((unused)),
+		    int major __attribute((unused)),
+		    int minor __attribute((unused)),
+		    void **private)
 {
 	int r = 0;
 	int *percent_warning = (int*)private;
@@ -201,8 +207,11 @@
 	return r;
 }
 
-int unregister_device(const char *device, const char *uuid, int major, int minor,
-		   void **unused __attribute((unused)))
+int unregister_device(const char *device,
+		      const char *uuid __attribute((unused)),
+		      int major __attribute((unused)),
+		      int minor __attribute((unused)),
+		      void **unused __attribute((unused)))
 {
 	pthread_mutex_lock(&_register_mutex);
 
--- LVM2/lib/activate/activate.c	2008/01/30 13:59:57	1.132
+++ LVM2/lib/activate/activate.c	2008/01/31 12:19:35	1.133
@@ -679,6 +679,7 @@
 	struct list *tmp, *snh, *snht;
 	struct lv_segment *seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
+	uint32_t s;
 
 	/* skip dmeventd code altogether */
 	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)
@@ -715,6 +716,19 @@
 	list_iterate(tmp, &lv->segments) {
 		seg = list_item(tmp, struct lv_segment);
 
+		/* Recurse for AREA_LV */
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			if (!monitor_dev_for_events(cmd, seg_lv(seg, s),
+						    monitor)) {
+				log_error("Failed to %smonitor %s",
+					  monitor ? "" : "un",
+					  seg_lv(seg, s)->name);
+				r = 0;
+			}
+		}
+
 		if (!seg_monitored(seg) || (seg->status & PVMOVE))
 			continue;
 
--- LVM2/lib/filters/filter-md.c	2007/08/20 20:55:25	1.7
+++ LVM2/lib/filters/filter-md.c	2008/01/31 12:19:35	1.8
@@ -19,7 +19,8 @@
 
 #ifdef linux
 
-static int _ignore_md(struct dev_filter *f, struct device *dev)
+static int _ignore_md(struct dev_filter *f __attribute((unused)),
+		      struct device *dev)
 {
 	int ret;
 	
--- LVM2/lib/metadata/mirror.c	2008/01/30 14:00:00	1.68
+++ LVM2/lib/metadata/mirror.c	2008/01/31 12:19:35	1.69
@@ -1182,7 +1182,7 @@
 		return NULL;
 	}
 
-	if (dm_snprintf(log_name, len, "%s%s", lv->name, suffix) < 0) {
+	if (dm_snprintf(log_name, len, "%s%s", lv_name, suffix) < 0) {
 		log_error("log_name allocation failed.");
 		return NULL;
 	}
@@ -1207,7 +1207,9 @@
 						 int in_sync)
 {
 	struct logical_volume *log_lv;
-	const char *suffix;
+	const char *suffix, *c;
+	char *lv_name;
+	size_t len;
 	struct lv_segment *seg;
 
 	init_mirror_in_sync(in_sync);
@@ -1217,15 +1219,34 @@
 		return NULL;
 	}
 
-	/* Check if the log is for temporary sync layer. */
+	/* Mirror log name is lv_name + suffix, determined as the following:
+	 *   1. suffix is:
+	 *        o "_mlog" for the original mirror LV.
+	 *        o "_mlogtmp_%d" for temporary mirror LV,
+	 *   2. lv_name is:
+	 *        o lv->name, if the log is temporary
+	 *        o otherwise, the top-level LV name
+	 */
 	seg = first_seg(lv);
 	if (seg_type(seg, 0) == AREA_LV &&
-	    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER))
+	    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER)) {
+		lv_name = lv->name;
 		suffix = "_mlogtmp_%d";
-	else
+	} else if ((c = strstr(lv->name, MIRROR_SYNC_LAYER))) {
+		len = c - lv->name + 1;
+		if (!(lv_name = alloca(len)) ||
+		    !dm_snprintf(lv_name, len, "%s", lv->name)) {
+			log_error("mirror log name allocation failed");
+			return 0;
+		}
+		suffix = "_mlog";
+	} else {
+		lv_name = lv->name;
 		suffix = "_mlog";
+	}
 
-	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name, suffix))) {
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc,
+					  (const char *) lv_name, suffix))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}
--- LVM2/lib/mirror/mirrored.c	2008/01/30 14:00:00	1.51
+++ LVM2/lib/mirror/mirrored.c	2008/01/31 12:19:35	1.52
@@ -456,7 +456,8 @@
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
-static int _target_set_events(struct lv_segment *seg, int evmask, int set)
+static int _target_set_events(struct lv_segment *seg,
+			      int evmask __attribute((unused)), int set)
 {
 	char *dso, *name;
 	struct logical_volume *lv;
--- LVM2/lib/report/report.c	2008/01/30 14:00:00	1.75
+++ LVM2/lib/report/report.c	2008/01/31 12:19:36	1.76
@@ -1049,7 +1049,7 @@
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, sorttype, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), width, id, head, &_ ## func ## _disp, desc},
+#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, sorttype, (off_t)((uintptr_t)&_dummy._ ## strct.field - (uintptr_t)&_dummy._ ## strct), width, id, head, &_ ## func ## _disp, desc},
 
 static struct dm_report_field_type _fields[] = {
 #include "columns.h"
--- LVM2/lib/snapshot/snapshot.c	2008/01/30 14:00:01	1.28
+++ LVM2/lib/snapshot/snapshot.c	2008/01/31 12:19:36	1.29
@@ -213,7 +213,8 @@
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
-static int _target_set_events(struct lv_segment *seg, int events, int set)
+static int _target_set_events(struct lv_segment *seg,
+			      int events __attribute((unused)), int set)
 {
 	char *dso, *name;
 	struct volume_group *vg = seg->lv->vg;
/cvs/lvm2/LVM2/test/t-mirror-names.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-mirror-names.sh
+++ -	2008-01-31 12:19:37.979503000 +0000
@@ -0,0 +1,206 @@
+#!/bin/sh
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2008 NEC Corporation
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description="check namings of mirrored LV"
+privileges_required_=1
+
+. ./test-lib.sh
+
+dmsetup_has_dm_devdir_support_ ||
+{
+  say "Your version of dmsetup lacks support for changing DM_DEVDIR."
+  say "Skipping this test"
+  exit 0
+}
+
+cleanup_()
+{
+  test -n "$vg" && {
+    lvremove -ff $vg
+    vgremove $vg
+  } > /dev/null
+  test -n "$pvs" && {
+    pvremove $pvs > /dev/null
+    for d in $pvs; do
+      dmsetup remove $(basename $d)
+    done
+  }
+  losetup -d $lodev
+  rm -f $lofile
+}
+
+# ---------------------------------------------------------------------
+# config
+
+nr_pvs=5
+pvsize=$((80 * 1024 * 2))
+
+vg=mirror-names-vg-$$
+lv1=lv1
+lv2=lv2
+
+# ---------------------------------------------------------------------
+# Utilities
+
+pv_()
+{
+  echo "$G_dev_/mapper/pv$1"
+}
+
+lv_devices_()
+{
+  local d
+  local lv=$1
+  shift
+  local devices=$*
+
+  local devs=$(lvs -a -odevices --noheadings $lv | sed 's/([0-9]*)//g' |
+               sed 's/ //g' | sed 's/,/ /g')
+
+  for d in $devs; do
+    (echo $devices | grep -q $d)  || return 1
+    devices=$(echo $devices | sed "s/$d//")
+  done
+
+  [ "$(echo $devices | sed 's/ //g')" = "" ]
+}
+
+lv_mirror_log_()
+{
+  local lv=$1
+
+  echo $(lvs -a -omirror_log --noheadings $lv | sed 's/ //g')
+}
+
+lv_convert_lv_()
+{
+  local lv=$1
+
+  echo $(lvs -a -oconvert_lv --noheadings $lv | sed 's/ //g')
+}
+
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+test_expect_success \
+  'set up temp file and loopback device' \
+  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
+
+offset=0
+pvs=
+for n in $(seq 1 $nr_pvs); do
+  test_expect_success \
+      "create pv$n" \
+      'echo "0 $pvsize linear $lodev $offset" > in &&
+       dmsetup create pv$n < in'
+  offset=$(($offset + $pvsize))
+done
+
+for n in $(seq 1 $nr_pvs); do
+  pvs="$pvs $(pv_ $n)"
+done
+
+test_expect_success \
+  "Run this: pvcreate $pvs" \
+  'pvcreate $pvs'
+
+test_expect_success \
+  'set up a VG' \
+  'vgcreate $vg $pvs'
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_()
+{
+  lvremove -ff $vg;
+  :
+}
+
+check_and_cleanup_lvs_()
+{
+  lvs -a -o+devices $vg &&
+  lvremove -ff $vg
+}
+
+test_expect_success "check environment setup/cleanup" \
+  'prepare_lvs_ &&
+   check_and_cleanup_lvs_'
+
+# ---------------------------------------------------------------------
+# basic
+
+test_expect_success "init: lvcreate" "prepare_lvs_"
+
+test_expect_success "mirror images are ${lv1}_mimage_x" \
+  'lvcreate -l2 -m1 -n $lv1 $vg &&
+   lv_devices_ $vg/$lv1 "$lv1"_mimage_0 "$lv1"_mimage_1'
+
+test_expect_success "mirror log is ${lv1}_mlog" \
+  'lv_mirror_log_ $vg/$lv1 "$lv1"_mlog'
+
+test_expect_success "cleanup" "check_and_cleanup_lvs_"
+
+# ---------------------------------------------------------------------
+# lvrename
+
+test_expect_success "init: lvrename" "prepare_lvs_"
+
+test_expect_success "renamed mirror names: $lv1 to $lv2" \
+  'lvcreate -l2 -m1 -n $lv1 $vg &&
+   lvrename $vg/$lv1 $vg/$lv2 &&
+   lv_devices_ $vg/$lv2 "$lv2"_mimage_0 "$lv2"_mimage_1 &&
+   lv_mirror_log_ $vg/$lv2 "$lv2"_mlog'
+
+test_expect_success "cleanup" "check_and_cleanup_lvs_"
+
+# ---------------------------------------------------------------------
+# lvconvert
+
+test_expect_success "init: lvconvert" "prepare_lvs_"
+
+test_expect_success "converting mirror names is ${lv1}_mimagetmp_2" \
+  'lvcreate -l2 -m1 -n $lv1 $vg &&
+   lvconvert -m+1 -i1000 -b $vg/$lv1 &&
+   convlv=$(lv_convert_lv_ "$vg/$lv1") &&
+   test "$convlv" = "$lv1"_mimagetmp_2 &&
+   lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 &&
+   lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 &&
+   loglv=$(lv_mirror_log_ "$vg/$convlv") &&
+   test "$loglv" = "$lv1"_mlog'
+
+test_expect_success "mirror log name after re-adding is ${lv1}_mlog" \
+  'lvconvert --mirrorlog core $vg/$lv1 &&
+   lvconvert --mirrorlog disk $vg/$lv1 &&
+   convlv=$(lv_convert_lv_ "$vg/$lv1") &&
+   lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 &&
+   lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 &&
+   loglv=$(lv_mirror_log_ "$vg/$convlv") &&
+   test "$loglv" = "$lv1"_mlog'
+
+test_expect_success "renamed converting mirror names: $lv1 to $lv2" \
+  'lvrename $vg/$lv1 $vg/$lv2 &&
+   convlv=$(lv_convert_lv_ "$vg/$lv2") &&
+   lv_devices_ $vg/$lv2 "$convlv" "$lv2"_mimage_2 &&
+   lv_devices_ "$vg/$convlv" "$lv2"_mimage_0 "$lv2"_mimage_1 &&
+   loglv=$(lv_mirror_log_ "$vg/$convlv") &&
+   test "$loglv" = "$lv2"_mlog'
+
+test_expect_success "cleanup" "check_and_cleanup_lvs_"
+
+# Temporary mirror log should have "_mlogtmp_<n>" suffix
+# but currently lvconvert doesn't have an option to add the log.
+# If such feature is added in future, a test for that should
+# be added.
+
+# ---------------------------------------------------------------------
+test_done
--- LVM2/tools/lvm-static.c	2008/01/30 14:00:01	1.4
+++ LVM2/tools/lvm-static.c	2008/01/31 12:19:36	1.5
@@ -20,7 +20,8 @@
 	return lvm2_main(argc, argv, 1);
 }
 
-int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
+int lvm_shell(struct cmd_context *cmd __attribute((unused)),
+	      struct cmdline_context *cmdline __attribute((unused)))
 {
 	return 0;
 }
--- LVM2/tools/lvm.c	2008/01/30 14:00:02	1.104
+++ LVM2/tools/lvm.c	2008/01/31 12:19:36	1.105
@@ -121,7 +121,8 @@
 }
 
 /* Custom completion function */
-static char **_completion(const char *text, int start_pos, int end_pos)
+static char **_completion(const char *text, int start_pos,
+			  int end_pos __attribute((unused)))
 {
 	char **match_list = NULL;
 	int p = 0;
--- LVM2/tools/lvm2cmd.c	2007/08/20 20:55:30	1.3
+++ LVM2/tools/lvm2cmd.c	2008/01/31 12:19:36	1.4
@@ -20,7 +20,8 @@
 	return cmdlib_lvm2_init(0);
 }
 
-int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
+int lvm_shell(struct cmd_context *cmd __attribute((unused)),
+	      struct cmdline_context *cmdline __attribute((unused)))
 {
 	return 0;
 }


