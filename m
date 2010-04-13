From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Apr 2010 01:43:57 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c doc/exampl ...
Message-ID: <20100413014357.3353.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-13 01:43:56

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c 
	doc            : example.conf 

Log message:
	Add activation/polling_interval to lvm.conf as --interval default.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1510&r2=1.1511
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2010/04/12 11:52:53	1.1510
+++ LVM2/WHATS_NEW	2010/04/13 01:43:56	1.1511
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Add activation/polling_interval to lvm.conf as --interval default.
   Don't ignore error if resuming any LV fails in resume_lvs.
   Skip closing persistent filter cache file if open failed.
   Install .a .so links to $(usrlibdir).
--- LVM2/tools/polldaemon.c	2010/01/22 21:59:43	1.32
+++ LVM2/tools/polldaemon.c	2010/04/13 01:43:56	1.33
@@ -280,7 +280,9 @@
 	interval_sign = arg_sign_value(cmd, interval_ARG, 0);
 	if (interval_sign == SIGN_MINUS)
 		log_error("Argument to --interval cannot be negative");
-	parms.interval = arg_uint_value(cmd, interval_ARG, DEFAULT_INTERVAL);
+	parms.interval = arg_uint_value(cmd, interval_ARG,
+					find_config_tree_int(cmd, "activation/polling_interval",
+							     DEFAULT_INTERVAL));
 	parms.wait_before_testing = (interval_sign == SIGN_PLUS);
 	parms.progress_display = 1;
 	parms.progress_title = progress_title;
@@ -297,7 +299,8 @@
 
 		/* FIXME Disabled multiple-copy wait_event */
 		if (!name)
-			parms.interval = DEFAULT_INTERVAL;
+			parms.interval = find_config_tree_int(cmd, "activation/polling_interval",
+							      DEFAULT_INTERVAL);
 	}
 
 	if (parms.background) {
--- LVM2/doc/example.conf	2010/03/23 22:30:19	1.56
+++ LVM2/doc/example.conf	2010/04/13 01:43:56	1.57
@@ -427,11 +427,19 @@
     # Set to 1 to revert to the default behaviour prior to version 2.02.62
     # which used mlockall() to pin the whole process's memory while activating
     # devices.
-    # use_mlockall = 0
+    use_mlockall = 0
 
     # Monitoring is enabled by default when activating logical volumes.
     # Set to 0 to disable monitoring or use the --ignoremonitoring option.
-    # monitoring = 1
+    monitoring = 1
+
+    # When pvmove or lvconvert must wait for the kernel to finish
+    # synchronising or merging data, they check and report progress
+    # at intervals of this number of seconds.  The default is 15 seconds.
+    # If this is set to 0 and there is only one thing to wait for, there
+    # are no progress reports, but the process is awoken immediately the
+    # operation is complete.
+    polling_interval = 15
 }
 
 


