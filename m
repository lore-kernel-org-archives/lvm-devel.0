From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Jun 2011 03:32:47 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/mm/memlock ...
Message-ID: <20110613033247.23259.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-13 03:32:46

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/mm         : memlock.c 
	libdm          : libdevmapper.h libdm-common.c libdm-common.h 
	                 libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Maintain a count of the number of suspended devices in libdevmapper
	and use this for the LVM critical section logic.  Also report an error if
	code tries to load a table while any device is known to be in the
	suspended state.
	(If the variety of problems these changes are showing up can't be fixed
	before the next release, the error messages can be reduced to debug
	level.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2012&r2=1.2013
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.471&r2=1.472
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2011/06/12 00:23:50	1.2012
+++ LVM2/WHATS_NEW	2011/06/13 03:32:45	1.2013
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Use dm_get_suspended_counter in replacement critical_section logic.
   Downgrade critical_section errors to debug level until it is moved to libdm.
   Fix ignored background polling default in vgchange -ay.
   Fix pvmove activation sequences to avoid trapped I/O with multiple LVs.
--- LVM2/WHATS_NEW_DM	2011/06/12 19:49:40	1.471
+++ LVM2/WHATS_NEW_DM	2011/06/13 03:32:45	1.472
@@ -1,5 +1,7 @@
 Version 1.02.65 - 
 ==================================
+  Warn if a table is loaded while a device is known to be in suspended state.
+  Add dm_get_suspended_counter() for number of devs in suspended state by lib.
   Fix "all" report field prefix matching to include label fields with pv_all.
   Delay resuming new preloaded mirror devices with core logs in deptree code.
   Accept new kernel version 3 uname formats in initialisation.
--- LVM2/lib/mm/memlock.c	2011/06/12 00:23:50	1.44
+++ LVM2/lib/mm/memlock.c	2011/06/13 03:32:46	1.45
@@ -75,7 +75,7 @@
 
 static void *_malloc_mem = NULL;
 static int _mem_locked = 0;
-static int _critical_section_count = 0;
+static int _critical_section = 0;
 static int _memlock_count_daemon = 0;
 static int _priority;
 static int _default_priority;
@@ -374,10 +374,10 @@
 
 static void _lock_mem_if_needed(struct cmd_context *cmd)
 {
-	log_debug("Lock: Memlock counters: locked:%d critical:%d daemon:%d",
-		  _mem_locked, _critical_section_count, _memlock_count_daemon);
+	log_debug("Lock:   Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
+		  _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
 	if (!_mem_locked &&
-	    ((_critical_section_count + _memlock_count_daemon) == 1)) {
+	    ((_critical_section + _memlock_count_daemon) == 1)) {
 		_mem_locked = 1;
 		_lock_mem(cmd);
 	}
@@ -385,10 +385,10 @@
 
 static void _unlock_mem_if_possible(struct cmd_context *cmd)
 {
-	log_debug("Unlock: Memlock counters: locked:%d critical:%d daemon:%d",
-		  _mem_locked, _critical_section_count, _memlock_count_daemon);
+	log_debug("Unlock: Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
+		  _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
 	if (_mem_locked &&
-	    !_critical_section_count &&
+	    !_critical_section &&
 	    !_memlock_count_daemon) {
 		_unlock_mem(cmd);
 		_mem_locked = 0;
@@ -397,25 +397,25 @@
 
 void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
-	++_critical_section_count;
-	log_debug("critical_section_inc to %d (%s).", _critical_section_count,
-		  reason);
+	if (!_critical_section) {
+		_critical_section = 1;
+		log_debug("Entering critical section (%s).", reason);
+	}
+
 	_lock_mem_if_needed(cmd);
 }
 
 void critical_section_dec(struct cmd_context *cmd, const char *reason)
 {
-	/* FIXME Maintain accurate suspended device counter in libdevmapper */
-	if (!_critical_section_count)
-		log_debug("_critical_section has dropped below 0.");
-	--_critical_section_count;
-	log_debug("critical_section_dec to %d (%s).", _critical_section_count,
-		  reason);
+	if (_critical_section && !dm_get_suspended_counter()) {
+		_critical_section = 0;
+		log_debug("Leaving critical section (%s).", reason);
+	}
 }
 
 int critical_section(void)
 {
-	return _critical_section_count;
+	return _critical_section;
 }
 
 /*
@@ -428,7 +428,7 @@
 void memlock_inc_daemon(struct cmd_context *cmd)
 {
 	++_memlock_count_daemon;
-	if (_memlock_count_daemon == 1 && _critical_section_count > 0)
+	if (_memlock_count_daemon == 1 && _critical_section > 0)
                 log_error(INTERNAL_ERROR "_memlock_inc_daemon used in critical section.");
 	log_debug("memlock_count_daemon inc to %d", _memlock_count_daemon);
 	_lock_mem_if_needed(cmd);
@@ -460,7 +460,7 @@
 {
 	log_debug("memlock reset.");
 	_mem_locked = 0;
-	_critical_section_count = 0;
+	_critical_section = 0;
 	_memlock_count_daemon = 0;
 }
 
--- LVM2/libdm/libdevmapper.h	2011/03/10 12:48:40	1.137
+++ LVM2/libdm/libdevmapper.h	2011/06/13 03:32:46	1.138
@@ -74,6 +74,11 @@
  */
 int dm_log_is_non_default(void);
 
+/*
+ * Number of devices currently in suspended state (via the library).
+ */
+int dm_get_suspended_counter(void);
+
 enum {
 	DM_DEVICE_CREATE,
 	DM_DEVICE_RELOAD,
--- LVM2/libdm/libdm-common.c	2011/04/22 11:56:41	1.117
+++ LVM2/libdm/libdm-common.c	2011/06/13 03:32:46	1.118
@@ -60,6 +60,7 @@
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 
 static int _verbose = 0;
+static int _suspended_dev_counter = 0;
 
 #ifdef HAVE_SELINUX_LABEL_H
 static struct selabel_handle *_selabel_handle = NULL;
@@ -173,6 +174,28 @@
 	return 1;
 }
 
+void inc_suspended(void)
+{
+	_suspended_dev_counter++;
+	log_debug("Suspended device counter increased to %d", _suspended_dev_counter);
+}
+
+void dec_suspended(void)
+{
+	if (!_suspended_dev_counter) {
+		log_error("Attempted to decrement suspended device counter below zero.");
+		return;
+	}
+
+	_suspended_dev_counter--;
+	log_debug("Suspended device counter reduced to %d", _suspended_dev_counter);
+}
+
+int dm_get_suspended_counter(void)
+{
+	return _suspended_dev_counter;
+}
+
 struct dm_task *dm_task_create(int type)
 {
 	struct dm_task *dmt = dm_zalloc(sizeof(*dmt));
--- LVM2/libdm/libdm-common.h	2010/12/13 10:43:58	1.7
+++ LVM2/libdm/libdm-common.h	2011/06/13 03:32:46	1.8
@@ -33,4 +33,7 @@
 void update_devs(void);
 void selinux_release(void);
 
+void inc_suspended(void);
+void dec_suspended(void);
+
 #endif
--- LVM2/libdm/libdm-deptree.c	2011/06/11 12:55:31	1.95
+++ LVM2/libdm/libdm-deptree.c	2011/06/13 03:32:46	1.96
@@ -1034,7 +1034,7 @@
 static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 			uint32_t read_ahead, uint32_t read_ahead_flags,
 			struct dm_info *newinfo, uint32_t *cookie,
-			uint16_t udev_flags)
+			uint16_t udev_flags, int already_suspended)
 {
 	struct dm_task *dmt;
 	int r = 0;
@@ -1066,8 +1066,11 @@
 	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
 
-	if ((r = dm_task_run(dmt)))
+	if ((r = dm_task_run(dmt))) {
+		if (already_suspended)
+			dec_suspended();
 		r = dm_task_get_info(dmt, newinfo);
+	}
 
 out:
 	dm_task_destroy(dmt);
@@ -1106,8 +1109,10 @@
 	if (no_flush && !dm_task_no_flush(dmt))
 		log_error("Failed to set no_flush flag.");
 
-	if ((r = dm_task_run(dmt)))
+	if ((r = dm_task_run(dmt))) {
+		inc_suspended();
 		r = dm_task_get_info(dmt, newinfo);
+	}
 
 	dm_task_destroy(dmt);
 
@@ -1352,7 +1357,7 @@
 
 			if (!_resume_node(child->name, child->info.major, child->info.minor,
 					  child->props.read_ahead, child->props.read_ahead_flags,
-					  &newinfo, &child->dtree->cookie, child->udev_flags)) {
+					  &newinfo, &child->dtree->cookie, child->udev_flags, child->info.suspended)) {
 				log_error("Unable to resume %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
 					  child->info.minor);
@@ -1919,7 +1924,8 @@
 
 		if (!_resume_node(child->name, child->info.major, child->info.minor,
 				  child->props.read_ahead, child->props.read_ahead_flags,
-				  &newinfo, &child->dtree->cookie, child->udev_flags)) {
+				  &newinfo, &child->dtree->cookie, child->udev_flags,
+				  child->info.suspended)) {
 			log_error("Unable to resume %s (%" PRIu32
 				  ":%" PRIu32 ")", child->name, child->info.major,
 				  child->info.minor);
--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/09 15:07:40	1.104
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/13 03:32:46	1.105
@@ -2026,6 +2026,7 @@
 	unsigned command;
 	int check_udev;
 	int udev_only;
+	int suspended_counter;
 
 #ifdef DM_COMPAT
 	if (_dm_version == 1)
@@ -2057,6 +2058,22 @@
 		return 0;
 	}
 
+	if ((suspended_counter = dm_get_suspended_counter()) &&
+	    dmt->type == DM_DEVICE_RELOAD)
+		log_error("Performing unsafe table load while %d device(s) "
+			  "are known to be suspended: "
+			  "%s%s %s %s%.0d%s%.0d%s%s",
+			  suspended_counter,
+	                  dmt->new_uuid ? "UUID " : "",
+	                  dmi->name,
+			  dmi->uuid,
+	                  dmt->major > 0 ? "(" : "",
+	                  dmt->major > 0 ? dmt->major : 0,
+	                  dmt->major > 0 ? ":" : "",
+	                  dmt->minor > 0 ? dmt->minor : 0,
+	                  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
+	                  dmt->major > 0 ? ") " : "");
+
 	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:
 	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor))) {


