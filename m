From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Jan 2008 15:32:20 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in dm ...
Message-ID: <20080109153220.727.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-01-09 15:32:19

Modified files:
	.              : WHATS_NEW configure configure.in 
	dmeventd       : Makefile.in 
	doc            : example.conf 
	lib/activate   : activate.c 
	lib/snapshot   : snapshot.c 
Added files:
	dmeventd/snapshot: Makefile.in dmeventd_snapshot.c 

Log message:
	Add snapshot dmeventd library (enables dmeventd snapshot monitoring).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.753&r2=1.754
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2008/01/09 00:18:36	1.753
+++ LVM2/WHATS_NEW	2008/01/09 15:32:18	1.754
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Add snapshot dmeventd library (enables dmeventd snapshot monitoring).
   Prevent pvcreate from overwriting MDA-less PVs belonging to active VGs.
   Fix a segfault if using pvs with --all argument. (2.02.29)
   Update --uuid argument description in man pages.
--- LVM2/configure	2007/12/17 12:23:23	1.65
+++ LVM2/configure	2008/01/09 15:32:18	1.66
@@ -11126,7 +11126,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile dmeventd/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11688,6 +11688,7 @@
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
     "dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/Makefile" ;;
     "dmeventd/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/mirror/Makefile" ;;
+    "dmeventd/snapshot/Makefile" ) CONFIG_FILES="$CONFIG_FILES dmeventd/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
--- LVM2/configure.in	2007/12/17 12:23:23	1.65
+++ LVM2/configure.in	2008/01/09 15:32:19	1.66
@@ -642,6 +642,7 @@
 daemons/clvmd/Makefile
 dmeventd/Makefile
 dmeventd/mirror/Makefile
+dmeventd/snapshot/Makefile
 doc/Makefile
 include/Makefile
 lib/Makefile
--- LVM2/dmeventd/Makefile.in	2007/09/21 10:16:43	1.2
+++ LVM2/dmeventd/Makefile.in	2008/01/09 15:32:19	1.3
@@ -16,7 +16,7 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-SUBDIRS += mirror
+SUBDIRS += mirror snapshot
 
 include $(top_srcdir)/make.tmpl
 
