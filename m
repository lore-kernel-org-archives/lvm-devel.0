From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jan 2010 22:15:48 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20100121221548.14214.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-21 22:15:46

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/dmeventd/plugins: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in dmeventd_mirror.c 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	                                   dmeventd_snapshot.c 
	include        : .symlinks.in 
Added files:
	daemons/dmeventd/plugins/lvm2: .exported_symbols Makefile.in 
	                               dmeventd_lvm.c dmeventd_lvm.h 

Log message:
	Add libdevmapper-event-lvm2.so to serialise dmeventd plugin liblvm2cmd use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1398&r2=1.1399
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/01/21 21:09:23	1.1398
+++ LVM2/WHATS_NEW	2010/01/21 22:15:45	1.1399
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Add libdevmapper-event-lvm2.so to serialise dmeventd plugin liblvm2cmd use.
   Cleanup memory initialization and freeing in pv_read() and pv_create().
   Clear pointer and counters after their release in _fin_commands().
   Add t-topology-support.sh and t-snapshot-merge.sh tests.
--- LVM2/configure	2010/01/19 02:04:33	1.114
+++ LVM2/configure	2010/01/21 22:15:45	1.115
@@ -15531,7 +15531,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16138,6 +16138,7 @@
     "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
     "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
+    "daemons/dmeventd/plugins/lvm2/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/lvm2/Makefile" ;;
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
--- LVM2/configure.in	2010/01/19 02:04:34	1.123
+++ LVM2/configure.in	2010/01/21 22:15:45	1.124
@@ -1156,6 +1156,7 @@
 daemons/dmeventd/Makefile
 daemons/dmeventd/libdevmapper-event.pc
 daemons/dmeventd/plugins/Makefile
