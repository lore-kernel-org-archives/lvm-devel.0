From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 05:00:23 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20110811050023.3904.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 05:00:22

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/dmeventd/plugins: Makefile.in 
	lib/config     : defaults.h 
	lib/raid       : raid.c 
Added files:
	daemons/dmeventd/plugins/raid: .exported_symbols Makefile.in 
	                               dmeventd_raid.c 

Log message:
	Add dmeventd monitoring for RAID devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2060&r2=1.2061
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/raid/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/raid/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2011/08/11 04:18:17	1.2060
+++ LVM2/WHATS_NEW	2011/08/11 05:00:20	1.2061
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add dmeventd monitoring shared library for RAID.
   Add RAID metadata devices to considered devices in _add_lv_to_dtree.
   Fix renaming of RAID logical volumes.
   Replace free_vg with release_vg and move it to vg.c.
--- LVM2/configure	2011/08/09 18:14:48	1.152
+++ LVM2/configure	2011/08/11 05:00:20	1.153
@@ -10165,7 +10165,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makef!
 ile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/dat!
 astruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10863,6 +10863,7 @@
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
     "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
     "daemons/dmeventd/plugins/lvm2/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/lvm2/Makefile" ;;
+    "daemons/dmeventd/plugins/raid/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/raid/Makefile" ;;
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
--- LVM2/configure.in	2011/08/09 18:11:00	1.166
+++ LVM2/configure.in	2011/08/11 05:00:21	1.167
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -1382,6 +1382,7 @@
 daemons/dmeventd/libdevmapper-event.pc
 daemons/dmeventd/plugins/Makefile
 daemons/dmeventd/plugins/lvm2/Makefile
+daemons/dmeventd/plugins/raid/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 doc/Makefile
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2010/04/09 21:34:27	1.8
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2011/08/11 05:00:21	1.9
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2005, 2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,7 +16,7 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS += lvm2 mirror snapshot
+SUBDIRS += lvm2 mirror snapshot raid
 
 include $(top_builddir)/make.tmpl
 
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/raid/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/raid/.exported_symbols
+++ -	2011-08-11 05:00:23.197949000 +0000
@@ -0,0 +1,3 @@
+process_event
+register_device
+unregister_device
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/raid/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/raid/Makefile.in
+++ -	2011-08-11 05:00:23.276942000 +0000
@@ -0,0 +1,39 @@
+#
+# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+# Copyright (C) 2004-2005, 2008-2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+
+SOURCES = dmeventd_raid.c
+
+LIB_NAME = libdevmapper-event-lvm2raid
+LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+
+include $(top_builddir)/make.tmpl
+
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
+
+install_lvm2: install_dm_plugin
+
+install: install_lvm2
+
+DISTCLEAN_TARGETS += .exported_symbols_generated
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ -	2011-08-11 05:00:23.355807000 +0000
@@ -0,0 +1,145 @@
+/*
+ * Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+
+#include "lvm2cmd.h"
+#include "errors.h"
+#include "libdevmapper-event.h"
+#include "dmeventd_lvm.h"
+
+#include <syslog.h> /* FIXME Replace syslog with multilog */
+/* FIXME Missing openlog? */
+/* FIXME Replace most syslogs with log_error() style messages and add complete context. */
+/* FIXME Reformat to 80 char lines. */
+
+static int _process_raid_event(char *params, const char *device)
+{
+	int i, n, failure = 0;
+	char *p, *a[4];
+	char *raid_type;
+	char *num_devices;
+	char *health_chars;
+	char *resync_ratio;
+
+	/*
+	 * RAID parms:     <raid_type> <#raid_disks> \
+	 *                 <health chars> <resync ratio>
+	 */
+	if (!dm_split_words(params, 4, 0, a)) {
+		syslog(LOG_ERR, "Failed to process status line for %s\n",
+		       device);
+		return -EINVAL;
+	}
+	raid_type = a[0];
+	num_devices = a[1];
+	health_chars = a[2];
+	resync_ratio = a[3];
+
+	if (!(n = atoi(num_devices))) {
+		syslog(LOG_ERR, "Failed to parse number of devices for %s: %s",
+		       device, num_devices);
+		return -EINVAL;
+	}
+
+	for (i = 0; i < n; i++) {
+		switch (health_chars[i]) {
+		case 'A':
+			/* Device is 'A'live and well */
+		case 'a':
+			/* Device is 'a'live, but not yet in-sync */
+			break;
+		case 'D':
+			syslog(LOG_ERR,
+			       "Device #%d of %s array, %s, has failed.",
+			       i, raid_type, device);
+			failure++;
+			break;
+		default:
+			/* Unhandled character returned from kernel */
+			break;
+		}
+		if (failure)
+			return 0; /* Don't bother parsing rest of status */
+	}
+
+	p = strstr(resync_ratio, "/");
+	if (!p) {
+		syslog(LOG_ERR, "Failed to parse resync_ratio for %s: %s",
+		       device, resync_ratio);
+		return -EINVAL;
+	}
+	p[0] = '\0';
+	syslog(LOG_INFO, "%s array, %s, is %s in-sync.",
+	       raid_type, device, strcmp(resync_ratio, p+1) ? "not" : "now");
+
+	return 0;
+}
+
+void process_event(struct dm_task *dmt,
+		   enum dm_event_mask event __attribute__((unused)),
+		   void **unused __attribute__((unused)))
+{
+	void *next = NULL;
+	uint64_t start, length;
+	char *target_type = NULL;
+	char *params;
+	const char *device = dm_task_get_name(dmt);
+
+	dmeventd_lvm2_lock();
+
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length,
+					  &target_type, &params);
+
+		if (!target_type) {
+			syslog(LOG_INFO, "%s mapping lost.", device);
+			continue;
+		}
+
+		if (strcmp(target_type, "raid")) {
+			syslog(LOG_INFO, "%s has non-raid portion.", device);
+			continue;
+		}
+
+		if (_process_raid_event(params, device))
+			syslog(LOG_ERR, "Failed to process event for %s",
+			       device);
+	} while (next);
+
+	dmeventd_lvm2_unlock();
+}
+
+int register_device(const char *device,
+		    const char *uuid __attribute__((unused)),
+		    int major __attribute__((unused)),
+		    int minor __attribute__((unused)),
+		    void **unused __attribute__((unused)))
+{
+	int r = dmeventd_lvm2_init();
+	syslog(LOG_INFO, "Monitoring RAID device %s for events.", device);
+	return r;
+}
+
+int unregister_device(const char *device,
+		      const char *uuid __attribute__((unused)),
+		      int major __attribute__((unused)),
+		      int minor __attribute__((unused)),
+		      void **unused __attribute__((unused)))
+{
+	syslog(LOG_INFO, "No longer monitoring RAID device %s for events.",
+	       device);
+	dmeventd_lvm2_exit();
+	return 1;
+}
--- LVM2/lib/config/defaults.h	2011/08/02 22:07:22	1.80
+++ LVM2/lib/config/defaults.h	2011/08/11 05:00:21	1.81
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -54,6 +54,7 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+#define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_SNAPSHOT_LIB "libdevmapper-event-lvm2snapshot.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
--- LVM2/lib/raid/raid.c	2011/08/02 22:07:23	1.1
+++ LVM2/lib/raid/raid.c	2011/08/11 05:00:22	1.2
@@ -25,6 +25,7 @@
 #include "activate.h"
 #include "metadata.h"
 #include "lv_alloc.h"