/cvs/lvm2/LVM2/dmeventd/snapshot/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/dmeventd/snapshot/Makefile.in
+++ -	2008-01-09 15:32:20.555931000 +0000
@@ -0,0 +1,36 @@
+#
+# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+# Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the LVM2.
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
+VPATH = @srcdir@
+
+INCLUDES += -I${top_srcdir}/tools
+CLDFLAGS += -L${top_srcdir}/tools -ldevmapper -llvm2cmd
+
+SOURCES = dmeventd_snapshot.c
+
+ifeq ("@LIB_SUFFIX@","dylib")
+  LIB_SHARED = libdevmapper-event-lvm2snapshot.dylib
+else
+  LIB_SHARED = libdevmapper-event-lvm2snapshot.so
+endif
+
+include $(top_srcdir)/make.tmpl
+
+install: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+		$(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+
/cvs/lvm2/LVM2/dmeventd/snapshot/dmeventd_snapshot.c,v  -->  standard output
revision 1.1
--- LVM2/dmeventd/snapshot/dmeventd_snapshot.c
+++ -	2008-01-09 15:32:20.642063000 +0000
@@ -0,0 +1,223 @@
+/*
+ * Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
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
+#include "libdevmapper.h"
+#include "libdevmapper-event.h"
+#include "lvm2cmd.h"
+#include "lvm-string.h"
+
+#include <errno.h>
+#include <signal.h>
+#include <string.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <pthread.h>
+#include <unistd.h>
+
+#include <syslog.h> /* FIXME Replace syslog with multilog */
+/* FIXME Missing openlog? */
+
+/* First warning when snapshot is 80% full. */
+#define WARNING_THRESH 80
+/* Further warnings at 85%, 90% and 95% fullness. */
+#define WARNING_STEP 5
+
+static pthread_mutex_t _register_mutex = PTHREAD_MUTEX_INITIALIZER;
+
+/*
+ * Number of active registrations.
+ */
+static int _register_count = 0;
+
+static struct dm_pool *_mem_pool = NULL;
+static void *_lvm_handle = NULL;
+
+struct snap_status {
+	int invalid;
+	int used;
+	int max;
+};
+
+/*
+ * Currently only one event can be processed at a time.
+ */
+static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
+
+static void _temporary_log_fn(int level, const char *file,
+			      int line, const char *format)
+{
+	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
+		syslog(LOG_CRIT, "%s", format);
+	else
+		syslog(LOG_DEBUG, "%s", format);
+}
+
+/* FIXME possibly reconcile this with target_percent when we gain
+   access to regular LVM library here. */
+static void _parse_snapshot_params(char *params, struct snap_status *stat)
+{
+	char *p;
+	/*
+	 * xx/xx	-- fractions used/max
+	 * Invalid	-- snapshot invalidated
+	 * Unknown	-- status unknown
+	 */
+	stat->used = stat->max = 0;
+
+	if (!strncmp(params, "Invalid", 7)) {
+		stat->invalid = 1;
+		return;
+	}
+
+	/*
+	 * When we return without setting non-zero max, the parent is
+	 * responsible for reporting errors.
+	 */
+	if (!strncmp(params, "Unknown", 7))
+		return;
+
+	if (!(p = strstr(params, "/")))
+		return;
+
+	*p = '\0';
+	p++;
+
+	stat->used = atoi(params);
+	stat->max = atoi(p);
+}
+
+/* send unregister command to itself */
+static void _unregister_self(struct dm_task *dmt)
+{
+	const char *name = dm_task_get_name(dmt);
+	struct dm_event_handler *dmevh;
+
+	if (!(dmevh = dm_event_handler_create()))
+		return;
+
+	if (dm_event_handler_set_dev_name(dmevh, name))
+		goto fail;
+
+	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS|DM_EVENT_TIMEOUT);
+	dm_event_unregister_handler(dmevh);
+fail:
+	dm_event_handler_destroy(dmevh);
+}
+
+void process_event(struct dm_task *dmt, enum dm_event_mask event,
+		   void **private)
+{
+	void *next = NULL;
+	uint64_t start, length;
+	char *target_type = NULL;
+	char *params;
+	struct snap_status stat = { 0 };
+	const char *device = dm_task_get_name(dmt);
+	int percent, *percent_warning = (int*)private;
+
+	/* No longer monitoring, waiting for remove */
+	if (!*percent_warning)
+		return;
+
+	if (pthread_mutex_trylock(&_event_mutex)) {
+		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
+		pthread_mutex_lock(&_event_mutex);
+	}
+
+	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+	if (!target_type)
+		goto out;
+
+	_parse_snapshot_params(params, &stat);
+	/*
+	 * If the snapshot has been invalidated or we failed to parse
+	 * the status string. Report the full status string to syslog.
+	 */
+	if (stat.invalid || !stat.max) {
+		syslog(LOG_ERR, "Snapshot %s changed state to: %s\n", device, params);
+		_unregister_self(dmt);
+		*percent_warning = 0;
+		goto out;
+	}
+
+	percent = 100 * stat.used / stat.max;
+	if (percent >= *percent_warning) {
+		syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
+		/* Print warning on the next multiple of WARNING_STEP. */
+		*percent_warning = (percent / WARNING_STEP) * WARNING_STEP + WARNING_STEP;
+	}
+out:
+	pthread_mutex_unlock(&_event_mutex);
+}
+
+int register_device(const char *device, const char *uuid, int major, int minor,
+		   void **private)
+{
+	int r = 0;
+	int *percent_warning = (int*)private;
+
+	pthread_mutex_lock(&_register_mutex);
+
+	/*
+	 * Need some space for allocations.  1024 should be more
+	 * than enough for what we need (device mapper name splitting)
+	 */
+	if (!_mem_pool && !(_mem_pool = dm_pool_create("snapshot_dso", 1024)))
+		goto out;
+
+	*percent_warning = WARNING_THRESH; /* Print warning if snapshot is full */
+
+	if (!_lvm_handle) {
+		lvm2_log_fn(_temporary_log_fn);
+		if (!(_lvm_handle = lvm2_init())) {
+			dm_pool_destroy(_mem_pool);
+			_mem_pool = NULL;
+			goto out;
+		}
+		lvm2_log_level(_lvm_handle, LVM2_LOG_SUPPRESS);
+		/* FIXME Temporary: move to dmeventd core */
+		lvm2_run(_lvm_handle, "_memlock_inc");
+	}
+
+	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
+
+	_register_count++;
+	r = 1;
+
+out:
+	pthread_mutex_unlock(&_register_mutex);
+
+	return r;
+}
+
+int unregister_device(const char *device, const char *uuid, int major, int minor,
+		   void **unused __attribute((unused)))
+{
+	pthread_mutex_lock(&_register_mutex);
+
+	syslog(LOG_INFO, "No longer monitoring snapshot %s\n",
+	       device);
+
+	if (!--_register_count) {
+		dm_pool_destroy(_mem_pool);
+		_mem_pool = NULL;
+		lvm2_run(_lvm_handle, "_memlock_dec");
+		lvm2_exit(_lvm_handle);
+		_lvm_handle = NULL;
+	}
+
+	pthread_mutex_unlock(&_register_mutex);
+
+	return 1;
+}
--- LVM2/doc/example.conf	2007/11/09 16:51:53	1.32
+++ LVM2/doc/example.conf	2008/01/09 15:32:19	1.33
@@ -384,10 +384,20 @@
 # dmeventd {
     # mirror_library is the library used when monitoring a mirror device.
     #
