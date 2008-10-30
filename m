From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Oct 2008 17:40:01 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-globals.h
Message-ID: <20081030174001.2086.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-30 17:40:01

Modified files:
	.              : WHATS_NEW 
Added files:
	lib/misc       : lvm-globals.h 

Log message:
	separate lvm-globals

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.985&r2=1.986
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2008/10/30 17:27:28	1.985
+++ LVM2/WHATS_NEW	2008/10/30 17:40:00	1.986
@@ -1,6 +1,6 @@
 Version 2.02.43 -
 ===================================
-  Split out lvm-logging.h from log.h.
+  Split out lvm-logging.h from log.h and lvm-globals.[ch] from log.[ch].
   Add libdm subdirectory for libdevmapper files.
 
 Version 2.02.42 - 26th October 2008
/cvs/lvm2/LVM2/lib/misc/lvm-globals.h,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/lvm-globals.h
+++ -	2008-10-30 17:40:01.677555000 +0000
@@ -0,0 +1,59 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
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
+#ifndef _LVM_GLOBALS_H
+#define _LVM_GLOBALS_H
+
+#define VERBOSE_BASE_LEVEL _LOG_WARN
+#define SECURITY_LEVEL 0
+
+void init_verbose(int level);
+void init_test(int level);
+void init_md_filtering(int level);
+void init_pvmove(int level);
+void init_full_scan_done(int level);
+void init_trust_cache(int trustcache);
+void init_debug(int level);
+void init_cmd_name(int status);
+void init_msg_prefix(const char *prefix);
+void init_indent(int indent);
+void init_ignorelockingfailure(int level);
+void init_lockingfailed(int level);
+void init_security_level(int level);
+void init_mirror_in_sync(int in_sync);
+void init_dmeventd_monitor(int reg);
+void init_ignore_suspended_devices(int ignore);
+void init_error_message_produced(int error_message_produced);
+
+void set_cmd_name(const char *cmd_name);
+
+int test_mode(void);
+int md_filtering(void);
+int pvmove_mode(void);
+int full_scan_done(void);
+int trust_cache(void);
+int verbose_level(void);
+int debug_level(void);
+int ignorelockingfailure(void);
+int lockingfailed(void);
+int security_level(void);
+int mirror_in_sync(void);
+int ignore_suspended_devices(void);
+const char *log_command_name(void);
+
+#define DMEVENTD_MONITOR_IGNORE -1
+int dmeventd_monitor_mode(void);
+
+#endif