+#include "defaults.h"
 
 static const char *_raid_name(const struct lv_segment *seg)
 {
@@ -261,6 +262,39 @@
 	dm_free((void *) segtype);
 }
 
+static const char *_get_raid_dso_path(struct cmd_context *cmd)
+{
+	const char *config_str = find_config_tree_str(cmd, "dmeventd/raid_library",
+						      DEFAULT_DMEVENTD_RAID_LIB);
+	return get_monitor_dso_path(cmd, config_str);
+}
+
+static int _raid_target_monitored(struct lv_segment *seg, int *pending)
+{
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	const char *dso_path = _get_raid_dso_path(cmd);
+
+	return target_registered_with_dmeventd(cmd, dso_path, seg->lv, pending);
+}
+
+static int _raid_set_events(struct lv_segment *seg, int evmask, int set)
+{
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	const char *dso_path = _get_raid_dso_path(cmd);
+
+	return target_register_events(cmd, dso_path, seg->lv, evmask, set, 0);
+}
+
+static int _raid_target_monitor_events(struct lv_segment *seg, int events)
+{
+	return _raid_set_events(seg, events, 1);
+}
+
+static int _raid_target_unmonitor_events(struct lv_segment *seg, int events)
+{
+	return _raid_set_events(seg, events, 0);
+}
+
 static struct segtype_handler _raid_ops = {
 	.name = _raid_name,
 	.text_import_area_count = _raid_text_import_area_count,
@@ -272,6 +306,9 @@
 	.target_present = _raid_target_present,
 	.modules_needed = _raid_modules_needed,
 	.destroy = _raid_destroy,
+	.target_monitored = _raid_target_monitored,
+	.target_monitor_events = _raid_target_monitor_events,
+	.target_unmonitor_events = _raid_target_unmonitor_events,
 };
 
 static struct segment_type *init_raid_segtype(struct cmd_context *cmd,
@@ -285,6 +322,12 @@
 	segtype->cmd = cmd;
 
 	segtype->flags = SEG_RAID;
+#ifdef DEVMAPPER_SUPPORT
+#ifdef DMEVENTD
+	if (_get_raid_dso_path(cmd))
+		segtype->flags |= SEG_MONITORED;
+#endif
+#endif
 	segtype->parity_devs = strstr(raid_type, "raid6") ? 2 : 1;
 
 	segtype->ops = &_raid_ops;