-    # "libdevmapper-event-lvm2mirror.so" attempts to recover from failures.
-    # It removes failed devices from a volume group and reconfigures a
-    # mirror as necessary.
-    #
+    # "libdevmapper-event-lvm2mirror.so" attempts to recover from
+    # failures.  It removes failed devices from a volume group and
+    # reconfigures a mirror as necessary. If no mirror library is
+    # provided, mirrors are not monitored through dmeventd.
+
     # mirror_library = "libdevmapper-event-lvm2mirror.so"
+
+    # snapshot_library is the library used when monitoring a snapshot device.
+    #
+    # "libdevmapper-event-lvm2snapshot.so" monitors the filling of
+    # snapshots and emits a warning through syslog, when the use of
+    # snapshot exceedes 80%. The warning is repeated when 85%, 90% and
+    # 95% of the snapshot are filled.
+
+    # snapshot_library = "libdevmapper-event-lvm2snapshot.so"
 #}
 
--- LVM2/lib/activate/activate.c	2007/11/12 20:51:53	1.128
+++ LVM2/lib/activate/activate.c	2008/01/09 15:32:19	1.129
@@ -669,7 +669,7 @@
 #ifdef DMEVENTD
 	int i, pending = 0, monitored;
 	int r = 1;
-	struct list *tmp;
+	struct list *tmp, *snh, *snht;
 	struct lv_segment *seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 
@@ -683,6 +683,29 @@
 	if (monitor && !dmeventd_monitor_mode())
 		return 1;
 
