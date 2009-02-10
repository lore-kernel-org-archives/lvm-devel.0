From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 10 Feb 2009 11:52:41 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c da ...
Message-ID: <20090210115241.13073.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-02-10 11:52:40

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c clvmd-corosync.c 

Log message:
	Allow clvmd to start up if its lockspace already exists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1038&r2=1.1039
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2009/02/09 09:45:49	1.1038
+++ LVM2/WHATS_NEW	2009/02/10 11:52:40	1.1039
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Allow clvmd to start up if its lockspace already exists.
   Separate PV label attributes which do not need parse metadata when reporting.
   Remove external dependency on the 'cut' command in fsadm.
   Fix pvs segfault when pv mda attributes requested for not available PV.
--- LVM2/daemons/clvmd/clvmd-cman.c	2008/11/04 16:41:47	1.24
+++ LVM2/daemons/clvmd/clvmd-cman.c	2009/02/10 11:52:40	1.25
@@ -110,8 +110,13 @@
 	/* Create a lockspace for LV & VG locks to live in */
 	lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
 	if (!lockspace) {
-		syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
-		return -1;
+		if (errno == EEXIST) {
+			lockspace = dlm_open_lockspace(LOCKSPACE_NAME);
+		}
+		if (!lockspace) {
+			syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
+			return -1;
+		}
 	}
 	dlm_ls_pthread_init(lockspace);
 	DEBUGLOG("DLM initialisation complete\n");
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/02 14:34:25	1.2
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/10 11:52:40	1.3
@@ -314,9 +314,14 @@
 	/* Create a lockspace for LV & VG locks to live in */
 	lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
 	if (!lockspace) {
-		syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
-		quorum_finalize(quorum_handle);
-		return -1;
+		if (errno == EEXIST) {
+			lockspace = dlm_open_lockspace(LOCKSPACE_NAME);
+		}
+		if (!lockspace) {
+			syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
+			quorum_finalize(quorum_handle);
+			return -1;
+		}
 	}
 	dlm_ls_pthread_init(lockspace);
 	DEBUGLOG("DLM initialisation complete\n");