+daemons/dmeventd/plugins/lvm2/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 doc/Makefile
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2009/10/02 19:10:33	1.4
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2010/01/21 22:15:46	1.5
@@ -17,7 +17,10 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-SUBDIRS += mirror snapshot
+SUBDIRS += lvm2 mirror snapshot
+
+mirror: lvm2
+snapshot: lvm2
 
 include ../../../make.tmpl
 
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols
+++ -	2010-01-21 22:15:47.576753000 +0000
@@ -0,0 +1,6 @@
+init_lvm
+fini_lvm
+lock_lvm
+unlock_lvm
+lvm_pool
+lvm_handle
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ -	2010-01-21 22:15:47.659652000 +0000
@@ -0,0 +1,39 @@
+#
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+VPATH = @srcdir@
+
+CLDFLAGS += -L${top_builddir}/tools
+
+SOURCES = dmeventd_lvm.c
+
+ifeq ("@LIB_SUFFIX@","dylib")
+  LIB_SHARED = libdevmapper-event-lvm2.dylib
+else
+  LIB_SHARED = libdevmapper-event-lvm2.so
+endif
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+include $(top_builddir)/make.tmpl
+
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+
+install_lvm2: libdevmapper-event-lvm2.$(LIB_SUFFIX)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+		$(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+
+install: install_lvm2
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ -	2010-01-21 22:15:47.744680000 +0000
@@ -0,0 +1,127 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+#include <pthread.h>
+#include <syslog.h>
+
+/*
+ * register_device() is called first and performs initialisation.
+ * Only one device may be registered or unregistered at a time.
+ */
+static pthread_mutex_t _register_mutex = PTHREAD_MUTEX_INITIALIZER;
+
+/*
+ * Number of active registrations.
+ */
+static int _register_count = 0;
+static struct dm_pool *_mem_pool = NULL;
+static void *_lvm_handle = NULL;
+
+/*
+ * Currently only one event can be processed at a time.
+ */
+static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
+
+/* FIXME Remove this: Pass messages back to dmeventd core for processing. */
+static void _temporary_log_fn(int level,
+			      const char *file __attribute((unused)),
+			      int line __attribute((unused)),
+			      int dm_errno __attribute((unused)),
+			      const char *format)
+{
+	level &= ~_LOG_STDERR;
+
+	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
+		syslog(LOG_CRIT, "%s", format);
+	else
+		syslog(LOG_DEBUG, "%s", format);
+}
+
+void dmeventd_lvm2_lock(void)
+{
+	if (pthread_mutex_trylock(&_event_mutex)) {
+		syslog(LOG_NOTICE, "Another thread is handling an event. Waiting...");
+		pthread_mutex_lock(&_event_mutex);
+	}
+}
+
+void dmeventd_lvm2_unlock(void)
+{
+	pthread_mutex_unlock(&_event_mutex);
+}
+
+int dmeventd_lvm2_init(void)
+{
+	int r = 0;
+
+	pthread_mutex_lock(&_register_mutex);
+
+	/*
+	 * Need some space for allocations.  1024 should be more
+	 * than enough for what we need (device mapper name splitting)
+	 */
+	if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024)))
+		goto out;
+
+	if (!_lvm_handle) {
+		lvm2_log_fn(_temporary_log_fn);
+		if (!(_lvm_handle = lvm2_init())) {
+			dm_pool_destroy(_mem_pool);
+			_mem_pool = NULL;
+			goto out;
+		}
+		/* FIXME Temporary: move to dmeventd core */
+		lvm2_run(_lvm_handle, "_memlock_inc");
+	}
+
+	_register_count++;
+	r = 1;
+
+out:
+	pthread_mutex_unlock(&_register_mutex);
+	return r;
+}
+
+void dmeventd_lvm2_exit(void)
+{
+	pthread_mutex_lock(&_register_mutex);
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
+}
+
+struct dm_pool *dmeventd_lvm2_pool(void)
+{
+	return _mem_pool;
+}
+
+int dmeventd_lvm2_run(const char *cmdline)
+{
+	return lvm2_run(_lvm_handle, cmdline);
+}
+
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
+++ -	2010-01-21 22:15:47.831375000 +0000
@@ -0,0 +1,39 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+/*
+ * Wrappers around liblvm2cmd functions for dmeventd plug-ins.
+ *
+ * liblvm2cmd is not thread-safe so the locking in this library helps dmeventd
+ * threads to co-operate in sharing a single instance.
+ *
+ * FIXME Either support this properly as a generic liblvm2cmd wrapper or make
+ * liblvm2cmd thread-safe so this can go away.
+ */
+
+#include "libdevmapper.h"
+
+#ifndef _DMEVENTD_LVMWRAP_H
+#define _DMEVENTD_LVMWRAP_H
+
+int dmeventd_lvm2_init(void);
+void dmeventd_lvm2_exit(void);
+int dmeventd_lvm2_run(const char *cmdline);
+
+void dmeventd_lvm2_lock(void);
+void dmeventd_lvm2_unlock(void);
+
+struct dm_pool *dmeventd_lvm2_pool(void);
+
+#endif /* _DMEVENTD_LVMWRAP_H */
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/10/09 16:04:54	1.12
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/01/21 22:15:46	1.13
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005, 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2005, 2008-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -17,8 +17,8 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_builddir}/tools
+INCLUDES += -I${top_srcdir}/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L${top_builddir}/tools -L${top_builddir}/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_mirror.c
 
@@ -32,7 +32,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@ -ldevmapper-event-lvm2
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/01/06 13:26:21	1.29
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/01/21 22:15:46	1.30
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -12,18 +12,14 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "lib.h"
+
 #include "lvm2cmd.h"
 #include "errors.h"
+#include "libdevmapper-event.h"
+#include "dmeventd_lvm.h"
 
-#include <libdevmapper.h>
-#include <libdevmapper-event.h>
-#include <errno.h>
-#include <signal.h>
-#include <string.h>
-#include <stdio.h>
-#include <stdlib.h>
 #include <pthread.h>
-#include <unistd.h>
 
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
@@ -34,25 +30,6 @@
 #define ME_INSYNC    1
 #define ME_FAILURE   2
 
-/*
- * register_device() is called first and performs initialisation.
- * Only one device may be registered or unregistered at a time.
- */
-static pthread_mutex_t _register_mutex = PTHREAD_MUTEX_INITIALIZER;
-
-/*
- * Number of active registrations.
- */
-static int _register_count = 0;
-
-static struct dm_pool *_mem_pool = NULL;
-static void *_lvm_handle = NULL;
-
-/*
- * Currently only one event can be processed at a time.
- */
-static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
-
 static int _process_status_code(const char status_code, const char *dev_name,
 				const char *dev_type, int r)
 {
@@ -155,18 +132,6 @@
 	return ME_IGNORE;
 }
 