+	/*
+	 * In case of a snapshot device, we monitor lv->snapshot->lv,
+	 * not the actual LV itself.
+	 */
+	if (lv_is_cow(lv))
+		return monitor_dev_for_events(cmd, lv->snapshot->lv, monitor);
+
+	/*
+	 * In case this LV is a snapshot origin, we instead monitor
+	 * each of its respective snapshots (the origin itself does
+	 * not need to be monitored).
+	 *
+	 * TODO: This may change when snapshots of mirrors are allowed.
+	 */
+	if (lv_is_origin(lv)) {
+		list_iterate_safe(snh, snht, &lv->snapshot_segs)
+			if (!monitor_dev_for_events(
+				cmd, list_struct_base(snh,
+					struct lv_segment, origin_list)->cow, monitor))
+				r=0;
+		return r;
+	}
+
 	list_iterate(tmp, &lv->segments) {
 		seg = list_item(tmp, struct lv_segment);
 
--- LVM2/lib/snapshot/snapshot.c	2007/11/02 20:40:04	1.24
+++ LVM2/lib/snapshot/snapshot.c	2008/01/09 15:32:19	1.25
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,6 +21,10 @@
 #include "config.h"
 #include "activate.h"
 #include "str_list.h"
+#ifdef DMEVENTD
+#  include "sharedlib.h"
+#  include <libdevmapper-event.h>
+#endif
 
 static const char *_snap_name(const struct lv_segment *seg)
 {
@@ -125,6 +129,133 @@
 
 	return _snap_present;
 }
+
+#ifdef DMEVENTD
+static int _get_snapshot_dso_path(struct cmd_context *cmd, char **dso)
+{
+	char *path;
+	const char *libpath;
+
+	if (!(path = dm_pool_alloc(cmd->mem, PATH_MAX))) {
+		log_error("Failed to allocate dmeventd library path.");
+		return 0;
+	}
+
+	libpath = find_config_tree_str(cmd, "dmeventd/snapshot_library", NULL);
+	if (!libpath)
+		return 0;
+
+	get_shared_library_path(cmd, libpath, path, PATH_MAX);
+
+	*dso = path;
+
+	return 1;
+}
+
+static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
+							 const char *dso,
+							 const int timeout,
+							 enum dm_event_mask mask)
+{
+	struct dm_event_handler *dmevh;
+
+	if (!(dmevh = dm_event_handler_create()))
+		return_0;
+
+       if (dm_event_handler_set_dso(dmevh, dso))
+		goto fail;
+
+	if (dm_event_handler_set_dev_name(dmevh, dmname))
+		goto fail;
+
+	dm_event_handler_set_timeout(dmevh, timeout);
+	dm_event_handler_set_event_mask(dmevh, mask);
+	return dmevh;
+
+fail:
+	dm_event_handler_destroy(dmevh);
+	return NULL;
+}
+
+static int _target_registered(struct lv_segment *seg, int *pending)
+{
+	char *dso, *name;
+	struct logical_volume *lv;
+	struct volume_group *vg;
+	enum dm_event_mask evmask = 0;
+	struct dm_event_handler *dmevh;
+
+	lv = seg->lv;
+	vg = lv->vg;
+
+	*pending = 0;
+	if (!_get_snapshot_dso_path(vg->cmd, &dso))
+		return_0;
+
+	if (!(name = build_dm_name(vg->cmd->mem, vg->name, seg->cow->name, NULL)))
+		return_0;
+
+	if (!(dmevh = _create_dm_event_handler(name, dso, 0, DM_EVENT_ALL_ERRORS)))
+		return_0;
+
+	if (dm_event_get_registered_device(dmevh, 0)) {
+		dm_event_handler_destroy(dmevh);
+		return 0;
+	}
+
+	evmask = dm_event_handler_get_event_mask(dmevh);
+	if (evmask & DM_EVENT_REGISTRATION_PENDING) {
+		*pending = 1;
+		evmask &= ~DM_EVENT_REGISTRATION_PENDING;
+	}
+
+	dm_event_handler_destroy(dmevh);
+
+	return evmask;
+}
+
+/* FIXME This gets run while suspended and performs banned operations. */
+static int _target_set_events(struct lv_segment *seg, int events, int set)
+{
+	char *dso, *name;
+	struct volume_group *vg = seg->lv->vg;
+	struct dm_event_handler *dmevh;
+	int r;
+
+	if (!_get_snapshot_dso_path(vg->cmd, &dso))
+		return_0;
+
+	if (!(name = build_dm_name(vg->cmd->mem, vg->name, seg->cow->name, NULL)))
+		return_0;
+
+	/* FIXME: make timeout configurable */
+	if (!(dmevh = _create_dm_event_handler(name, dso, 10,
+		DM_EVENT_ALL_ERRORS|DM_EVENT_TIMEOUT)))
+		return_0;
+
+	r = set ? dm_event_register_handler(dmevh) : dm_event_unregister_handler(dmevh);
+	dm_event_handler_destroy(dmevh);
+	if (!r)
+		return_0;
+
+	log_info("%s %s for events", set ? "Registered" : "Unregistered", name);
+
+	return 1;
+}
+
+static int _target_register_events(struct lv_segment *seg,
+				   int events)
+{
+	return _target_set_events(seg, events, 1);
+}
+
+static int _target_unregister_events(struct lv_segment *seg,
+				     int events)
+{
+	return _target_set_events(seg, events, 0);
+}
+
+#endif /* DMEVENTD */
 #endif
 
 static int _snap_modules_needed(struct dm_pool *mem,
@@ -151,6 +282,11 @@
 #ifdef DEVMAPPER_SUPPORT
 	.target_percent = _snap_target_percent,
 	.target_present = _snap_target_present,
+#ifdef DMEVENTD
+	.target_monitored = _target_registered,
+	.target_monitor_events = _target_register_events,
+	.target_unmonitor_events = _target_unregister_events,
+#endif
 #endif
 	.modules_needed = _snap_modules_needed,
 	.destroy = _snap_destroy,
@@ -164,6 +300,7 @@
 #endif
 {
 	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+	char *dso;
 
 	if (!segtype) {
 		stack;
@@ -176,6 +313,10 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_SNAPSHOT;
 
+#ifdef DMEVENTD
+	if (_get_snapshot_dso_path(cmd, &dso))
+		segtype->flags |= SEG_MONITORED;
+#endif
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
 	return segtype;


