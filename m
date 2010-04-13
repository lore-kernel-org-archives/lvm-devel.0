From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Apr 2010 19:54:17 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20100413195417.20467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-13 19:54:17

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c lvm-functions.c 

Log message:
	Use C locales and use_mlockall for clvmd.
	
	Use same steps for clvmd as for dmeventd - using C locales to avoid reading
	large mmaps and use mlockall() for threaded version.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1514&r2=1.1515
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/WHATS_NEW	2010/04/13 18:18:54	1.1514
+++ LVM2/WHATS_NEW	2010/04/13 19:54:16	1.1515
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Use C locales and use_mlockall for clvmd.
   Refactor code related to vg->pvs list and add pv->vg link.
   Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.
   Add activation/polling_interval to lvm.conf as --interval default.
--- LVM2/daemons/clvmd/clvmd.c	2010/04/06 15:29:30	1.65
+++ LVM2/daemons/clvmd/clvmd.c	2010/04/13 19:54:16	1.66
@@ -360,6 +360,13 @@
 		return debug_clvmd(debug, clusterwide_opt)==1?0:1;
 	}
 
+	/*
+	 * Switch to C locale to avoid reading large locale-archive file
+	 * used by some glibc (on some distributions it takes over 100MB).
+	 * Daemon currently needs to use mlockall().
+	 */
+	setenv("LANG", "C", 1);
+
 	/* Fork into the background (unless requested not to) */
 	if (debug != DEBUG_STDERR) {
 		be_daemon(start_timeout);
--- LVM2/daemons/clvmd/lvm-functions.c	2010/03/26 15:40:14	1.87
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/04/13 19:54:16	1.88
@@ -878,13 +878,16 @@
 
 	/* Trap log messages so we can pass them back to the user */
 	init_log_fn(lvm2_log_fn);
+	memlock_inc_daemon(cmd);
 
 	return 1;
 }
 
 void destroy_lvm(void)
 {
-	if (cmd)
+	if (cmd) {
+		memlock_dec_daemon(cmd);
 		destroy_toolcontext(cmd);
+	}
 	cmd = NULL;
 }


