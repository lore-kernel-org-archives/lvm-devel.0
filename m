From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 16:46:57 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/log ...
Message-ID: <20100215164657.6726.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 16:46:56

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	lib/log        : log.h 

Log message:
	Add LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES environment variable to suppress error
	and warning mesages while --ignorelockingfailure is used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1429&r2=1.1430
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2010/02/15 16:38:22	1.1429
+++ LVM2/WHATS_NEW	2010/02/15 16:46:56	1.1430
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Add LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES env. var. to suppress error and warning mesages.
   Remove hard-coded rule to skip _mimage devices in 11-dm-lvm.rules.
   Use udev transactions in testsuite.
   Don't use LVM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
--- LVM2/lib/locking/locking.c	2010/01/22 09:45:29	1.73
+++ LVM2/lib/locking/locking.c	2010/02/15 16:46:56	1.74
@@ -219,6 +219,11 @@
  */
 int init_locking(int type, struct cmd_context *cmd)
 {
+	int suppress_messages = 0;
+
+	if (ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
+		suppress_messages = 1;
+
 	if (type < 0)
 		type = find_config_tree_int(cmd, "global/locking_type", 1);
 
@@ -237,7 +242,8 @@
 				 _blocking_supported ? "" : "Non-blocking ");
 
 		if (!init_file_locking(&_locking, cmd)) {
-			log_error("File-based locking initialisation failed.");
+			log_error_suppress(suppress_messages,
+					   "File-based locking initialisation failed.");
 			break;
 		}
 		return 1;
@@ -264,7 +270,8 @@
 	case 3:
 		log_very_verbose("Cluster locking selected.");
 		if (!init_cluster_locking(&_locking, cmd)) {
-			log_error("Internal cluster locking initialisation failed.");
+			log_error_suppress(suppress_messages,
+					   "Internal cluster locking initialisation failed.");
 			break;
 		}
 		return 1;
@@ -286,13 +293,16 @@
 	    find_config_tree_int(cmd, "locking/fallback_to_local_locking",
 	    	    find_config_tree_int(cmd, "global/fallback_to_local_locking",
 					 DEFAULT_FALLBACK_TO_LOCAL_LOCKING))) {
-		log_warn("WARNING: Falling back to local file-based locking.");
-		log_warn("Volume Groups with the clustered attribute will "
-			  "be inaccessible.");
+		log_warn_suppress(suppress_messages,
+				  "WARNING: Falling back to local file-based locking.");
+		log_warn_suppress(suppress_messages,
+				  "Volume Groups with the clustered attribute will "
+				  "be inaccessible.");
 		if (init_file_locking(&_locking, cmd))
 			return 1;
 		else
-			log_error("File-based locking initialisation failed.");
+			log_error_suppress(suppress_messages,
+					   "File-based locking initialisation failed.");
 	}
 
 	if (!ignorelockingfailure())
--- LVM2/lib/log/log.h	2009/12/16 19:22:12	1.47
+++ LVM2/lib/log/log.h	2010/02/15 16:46:56	1.48
@@ -59,7 +59,9 @@
 #define log_info(x...) LOG_LINE(_LOG_INFO, x)
 #define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)
 #define log_warn(x...) LOG_LINE(_LOG_WARN | _LOG_STDERR, x)
+#define log_warn_suppress(s, x...) LOG_LINE(s ? _LOG_NOTICE : _LOG_WARN | _LOG_STDERR, x)
 #define log_err(x...) LOG_LINE_WITH_ERRNO(_LOG_ERR, EUNCLASSIFIED, x)
+#define log_err_suppress(s, x...) LOG_LINE_WITH_ERRNO(s ? _LOG_NOTICE : _LOG_ERR, EUNCLASSIFIED, x)
 #define log_fatal(x...) LOG_LINE_WITH_ERRNO(_LOG_FATAL, EUNCLASSIFIED, x)
 
 #define stack log_debug("<backtrace>")	/* Backtrace on error */
@@ -67,6 +69,7 @@
 #define log_verbose(args...) log_notice(args)
 #define log_print(args...) LOG_LINE(_LOG_WARN, args)
 #define log_error(args...) log_err(args)
+#define log_error_suppress(s, args...) log_err_suppress(s, args)
 #define log_errno(args...) LOG_LINE_WITH_ERRNO(_LOG_ERR, args)
 
 /* System call equivalents */