-static void _temporary_log_fn(int level,
-			      const char *file __attribute((unused)),
-			      int line __attribute((unused)),
-			      int dm_errno __attribute((unused)),
-			      const char *format)
-{
-	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
-		syslog(LOG_CRIT, "%s", format);
-	else
-		syslog(LOG_DEBUG, "%s", format);
-}
-
 static int _remove_failed_devices(const char *device)
 {
 	int r;
@@ -177,7 +142,7 @@
 	if (strlen(device) > 200)  /* FIXME Use real restriction */
 		return -ENAMETOOLONG;	/* FIXME These return code distinctions are not used so remove them! */
 
-	if (!dm_split_lvm_name(_mem_pool, device, &vg, &lv, &layer)) {
+	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
 		syslog(LOG_ERR, "Unable to determine VG name from %s",
 		       device);
 		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
@@ -187,15 +152,13 @@
 	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
-		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
-	r = lvm2_run(_lvm_handle, cmd_str);
+	r = dmeventd_lvm2_run(cmd_str);
 
 	syslog(LOG_INFO, "Repair of mirrored LV %s/%s %s.", vg, lv, (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
 
-	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 	return (r == ECMD_PROCESSED) ? 0 : -1;
 }
 
@@ -209,10 +172,8 @@
 	char *params;
 	const char *device = dm_task_get_name(dmt);
 
-	if (pthread_mutex_trylock(&_event_mutex)) {
-		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
-		pthread_mutex_lock(&_event_mutex);
-	}
+	dmeventd_lvm2_lock();
+
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
@@ -255,7 +216,7 @@
 		}
 	} while (next);
 
-	pthread_mutex_unlock(&_event_mutex);
+	dmeventd_lvm2_unlock();
 }
 
 int register_device(const char *device,
@@ -264,38 +225,8 @@
 		    int minor __attribute((unused)),
 		    void **unused __attribute((unused)))
 {
-	int r = 0;
-
-	pthread_mutex_lock(&_register_mutex);
-
-	/*
-	 * Need some space for allocations.  1024 should be more
-	 * than enough for what we need (device mapper name splitting)
-	 */
-	if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024)))
-		goto out;
-
-	if (!_lvm_handle) {
-		lvm2_log_fn(_temporary_log_fn);
-		if (!(_lvm_handle = lvm2_init())) {
-			dm_pool_destroy(_mem_pool);
-			_mem_pool = NULL;
-			goto out;
-		}
-		lvm2_log_level(_lvm_handle, LVM2_LOG_SUPPRESS);
-		/* FIXME Temporary: move to dmeventd core */
-		lvm2_run(_lvm_handle, "_memlock_inc");
-	}
-
-	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
-
-	_register_count++;
-	r = 1;
-
-out:
-	pthread_mutex_unlock(&_register_mutex);
-
-	return r;
+	syslog(LOG_INFO, "Monitoring mirror device %s for events", device);
+	return dmeventd_lvm2_init();
 }
 
 int unregister_device(const char *device,
@@ -304,20 +235,8 @@
 		      int minor __attribute((unused)),
 		      void **unused __attribute((unused)))
 {
-	pthread_mutex_lock(&_register_mutex);
-
 	syslog(LOG_INFO, "No longer monitoring mirror device %s for events\n",
 	       device);
-
-	if (!--_register_count) {
-		dm_pool_destroy(_mem_pool);
-		_mem_pool = NULL;
-		lvm2_run(_lvm_handle, "_memlock_dec");
-		lvm2_exit(_lvm_handle);
-		_lvm_handle = NULL;
-	}
-
-	pthread_mutex_unlock(&_register_mutex);
-
+	dmeventd_lvm2_exit();
 	return 1;
 }
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/10/09 16:04:54	1.8
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/01/21 22:15:46	1.9
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
@@ -17,8 +17,8 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_builddir}/tools
+INCLUDES += -I${top_srcdir}/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L${top_builddir}/tools -L${top_builddir}/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_snapshot.c
 
@@ -32,7 +32,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@ -ldevmapper-event-lvm2
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2009/09/17 10:37:24	1.4
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/01/21 22:15:46	1.5
@@ -12,19 +12,16 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
-#include "libdevmapper-event.h"
+#include "dmlib.h"
+
 #include "lvm2cmd.h"
+#include "errors.h"
+#include "libdevmapper-event.h"
+#include "dmeventd_lvm.h"
+
 #include "lvm-string.h"
 
-#include <errno.h>
-#include <signal.h>
-#include <string.h>
-#include <stdio.h>
-#include <stdlib.h>
 #include <pthread.h>
-#include <unistd.h>
-
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 
@@ -33,39 +30,12 @@
 /* Further warnings at 85%, 90% and 95% fullness. */
 #define WARNING_STEP 5
 
-static pthread_mutex_t _register_mutex = PTHREAD_MUTEX_INITIALIZER;
-
-/*
- * Number of active registrations.
- */
-static int _register_count = 0;
-
-static struct dm_pool *_mem_pool = NULL;
-static void *_lvm_handle = NULL;
-
 struct snap_status {
 	int invalid;
 	int used;
 	int max;
 };
 
-/*
- * Currently only one event can be processed at a time.
- */
-static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
-
-static void _temporary_log_fn(int level,
-			      const char *file __attribute((unused)),
-			      int line __attribute((unused)),
-			      int dm_errno __attribute((unused)),
-			      const char *format)
-{
-	if (!strncmp(format, "WARNING: ", 9) && (level < 5))
-		syslog(LOG_CRIT, "%s", format);
-	else
-		syslog(LOG_DEBUG, "%s", format);
-}
-
 /* FIXME possibly reconcile this with target_percent when we gain
    access to regular LVM library here. */
 static void _parse_snapshot_params(char *params, struct snap_status *stat)
@@ -116,10 +86,7 @@
 	if (!*percent_warning)
 		return;
 
-	if (pthread_mutex_trylock(&_event_mutex)) {
-		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
-		pthread_mutex_lock(&_event_mutex);
-	}
+	dmeventd_lvm2_lock();
 
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 	if (!target_type)
@@ -143,7 +110,7 @@
 		*percent_warning = (percent / WARNING_STEP) * WARNING_STEP + WARNING_STEP;
 	}
 out:
-	pthread_mutex_unlock(&_event_mutex);
+	dmeventd_lvm2_unlock();
 }
 
 int register_device(const char *device,
@@ -152,41 +119,12 @@
 		    int minor __attribute((unused)),
 		    void **private)
 {
-	int r = 0;
 	int *percent_warning = (int*)private;
 
-	pthread_mutex_lock(&_register_mutex);
-
-	/*
-	 * Need some space for allocations.  1024 should be more
-	 * than enough for what we need (device mapper name splitting)
-	 */
-	if (!_mem_pool && !(_mem_pool = dm_pool_create("snapshot_dso", 1024)))
-		goto out;
-
 	*percent_warning = WARNING_THRESH; /* Print warning if snapshot is full */
 
-	if (!_lvm_handle) {
-		lvm2_log_fn(_temporary_log_fn);
-		if (!(_lvm_handle = lvm2_init())) {
-			dm_pool_destroy(_mem_pool);
-			_mem_pool = NULL;
-			goto out;
-		}
-		lvm2_log_level(_lvm_handle, LVM2_LOG_SUPPRESS);
-		/* FIXME Temporary: move to dmeventd core */
-		lvm2_run(_lvm_handle, "_memlock_inc");
-	}
-
 	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
-
-	_register_count++;
-	r = 1;
-
-out:
-	pthread_mutex_unlock(&_register_mutex);
-
-	return r;
+	return dmeventd_lvm2_init();
 }
 
 int unregister_device(const char *device,
@@ -195,20 +133,8 @@
 		      int minor __attribute((unused)),
 		      void **unused __attribute((unused)))
 {
-	pthread_mutex_lock(&_register_mutex);
-
 	syslog(LOG_INFO, "No longer monitoring snapshot %s\n",
 	       device);
-
-	if (!--_register_count) {
-		dm_pool_destroy(_mem_pool);
-		_mem_pool = NULL;
-		lvm2_run(_lvm_handle, "_memlock_dec");
-		lvm2_exit(_lvm_handle);
-		_lvm_handle = NULL;
-	}
-
-	pthread_mutex_unlock(&_register_mutex);
-
+	dmeventd_lvm2_exit();
 	return 1;
 }
--- LVM2/include/.symlinks.in	2009/10/02 19:10:34	1.1
+++ LVM2/include/.symlinks.in	2010/01/21 22:15:46	1.2
@@ -59,3 +59,4 @@
 @top_srcdir@/libdm/misc/dmlib.h
 @top_srcdir@/libdm/misc/kdev_t.h
 @top_srcdir@/po/pogen.h
+@top_srcdir@/tools/lvm2cmd.h


